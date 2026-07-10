<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,book.Book,categories.Category"%>
<%-- Hỗ trợ JSTL Core --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sách - LibraryOS</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/assets/css/category-colors.css" rel="stylesheet" type="text/css">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
        }
        
        .badge-soft-purple {
            background-color: rgba(167, 139, 250, 0.15);
            color: #6d28d9;
            font-weight: 500;
        }
        
        /* Modal custom scroll */
        .modal-body-scroll {
            max-height: 60vh;
            overflow-y: auto;
        }
    </style>
</head>
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH: Cột trái (Sidebar) + Cột phải (Content) -->
    <div class="d-flex">
        
        <!-- 1. CỘT TRÁI: NHÚNG SIDEBAR -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- 2. CỘT PHẢI: KHU VỰC NỘI DUNG -->
        <main class="w-100" style="min-height: 100vh; display: flex; flex-direction: column;">
            
            <!-- Header ngang -->
            <jsp:include page="/views/layout/header.jsp"/>

            <!-- Vùng đệm p-4 -->
            <div class="container-fluid p-4 flex-grow-1">
                

                <%-- ── TIÊU ĐỀ TRANG ── --%>
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h1 class="fw-bold m-0 text-dark" style="font-size:1.6rem;">Danh sách đầu sách</h1>
                        <p class="text-muted mb-0 mt-1" style="font-size:.85rem;">
                            Quản lý danh sách đầu sách trong hệ thống
                        </p>
                    </div>
                    <div class="d-flex gap-2">
                        <button type="button"
                                id="btn-open-archive"
                                class="btn btn-slate hover-lift"
                                data-bs-toggle="modal"
                                data-bs-target="#archiveModal">
                            <i class="fa-solid fa-trash-can"></i>
                            <span>Thùng rác</span>
                        </button>
                        <a href="${pageContext.request.contextPath}/books?action=add"
                           id="btn-add-book"
                           class="btn btn-primary hover-lift">
                            <i class="fa-solid fa-plus"></i>
                            <span>Thêm đầu sách</span>
                        </a>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- 4 SUMMARY CARDS THỐNG KÊ NHANH                          -->
                <!-- ======================================================= -->
                <div class="row g-3 mb-4">
                    <!-- Thẻ 1: Tổng đầu sách -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-primary h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Tổng đầu sách</span>
                                <div class="stat-icon"><i class="fa-solid fa-book-bookmark"></i></div>
                            </div>
                            <div class="stat-value">${totalBooks}</div>
                        </div>
                    </div>

                    <!-- Thẻ 2: Tổng số cuốn sách -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-info h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Tổng số cuốn sách</span>
                                <div class="stat-icon"><i class="fa-solid fa-copy"></i></div>
                            </div>
                            <div class="stat-value">${totalCopies}</div>
                        </div>
                    </div>

                    <!-- Thẻ 3: Cuốn sách khả dụng -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-success h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Sách khả dụng (trong kho)</span>
                                <div class="stat-icon"><i class="fa-solid fa-circle-check"></i></div>
                            </div>
                            <div class="stat-value">${availableCopies}</div>
                        </div>
                    </div>

                    <!-- Thẻ 4: Sách hỏng/mất -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-danger h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Sách đang hỏng/Mất</span>
                                <div class="stat-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                            </div>
                            <div class="stat-value">${damagedOrLostCopies}</div>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- KHỐI CHÍNH (CARD-MAIN): BỘ LỌC VÀ BẢNG HIỂN THỊ DỮ LIỆU -->
                <!-- ======================================================= -->
                <div class="card-main bg-white">
                    
                    <%-- ── TOOLBAR: Tìm kiếm + Lọc ── --%>
                    <div class="p-3 border-bottom">
                        <form action="${pageContext.request.contextPath}/books" method="get" class="d-flex align-items-center toolbar flex-wrap">
                            
                            <%-- Input tìm kiếm --%>
                            <div class="search-wrapper">
                                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                <input type="text" class="search-input" name="query" value="<c:out value='${selectedQuery}'/>" placeholder="Tìm theo tiêu đề, tác giả, NXB...">
                            </div>

                            <%-- Lọc theo Danh mục --%>
                            <select class="filter-select" name="categoryId">
                                <option value="">-- Tất cả danh mục --</option>
                                <c:forEach var="cat" items="${categoriesList}">
                                    <option value="${cat.categoryId}" ${cat.categoryId == selectedCategoryId ? 'selected' : ''}>${cat.name}</option>
                                </c:forEach>
                            </select>

                            <button type="submit" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow">
                                <i class="fa-solid fa-filter me-1"></i> Lọc
                            </button>

                            <%-- Nút xóa bộ lọc --%>
                            <c:if test="${not empty selectedQuery or not empty selectedCategoryId}">
                                <a href="${pageContext.request.contextPath}/books?clearFilters=true" class="btn-clear-filter ms-2">
                                    <i class="fa-solid fa-xmark me-1"></i> Xóa lọc
                                </a>
                            </c:if>

                            <%-- Tổng kết quả --%>
                            <span class="text-muted ms-auto" style="font-size:.82rem;">
                                <c:choose>
                                    <c:when test="${not empty booksList}">
                                        Hiển thị <strong>${booksList.size()}</strong> đầu sách
                                    </c:when>
                                    <c:otherwise>Không có kết quả</c:otherwise>
                                </c:choose>
                            </span>
                        </form>
                    </div>

                    <%-- ── BẢNG DANH SÁCH ── --%>
                    <div class="table-responsive">
                        <c:choose>
                            <c:when test="${not empty booksList}">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th class="ps-4" style="width: 50px;">ID</th>
                                            <th style="width: 80px; text-align: center;">Ảnh</th>
                                            <th>Thông tin sách / Tác giả</th>
                                            <th style="width: 180px; text-align: center;">Danh mục</th>
                                            <th style="width: 180px;">NXB & Năm</th>
                                            <th style="width: 140px;">Giá Nhập</th>
                                            <th style="width: 160px; text-align: center;">Tình trạng kho</th>
                                            <th style="width: 160px; text-align: center;">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="book" items="${booksList}" varStatus="loop">
                                            <tr>
                                                <!-- ID -->
                                                <td class="ps-4 text-muted fw-medium">#${book.bookId}</td>
                                                <!-- Ảnh bìa -->
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${not empty book.imagePath}">
                                                            <img src="${pageContext.request.contextPath}/${book.imagePath}" 
                                                                 alt="${book.title}" 
                                                                 class="rounded shadow-sm" 
                                                                 style="width: 48px; height: 64px; object-fit: cover; border: 1px solid var(--border);">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="d-inline-flex align-items-center justify-content-center rounded bg-light text-muted shadow-sm" 
                                                                 style="width: 48px; height: 64px; border: 1px dashed var(--border);">
                                                                <i class="fa-solid fa-book" style="font-size: 1.2rem;"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <!-- Tiêu đề & Tác giả -->
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="fw-bold text-indigo-brand fs-6 text-decoration-none hover-underline text-truncate d-inline-block" style="cursor: pointer; max-width: 280px;" title="${book.title}">
                                                        ${book.title}
                                                    </a>
                                                    <div class="text-muted small mt-0.5"><i class="fa-regular fa-user me-1"></i>${book.author}</div>
                                                </td>
                                                <!-- Danh mục -->
                                                <td class="text-center">
                                                    <span class="badge-status badge-theme-${book.categoryColorTheme} px-3 py-1.5 fs-7">${book.categoryName}</span>
                                                </td>
                                                <!-- Nhà xuất bản & Năm -->
                                                <td class="text-muted">
                                                    <div>${book.publisher}</div>
                                                    <div class="small">${book.publishYear != 0 ? book.publishYear : "N/A"}</div>
                                                </td>
                                                <!-- Giá bìa -->
                                                <td class="fw-semibold text-dark">
                                                    <fmt:formatNumber value="${book.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                </td>
                                                <!-- Số cuốn sách khả dụng / Tổng số cuốn -->
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${book.totalCopies == 0}">
                                                            <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">Chưa nhập cuốn nào</span>
                                                        </c:when>
                                                        <c:when test="${book.availableCopies == 0}">
                                                            <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">Hết sách</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 rounded-pill px-3 py-1.5 fw-medium">Còn ${book.availableCopies}/${book.totalCopies} cuốn</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <!-- Thao tác hành động -->
                                                <td>
                                                    <div class="d-flex gap-1 justify-content-center">
                                                        <%-- Quản lý cuốn sách --%>
                                                        <a href="${pageContext.request.contextPath}/books?action=copies&id=${book.bookId}&from=list" class="btn-action" title="Quản lý cuốn sách">
                                                            <i class="fa-solid fa-list-check"></i>
                                                        </a>
                                                        <%-- Xem chi tiết --%>
                                                        <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="btn-action" title="Xem chi tiết">
                                                            <i class="fa-solid fa-eye"></i>
                                                        </a>
                                                        <%-- Sửa --%>
                                                        <a href="${pageContext.request.contextPath}/books?action=edit&id=${book.bookId}&from=list" class="btn-action" title="Sửa">
                                                            <i class="fa-solid fa-pen"></i>
                                                        </a>
                                                        <%-- Xóa --%>
                                                        <button class="btn-action danger btn-delete-book" 
                                                                data-id="${book.bookId}" data-title="${book.title}" title="Xóa">
                                                            <i class="fa-solid fa-trash-can"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="icon"><i class="fa-solid fa-book"></i></div>
                                    <h5 class="fw-bold text-dark mb-1">Không tìm thấy đầu sách nào</h5>
                                    <p class="text-muted small mb-4">
                                        <c:choose>
                                            <c:when test="${not empty selectedQuery or not empty selectedCategoryId}">
                                                Không có kết quả phù hợp với bộ lọc tìm kiếm hiện tại.
                                            </c:when>
                                            <c:otherwise>
                                                Chưa có đầu sách nào trong hệ thống.
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                    <c:if test="${empty selectedQuery and empty selectedCategoryId}">
                                        <a href="${pageContext.request.contextPath}/books?action=add"
                                           class="btn btn-primary rounded-3 px-4 fw-medium hover-lift">
                                            <i class="fa-solid fa-plus me-2"></i>Thêm đầu sách đầu tiên
                                        </a>
                                    </c:if>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- ======================================================= -->
    <!-- CÁC HỘP THOẠI MODAL (BOOTSTRAP 5)                       -->
    <!-- ======================================================= -->

    <!-- Modal: Xác nhận xóa đầu sách (Bắc cầu) -->
    <div class="modal fade" id="deleteBookModal" tabindex="-1" aria-labelledby="deleteBookModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow rounded-3">
                <div class="modal-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="bg-danger bg-opacity-10 text-danger rounded-circle d-flex align-items-center justify-content-center"
                             style="width:36px;height:36px;flex-shrink:0;">
                            <i class="fa-solid fa-triangle-exclamation text-danger"></i>
                        </div>
                        <h6 class="modal-title fw-bold m-0" id="deleteBookModalLabel">Xác nhận xóa đầu sách</h6>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <form action="${pageContext.request.contextPath}/books?action=delete" method="post" class="m-0">
                    <input type="hidden" id="deleteBookId" name="bookId">
                    <div class="modal-body">
                        <p class="mb-1" style="font-size:.9rem;">Bạn có chắc chắn muốn xóa đầu sách:</p>
                        <p class="fw-bold mb-3" id="deleteBookTitle" style="font-size:1rem; color:var(--primary);">—</p>
                        <div class="rounded-3 p-3" style="background:#FEF2F2;border:1px solid #FECACA;font-size:.82rem;color:#991B1B;">
                            <i class="fa-solid fa-info-circle me-1"></i>
                            Hành động này sẽ thực hiện xóa mềm đầu sách này <strong>VÀ toàn bộ cuốn sách con</strong> trực thuộc đầu sách đó khỏi kho dữ liệu.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger hover-lift">
                            <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <!-- Modal: Thùng rác Đầu sách -->
    <div class="modal fade" id="archiveModal" tabindex="-1" aria-labelledby="archiveModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content border-0 shadow rounded-3">
                <div class="modal-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center"
                             style="width:36px;height:36px;flex-shrink:0;">
                            <i class="fa-solid fa-trash-can text-secondary"></i>
                        </div>
                        <h6 class="modal-title fw-bold m-0" id="archiveModalLabel">Thùng rác Đầu sách</h6>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="text-muted small mb-3">
                        <i class="fa-solid fa-info-circle me-1"></i>
                        Dưới đây là danh sách các đầu sách đã bị xóa mềm. Bạn có thể khôi phục lại chúng cùng toàn bộ các cuốn sách con.
                    </p>
                    
                    <div class="table-responsive rounded-3 border" style="max-height: 290px; overflow-y: auto;">
                        <table class="table table-hover align-middle mb-0" style="font-size:.85rem;">
                            <thead class="table-light" style="position: sticky; top: 0; z-index: 10;">
                                <tr>
                                    <th class="ps-3" style="width: 80px;">ID</th>
                                    <th>Tên đầu sách</th>
                                    <th>Tác giả</th>
                                    <th>Danh mục</th>
                                    <th>Năm XB</th>
                                    <th class="text-center" style="width: 120px;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty deletedBooksList}">
                                        <tr>
                                            <td colspan="6" class="text-center py-4 text-muted">
                                                Thùng rác hiện đang trống.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="b" items="${deletedBooksList}">
                                            <tr>
                                                <td class="ps-3 text-muted fw-medium">#${b.bookId}</td>
                                                <td class="fw-semibold text-dark">${b.title}</td>
                                                <td>${empty b.author ? '—' : b.author}</td>
                                                <td><span class="badge-status badge-theme-${b.categoryColorTheme} px-3 py-1.5 fs-7">${b.categoryName}</span></td>
                                                <td>${empty b.publishYear ? '—' : b.publishYear}</td>
                                                <td class="text-center">
                                                    <form action="${pageContext.request.contextPath}/books?action=restore" method="post" class="d-inline m-0">
                                                        <input type="hidden" name="bookId" value="${b.bookId}">
                                                        <button type="submit" class="btn-action" title="Khôi phục đầu sách" style="color: var(--success) !important; border-color: var(--success-border) !important;">
                                                            <i class="fa-solid fa-trash-can-arrow-up"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Đóng</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Script điều khiển Modal và AJAX nạp dữ liệu cuốn sách (Tách ra từ books.jsp) -->
    <script>
        // Khai báo context path cho file JS ngoài sử dụng
        const contextPath = "${pageContext.request.contextPath}";
    </script>
    <%-- ── FLASH TOAST (cục bộ tương tự Độc giả) ── --%>
    <%
        String msg = (String) session.getAttribute("message");
        String msgType = (String) session.getAttribute("messageType");
        if (msg != null) {
            session.removeAttribute("message");
            session.removeAttribute("messageType");
            String resolvedType = "success".equals(msgType) ? "success" : "error";
    %>
        <div class="flash-toast <%= resolvedType %>" id="flash-toast" role="alert">
            <span class="toast-icon">
                <% if ("success".equals(resolvedType)) { %>
                    <i class="fa-solid fa-circle-check"></i>
                <% } else { %>
                    <i class="fa-solid fa-circle-xmark"></i>
                <% } %>
            </span>
            <div class="toast-body small fw-medium m-0">
                <%= msg %>
            </div>
            <button type="button" class="toast-close" onclick="closeToast()">&times;</button>
        </div>
        <script>
            function closeToast() {
                const toast = document.getElementById('flash-toast');
                if (toast) {
                    toast.style.transition = 'opacity .3s ease';
                    toast.style.opacity = '0';
                    setTimeout(() => toast.remove(), 300);
                }
            }
            (function () {
                const toast = document.getElementById('flash-toast');
                if (toast) {
                    setTimeout(closeToast, 3500);
                }
            })();
        </script>
    <%
        }
    %>
    <script src="${pageContext.request.contextPath}/assets/book/books-jsp.js"></script>
</body>
</html>