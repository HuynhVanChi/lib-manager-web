<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,categories.Category,book.Book"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sửa Đầu Sách - LibraryOS</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
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
                
                <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/books">
                                        <i class="fa-solid fa-book me-1"></i>Quản lý sách
                                    </a>
                                </li>
                                <li class="breadcrumb-item active" aria-current="page">Chỉnh sửa</li>
                            </ol>
                        </nav>
                        <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">Chỉnh sửa đầu sách</h1>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" id="btn-back" class="btn-back hover-lift">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>

                <!-- Thẻ Form chính -->
                <div class="row justify-content-center">
                    <div class="col-12 col-lg-10">
                        <div class="form-card bg-white">
                            
                            <%-- Header card --%>
                            <div class="form-card-header">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="rounded-circle d-flex align-items-center justify-content-center"
                                         style="width:44px;height:44px;background:rgba(255,255,255,.2);flex-shrink:0;">
                                        <i class="fa-solid fa-pen-to-square text-white fs-5"></i>
                                    </div>
                                    <div>
                                        <h5 class="text-white fw-bold mb-0">Chỉnh sửa thông tin</h5>
                                        <p class="text-white mb-0" style="opacity:.75;font-size:.82rem;">
                                            Cập nhật thông tin chi tiết của đầu sách: <strong class="text-warning">${book.title}</strong>
                                        </p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="p-4">

                                <form id="editBookForm" action="${pageContext.request.contextPath}/books?action=update" method="post" enctype="multipart/form-data">
                                    <!-- ID ẩn của sách -->
                                    <input type="hidden" name="bookId" value="${book.bookId}">
                                    <!-- Trạng thái gỡ ảnh -->
                                    <input type="hidden" name="removeImage" id="removeImage" value="false">

                                    <div class="row">
                                        <%-- CỘT TRÁI: KHUNG CHỌN ẢNH BÌA --%>
                                        <div class="col-md-4 text-center border-end d-flex flex-column align-items-center justify-content-center py-3">
                                            <div class="position-relative" style="width: 150px; height: 200px;">
                                                <!-- Nút gỡ ảnh hình tròn nhỏ ở góc chứa icon thùng rác -->
                                                <button type="button" id="btnRemoveImage" class="btn btn-danger btn-sm rounded-circle position-absolute ${not empty book.imagePath ? '' : 'd-none'}" 
                                                        style="top: -10px; right: -10px; width: 24px; height: 24px; display: flex; align-items: center; justify-content: center; z-index: 10;" 
                                                        title="Gỡ ảnh bìa">
                                                    <i class="fa-solid fa-trash-can" style="font-size: 10px;"></i>
                                                </button>
                                                
                                                <div id="imagePreviewContainer" class="d-flex flex-column align-items-center justify-content-center w-100 h-100" 
                                                     style="border: 2px dashed #D1D5DB; border-radius: 8px; cursor: pointer; overflow: hidden; background: #F3F4F6; transition: all 0.2s;">
                                                    <i class="fa-solid fa-image text-muted fs-1 mb-2 ${not empty book.imagePath ? 'd-none' : ''}" id="placeholderIcon"></i>
                                                    <span class="text-muted small ${not empty book.imagePath ? 'd-none' : ''}" id="placeholderText">Chọn ảnh bìa</span>
                                                    <img id="imagePreview" src="${not empty book.imagePath ? pageContext.request.contextPath.concat('/').concat(book.imagePath) : ''}" 
                                                         class="w-100 h-100 ${not empty book.imagePath ? '' : 'd-none'}" style="object-fit: cover;">
                                                </div>
                                            </div>
                                            <input type="file" name="imageFile" id="imageFile" accept="image/*" class="d-none">
                                            <div class="form-hint mt-3">Định dạng hỗ trợ: JPG, PNG, WEBP</div>
                                        </div>

                                        <%-- CỘT PHẢI: CÁC TRƯỜNG THÔNG TIN SÁCH --%>
                                        <div class="col-md-8 ps-md-4">
                                            <div class="section-divider">
                                                <i class="fa-solid fa-book-open me-2"></i>Thông tin cơ bản
                                            </div>

                                            <!-- 1. Tên sách -->
                                            <div class="mb-3">
                                                <label for="title" class="form-label">Tên đầu sách <span class="required-mark">*</span></label>
                                                <input type="text" class="form-control" id="title" name="title" value="<c:out value='${book.title}'/>" required placeholder="Nhập tiêu đề sách...">
                                                <div class="form-hint">Nhập tên đầy đủ của đầu sách.</div>
                                            </div>

                                            <!-- 2. Danh mục & Tác giả -->
                                            <div class="row mb-3">
                                                <div class="col-12 col-md-6 mb-3 mb-md-0">
                                                    <label for="categoryId" class="form-label">Danh mục phân loại <span class="required-mark">*</span></label>
                                                    <select class="filter-select w-100" id="categoryId" name="categoryId" required>
                                                        <c:forEach var="cat" items="${categoriesList}">
                                                            <option value="${cat.categoryId}" ${cat.categoryId == book.categoryId ? 'selected' : ''}>${cat.name}</option>
                                                        </c:forEach>
                                                    </select>
                                                </div>
                                                <div class="col-12 col-md-6">
                                                    <label for="author" class="form-label">Tác giả <span class="required-mark">*</span></label>
                                                    <input type="text" class="form-control" id="author" name="author" value="<c:out value='${book.author}'/>" required placeholder="Ví dụ: Dale Carnegie...">
                                                </div>
                                            </div>

                                            <div class="section-divider">
                                                <i class="fa-solid fa-print me-2"></i>Thông tin xuất bản
                                            </div>

                                            <!-- 3. Nhà xuất bản & Năm xuất bản -->
                                            <div class="row mb-3">
                                                <div class="col-12 col-md-8 mb-3 mb-md-0">
                                                    <label for="publisher" class="form-label">Nhà xuất bản</label>
                                                    <input type="text" class="form-control" id="publisher" name="publisher" value="<c:out value='${book.publisher}'/>">
                                                </div>
                                                <div class="col-12 col-md-4">
                                                    <label for="publishYear" class="form-label">Năm xuất bản</label>
                                                    <input type="number" class="form-control" id="publishYear" name="publishYear" value="${book.publishYear != 0 ? book.publishYear : ''}" min="1000" max="2100">
                                                </div>
                                            </div>
                                            
                                            <div class="section-divider">
                                                <i class="fa-solid fa-tags me-2"></i>Thông tin tài chính
                                            </div>

                                            <!-- 4. Giá bìa mặc định -->
                                            <div class="row mb-3">
                                                <div class="col-12 col-md-6">
                                                    <label for="price" class="form-label">Giá nhập (VND) <span class="required-mark">*</span></label>
                                                    <input type="number" class="form-control" id="price" name="price" value="${book.price != null ? book.price : '0'}" min="0" step="1000" required placeholder="Ví dụ: 79000">
                                                    <div class="form-hint">Giá bìa niêm yết làm giá trị mặc định cho các cuốn sách.</div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <hr class="text-muted my-4">

                                    <!-- Nút hành động -->
                                    <div class="d-flex justify-content-end gap-2">
                                        <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" id="btnCancel" class="btn btn-cancel hover-lift">
                                            Hủy bỏ
                                        </a>
                                        <button type="submit" class="btn btn-save hover-lift">
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

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- JS Phát hiện thay đổi Form chưa lưu & Preview ảnh bìa -->
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

            // ── Xử lý Chọn & Xem trước & Gỡ ảnh bìa ──
            const fileInput = document.getElementById("imageFile");
            const previewContainer = document.getElementById("imagePreviewContainer");
            const previewImage = document.getElementById("imagePreview");
            const placeholderIcon = document.getElementById("placeholderIcon");
            const placeholderText = document.getElementById("placeholderText");
            const btnRemoveImage = document.getElementById("btnRemoveImage");
            const removeImageInput = document.getElementById("removeImage");

            // Bấm vào khung preview để chọn file
            previewContainer.addEventListener("click", function() {
                fileInput.click();
            });

            // Khi file thay đổi, đọc và hiển thị preview
            fileInput.addEventListener("change", function() {
                const file = this.files[0];
                if (file) {
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        previewImage.src = e.target.result;
                        previewImage.classList.remove("d-none");
                        placeholderIcon.classList.add("d-none");
                        placeholderText.classList.add("d-none");
                        btnRemoveImage.classList.remove("d-none");
                        removeImageInput.value = "false";
                    }
                    reader.readAsDataURL(file);
                    isDirty = true;
                }
            });

            // Khi click nút gỡ ảnh
            btnRemoveImage.addEventListener("click", function(e) {
                e.stopPropagation(); // ngăn sự kiện click lan tới previewContainer làm mở hộp thoại chọn file lần nữa
                fileInput.value = ""; // xóa file trong input
                previewImage.src = "";
                previewImage.classList.add("d-none");
                placeholderIcon.classList.remove("d-none");
                placeholderText.classList.remove("d-none");
                btnRemoveImage.classList.add("d-none");
                removeImageInput.value = "true"; // Đánh dấu cho Servlet xóa ảnh cũ
                isDirty = true;
            });
        });
    </script>
    <%-- ── FLASH TOAST (cục bộ tương tự Độc giả) ── --%>
    <c:if test="${not empty errorMessage}">
        <div class="flash-toast error" id="flash-toast" role="alert">
            <span class="toast-icon">
                <i class="fa-solid fa-circle-xmark"></i>
            </span>
            <span style="font-size:.875rem;font-weight:500;flex:1;">
                <c:out value="${errorMessage}"/>
            </span>
            <button class="toast-close" onclick="closeToast()" aria-label="Đóng">
                <i class="fa-solid fa-xmark"></i>
            </button>
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
    </c:if>
</body>
</html>
