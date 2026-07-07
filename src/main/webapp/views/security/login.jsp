<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - LibraryOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --indigo-dark:   #312E81;
            --indigo-mid:    #4338CA;
            --violet-light:  #A78BFA;
            --pink-soft:     #F9A8D4;
            --bg-soft:       #F9FAFB;
        }
        * { font-family: 'Outfit', sans-serif; box-sizing: border-box; }

        body {
            margin: 0; padding: 0; min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            background: linear-gradient(135deg, #312E81 0%, #4C1D95 55%, #701a75 100%);
            position: relative; overflow: hidden;
        }

        /* --- Blobs decoratifs --- */
        .blob {
            position: absolute; border-radius: 50%;
            filter: blur(90px); opacity: 0.4; pointer-events: none;
        }
        .blob-1 { width: 380px; height: 380px; background: #A78BFA; top: -80px; left: -80px; }
        .blob-2 { width: 300px; height: 300px; background: #F9A8D4; bottom: -60px; right: -60px; }
        .blob-3 { width: 200px; height: 200px; background: #60A5FA; top: 40%; left: 60%; }

        /* --- Card --- */
        .login-card {
            position: relative; z-index: 10;
            background: rgba(255,255,255,0.08);
            backdrop-filter: blur(22px); -webkit-backdrop-filter: blur(22px);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 24px; padding: 44px 40px;
            width: 100%; max-width: 420px;
            box-shadow: 0 25px 50px rgba(0,0,0,0.35);
            animation: slideUp .6s cubic-bezier(.16,1,.3,1) both;
        }
        @keyframes slideUp {
            from { opacity:0; transform: translateY(24px); }
            to   { opacity:1; transform: translateY(0);    }
        }

        /* --- Logo --- */
        .logo-ring {
            width: 60px; height: 60px; border-radius: 50%;
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.2);
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 1.5rem; color: #fff; margin-bottom: 14px;
        }

        /* --- Input --- */
        .field-wrap { position: relative; margin-bottom: 18px; }
        .field-icon {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: rgba(255,255,255,0.4); font-size: .9rem; pointer-events: none;
        }
        .form-input {
            width: 100%; background: rgba(255,255,255,0.08);
            border: 1px solid rgba(255,255,255,0.15); color: #fff;
            border-radius: 12px; padding: 12px 14px 12px 40px;
            font-size: .95rem; transition: border-color .25s, box-shadow .25s;
            outline: none;
        }
        .form-input:focus {
            border-color: #A78BFA;
            box-shadow: 0 0 0 3px rgba(167,139,250,0.25);
        }
        .form-input::placeholder { color: rgba(255,255,255,0.3); }

        /* --- Eye toggle --- */
        .eye-btn {
            position: absolute; right: 14px; top: 50%; transform: translateY(-50%);
            background: none; border: none; color: rgba(255,255,255,0.4);
            cursor: pointer; padding: 0; transition: color .2s;
        }
        .eye-btn:hover { color: #fff; }

        /* --- Submit button --- */
        .btn-login {
            width: 100%; padding: 13px;
            background: linear-gradient(135deg, #A78BFA 0%, #F9A8D4 100%);
            border: none; border-radius: 12px;
            font-weight: 600; font-size: 1rem; color: #fff;
            cursor: pointer; transition: all .25s ease;
            box-shadow: 0 4px 15px rgba(167,139,250,0.4);
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(167,139,250,0.5);
        }

        /* --- Error alert --- */
        .alert-glass {
            background: rgba(239,68,68,0.15);
            border: 1px solid rgba(239,68,68,0.3);
            color: #fca5a5; border-radius: 10px;
            padding: 10px 14px; font-size: .875rem;
            margin-bottom: 20px; display: flex; align-items: center; gap: 8px;
        }
    </style>
</head>
<body>
    <div class="blob blob-1"></div>
    <div class="blob blob-2"></div>
    <div class="blob blob-3"></div>

    <div class="login-card">
        <!-- Logo -->
        <div class="text-center">
            <div class="logo-ring mx-auto">
                <i class="fa-solid fa-book-open-reader"></i>
            </div>
            <h3 class="fw-bold text-white mb-1" style="letter-spacing:.4px;">LibraryOS</h3>
            <p class="mb-4" style="color:rgba(255,255,255,0.4); font-size:.875rem;">
                Hệ thống Quản lý Thư viện thông minh
            </p>
        </div>

        <!-- Error message -->
        <% String err = (String) request.getAttribute("loginError"); %>
        <% if (err != null) { %>
        <div class="alert-glass">
            <i class="fa-solid fa-circle-exclamation"></i> <%=err%>
        </div>
        <% } %>

        <!-- Form -->
        <form action="${pageContext.request.contextPath}/login" method="POST">
            <div class="field-wrap">
                <i class="fa-solid fa-user field-icon"></i>
                <input type="text" name="username" class="form-input"
                       placeholder="Tên đăng nhập" required autofocus>
            </div>

            <div class="field-wrap mb-4">
                <i class="fa-solid fa-lock field-icon"></i>
                <input type="password" id="pw" name="password" class="form-input"
                       placeholder="Mật khẩu" required>
                <button type="button" class="eye-btn" id="eyeBtn" aria-label="Hiện/ẩn mật khẩu">
                    <i class="fa-solid fa-eye-slash" id="eyeIcon"></i>
                </button>
            </div>

            <button type="submit" class="btn-login" id="btn-login">
                Đăng nhập &nbsp;<i class="fa-solid fa-arrow-right-to-bracket"></i>
            </button>
        </form>
    </div>

    <script>
        document.getElementById('eyeBtn').addEventListener('click', function () {
            var pw   = document.getElementById('pw');
            var icon = document.getElementById('eyeIcon');
            if (pw.type === 'password') {
                pw.type = 'text';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            } else {
                pw.type = 'password';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            }
        });
    </script>
</body>
</html>
