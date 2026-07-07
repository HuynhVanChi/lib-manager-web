<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    add.jsp – Trang thêm tài khoản độc lập (dự phòng nếu cần trang riêng).
    Hiện tại, chức năng Thêm đã được tích hợp vào Modal trong index.jsp.
    File này được giữ lại theo cấu trúc dự án.
--%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm Tài khoản - LibraryOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --indigo: #312E81; --violet: #A78BFA; --pink: #F9A8D4; }
        * { font-family: 'Outfit', sans-serif; }
        body { background: #F9FAFB; }
        .form-card {
            background: #fff; border-radius: 16px;
            box-shadow: 0 4px 24px rgba(49,46,129,.08);
            border: 1px solid #EEF2FF; padding: 36px;
        }
        .form-label { font-size: .82rem; font-weight: 600; color: #6B7280; }
        .form-control, .form-select {
            border-radius: 10px; border: 1px solid #DDE3F4;
            background: #F5F7FF; transition: all .2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--violet);
            box-shadow: 0 0 0 3px rgba(167,139,250,.18);
            background: #fff;
        }
        .btn-submit {
            background: linear-gradient(135deg, var(--violet) 0%, var(--pink) 100%);
            border: none; color: #fff; border-radius: 10px; font-weight: 600;
            padding: 10px 28px;
            box-shadow: 0 4px 12px rgba(167,139,250,.4); transition: all .25s;
        }
        .btn-submit:hover { transform: translateY(-2px); color:#fff; box-shadow: 0 8px 20px rgba(167,139,250,.5); }
        .btn-cancel {
            border: 1.5px solid var(--violet); color: var(--violet);
            border-radius: 10px; padding: 9px 24px; font-weight: 500;
            background: transparent; transition: all .2s;
        }
        .btn-cancel:hover { background: var(--violet); color: #fff; }
    </style>
</head>
<body>
<div class="d-flex">
    <jsp:include page="/views/layout/sidebar.jsp"/>
    <main class="w-100">
        <jsp:include page="/views/layout/header.jsp"/>
        <div class="container-fluid p-4">
            <div class="row justify-content-center">
                <div class="col-12 col-md-8 col-lg-6">
                    <div class="d-flex align-items-center mb-4 gap-3">
                        <a href="${pageContext.request.contextPath}/accounts"
                           class="btn btn-sm" style="background:#EDE9FE;color:#6D28D9;border-radius:8px;">
                            <i class="fa-solid fa-chevron-left me-1"></i>Quay lại
                        </a>
                        <h2 class="fw-bold m-0" style="color:#312E81;">Thêm tài khoản mới</h2>
                    </div>

                    <div class="form-card">
                        <form action="${pageContext.request.contextPath}/accounts" method="POST">
                            <input type="hidden" name="action" value="create">
                            <div class="mb-3">
                                <label class="form-label">Tên đăng nhập <span class="text-danger">*</span></label>
                                <input type="text" name="username" class="form-control"
                                       placeholder="Nhập tên đăng nhập" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mật khẩu <span class="text-danger">*</span></label>
                                <input type="password" name="password" class="form-control"
                                       placeholder="Nhập mật khẩu" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Họ và tên <span class="text-danger">*</span></label>
                                <input type="text" name="fullName" class="form-control"
                                       placeholder="Nhập họ và tên đầy đủ" required>
                            </div>
                            <div class="mb-4">
                                <label class="form-label">Vai trò <span class="text-danger">*</span></label>
                                <select name="role" class="form-select" required>
                                    <option value="Staff">Thủ thư (Staff)</option>
                                    <option value="Admin">Quản trị viên (Admin)</option>
                                </select>
                            </div>
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-submit">
                                    <i class="fa-solid fa-plus me-1"></i>Tạo tài khoản
                                </button>
                                <a href="${pageContext.request.contextPath}/accounts" class="btn btn-cancel">
                                    Hủy
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
</body>
</html>
