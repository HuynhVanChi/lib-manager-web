<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Nhúng Font chữ Inter (Sans-serif) và FontAwesome -->
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

<style>
    /* CSS cực mỏng cho những phần Bootstrap không hỗ trợ (Hover, Scrollbar, Pseudo-element) */
    .sidebar-scroll::-webkit-scrollbar { width: 5px; }
    .sidebar-scroll::-webkit-scrollbar-thumb { background-color: #dee2e6; border-radius: 4px; }

    .menu-link {
        transition: background-color 0.2s ease-in-out;
    }
    .menu-link:hover {
        background-color: #f3f4f6 !important;
    }
    
    /* Vạch đen đánh dấu trang hiện tại */
    .menu-link.active {
        background-color: #f3f4f6 !important;
        font-weight: 600 !important;
        position: relative;
    }
    .menu-link.active::before {
        content: "";
        position: absolute;
        left: -16px; /* Đẩy vạch đen ra sát mép trái sidebar */
        top: 15%;
        height: 70%;
        width: 4px;
        background-color: #000000;
        border-radius: 0 4px 4px 0;
    }
</style>

<%
    String currentURL = request.getRequestURI();
%>

<!-- Dùng vh-100 (cao 100%), sticky-top (đứng im), bg-white (nền trắng), border-end (viền phải) -->
<div class="d-flex flex-column vh-100 sticky-top bg-white border-end shadow-sm sidebar-scroll" 
     style="width: 260px; font-family: 'Inter', sans-serif; overflow-y: auto;">
    
    <!-- Tiêu đề & Logo -->
    <div class="p-4 d-flex align-items-center mb-1">
        <i class="fa-solid fa-book-open-reader fs-3 me-3 text-dark"></i>
        <span class="fs-4 fw-bold text-dark" style="letter-spacing: 0.2px;">LibraryOS</span>
    </div>

    <!-- Danh sách Menu (Dùng nav flex-column của Bootstrap) -->
    <div class="nav flex-column px-3 mb-auto">
        
        <a href="${pageContext.request.contextPath}/dashboard" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/dashboard") ? "active" : "" %>">
            <i class="fa-solid fa-chart-pie" style="width: 32px; font-size: 1.15rem;"></i> Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/books" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/books") ? "active" : "" %>">
            <i class="fa-solid fa-book" style="width: 32px; font-size: 1.15rem;"></i> Sách
        </a>

        <a href="${pageContext.request.contextPath}/categories" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/categories") ? "active" : "" %>">
            <i class="fa-solid fa-tags" style="width: 32px; font-size: 1.15rem;"></i> Danh mục
        </a>

        <a href="${pageContext.request.contextPath}/readers" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/readers") ? "active" : "" %>">
            <i class="fa-solid fa-users" style="width: 32px; font-size: 1.15rem;"></i> Độc giả
        </a>

        <a href="${pageContext.request.contextPath}/borrow-return" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/borrow-return") ? "active" : "" %>">
            <i class="fa-solid fa-hand-holding-hand" style="width: 32px; font-size: 1.15rem;"></i> Mượn sách
        </a>

        <a href="${pageContext.request.contextPath}/accounts" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/accounts") ? "active" : "" %>">
            <i class="fa-solid fa-user-tie" style="width: 32px; font-size: 1.15rem;"></i> Nhân sự
        </a>

        <a href="${pageContext.request.contextPath}/recommends" 
           class="nav-link text-dark fw-medium d-flex align-items-center mb-1 rounded py-2 px-3 menu-link <%= currentURL.contains("/recommends") ? "active" : "" %>">
            <i class="fa-solid fa-lightbulb" style="width: 32px; font-size: 1.15rem;"></i> Đề xuất sách
        </a>

    </div>
</div>