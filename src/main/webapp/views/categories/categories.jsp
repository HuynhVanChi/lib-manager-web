<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,categories.Category"%>
<%-- Hỗ trợ JSTL Core --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isTrashView ? "Thùng rác Danh mục" : "Quản lý Danh mục"} - LibraryOS</title>
    
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

                <!-- Tiêu đề trang & Nút chức năng -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="fw-bold m-0 text-dark">${isTrashView ? "Thùng rác Danh mục" : "Danh mục sách"}</h2>
                        <p class="text-muted small m-0 mt-1">${isTrashView ? "Xem và khôi phục các danh mục đã bị xóa mềm" : "Quản lý các danh mục phân loại đầu sách"}</p>
                    </div>
                    
                    <div class="d-flex gap-2">
                        <c:choose>
                            <c:when test="${isTrashView}">
                                <a href="${pageContext.request.contextPath}/categories" class="btn btn-outline-secondary rounded-3 d-flex align-items-center gap-2 px-3 py-2 fw-medium">
                                    <i class="fa-solid fa-arrow-left"></i> Quay lại Danh sách
                                </a>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/categories?trash=true" class="btn btn-outline-danger rounded-3 d-flex align-items-center gap-2 px-3 py-2 fw-medium border-0 shadow-sm bg-white text-danger">
                                    <i class="fa-solid fa-trash-can"></i> Thùng rác
                                </a>
                                <button class="btn btn-indigo-brand rounded-3 d-flex align-items-center gap-2 px-3 py-2 fw-medium" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                                    <i class="fa-solid fa-plus"></i> Thêm danh mục
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Bảng trắng (Card) chứa nội dung chính -->
                <div class="card card-custom shadow-sm">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle table-premium m-0">
                                <thead>
                                    <tr>
                                        <th class="ps-4 py-3" style="width: 80px;">Mã</th>
                                        <th style="width: 250px;">Tên Danh Mục</th>
                                        <th>Mô Tả Chi Tiết</th>
                                        <c:choose>
                                            <c:when test="${isTrashView}">
                                                <th style="width: 200px;">Ngày Xóa</th>
                                                <th class="text-end pe-4" style="width: 150px;">Thao tác</th>
                                            </c:when>
                                            <c:otherwise>
                                                <th style="width: 200px;">Ngày Tạo</th>
                                                <th class="text-end pe-4" style="width: 180px;">Thao tác</th>
                                            </c:otherwise>
                                        </c:choose>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:choose>
                                        <c:when test="${isTrashView}">
                                            <!-- Hiển thị Thùng rác -->
                                            <c:choose>
                                                <c:when test="${empty deletedCategories}">
                                                    <tr>
                                                        <td colspan="5" class="text-center py-5 text-muted">
                                                            <i class="fa-regular fa-trash-can fs-2 mb-3 d-block text-secondary"></i>
                                                            Thùng rác trống.
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="cat" items="${deletedCategories}">
                                                        <tr>
                                                            <td class="ps-4 fw-semibold text-secondary">#${cat.categoryId}</td>
                                                            <td><span class="fw-bold text-indigo-brand">${cat.name}</span></td>
                                                            <td class="text-muted text-truncate" style="max-width: 350px;">${cat.description}</td>
                                                            <td>${cat.deletedAt}</td>
                                                            <td class="text-end pe-4">
                                                                <button class="btn btn-outline-success btn-sm rounded-3 px-3 py-1.5 fw-medium btn-restore-trigger" 
                                                                        data-id="${cat.categoryId}" data-name="${cat.name}">
                                                                    <i class="fa-solid fa-rotate-left me-1"></i> Khôi phục
                                                                </button>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:otherwise>
                                            <!-- Hiển thị Danh mục hoạt động -->
                                            <c:choose>
                                                <c:when test="${empty activeCategories}">
                                                    <tr>
                                                        <td colspan="5" class="text-center py-5 text-muted">
                                                            <i class="fa-regular fa-folder-open fs-2 mb-3 d-block text-secondary"></i>
                                                            Chưa có danh mục nào. Hãy bấm "Thêm danh mục" để khởi tạo!
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="cat" items="${activeCategories}">
                                                        <tr>
                                                            <td class="ps-4 fw-semibold text-secondary">#${cat.categoryId}</td>
                                                            <td>
                                                                <span class="badge badge-soft-purple rounded-pill px-3 py-1.5 fs-7">${cat.name}</span>
                                                            </td>
                                                            <td class="text-muted" style="max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                                ${cat.description != null && !cat.description.isEmpty() ? cat.description : "Không có mô tả"}
                                                            </td>
                                                            <td>${cat.createdAt}</td>
                                                            <td class="text-end pe-4">
                                                                <div class="d-flex justify-content-end gap-2">
                                                                    <button class="btn btn-outline-indigo-brand btn-sm rounded-3 px-2 py-1.5 btn-edit-trigger" 
                                                                            data-id="${cat.categoryId}" data-name="${cat.name}" data-desc="${cat.description}">
                                                                        <i class="fa-solid fa-pen-to-square"></i> Sửa
                                                                    </button>
                                                                    <button class="btn btn-outline-danger btn-sm rounded-3 px-2 py-1.5 btn-delete-trigger" 
                                                                            data-id="${cat.categoryId}" data-name="${cat.name}">
                                                                        <i class="fa-solid fa-trash-can"></i> Xóa
                                                                    </button>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
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
    <!-- 3. CÁC MODAL HỘP THOẠI (BOOTSTRAP 5)                    -->
    <!-- ======================================================= -->

    <!-- Modal: Thêm danh mục -->
    <div class="modal fade" id="addCategoryModal" tabindex="-1" aria-labelledby="addCategoryModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow rounded-3">
                <form action="${pageContext.request.contextPath}/categories?action=insert" method="post">
                    <div class="modal-header bg-indigo-brand text-white border-0 py-3 rounded-top-3">
                        <h5 class="modal-title fw-bold" id="addCategoryModalLabel">
                            <i class="fa-solid fa-plus-circle me-2"></i>Thêm Danh Mục Mới
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label for="addName" class="form-label fw-semibold text-secondary">Tên danh mục <span class="text-danger">*</span></label>
                            <input type="text" class="form-control rounded-3" id="addName" name="name" required placeholder="Ví dụ: Công nghệ thông tin, Kinh tế...">
                        </div>
                        <div class="mb-0">
                            <label for="addDescription" class="form-label fw-semibold text-secondary">Mô tả</label>
                            <textarea class="form-control rounded-3" id="addDescription" name="description" rows="4" placeholder="Mô tả tóm tắt nội dung danh mục sách này..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="button" class="btn btn-light rounded-3 px-4 py-2" data-bs-dismiss="modal">Hủy bỏ</button>
                        <button type="submit" class="btn btn-indigo-brand rounded-3 px-4 py-2">Xác nhận thêm</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Sửa danh mục -->
    <div class="modal fade" id="editCategoryModal" tabindex="-1" aria-labelledby="editCategoryModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow rounded-3">
                <form action="${pageContext.request.contextPath}/categories?action=update" method="post">
                    <input type="hidden" id="editCategoryId" name="categoryId">
                    <div class="modal-header bg-indigo-brand text-white border-0 py-3 rounded-top-3">
                        <h5 class="modal-title fw-bold" id="editCategoryModalLabel">
                            <i class="fa-solid fa-pen-to-square me-2"></i>Chỉnh Sửa Danh Mục
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label for="editName" class="form-label fw-semibold text-secondary">Tên danh mục <span class="text-danger">*</span></label>
                            <input type="text" class="form-control rounded-3" id="editName" name="name" required>
                        </div>
                        <div class="mb-0">
                            <label for="editDescription" class="form-label fw-semibold text-secondary">Mô tả</label>
                            <textarea class="form-control rounded-3" id="editDescription" name="description" rows="4"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="button" class="btn btn-light rounded-3 px-4 py-2" data-bs-dismiss="modal">Hủy bỏ</button>
                        <button type="submit" class="btn btn-indigo-brand rounded-3 px-4 py-2">Lưu thay đổi</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Xác nhận xóa mềm -->
    <div class="modal fade" id="deleteCategoryModal" tabindex="-1" aria-labelledby="deleteCategoryModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 400px;">
            <div class="modal-content border-0 shadow rounded-3">
                <form action="${pageContext.request.contextPath}/categories?action=delete" method="post">
                    <input type="hidden" id="deleteCategoryId" name="categoryId">
                    <div class="modal-body p-4 text-center">
                        <i class="fa-solid fa-triangle-exclamation text-danger fs-1 mb-3"></i>
                        <h5 class="fw-bold mb-2">Xác nhận xóa danh mục</h5>
                        <p class="text-muted small mb-4">Bạn có chắc chắn muốn xóa danh mục <span class="fw-bold text-dark" id="deleteCategoryName"></span>? Hành động này sẽ chuyển danh mục vào thùng rác.</p>
                        
                        <div class="d-flex gap-2 justify-content-center">
                            <button type="button" class="btn btn-light rounded-3 px-4 py-2 flex-grow-1" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-danger rounded-3 px-4 py-2 flex-grow-1">Đồng ý xóa</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Xác nhận khôi phục -->
    <div class="modal fade" id="restoreCategoryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 400px;">
            <div class="modal-content border-0 shadow rounded-3">
                <form action="${pageContext.request.contextPath}/categories?action=restore" method="post">
                    <input type="hidden" id="restoreCategoryId" name="categoryId">
                    <div class="modal-body p-4 text-center">
                        <i class="fa-solid fa-clock-rotate-left text-success fs-1 mb-3"></i>
                        <h5 class="fw-bold mb-2">Khôi phục danh mục</h5>
                        <p class="text-muted small mb-4">Bạn có chắc chắn muốn khôi phục danh mục <span class="fw-bold text-dark" id="restoreCategoryName"></span> về danh sách hoạt động?</p>
                        
                        <div class="d-flex gap-2 justify-content-center">
                            <button type="button" class="btn btn-light rounded-3 px-4 py-2 flex-grow-1" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" class="btn btn-success rounded-3 px-4 py-2 flex-grow-1 text-white">Khôi phục</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Script tương tác Modal (Tách ra từ categories.jsp) -->
    <script src="${pageContext.request.contextPath}/assets/categories/categories-jsp.js"></script>
</body>
</html>