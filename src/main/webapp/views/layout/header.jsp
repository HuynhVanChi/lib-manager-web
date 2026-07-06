<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // Lấy URI hiện tại để đồng bộ tiêu đề động tương thích hoàn toàn với Sidebar
    String currentHeaderURL = request.getRequestURI();
    String pageTitle = "Hệ thống"; // Tiêu đề mặc định dự phòng

    if (currentHeaderURL.contains("/dashboard")) {
        pageTitle = "Dashboard";
    } else if (currentHeaderURL.contains("/books")) {
        pageTitle = "Quản lý Sách";
    } else if (currentHeaderURL.contains("/categories")) {
        pageTitle = "Quản lý Danh mục";
    } else if (currentHeaderURL.contains("/readers")) {
        pageTitle = "Quản lý Độc giả";
    } else if (currentHeaderURL.contains("/borrow-return")) {
        pageTitle = "Quản lý Mượn trả";
    } else if (currentHeaderURL.contains("/accounts")) {
        pageTitle = "Quản lý Nhân sự";
    } else if (currentHeaderURL.contains("/recommends")) {
        pageTitle = "Đề xuất Sách";
    } else if (currentHeaderURL.contains("/AuditLogs")) {
        pageTitle = "Audit Logs";
    }
%>

<header class="d-flex justify-content-between align-items-center bg-white border-bottom px-4 py-2 shadow-sm sticky-top" 
        style="height: 70px; font-family: 'Inter', sans-serif;">
    
    <div class="header-left">
        <h4 class="fw-bold m-0 text-dark" id="header-dynamic-title"><%= pageTitle %></h4>
    </div>

    <div class="header-center bg-light border rounded-pill px-3 py-1.5 d-flex align-items-center text-secondary border-0 shadow-sm">
        <i class="fa-regular fa-clock me-2 text-primary"></i>
        <span class="fw-medium small" id="live-clock" style="letter-spacing: 0.5px;">00:00:00 — 01/01/2026</span>
    </div>

    <div class="header-right d-flex align-items-center">
        
        <div class="d-flex align-items-center pe-3 me-3 border-end border-2 header-user">
            <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center shadow-sm" 
                 style="width: 45px; height: 45px; margin-right: 10px;">
                <i class="fa-solid fa-user-shield fs-5"></i>
            </div>
            <div class="d-flex flex-column lh-sm">
                <span class="fw-semibold text-dark small">Nguyễn Văn A</span>
                <span class="text-muted fw-medium" style="font-size: 0.75rem;">Admin</span>
            </div>
        </div>

        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm border-0 rounded-3 px-3 py-2 d-flex align-items-center fw-medium gap-2 text-decoration-none">
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