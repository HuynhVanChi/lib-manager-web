<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="security.TaiKhoan" %>

<%
    // Lấy thông tin người dùng từ session
    TaiKhoan currentUser = null;
    HttpSession currentSession = request.getSession(false);
    if (currentSession != null) {
        currentUser = (TaiKhoan) currentSession.getAttribute("currentUser");
    }
    String userFullName = (currentUser != null) ? currentUser.getFullName() : "Khách";
    String userRole = (currentUser != null) ? currentUser.getRole() : "Guest";

    // Lấy chữ cái đầu của tên chính (tên cuối cùng)
    String firstLetter = "";
    if (userFullName != null && !userFullName.trim().isEmpty()) {
        String[] parts = userFullName.trim().split("\\s+");
        if (parts.length > 0) {
            String namePart = parts[parts.length - 1];
            if (!namePart.isEmpty()) {
                firstLetter = namePart.substring(0, 1).toUpperCase();
            }
        }
    }
    if (firstLetter.isEmpty()) {
        firstLetter = "U";
    }

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
        
        <a href="${pageContext.request.contextPath}/accounts?action=detail&userId=<%= (currentUser != null) ? currentUser.getUserId() : "" %>" 
           class="d-flex align-items-center pe-3 me-3 border-end border-2 header-user text-decoration-none" 
           style="flex-shrink: 0; cursor: pointer; transition: opacity 0.2s;"
           onmouseover="this.style.opacity='0.85'" 
           onmouseout="this.style.opacity='1'">
            <div class="text-white rounded-circle d-flex align-items-center justify-content-center shadow-sm fw-bold" 
                 style="width: 45px; height: 45px; margin-right: 12px; flex-shrink: 0; background-color: #2e3894; font-size: 1.2rem; user-select: none;">
                <%= firstLetter %>
            </div>
            <div class="d-flex flex-column lh-sm" style="flex-shrink: 0;">
                <span class="fw-bold text-dark" style="font-size: 0.95rem; font-weight: 600;"><%= userFullName %></span>
                <span class="text-muted fw-medium" style="font-size: 0.75rem; color: #718096 !important; margin-top: 1px;"><%= userRole %></span>
            </div>
        </a>

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