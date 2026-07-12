<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Nhúng Stylesheet dùng chung toàn hệ thống để đảm bảo Sidebar hoạt động trên tất cả các trang -->
<link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">

<!-- Nhúng Font chữ Inter (Sans-serif) và FontAwesome -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    /* Custom Scrollbar cho Sidebar nền tối */
    .sidebar-scroll::-webkit-scrollbar { width: 5px; }
    .sidebar-scroll::-webkit-scrollbar-thumb { background-color: rgba(255, 255, 255, 0.15); border-radius: 4px; }
</style>

<%
    // Lấy original request URI thực tế từ trình duyệt (khi Servlet forward sang JSP)
    String currentURI = (String) request.getAttribute("javax.servlet.forward.request_uri");
    if (currentURI == null) {
        currentURI = request.getRequestURI();
    }
    String checkURI = (currentURI != null) ? currentURI.toLowerCase() : "";
%>

<!-- Sidebar dùng class sidebar-custom để áp dụng theme tối đồng bộ -->
<div class="d-flex flex-column vh-100 sticky-top shadow-lg sidebar-scroll sidebar-custom">
    
    <!-- Tiêu đề & Logo (Khung ngoài 100%, khung trong dùng flex để tùy biến padding/gap) -->
    <div class="logo-area">
        <div class="logo-inner">
            <div class="logo-icon-box">
                <i class="fa-solid fa-book-open"></i>
            </div>
            <span class="logo-text">LibraryOS</span>
        </div>
    </div>

    <!-- Danh sách Menu (Dùng nav flex-column) -->
    <div class="nav flex-column px-3 mb-auto">
        
        <a href="${pageContext.request.contextPath}/dashboard" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= checkURI.contains("dashboard") ? "active" : "" %>">
            <i class="fa-solid fa-chart-pie" style="width: 32px; font-size: 1.15rem;"></i> Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/books" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= (checkURI.contains("book") || checkURI.contains("copy")) ? "active" : "" %>">
            <i class="fa-solid fa-book" style="width: 32px; font-size: 1.15rem;"></i> Sách
        </a>

        <a href="${pageContext.request.contextPath}/categories" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= checkURI.contains("categor") ? "active" : "" %>">
            <i class="fa-solid fa-tags" style="width: 32px; font-size: 1.15rem;"></i> Danh mục
        </a>

        <a href="${pageContext.request.contextPath}/readers" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= checkURI.contains("reader") ? "active" : "" %>">
            <i class="fa-solid fa-users" style="width: 32px; font-size: 1.15rem;"></i> Độc giả
        </a>

        <a href="${pageContext.request.contextPath}/borrow-return" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= (checkURI.contains("borrow") || checkURI.contains("return")) ? "active" : "" %>">
            <i class="fa-solid fa-hand-holding-hand" style="width: 32px; font-size: 1.15rem;"></i> Mượn sách
        </a>

        <a href="${pageContext.request.contextPath}/recommend" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= checkURI.contains("recommend") ? "active" : "" %>">
            <i class="fa-solid fa-lightbulb" style="width: 32px; font-size: 1.15rem;"></i> Đề xuất sách
        </a>

        <% 
            security.TaiKhoan currentUser = (session != null)
                    ? (security.TaiKhoan) session.getAttribute("currentUser") : null;
            String userRole = (currentUser != null) ? currentUser.getRole() : null;
            if ("Admin".equals(userRole)) {
        %>
        <a href="${pageContext.request.contextPath}/accounts" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= (checkURI.contains("account") || checkURI.contains("staff") || checkURI.contains("user")) ? "active" : "" %>">
            <i class="fa-solid fa-user-tie" style="width: 32px; font-size: 1.15rem;"></i> Nhân sự
        </a>

        <a href="${pageContext.request.contextPath}/AuditLogs" 
           class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= checkURI.contains("audit") ? "active" : "" %>">
            <i class="fa-solid fa-clock-rotate-left" style="width: 32px; font-size: 1.15rem;"></i> Nhật ký hệ thống
        </a>
        <% } %>

    </div>
</div>