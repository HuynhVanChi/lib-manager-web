<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="security.TaiKhoan" %>
<%
    TaiKhoan editUser = (TaiKhoan) request.getAttribute("editUser");
    if (editUser == null) {
        response.sendRedirect(request.getContextPath() + "/accounts");
        return;
    }
    String toastMsg  = (String) request.getAttribute("toastMessage");
    String toastType = (String) request.getAttribute("toastType");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chỉnh sửa tài khoản nhân sự - LibraryOS">
    <title>Chỉnh sửa Tài khoản - LibraryOS</title>

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
            <div class="mb-4">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/accounts">
                                <i class="fa-solid fa-user-tie me-1"></i>Nhân sự
                            </a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/accounts?action=detail&userId=<%= editUser.getUserId() %>">
                                <%= editUser.getFullName() %>
                            </a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">Chỉnh sửa</li>
                    </ol>
                </nav>
                <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                    Chỉnh sửa tài khoản
                </h1>
            </div>

            <%-- ===== Toast / Alert ===== --%>
            <% if (toastMsg != null) {
                String toastCls = "success".equals(toastType) ? "success" : "error";
                String iconCls  = "success".equals(toastType) ? "fa-circle-check" : "fa-circle-xmark";
            %>
            <div class="flash-toast <%=toastCls%>" id="flash-toast" role="alert" style="margin-bottom: 20px;">
                <span class="toast-icon">
                    <i class="fa-solid <%=iconCls%>"></i>
                </span>
                <div class="toast-body small fw-medium m-0">
                    <%=toastMsg%>
                </div>
                <button type="button" class="toast-close" onclick="closeToast()">&times;</button>
            </div>
            <% } %>

            <%-- ── FORM CARD ── --%>
            <div class="card form-card">

                <%-- Header card --%>
                <div class="card-header form-card-header text-white d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-3 w-100">
                        <div class="rounded-circle d-flex align-items-center justify-content-center"
                             style="width:44px;height:44px;background:rgba(255,255,255,.15);flex-shrink:0;">
                            <i class="fa-solid fa-user-pen text-white fs-5"></i>
                        </div>
                        <div>
                            <h5 class="text-white fw-bold mb-0">
                                <%= editUser.getFullName() %>
                            </h5>
                            <div class="header-meta-badge">
                                <i class="fa-solid fa-hashtag" style="font-size:.7rem;"></i>
                                ID: <%= editUser.getUserId() %>
                                &nbsp;·&nbsp;
                                <i class="fa-regular fa-calendar" style="font-size:.7rem;"></i>
                                Tạo: <%= editUser.getCreatedAt() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy").format(editUser.getCreatedAt()) : "—" %>
                            </div>
                        </div>
                        <%-- Link xem chi tiết từ form edit --%>
                        <a href="${pageContext.request.contextPath}/accounts?action=detail&userId=<%= editUser.getUserId() %>"
                           class="btn-detail-link ms-auto"
                           title="Xem chi tiết nhân sự">
                            <i class="fa-solid fa-arrow-up-right-from-square" style="color:rgba(255,255,255,.6);"></i>
                            <span style="color:rgba(255,255,255,.6);">Xem chi tiết</span>
                        </a>
                    </div>
                </div>

                <%-- Body form --%>
                <div class="p-4">

                    <%-- Form chỉnh sửa --%>
                    <form action="${pageContext.request.contextPath}/accounts" method="POST" id="form-edit-account" novalidate>
                        <input type="hidden" name="action" value="update">
                        <input type="hidden" name="userId" value="<%= editUser.getUserId() %>">

                        <div class="row">
                            <%-- CỘT TRÁI: THÔNG TIN TÀI KHOẢN --%>
                            <div class="col-lg-6 col-12 border-end pe-lg-4">
                                <div class="section-divider">
                                    <i class="fa-solid fa-key me-2"></i>Thông tin tài khoản
                                </div>

                                <%-- Tên đăng nhập --%>
                                <div class="mb-3">
                                    <label for="username" class="form-label">
                                        Tên đăng nhập <span class="required-mark">*</span>
                                    </label>
                                    <input type="text"
                                           id="username"
                                           name="username"
                                           class="form-control"
                                           placeholder="Nhập tên đăng nhập"
                                           value="<%= editUser.getUsername() %>"
                                           required
                                           autocomplete="off">
                                </div>

                                <%-- Mật khẩu mới --%>
                                <div class="mb-3">
                                    <label for="input-password" class="form-label">Mật khẩu mới</label>
                                    <div class="position-relative">
                                        <input type="password"
                                               id="input-password"
                                               name="password"
                                               class="form-control pe-5"
                                               placeholder="Để trống nếu không đổi mật khẩu">
                                        <button type="button" class="btn position-absolute end-0 top-50 translate-middle-y border-0 bg-transparent text-muted py-0" id="toggle-password" style="z-index: 10; height: 100%;">
                                            <i class="fa-regular fa-eye" id="eye-icon"></i>
                                        </button>
                                    </div>
                                    <div class="form-hint">
                                        <i class="fa-solid fa-circle-info me-1"></i>
                                        Để trống trường này nếu bạn không muốn thay đổi mật khẩu.
                                    </div>
                                </div>
                            </div>

                            <%-- CỘT PHẢI: THÔNG TIN CÁ NHÂN --%>
                            <div class="col-lg-6 col-12 ps-lg-4 mt-4 mt-lg-0">
                                <div class="section-divider">
                                    <i class="fa-solid fa-id-card me-2"></i>Thông tin cá nhân
                                </div>

                                <%-- Họ và tên --%>
                                <div class="mb-3">
                                    <label for="fullName" class="form-label">
                                        Họ và tên <span class="required-mark">*</span>
                                    </label>
                                    <input type="text"
                                           id="fullName"
                                           name="fullName"
                                           class="form-control"
                                           placeholder="Ví dụ: Nguyễn Văn A"
                                           value="<%= editUser.getFullName() %>"
                                           required>
                                </div>

                                <%-- Vai trò --%>
                                <div class="mb-3">
                                    <label for="role" class="form-label">
                                        Vai trò <span class="required-mark">*</span>
                                    </label>
                                    <select id="role" name="role" class="form-select" required>
                                        <option value="Staff" <%= "Staff".equals(editUser.getRole()) ? "selected" : "" %>>Thủ thư (Staff)</option>
                                        <option value="Admin" <%= "Admin".equals(editUser.getRole()) ? "selected" : "" %>>Quản trị viên (Admin)</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <%-- ── FOOTER: Nút hành động ── --%>
                        <div class="d-flex align-items-center gap-3 mt-4 pt-3 border-top">
                            <button type="submit" id="btn-save" class="btn btn-save hover-lift">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu thay đổi
                            </button>
                            <a href="${pageContext.request.contextPath}/accounts"
                               id="btn-cancel"
                               class="btn btn-cancel text-decoration-none hover-lift">
                                <i class="fa-solid fa-arrow-left me-2"></i>Hủy
                            </a>
                            <span class="text-muted ms-auto" style="font-size:.78rem;">
                                <span class="required-mark">*</span> Trường bắt buộc
                            </span>
                        </div>

                    </form>
                </div>
                <%-- END Body --%>

            </div>
            <%-- END FORM CARD --%>

        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ── Đóng flash toast ──
    function closeToast() {
        const toast = document.getElementById('flash-toast');
        if (toast) {
            toast.style.transition = 'opacity .3s ease';
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 300);
        }
    }

    // ── Tự động đóng toast sau 4 giây ──
    (function () {
        const toast = document.getElementById('flash-toast');
        if (toast) {
            setTimeout(closeToast, 4000);
        }
    })();

    // ── Bật/tắt hiển thị mật khẩu ──
    const togglePasswordBtn = document.getElementById('toggle-password');
    const passwordInput = document.getElementById('input-password');
    const eyeIcon = document.getElementById('eye-icon');

    if (togglePasswordBtn && passwordInput && eyeIcon) {
        togglePasswordBtn.addEventListener('click', function() {
            if (passwordInput.type === 'password') {
                passwordInput.type = 'text';
                eyeIcon.classList.remove('fa-eye');
                eyeIcon.classList.add('fa-eye-slash');
            } else {
                passwordInput.type = 'password';
                eyeIcon.classList.remove('fa-eye-slash');
                eyeIcon.classList.add('fa-eye');
            }
        });
    }
</script>
</body>
</html>
