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

    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <style>
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
                       class="btn-edit hover-lift">
                        <i class="fa-solid fa-user-pen"></i> Chỉnh sửa
                    </a>
                    <a href="${pageContext.request.contextPath}/readers"
                       id="btn-back"
                       class="btn-back hover-lift">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- HERO BANNER — Thông tin nhanh độc giả   --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="details-hero">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="details-avatar">
                        <i class="fa-solid fa-user"></i>
                    </div>
                    <div>
                        <h2 class="details-hero-name">
                            <c:out value="${reader.fullName}"/>
                        </h2>
                        <div class="details-hero-email">
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
                    <span class="details-hero-pill">
                        <i class="fa-solid fa-hashtag"></i> ID: ${reader.readerId}
                    </span>
                    <c:if test="${not empty reader.phone}">
                        <span class="details-hero-pill">
                            <i class="fa-solid fa-phone"></i>
                            <c:out value="${reader.phone}"/>
                        </span>
                    </c:if>
                    <c:if test="${reader.membershipExpiredAt != null}">
                        <span class="details-hero-pill">
                            <i class="fa-solid fa-id-card"></i>
                            Hạn thẻ: <fmt:formatDate value="${reader.membershipExpiredAt}" pattern="dd/MM/yyyy"/>
                        </span>
                    </c:if>
                    <span class="details-hero-pill">
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
                    <div class="stat-card stat-primary h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Tổng lần mượn</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-book-open"></i></div>
                        </div>
                        <div class="stat-value">${stats.totalBorrows}</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-success h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Đang mượn</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-book-bookmark"></i></div>
                        </div>
                        <div class="stat-value">${stats.activeBorrows}</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-danger h-100">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">Quá hạn</span>
                            <div class="stat-icon m-0"><i class="fa-solid fa-triangle-exclamation"></i></div>
                        </div>
                        <div class="stat-value">${stats.overdueBorrows}</div>
                    </div>
                </div>
                <div class="col-6 col-lg-3">
                    <div class="stat-card stat-warning h-100">
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
                                <table class="table-custom">
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
                                                            <span class="badge-status badge-info-custom">
                                                                <i class="fa-solid fa-book-open me-1" style="font-size:.6rem;"></i>Đang mượn
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${h.borrowStatus == 'Returned'}">
                                                            <span class="badge-status badge-active">
                                                                <i class="fa-solid fa-check me-1" style="font-size:.6rem;"></i>Đã trả
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${h.borrowStatus == 'Overdue'}">
                                                            <span class="badge-status badge-danger-custom">
                                                                <i class="fa-solid fa-triangle-exclamation me-1" style="font-size:.6rem;"></i>Quá hạn
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${h.borrowStatus == 'Lost'}">
                                                            <span class="badge-status badge-expired">
                                                                <i class="fa-solid fa-circle-xmark me-1" style="font-size:.6rem;"></i>Báo mất
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-status badge-expired">
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
