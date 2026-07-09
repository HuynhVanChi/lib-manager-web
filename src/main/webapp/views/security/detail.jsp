<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="security.TaiKhoan" %>
<%
    TaiKhoan account = (TaiKhoan) request.getAttribute("account");
    if (account == null) {
        response.sendRedirect(request.getContextPath() + "/accounts");
        return;
    }

    // Tính toán viết tắt tên (Avatar Initials)
    String initials = "U";
    if (account.getFullName() != null && !account.getFullName().trim().isEmpty()) {
        String[] parts = account.getFullName().trim().split("\\s+");
        if (parts.length > 0) {
            if (parts.length >= 2) {
                String first = parts[parts.length - 2].substring(0, 1);
                String last = parts[parts.length - 1].substring(0, 1);
                initials = (first + last).toUpperCase();
            } else {
                initials = parts[0].substring(0, Math.min(parts[0].length(), 2)).toUpperCase();
            }
        }
    }

    // Định dạng thời gian
    String formattedCreated = account.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(account.getCreatedAt()) : "—";
    String formattedCreatedFull = account.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(account.getCreatedAt()) : "—";
    java.sql.Timestamp lastUpdate = account.getUpdatedAt() != null ? account.getUpdatedAt() : account.getCreatedAt();
    String formattedLastUpdate = lastUpdate != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(lastUpdate) : "—";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chi tiết tài khoản nhân sự - LibraryOS">
    <title>Hồ sơ Nhân sự - LibraryOS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
</head>

<body class="m-0 p-0">
<div class="d-flex">

    <%-- SIDEBAR --%>
    <jsp:include page="/views/layout/sidebar.jsp"/>

    <%-- MAIN CONTENT --%>
    <main class="w-100">
        <jsp:include page="/views/layout/header.jsp"/>

        <div class="container-fluid p-4">

            <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
            <div class="d-flex justify-content-between align-items-start mb-4">
                <div>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/accounts" class="text-decoration-none">
                                    <i class="fa-solid fa-user-tie me-1"></i>Nhân sự
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">Chi tiết</li>
                        </ol>
                    </nav>
                    <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                        Hồ sơ nhân sự
                    </h1>
                </div>
                <%-- Nút hành động góc phải --%>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/accounts?action=edit&userId=<%= account.getUserId() %>"
                       id="btn-edit-account"
                       class="btn btn-edit hover-lift text-decoration-none">
                        <i class="fa-solid fa-user-pen"></i> Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/accounts"
                       id="btn-back"
                       class="btn btn-back hover-lift text-decoration-none">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- HERO BANNER — Thông tin nhanh nhân sự   --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="details-hero">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="details-avatar" style="background: var(--primary-soft); color: var(--primary); font-weight: 700; font-size: 1.5rem; display: flex; align-items: center; justify-content: center;">
                        <%= initials %>
                    </div>
                    <div>
                        <h2 class="details-hero-name text-white">
                            <%= account.getFullName() %>
                        </h2>
                        <div class="details-hero-email text-white-50">
                            <i class="fa-solid fa-user me-1" style="font-size:.75rem;"></i>
                            Tên đăng nhập: <%= account.getUsername() %>
                        </div>
                    </div>
                    <%-- Badge trạng thái --%>
                    <div class="ms-auto">
                        <span class="badge-status badge-active">
                            <i class="fa-solid fa-circle-check me-1" style="font-size:.65rem;"></i>Hoạt động
                        </span>
                    </div>
                </div>

                <%-- Thông tin nhanh dạng pill --%>
                <div class="d-flex gap-2 flex-wrap">
                    <span class="details-hero-pill">
                        <i class="fa-solid fa-hashtag"></i> ID: <%= account.getUserId() %>
                    </span>
                    <span class="details-hero-pill">
                        <i class="fa-solid fa-user-shield"></i>
                        Vai trò: <%= "Admin".equalsIgnoreCase(account.getRole()) ? "Quản trị viên" : "Thủ thư" %>
                    </span>
                    <span class="details-hero-pill">
                        <i class="fa-regular fa-calendar-plus"></i>
                        Tạo: <%= formattedCreated %>
                    </span>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- CARD THÔNG TIN CHI TIẾT                 --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="card detail-card bg-white">
                <div class="detail-card-header">
                    <i class="fa-solid fa-id-card text-primary"></i>
                    Thông tin chi tiết tài khoản
                </div>
                <div class="info-grid">
                    <div class="info-row">
                        <span class="info-label">Họ và tên</span>
                        <span class="info-value"><%= account.getFullName() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Tên đăng nhập</span>
                        <span class="info-value"><%= account.getUsername() %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Vai trò hệ thống</span>
                        <span class="info-value">
                            <%= "Admin".equalsIgnoreCase(account.getRole()) ? "Quản trị viên (Admin)" : "Thủ thư (Staff)" %>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Trạng thái hoạt động</span>
                        <span class="info-value text-success fw-semibold">Đang hoạt động</span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Ngày tạo tài khoản</span>
                        <span class="info-value"><%= formattedCreatedFull %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Cập nhật lần cuối</span>
                        <span class="info-value"><%= formattedLastUpdate %></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Mã tài khoản (User ID)</span>
                        <span class="info-value">#<%= account.getUserId() %></span>
                    </div>
                </div>
            </div>

        </div>
    </main>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
