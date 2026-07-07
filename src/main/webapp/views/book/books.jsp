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
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
        }
        /* Custom Indigo branding matching Colors.md */
        .bg-indigo-brand {
            background-color: #312E81 !important;
        }
        .text-indigo-brand {
            color: #312E81 !important;
        }
        .btn-indigo-brand {
            background-color: #312E81;
            color: #ffffff;
            border: none;
            transition: all 0.2s ease-in-out;
        }
        .btn-indigo-brand:hover {
            background-color: #1e1b4b;
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
        .btn-outline-indigo-brand {
            border: 2px solid #312E81;
            color: #312E81;
            background-color: transparent;
            font-weight: 600;
        }
        .btn-outline-indigo-brand:hover {
            background-color: #312E81;
            color: #ffffff;
        }
        
        /* Stats card styles */
        .stat-card {
            border: none;
            border-radius: 12px;
            transition: all 0.2s ease-in-out;
        }
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.05), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        .icon-box {
            width: 48px;
            height: 48px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        .table-premium th {
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            color: #4b5563;
            background-color: #f3f4f6;
            border-bottom: 2px solid #e5e7eb;
        }
        .table-premium td {
            font-size: 0.875rem;
            color: #1f2937;
        }
        .badge-soft-purple {
            background-color: rgba(167, 139, 250, 0.15);
            color: #6d28d9;
            font-weight: 500;
        }
        .card-custom {
            border: none;
            border-radius: 12px;
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

                <!-- ======================================================= -->
                <!-- 4 SUMMARY CARDS THỐNG KÊ NHANH                          -->
                <!-- ======================================================= -->
                <div class="row g-3 mb-4">
                    <!-- Thẻ 1: Tổng đầu sách -->
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card stat-card shadow-sm h-100">
                            <div class="card-body d-flex align-items-center p-3">
                                <div class="icon-box bg-primary bg-opacity-10 text-primary me-3">
                                    <i class="fa-solid fa-book-bookmark"></i>
                                </div>
                                <div>
                                    <span class="text-muted small fw-medium">Tổng đầu sách</span>
                                    <h4 class="fw-bold m-0 text-dark mt-1">${totalBooks}</h4>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Thẻ 2: Tổng số cuốn sách -->
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card stat-card shadow-sm h-100">
                            <div class="card-body d-flex align-items-center p-3">
                                <div class="icon-box bg-indigo-brand bg-opacity-10 text-indigo-brand me-3">
                                    <i class="fa-solid fa-copy"></i>
                                </div>
                                <div>
                                    <span class="text-muted small fw-medium">Tổng số cuốn sách</span>
                                    <h4 class="fw-bold m-0 text-dark mt-1">${totalCopies}</h4>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Thẻ 3: Cuốn sách khả dụng -->
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card stat-card shadow-sm h-100">
                            <div class="card-body d-flex align-items-center p-3">
                                <div class="icon-box bg-success bg-opacity-10 text-success me-3">
                                    <i class="fa-solid fa-circle-check"></i>
                                </div>
                                <div>
                                    <span class="text-muted small fw-medium">Sách khả dụng (trong kho)</span>
                                    <h4 class="fw-bold m-0 text-dark mt-1">${availableCopies}</h4>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Thẻ 4: Sách hỏng/mất -->
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card stat-card shadow-sm h-100">
                            <div class="card-body d-flex align-items-center p-3">
                                <div class="icon-box bg-danger bg-opacity-10 text-danger me-3">
                                    <i class="fa-solid fa-circle-exclamation"></i>
                                </div>
                                <div>
                                    <span class="text-muted small fw-medium">Sách đang hỏng/Mất</span>
                                    <h4 class="fw-bold m-0 text-dark mt-1">${damagedOrLostCopies}</h4>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- BỘ LỌC TÌM KIẾM VÀ NÚT THÊM MỚI                          -->
                <!-- ======================================================= -->
                <div class="card card-custom shadow-sm mb-4">
                    <div class="card-body p-3">
                        <form action="${pageContext.request.contextPath}/books" method="get" class="row g-2 align-items-center">
                            
                            <!-- Nhập từ khóa -->
                            <div class="col-12 col-md-4">
                                <div class="input-group">
                                    <span class="input-group-text bg-white border-end-0 text-muted rounded-start-3">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                    </span>
                                    <input type="text" class="form-control border-start-0 rounded-end-3" name="query" value="${selectedQuery}" placeholder="Tìm theo tiêu đề, tác giả, NXB...">
                                </div>
                            </div>

                            <!-- Lọc theo Danh mục -->
                            <div class="col-12 col-sm-6 col-md-3">
                                <select class="form-select rounded-3" name="categoryId">
                                    <option value="">-- Tất cả danh mục --</option>
                                    <c:forEach var="cat" items="${categoriesList}">
                                        <option value="${cat.categoryId}" ${cat.categoryId == selectedCategoryId ? 'selected' : ''}>${cat.name}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Nút hành động tìm kiếm -->
                            <div class="col-12 col-sm-6 col-md-5 d-flex justify-content-md-end gap-2 mt-md-0 mt-2">
                                <button type="submit" class="btn btn-outline-indigo-brand rounded-3 px-3">
                                    Tìm kiếm
                                </button>
                                <a href="${pageContext.request.contextPath}/books?clearFilters=true" class="btn btn-light rounded-3 px-3">
                                    Làm mới
                                </a>
                                <a href="${pageContext.request.contextPath}/books?action=add" class="btn btn-indigo-brand rounded-3 d-flex align-items-center gap-2 px-3 ms-auto">
                                    <i class="fa-solid fa-plus"></i> Thêm đầu sách
                                </a>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- ======================================================= -->
                <!-- BẢNG HIỂN THỊ ĐẦU SÁCH (BOOKS TABLE)                    -->
                <!-- ======================================================= -->
                <div class="card card-custom shadow-sm">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle table-premium m-0">
                                <thead>
                                    <tr>
                                        <th class="ps-4 py-3" style="width: 80px;">Mã</th>
                                        <th>Thông tin sách / Tác giả</th>
                                        <th style="width: 200px;">Danh mục</th>
                                        <th style="width: 200px;">NXB & Năm</th>
                                        <th style="width: 180px;">Số lượng cuốn</th>
                                        <th class="text-end pe-4" style="width: 320px;">Thao tác</th>
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
                                                        <span class="badge badge-soft-purple rounded-pill px-3 py-1.5 fs-7">${book.categoryName}</span>
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
                                                    <td class="text-end pe-4">
                                                        <div class="d-flex justify-content-end gap-1.5">
                                                            <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="btn btn-outline-info btn-sm rounded-3 px-2 py-1.5" title="Xem chi tiết">
                                                                <i class="fa-solid fa-eye"></i> Chi tiết
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/books?action=copies&id=${book.bookId}" class="btn btn-outline-success btn-sm rounded-3 px-2.5 py-1.5">
                                                                <i class="fa-solid fa-list-check me-1"></i> Bản sao
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/books?action=edit&id=${book.bookId}" class="btn btn-outline-indigo-brand btn-sm rounded-3 px-2 py-1.5">
                                                                <i class="fa-solid fa-pen"></i> Sửa
                                                            </a>
                                                            <button class="btn btn-outline-danger btn-sm rounded-3 px-2 py-1.5 btn-delete-book" 
                                                                    data-id="${book.bookId}" data-title="${book.title}">
                                                                <i class="fa-solid fa-trash-can"></i> Xóa
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