<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Từ chối truy cập - LibraryOS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Outfit', sans-serif; }
        body {
            background: #F9FAFB; height: 100vh;
            display: flex; align-items: center; justify-content: center; margin: 0;
        }
        .card-denied {
            max-width: 460px; width: 100%;
            background: #fff; border-radius: 20px; padding: 44px 40px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(49,46,129,.1);
            border: 1px solid #EEF2FF;
        }
        .shield-box {
            width: 80px; height: 80px; border-radius: 50%;
            background: linear-gradient(135deg, #EDE9FE, #FCE7F3);
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 2rem; color: #7C3AED; margin-bottom: 20px;
            animation: pulse 2.2s ease-in-out infinite;
        }
        @keyframes pulse {
            0%,100% { transform: scale(1);    box-shadow: 0 0 0 0 rgba(167,139,250,.4); }
            50%      { transform: scale(1.06); box-shadow: 0 0 0 12px rgba(167,139,250,0); }
        }
        .btn-back {
            background: linear-gradient(135deg, #312E81 0%, #4338CA 100%);
            color: #fff; border: none; border-radius: 10px;
            padding: 10px 24px; font-weight: 600; transition: all .25s;
            text-decoration: none; display: inline-block;
        }
        .btn-back:hover {
            transform: translateY(-2px); color: #fff;
            box-shadow: 0 6px 16px rgba(49,46,129,.35);
        }
        .code-403 { font-size: 5rem; font-weight: 700; color: #EDE9FE; line-height: 1; }
    </style>
</head>
<body>
    <div class="card-denied">
        <div class="code-403">403</div>
        <div class="shield-box mt-2">
            <i class="fa-solid fa-shield-halved"></i>
        </div>
        <h4 class="fw-bold mb-2" style="color:#1E1B4B;">Quyền truy cập bị từ chối</h4>
        <p class="text-muted mb-4" style="font-size:.9rem; line-height:1.6;">
            <%= request.getAttribute("errorMessage") != null
                ? request.getAttribute("errorMessage")
                : "Bạn không có quyền truy cập vào trang này." %>
        </p>
        <a href="${pageContext.request.contextPath}/dashboard" class="btn-back" id="btn-quay-lai">
            <i class="fa-solid fa-chevron-left me-1"></i> Quay lại Dashboard
        </a>
    </div>
</body>
</html>
