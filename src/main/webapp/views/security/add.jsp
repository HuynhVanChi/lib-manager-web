<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    add.jsp – Trang thêm tài khoản độc lập.
--%>
<%
    String toastMsg  = (String) request.getAttribute("toastMessage");
    String toastType = (String) request.getAttribute("toastType");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Tài khoản - LibraryOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
</head>
<body class="m-0 p-0">
<div class="d-flex">
    <jsp:include page="/views/layout/sidebar.jsp"/>
    <main class="w-100">
        <jsp:include page="/views/layout/header.jsp"/>
        <div class="container-fluid p-4">
            
            <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
            <div class="mb-4">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/accounts" class="text-decoration-none">
                                <i class="fa-solid fa-user-tie me-1"></i>Nhân sự
                            </a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">Thêm mới</li>
                    </ol>
                </nav>
                <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size: 1.5rem;">
                    Thêm tài khoản mới
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
                <span style="font-size:.875rem;font-weight:500;flex:1;">
                    <%=toastMsg%>
                </span>
                <button type="button" class="toast-close" onclick="closeToast()" aria-label="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <% } %>

            <%-- ── FORM CARD ── --%>
            <div class="form-card bg-white">
                
                <%-- Header card --%>
                <div class="form-card-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center"
                             style="width: 44px; height: 44px; background: rgba(255,255,255,0.2); flex-shrink: 0;">
                            <i class="fa-solid fa-user-plus text-white fs-5"></i>
                        </div>
                        <div>
                            <h5 class="text-white fw-bold mb-0">Thông tin tài khoản</h5>
                            <p class="text-white mb-0" style="opacity: 0.75; font-size: 0.82rem;">
                                Điền đầy đủ thông tin để tạo tài khoản mới
                            </p>
                        </div>
                    </div>
                </div>

                <%-- Body form --%>
                <div class="p-4">
                    <div style="max-width: 600px;">
                        <form action="${pageContext.request.contextPath}/accounts" method="POST">
                            <input type="hidden" name="action" value="create">
                            
                            <div class="mb-3">
                                <label class="form-label mb-1">Tên đăng nhập <span class="required-mark">*</span></label>
                                <div class="form-hint mb-1.5" style="font-size: .78rem; margin-bottom: 6px;">Dùng để đăng nhập vào hệ thống</div>
                                <input type="text" name="username" class="form-control" placeholder="Nhập tên đăng nhập" required autocomplete="off">
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label mb-1">Mật khẩu <span class="required-mark">*</span></label>
                                <div class="form-hint mb-1.5" style="font-size: .78rem; margin-bottom: 6px;">Tối thiểu 6 ký tự</div>
                                <div class="position-relative">
                                    <input type="password" name="password" id="input-password" class="form-control pe-5" placeholder="Nhập mật khẩu" required>
                                    <button type="button" class="btn position-absolute end-0 top-50 translate-middle-y border-0 bg-transparent text-muted py-0" id="toggle-password" style="z-index: 10; height: 100%;">
                                        <i class="fa-regular fa-eye" id="eye-icon"></i>
                                    </button>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label mb-1">Họ và tên <span class="required-mark">*</span></label>
                                <input type="text" name="fullName" class="form-control" placeholder="Nhập họ và tên" required>
                            </div>
                            
                            <div class="mb-4">
                                <label class="form-label mb-1">Vai trò <span class="required-mark">*</span></label>
                                <div class="form-hint mb-1.5" style="font-size: .78rem; margin-bottom: 6px;">Phân quyền truy cập vào hệ thống</div>
                                <select name="role" class="form-select" required>
                                    <option value="Staff">Thủ thư (Staff)</option>
                                    <option value="Admin">Quản trị viên (Admin)</option>
                                </select>
                            </div>
                            
                            <div class="d-flex gap-2 border-top pt-4">
                                <button type="submit" class="btn btn-save hover-lift">
                                    <i class="fa-solid fa-plus"></i> Tạo tài khoản
                                </button>
                                <a href="${pageContext.request.contextPath}/accounts" class="btn btn-cancel hover-lift">
                                    <i class="fa-solid fa-xmark"></i> Hủy
                                </a>
                            </div>
                        </form>
                    </div>
                </div>

            </div>

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
