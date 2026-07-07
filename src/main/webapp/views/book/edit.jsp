<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,categories.Category,book.Book"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa Đầu Sách - LibraryOS</title>
    
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
                
                <!-- Thanh hướng dẫn điều hướng (Breadcrumbs) -->
                <nav aria-label="breadcrumb" class="mb-4">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/books" class="text-indigo-brand text-decoration-none fw-medium">Quản lý Sách</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Sửa đầu sách</li>
                    </ol>
                </nav>

                <!-- Thẻ Form chính -->
                <div class="row justify-content-center">
                    <div class="col-12 col-lg-8">
                        <div class="card card-custom shadow-sm">
                            <div class="card-header bg-indigo-brand text-white border-0 py-3 rounded-top-3">
                                <h5 class="card-title fw-bold m-0 d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-pen-to-square"></i> Sửa Đầu Sách: <span class="text-warning">${book.title}</span>
                                </h5>
                            </div>
                            
                            <div class="card-body p-4">
                                <!-- Hiển thị thông báo lỗi xác thực từ Servlet (nếu có) -->
                                <c:if test="${not empty errorMessage}">
                                    <div class="alert alert-danger alert-dismissible fade show rounded-3 border-0 px-4 py-3 mb-4" role="alert">
                                        <div class="d-flex align-items-center">
                                            <i class="fa-solid fa-triangle-exclamation text-danger fs-5 me-3"></i>
                                            <div class="fw-semibold text-dark">${errorMessage}</div>
                                        </div>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                </c:if>

                                <form id="editBookForm" action="${pageContext.request.contextPath}/books?action=update" method="post">
                                    <!-- ID ẩn của sách -->
                                    <input type="hidden" name="bookId" value="${book.bookId}">

                                    <!-- 1. Tên sách -->
                                    <div class="mb-4">
                                        <label for="title" class="form-label fw-bold text-secondary">Tên đầu sách <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control form-control-lg rounded-3" id="title" name="title" value="${book.title}" required placeholder="Nhập tiêu đề sách...">
                                    </div>

                                    <!-- 2. Danh mục & Tác giả -->
                                    <div class="row mb-4">
                                        <div class="col-12 col-md-6 mb-3 mb-md-0">
                                            <label for="categoryId" class="form-label fw-bold text-secondary">Danh mục phân loại <span class="text-danger">*</span></label>
                                            <select class="form-select rounded-3" id="categoryId" name="categoryId" required>
                                                <c:forEach var="cat" items="${categoriesList}">
                                                    <option value="${cat.categoryId}" ${cat.categoryId == book.categoryId ? 'selected' : ''}>${cat.name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <label for="author" class="form-label fw-bold text-secondary">Tác giả</label>
                                            <input type="text" class="form-control rounded-3" id="author" name="author" value="${book.author}">
                                        </div>
                                    </div>

                                    <!-- 3. Nhà xuất bản & Năm xuất bản -->
                                    <div class="row mb-4">
                                        <div class="col-12 col-md-8 mb-3 mb-md-0">
                                            <label for="publisher" class="form-label fw-bold text-secondary">Nhà xuất bản</label>
                                            <input type="text" class="form-control rounded-3" id="publisher" name="publisher" value="${book.publisher}">
                                        </div>
                                        <div class="col-12 col-md-4">
                                            <label for="publishYear" class="form-label fw-bold text-secondary">Năm xuất bản</label>
                                            <input type="number" class="form-control rounded-3" id="publishYear" name="publishYear" value="${book.publishYear != 0 ? book.publishYear : ''}" min="1000" max="2100">
                                        </div>
                                    </div>

                                    <hr class="text-muted my-4">

                                    <!-- Nút hành động -->
                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" id="btnCancel" class="btn btn-light rounded-3 px-4 py-2.5 fw-semibold text-secondary">
                                            Hủy bỏ / Quay lại
                                        </a>
                                        <button type="submit" class="btn btn-indigo-brand rounded-3 px-5 py-2.5 fw-semibold">
                                            <i class="fa-solid fa-floppy-disk me-1"></i> Lưu thay đổi
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- JS Phát hiện thay đổi Form chưa lưu -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const form = document.getElementById("editBookForm");
            let isDirty = false;

            // Đánh dấu form thay đổi khi người dùng gõ
            form.addEventListener("input", function() {
                isDirty = true;
            });

            // Khi submit form, cho phép chuyển trang bình thường
            form.addEventListener("submit", function() {
                isDirty = false;
            });

            // Khi người dùng bấm Hủy bỏ, kiểm tra xem có dữ liệu chưa lưu không
            const btnCancel = document.getElementById("btnCancel");
            btnCancel.addEventListener("click", function(e) {
                if (isDirty) {
                    const confirmLeave = confirm("Bạn có các thay đổi chưa được lưu. Bạn có chắc chắn muốn hủy bỏ?");
                    if (!confirmLeave) {
                        e.preventDefault();
                    }
                }
            });

            // Ngăn chặn đóng tab/F5 ngoài ý muốn
            window.addEventListener("beforeunload", function(e) {
                if (isDirty) {
                    e.preventDefault();
                    e.returnValue = "Bạn có các thay đổi chưa được lưu.";
                }
            });
        });
    </script>
</body>
</html>
