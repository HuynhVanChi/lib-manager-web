<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Lấy URI gốc từ trình duyệt trước khi Servlet forward sang JSP
    String currentHeaderURL = (String) request.getAttribute("javax.servlet.forward.request_uri");
    if (currentHeaderURL == null) {
        currentHeaderURL = request.getRequestURI();
    }
    if (currentHeaderURL == null) {
        currentHeaderURL = "";
    }
    String checkURL = currentHeaderURL.toLowerCase();
    String pageTitle = "Hệ thống"; // Tiêu đề mặc định dự phòng

    if (checkURL.contains("/dashboard")) {
        pageTitle = "Dashboard";
    } else if (checkURL.contains("/book")) { // Khớp /books và /views/book/
        pageTitle = "Quản lý Sách";
    } else if (checkURL.contains("/categor")) { // Khớp /categories và /views/category/
        pageTitle = "Quản lý Danh mục";
    } else if (checkURL.contains("/reader")) { // Khớp /readers và /views/reader/
        pageTitle = "Quản lý Độc giả";
    } else if (checkURL.contains("/borrow") || checkURL.contains("/return")) {
        pageTitle = "Quản lý Mượn trả";
    } else if (checkURL.contains("/account") || checkURL.contains("/user")) {
        pageTitle = "Quản lý Nhân sự";
    } else if (checkURL.contains("/recommend")) {
        pageTitle = "Đề xuất Sách";
    } else if (checkURL.contains("/audit") || checkURL.contains("/log")) {
        pageTitle = "Audit Logs";
    }
%>

<header class="d-flex justify-content-between align-items-center bg-white border-bottom px-4 py-2 shadow-sm sticky-top" 
        style="height: 70px; font-family: 'Inter', sans-serif;">
    
    <!-- Cột trái chứa Tiêu đề động chính xác theo module -->
    <div class="header-left d-flex align-items-center">
        <h4 class="fw-bold m-0 text-dark" id="header-dynamic-title"><%= pageTitle %></h4>
    </div>

    <!-- Cột giữa chứa Đồng hồ hệ thống -->
    <div class="header-center bg-light border rounded-pill px-3 py-1.5 d-flex align-items-center text-secondary border-0 shadow-sm">
        <i class="fa-regular fa-clock me-2 text-primary"></i>
        <span class="fw-medium small" id="live-clock" style="letter-spacing: 0.5px;">00:00:00 — 01/01/2026</span>
    </div>

    <!-- Cột phải chứa thông tin người dùng và Đăng xuất (Khóa co giãn flex-shrink để giữ form tròn) -->
    <div class="header-right d-flex align-items-center">
        
        <div class="d-flex align-items-center pe-3 me-3 border-end border-2 header-user" style="flex-shrink: 0;">
            <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center shadow-sm" 
                 style="width: 45px; height: 45px; margin-right: 10px; flex-shrink: 0;">
                <i class="fa-solid fa-user-shield fs-5"></i>
            </div>
            <div class="d-flex flex-column lh-sm" style="flex-shrink: 0;">
                <span class="fw-semibold text-dark small">Nguyễn Văn A</span>
                <span class="text-muted fw-medium" style="font-size: 0.75rem;">Admin</span>
            </div>
        </div>

        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm border-0 rounded-3 px-3 py-2 d-flex align-items-center fw-medium gap-2 text-decoration-none" style="flex-shrink: 0;">
            <i class="fa-solid fa-right-from-bracket"></i>
            <span>Đăng xuất</span>
        </a>
        
    </div>
</header>

<script>
    (function(){
        function updateLiveClock() {
            const clockElement = document.getElementById('live-clock');
            if (!clockElement) return;

            const now = new Date();
            
            // Định dạng giờ:phút:giây đầy đủ 2 chữ số
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            
            // Định dạng ngày/tháng/năm
            const day = String(now.getDate()).padStart(2, '0');
            const month = String(now.getMonth() + 1).padStart(2, '0'); // Tháng bắt đầu từ 0
            const year = now.getFullYear();

            // Cập nhật giao diện trực quan
            clockElement.textContent = hours + ":" + minutes + ":" + seconds + " — " + day + "/" + month + "/" + year;      
        }
        updateLiveClock();
        setInterval(updateLiveClock, 1000);
    })();
</script>