<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chi tiết độc giả - LibraryOS">
    <title>Chi tiết Độc giả - LibraryOS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <style>
        :root {
            --primary:       #312E81;
            --primary-light: #4338CA;
            --primary-soft:  #EEF2FF;
            --secondary:     #A78BFA;
            --bg-page:       #F9FAFB;
            --text-dark:     #111827;
            --text-muted:    #6B7280;
            --border:        #E5E7EB;
            --radius:        10px;
        }

        body { background-color: var(--bg-page); font-family: 'Inter', sans-serif; }

        /* ── Override Bootstrap primary ── */
        .btn-primary  { background-color: var(--primary); border-color: var(--primary); }
        .btn-primary:hover { background-color: var(--primary-light); border-color: var(--primary-light); }
        .text-primary { color: var(--primary) !important; }
        .bg-primary   { background-color: var(--primary) !important; }

        /* ── Breadcrumb ── */
        .breadcrumb { font-size: .82rem; margin: 0; }
        .breadcrumb-item a { color: var(--text-muted); text-decoration: none; }
        .breadcrumb-item a:hover { color: var(--primary); }
        .breadcrumb-item.active { color: var(--primary); font-weight: 600; }
        .breadcrumb-item + .breadcrumb-item::before { color: var(--text-muted); }

        /* ── Card chung ── */
        .detail-card {
            border: none;
            border-radius: var(--radius);
            box-shadow: 0 1px 4px rgba(0,0,0,.07), 0 4px 16px rgba(0,0,0,.05);
            margin-bottom: 20px;
        }
        .detail-card-header {
            padding: 16px 20px;
            border-bottom: 1px solid var(--border);
            font-size: .8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .7px;
            color: var(--text-muted);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* ── Hero banner độc giả ── */
        .reader-hero {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: var(--radius);
            padding: 28px 28px 24px;
            margin-bottom: 20px;
            position: relative;
            overflow: hidden;
        }
        .reader-hero::after {
            content: '';
            position: absolute;
            right: -30px; top: -30px;
            width: 180px; height: 180px;
            border-radius: 50%;
            background: rgba(255,255,255,.06);
        }
        .reader-hero::before {
            content: '';
            position: absolute;
            right: 60px; bottom: -50px;
            width: 120px; height: 120px;
            border-radius: 50%;
            background: rgba(255,255,255,.04);
        }
        .reader-avatar {
            width: 64px; height: 64px;
            border-radius: 50%;
            background: rgba(255,255,255,.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.6rem;
            color: #fff;
            flex-shrink: 0;
            border: 2px solid rgba(255,255,255,.3);
        }
        .reader-hero-name {
            font-size: 1.35rem;
            font-weight: 700;
            color: #fff;
            margin: 0;
            line-height: 1.3;
        }
        .reader-hero-email { color: rgba(255,255,255,.75); font-size: .85rem; margin-top: 3px; }

        /* ── Badges trạng thái ── */
        .badge-status {
            font-size: .72rem; font-weight: 600;
            padding: 4px 12px; border-radius: 20px; letter-spacing: .3px;
        }
        .badge-active    { background: rgba(255,255,255,.2); color: #fff; border: 1px solid rgba(255,255,255,.3); }
        .badge-suspended { background: #FEF9C3; color: #854D0E; }
        .badge-expired   { background: #F3F4F6; color: #4B5563; }

        /* ── Info pills bên trong hero ── */
        .hero-pill {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,.12);
            border-radius: 20px; padding: 4px 12px;
            font-size: .78rem; color: rgba(255,255,255,.85);
        }
        .hero-pill i { font-size: .7rem; }

        /* ── Stat cards ── */
        .stat-card {
            border: none;
            border-radius: var(--radius);
            padding: 18px 20px;
            display: flex; flex-direction: column;
            gap: 6px;
            box-shadow: 0 1px 4px rgba(0,0,0,.07), 0 4px 12px rgba(0,0,0,.04);
            transition: transform .15s ease, box-shadow .15s ease;
        }
        .stat-card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,.1); }
        .stat-card .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            line-height: 1;
        }
        .stat-card .stat-label {
            font-size: .75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .5px;
            opacity: .75;
        }
        .stat-card .stat-icon {
            width: 36px; height: 36px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: .95rem;
            margin-bottom: 4px;
        }

        .stat-total    { background: var(--primary-soft); color: var(--primary); }
        .stat-total    .stat-icon { background: rgba(49,46,129,.12); color: var(--primary); }

        .stat-active   { background: #F0FDF4; color: #15803D; }
        .stat-active   .stat-icon { background: rgba(21,128,61,.12); color: #15803D; }

        .stat-overdue  { background: #FEF2F2; color: #DC2626; }
        .stat-overdue  .stat-icon { background: rgba(220,38,38,.12); color: #DC2626; }

        .stat-fines    { background: #FFFBEB; color: #92400E; }
        .stat-fines    .stat-icon { background: rgba(146,64,14,.12); color: #92400E; }

        /* ── Info grid trong card thông tin ── */
        .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0; }
        .info-row {
            display: flex; flex-direction: column;
            padding: 14px 20px;
            border-bottom: 1px solid var(--border);
            border-right: 1px solid var(--border);
        }
        .info-row:nth-child(even)  { border-right: none; }
        .info-row:nth-last-child(-n+2) { border-bottom: none; }
        .info-label {
            font-size: .72rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .5px;
            color: var(--text-muted); margin-bottom: 4px;
        }
        .info-value { font-size: .9rem; font-weight: 500; color: var(--text-dark); }
        .info-value.empty { color: var(--text-muted); font-style: italic; font-weight: 400; }

        /* ── Bảng lịch sử mượn ── */
        .history-table { border-collapse: separate; border-spacing: 0; width: 100%; }
        .history-table thead th {
            background-color: var(--primary-soft);
            color: var(--primary);
            font-weight: 600;
            font-size: .78rem;
            text-transform: uppercase;
            letter-spacing: .5px;
            padding: 11px 16px;
            border: none;
            white-space: nowrap;
        }
        .history-table thead th:first-child { border-radius: 8px 0 0 8px; }
        .history-table thead th:last-child  { border-radius: 0 8px 8px 0; }
        .history-table tbody tr {
            border-bottom: 1px solid var(--border);
            transition: background-color .12s;
        }
        .history-table tbody tr:last-child { border-bottom: none; }
        .history-table tbody tr:hover { background-color: #F5F3FF; }
        .history-table tbody td {
            padding: 12px 16px;
            font-size: .85rem;
            color: var(--text-dark);
            vertical-align: middle;
        }

        /* ── Badge trạng thái mượn ── */
        .borrow-badge {
            font-size: .7rem; font-weight: 600;
            padding: 3px 9px; border-radius: 20px;
        }
        .borrow-borrowing { background: #DBEAFE; color: #1D4ED8; }
        .borrow-returned  { background: #DCFCE7; color: #15803D; }
        .borrow-overdue   { background: #FEE2E2; color: #DC2626; }
        .borrow-lost      { background: #F3F4F6; color: #4B5563; }

        /* ── Empty state ── */
        .empty-state {
            padding: 48px 20px; text-align: center; color: var(--text-muted);
        }
        .empty-state .icon { font-size: 2.5rem; margin-bottom: 12px; opacity: .3; }

        /* ── Action buttons ── */
        .btn-edit {
            background-color: var(--primary); border-color: var(--primary);
            color: #fff; border-radius: 8px;
            padding: 9px 22px; font-weight: 600; font-size: .875rem;
            transition: all .2s; text-decoration: none;
            display: inline-flex; align-items: center; gap: 7px;
        }
        .btn-edit:hover {
            background-color: var(--primary-light); color: #fff;
            box-shadow: 0 4px 12px rgba(49,46,129,.3); transform: translateY(-1px);
        }
        .btn-back {
            border: 1.5px solid var(--border); border-radius: 8px;
            padding: 9px 20px; font-size: .875rem;
            color: var(--text-dark); background: #fff;
            transition: all .2s; text-decoration: none;
            display: inline-flex; align-items: center; gap: 7px;
        }
        .btn-back:hover { background: var(--bg-page); border-color: #9CA3AF; color: var(--text-dark); }

        /* ── Overdue date highlight ── */
        .date-overdue { color: #DC2626; font-weight: 600; }
    </style>
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
                                <a href="${pageContext.request.contextPath}/readers">
                                    <i class="fa-solid fa-users me-1"></i>Độc giả
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">Chi tiết</li>
                        </ol>
                    </nav>
                    <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                        Hồ sơ độc giả
                    </h1>
                </div>
                <%-- Nút hành động góc phải --%>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/readers/edit?id=${reader.readerId}"
                       id="btn-edit-reader"
                       class="btn-edit">
                        <i class="fa-solid fa-user-pen"></i> Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/readers"
                       id="btn-back"
                       class="btn-back">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- HERO BANNER — Thông tin nhanh độc giả   --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="reader-hero">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="reader-avatar">
                        <i class="fa-solid fa-user"></i>
                    </div>
                    <div>
                        <h2 class="reader-hero-name">
                            <c:out value="${reader.fullName}"/>
                        </h2>
                        <div class="reader-hero-email">
                            <i class="fa-solid fa-envelope me-1" style="font-size:.75rem;"></i>
                            <c:out value="${reader.email}"/>
                        </div>
                    </div>
                    <%-- Badge trạng thái --%>
                    <div class="ms-auto">
                        <c:choose>
                            <c:when test="${reader.status == 'Active'}">
                                <span class="badge-status badge-active">
                                    <i class="fa-solid fa-circle-check me-1" style="font-size:.65rem;"></i>Hoạt động
                                </span>
                            </c:when>
                            <c:when test="${reader.status == 'Suspended'}">
                                <span class="badge-status badge-suspended">
                                    <i class="fa-solid fa-circle-pause me-1" style="font-size:.65rem;"></i>Đình chỉ
                                </span>
                            </c:when>
                            <c:when test="${reader.status == 'Expired'}">
                                <span class="badge-status badge-expired">
                                    <i class="fa-solid fa-clock me-1" style="font-size:.65rem;"></i>Hết hạn
                                </span>
                            </c:when>
                        </c:choose>
                    </div>
                </div>

                <%-- Thông tin nhanh dạng pill --%>
                <div class="d-flex gap-2 flex-wrap">
                    <span class="hero-pill">
                        <i class="fa-solid fa-hashtag"></i> ID: ${reader.readerId}
                    </span>
                    <c:if test="${not empty reader.phone}">
                        <span class="hero-pill">
                            <i class="fa-solid fa-phone"></i>
                            <c:out value="${reader.phone}"/>
                        </span>
                    </c:if>
                    <c:if test="${reader.membershipExpiredAt != null}">
                        <span class="hero-pill">
                            <i class="fa-solid fa-id-card"></i>
                            Hạn thẻ: <fmt:formatDate value="${reader.membershipExpiredAt}" pattern="dd/MM/yyyy"/>
                        </span>
                    </c:if>
                    <span class="hero-pill">
                        <i class="fa-regular fa-calendar-plus"></i>
                        Tạo: <fmt:formatDate value="${reader.createdAt}" pattern="dd/MM/yyyy"/>
                    </span>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- 4 STAT CARDS — Thống kê nhanh           --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="row g-3 mb-4">
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-total h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Tổng lần mượn</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-book-open"></i></div>
                        </div>
                        <div class="stat-value">${stats.totalBorrows}</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-active h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Đang mượn</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-book-bookmark"></i></div>
                        </div>
                        <div class="stat-value">${stats.activeBorrows}</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-overdue h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Quá hạn</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-triangle-exclamation"></i></div>
                        </div>
                        <div class="stat-value">${stats.overdueBorrows}</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-fines h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Phí phạt chưa trả</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-coins"></i></div>
                        </div>
                        <div class="stat-value">
                            <fmt:formatNumber value="${stats.unpaidFines}" type="number" maxFractionDigits="0"/>đ
                        </div>
                    </div>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- CARD THÔNG TIN CHI TIẾT                 --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="detail-card bg-white">
                <div class="detail-card-header">
                    <i class="fa-solid fa-id-card text-primary"></i>
                    Thông tin chi tiết
                </div>
                <div class="info-grid">
                    <div class="info-row">
                        <span class="info-label">Họ và tên</span>
                        <span class="info-value"><c:out value="${reader.fullName}"/></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Email</span>
                        <span class="info-value"><c:out value="${reader.email}"/></span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Số điện thoại</span>
                        <span class="info-value ${empty reader.phone ? 'empty' : ''}">
                            <c:choose>
                                <c:when test="${not empty reader.phone}"><c:out value="${reader.phone}"/></c:when>
                                <c:otherwise>Chưa cập nhật</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Trạng thái</span>
                        <span class="info-value">
                            <c:choose>
                                <c:when test="${reader.status == 'Active'}">Đang hoạt động</c:when>
                                <c:when test="${reader.status == 'Suspended'}">Bị đình chỉ</c:when>
                                <c:when test="${reader.status == 'Expired'}">Hết hạn thẻ</c:when>
                                <c:otherwise><c:out value="${reader.status}"/></c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Hạn thẻ thành viên</span>
                        <span class="info-value ${reader.membershipExpiredAt == null ? 'empty' : ''}">
                            <c:choose>
                                <c:when test="${reader.membershipExpiredAt != null}">
                                    <fmt:formatDate value="${reader.membershipExpiredAt}" pattern="dd/MM/yyyy"/>
                                </c:when>
                                <c:otherwise>Không giới hạn</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Ngày đăng ký</span>
                        <span class="info-value">
                            <fmt:formatDate value="${reader.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Cập nhật lần cuối</span>
                        <span class="info-value">
                            <fmt:formatDate value="${reader.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                    <div class="info-row">
                        <span class="info-label">Mã độc giả</span>
                        <span class="info-value">#${reader.readerId}</span>
                    </div>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- CARD LỊCH SỬ MƯỢN SÁCH                 --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="detail-card bg-white">
                <div class="detail-card-header">
                    <i class="fa-solid fa-clock-rotate-left text-primary"></i>
                    Lịch sử mượn sách
                    <c:if test="${not empty borrowHistory}">
                        <span class="ms-auto fw-normal text-muted" style="font-size:.78rem;text-transform:none;letter-spacing:0;">
                            ${borrowHistory.size()} lượt mượn
                        </span>
                    </c:if>
                </div>

                <div class="p-3">
                    <c:choose>
                        <c:when test="${not empty borrowHistory}">
                            <div class="table-responsive">
                                <table class="history-table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Tên sách</th>
                                            <th>Mã vạch</th>
                                            <th>Ngày mượn</th>
                                            <th>Hạn trả</th>
                                            <th>Ngày trả</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="h" items="${borrowHistory}" varStatus="loop">
                                            <tr>
                                                <td class="text-muted fw-medium">${loop.index + 1}</td>
                                                <td>
                                                    <span class="fw-semibold" style="font-size:.875rem;">
                                                        <c:out value="${h.bookTitle}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span style="font-family:monospace;font-size:.82rem;background:#F3F4F6;
                                                                 padding:2px 7px;border-radius:4px;">
                                                        <c:out value="${h.barcode}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${h.borrowDate}" pattern="dd/MM/yyyy"/>
                                                </td>
                                                <td>
                                                    <%-- Tô đỏ hạn trả nếu trạng thái là Overdue --%>
                                                    <span class="${h.borrowStatus == 'Overdue' ? 'date-overdue' : ''}">
                                                        <fmt:formatDate value="${h.dueDate}" pattern="dd/MM/yyyy"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${h.returnDate != null}">
                                                            <fmt:formatDate value="${h.returnDate}" pattern="dd/MM/yyyy"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">—</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${h.borrowStatus == 'Borrowing'}">
                                                            <span class="borrow-badge borrow-borrowing">
                                                                <i class="fa-solid fa-book-open me-1" style="font-size:.6rem;"></i>Đang mượn
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${h.borrowStatus == 'Returned'}">
                                                            <span class="borrow-badge borrow-returned">
                                                                <i class="fa-solid fa-check me-1" style="font-size:.6rem;"></i>Đã trả
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${h.borrowStatus == 'Overdue'}">
                                                            <span class="borrow-badge borrow-overdue">
                                                                <i class="fa-solid fa-triangle-exclamation me-1" style="font-size:.6rem;"></i>Quá hạn
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${h.borrowStatus == 'Lost'}">
                                                            <span class="borrow-badge borrow-lost">
                                                                <i class="fa-solid fa-circle-xmark me-1" style="font-size:.6rem;"></i>Báo mất
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="borrow-badge borrow-lost">
                                                                <c:out value="${h.borrowStatus}"/>
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <div class="icon"><i class="fa-solid fa-book-open"></i></div>
                                <p class="fw-semibold mb-1" style="font-size:.9rem;color:var(--text-dark);">
                                    Chưa có lịch sử mượn sách
                                </p>
                                <p style="font-size:.82rem;">Độc giả này chưa thực hiện lần mượn sách nào.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            <%-- END HISTORY CARD --%>

        </div>
    </main>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
