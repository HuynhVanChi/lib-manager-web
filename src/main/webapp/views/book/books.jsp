<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,book.Book,categories.Category"%>
<%-- Hỗ trợ JSTL Core --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Sách - LibraryOS</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
        }
        
        /* ── Stat cards colors ── */
        .stat-total-books { background: var(--primary-soft); color: var(--primary); }
        .stat-total-books .stat-icon { background: rgba(49,46,129,.12); color: var(--primary); }

        .stat-total-copies { background: #EEF2FF; color: #4338CA; }
        .stat-total-copies .stat-icon { background: rgba(67,56,202,.12); color: #4338CA; }

        .stat-available-copies { background: #F0FDF4; color: #15803D; }
        .stat-available-copies .stat-icon { background: rgba(21,128,61,.12); color: #15803D; }

        .stat-damaged-copies { background: #FEF2F2; color: #DC2626; }
        .stat-damaged-copies .stat-icon { background: rgba(220,38,38,.12); color: #DC2626; }
        
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
                
                <!-- Hiển thị thông báo Flash (nếu có) -->
                <%
                    String msg = (String) session.getAttribute("message");
                    String msgType = (String) session.getAttribute("messageType");
                    if (msg != null) {
                        session.removeAttribute("message");
                        session.removeAttribute("messageType");
                %>
                    <div class="alert alert-<%= msgType %> alert-dismissible fade show rounded-3 shadow-sm border-0 px-4 py-3 mb-4" role="alert">
                        <div class="d-flex align-items-center">
                            <i class="fa-solid <%= "success".equals(msgType) ? "fa-circle-check text-success" : "fa-circle-exclamation text-danger" %> fs-5 me-3"></i>
                            <div class="fw-semibold text-dark"><%= msg %></div>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <%
                    }
                %>

                <%-- ── TIÊU ĐỀ TRANG ── --%>
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h1 class="fw-bold m-0 text-dark" style="font-size:1.6rem;">Danh sách đầu sách</h1>
                        <p class="text-muted mb-0 mt-1" style="font-size:.85rem;">
                            Quản lý danh sách đầu sách trong hệ thống
                        </p>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/books?action=add"
                           id="btn-add-book"
                           class="btn btn-primary d-flex align-items-center gap-2 px-4 py-2 rounded-3 fw-semibold shadow-sm hover-lift">
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
                        <div class="stat-card stat-total-books h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Tổng đầu sách</span>
                                <div class="stat-icon m-0"><i class="fa-solid fa-book-bookmark"></i></div>
                            </div>
                            <div class="stat-value">${totalBooks}</div>
                        </div>
                    </div>

                    <!-- Thẻ 2: Tổng số cuốn sách -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-total-copies h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Tổng số cuốn sách</span>
                                <div class="stat-icon m-0"><i class="fa-solid fa-copy"></i></div>
                            </div>
                            <div class="stat-value">${totalCopies}</div>
                        </div>
                    </div>

                    <!-- Thẻ 3: Cuốn sách khả dụng -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-available-copies h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Sách khả dụng (trong kho)</span>
                                <div class="stat-icon m-0"><i class="fa-solid fa-circle-check"></i></div>
                            </div>
                            <div class="stat-value">${availableCopies}</div>
                        </div>
                    </div>

                    <!-- Thẻ 4: Sách hỏng/mất -->
                    <div class="col-6 col-lg-3">
                        <div class="stat-card stat-damaged-copies h-100">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="stat-label">Sách đang hỏng/Mất</span>
                                <div class="stat-icon m-0"><i class="fa-solid fa-circle-exclamation"></i></div>
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
                                <a href="${pageContext.request.contextPath}/books?clearFilters=true" class="btn btn-outline-secondary px-3 py-2 rounded-3 fw-medium text-decoration-none ms-2">
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
                        <table class="table-custom">
                            <thead>
                                <tr>
                                    <th class="ps-4" style="width: 80px;">Mã</th>
                                    <th>Thông tin sách / Tác giả</th>
                                    <th style="width: 180px;">Danh mục</th>
                                    <th style="width: 180px;">NXB & Năm</th>
                                    <th style="width: 160px;">Số lượng cuốn</th>
                                    <th style="width: 160px; text-align: center;">Hành động</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty booksList}">
                                        <tr>
                                            <td colspan="6" class="text-center py-5 text-muted">
                                                <i class="fa-regular fa-folder-open fs-2 mb-3 d-block text-secondary"></i>
                                                Không tìm thấy đầu sách nào khớp với điều kiện lọc.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="book" items="${booksList}">
                                            <tr>
                                                <!-- ID đầu sách -->
                                                <td class="ps-4 fw-semibold text-secondary">#${book.bookId}</td>
                                                <!-- Tiêu đề & Tác giả -->
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="fw-bold text-indigo-brand fs-6 text-decoration-none hover-underline" style="cursor: pointer;">
                                                        ${book.title}
                                                    </a>
                                                    <div class="text-muted small mt-0.5"><i class="fa-regular fa-user me-1"></i>${book.author}</div>
                                                </td>
                                                <!-- Danh mục -->
                                                <td>
                                                    <span class="badge-status badge-restore-custom px-3 py-1.5 fs-7">${book.categoryName}</span>
                                                </td>
                                                <!-- Nhà xuất bản & Năm -->
                                                <td class="text-muted">
                                                    <div>${book.publisher}</div>
                                                    <div class="small">${book.publishYear != 0 ? book.publishYear : "N/A"}</div>
                                                </td>
                                                <!-- Số cuốn sách khả dụng / Tổng số cuốn -->
                                                <td>
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
                                                        <%-- Bản sao --%>
                                                        <a href="${pageContext.request.contextPath}/books?action=copies&id=${book.bookId}" class="btn-action" title="Bản sao">
                                                            <i class="fa-solid fa-list-check"></i>
                                                        </a>
                                                        <%-- Xem chi tiết --%>
                                                        <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="btn-action" title="Xem chi tiết">
                                                            <i class="fa-solid fa-eye"></i>
                                                        </a>
                                                        <%-- Sửa --%>
                                                        <a href="${pageContext.request.contextPath}/books?action=edit&id=${book.bookId}" class="btn-action" title="Sửa">
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
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- ======================================================= -->
    <!-- CÁC HỘP THOẠI MODAL (BOOTSTRAP 5)                       -->
    <!-- ======================================================= -->

    <!-- Modal: Xác nhận xóa đầu sách (Bắc cầu) -->
    <div class="modal fade" id="deleteBookModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 420px;">
            <div class="modal-content border-0 shadow rounded-3">
                <form action="${pageContext.request.contextPath}/books?action=delete" method="post">
                    <input type="hidden" id="deleteBookId" name="bookId">
                    <div class="modal-body p-4 text-center">
                        <i class="fa-solid fa-triangle-exclamation text-danger fs-1 mb-3"></i>
                        <h5 class="fw-bold mb-2">Xác nhận xóa đầu sách</h5>
                        <p class="text-muted small mb-4">Bạn có chắc chắn muốn xóa đầu sách <span class="fw-bold text-dark" id="deleteBookTitle"></span>?</p>
                        
                        <div class="alert alert-warning border-0 small text-start rounded-3 mb-4 py-2">
                            <i class="fa-solid fa-circle-info me-2 text-warning"></i>
                            <strong>Lưu ý:</strong> Hành động này sẽ thực hiện xóa mềm đầu sách này <strong>VÀ toàn bộ cuốn sách con</strong> trực thuộc đầu sách đó khỏi kho dữ liệu.
                        </div>

                        <div class="d-flex gap-2 justify-content-center">
                            <button type="button" class="btn btn-light rounded-3 px-4 py-2 flex-grow-1" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-danger rounded-3 px-4 py-2 flex-grow-1">Đồng ý xóa</button>
                        </div>
                    </div>
                </form>
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
    <script src="${pageContext.request.contextPath}/assets/book/books-jsp.js"></script>
</body>
</html>