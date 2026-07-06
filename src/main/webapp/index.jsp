<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tên Trang - LibraryOS</title>
    
    <!-- Nhúng Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Nhúng FontAwesome (Nếu cần dùng icon trong nội dung) -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
</head>

<!-- Body set bg-light (màu nền xám nhạt) để làm nổi bật các Card trắng bên trong -->
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH: Dùng d-flex để chia 2 cột -->
    <div class="d-flex">
        
        <!-- ========================================== -->
        <!-- 1. CỘT TRÁI: NHÚNG SIDEBAR DÙNG CHUNG       -->
        <!-- ========================================== -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- ========================================== -->
        <!-- 2. CỘT PHẢI: KHU VỰC NỘI DUNG CỦA TỪNG TRANG -->
        <!-- ========================================== -->
        <main class="w-100">
            
            <!-- (Tùy chọn) Gắn Header ngang vào đây nếu nhóm có làm Header -->
            <jsp:include page="/views/layout/header.jsp"/>

            <!-- Vùng đệm p-4 (padding) để nội dung không bị dính vào viền màn hình -->
            <div class="container-fluid p-4">
                
                <!-- Tiêu đề trang -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2 class="fw-bold m-0 text-dark">Tiêu đề chức năng</h2>
                    
                    <!-- Nút hành động góc phải trên cùng (Ví dụ: Thêm mới) -->
                    <a href="#" class="btn btn-primary">
                        <i class="fa-solid fa-plus me-1"></i> Thêm mới
                    </a>
                </div>

                <!-- Bảng trắng (Card) chứa nội dung chính -->
                <div class="card border-0 shadow-sm rounded-3">
                    <div class="card-body p-4">
                        <!-- ========================================== -->
                        <!-- ANH EM BẮT ĐẦU CODE GIAO DIỆN VÀO ĐÂY      -->
                        <!-- ========================================== -->
                        
                        <p class="text-muted">Nội dung bảng dữ liệu hoặc form điền thông tin sẽ nằm ở đây...</p>
                        
                        <!-- ========================================== -->
                        <!-- HẾT PHẦN CODE CỦA TỪNG NGƯỜI               -->
                        <!-- ========================================== -->
                    </div>
                </div>

            </div>
        </main>
        
    </div>

    <!-- Nhúng Bootstrap 5 JS Bundle (Chứa Popper.js để chạy Dropdown, Modal...) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>