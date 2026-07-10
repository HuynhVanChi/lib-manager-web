<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chi tiết đề xuất sách - LibraryOS">
    <title>Chi tiết Đề xuất Sách - LibraryOS</title>

    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
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
                                <a href="${pageContext.request.contextPath}/recommend">
                                    <i class="fa-solid fa-lightbulb me-1"></i>Đề xuất sách
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <c:out value="${recommendation.bookTitle}"/>
                            </li>
                        </ol>
                    </nav>
                    <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                        Chi tiết Đề xuất Sách
                    </h1>
                </div>
                <div class="d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/recommend"
                       id="btn-back"
                       class="btn btn-back hover-lift text-decoration-none">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại danh sách
                    </a>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- HERO BANNER — Thông tin nhanh đề xuất   --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="details-hero">
                <div class="d-flex align-items-center gap-3 mb-3">
                    <div class="details-avatar" style="background: rgba(49, 46, 129, 0.1); color: var(--primary);">
                        <i class="fa-solid fa-book-open"></i>
                    </div>
                    <div>
                        <h2 class="details-hero-name">
                            <c:out value="${recommendation.bookTitle}"/>
                        </h2>
                        <div class="details-hero-email">
                            <i class="fa-solid fa-feather-pointed me-1" style="font-size:.75rem;"></i>
                            Tác giả: <c:out value="${recommendation.author}"/>
                        </div>
                    </div>
                    <%-- Badge trạng thái --%>
                    <div class="ms-auto">
                        <c:choose>
                            <c:when test="${recommendation.status == 'Pending'}">
                                <span class="badge-status badge-suspended">Chờ xử lý</span>
                            </c:when>
                            <c:when test="${recommendation.status == 'Approved'}">
                                <span class="badge-status badge-active">Đã duyệt</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-status badge-danger-custom">Từ chối</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <%-- Thông tin nhanh dạng pill --%>
                <div class="d-flex gap-2 flex-wrap">
                    <span class="details-hero-pill">
                        <i class="fa-solid fa-hashtag"></i> ID Đề xuất: ${recommendation.recommendationId}
                    </span>
                    <span class="details-hero-pill">
                        <i class="fa-solid fa-user"></i> Độc giả: <c:out value="${recommendation.readerName}"/>
                    </span>
                    <span class="details-hero-pill">
                        <i class="fa-regular fa-calendar-plus"></i>
                        Ngày tạo: <fmt:formatDate value="${recommendation.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </span>
                </div>
            </div>

            <%-- ════════════════════════════════════════ --%>
            <%-- CHI TIẾT & THAO TÁC                     --%>
            <%-- ════════════════════════════════════════ --%>
            <div class="row g-4">

                <%-- CỘT 1: THÔNG TIN CHI TIẾT ĐỀ XUẤT (Metadata Grid Layout) --%>
                <div class="col-12 col-lg-8">
                    <div class="card detail-card bg-white h-100">
                        <div class="detail-card-header">
                            <i class="fa-solid fa-circle-info text-primary"></i>
                            <span>Thông tin đề xuất chi tiết</span>
                        </div>
                        <div class="info-grid">
                            <div class="info-row">
                                <span class="info-label">Họ và tên độc giả</span>
                                <span class="info-value"><c:out value="${recommendation.readerName}"/></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Số điện thoại độc giả</span>
                                <span class="info-value ${empty recommendation.readerPhone ? 'empty' : ''}">
                                    <c:choose>
                                        <c:when test="${not empty recommendation.readerPhone}"><c:out value="${recommendation.readerPhone}"/></c:when>
                                        <c:otherwise>Chưa cập nhật</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">ID Độc giả</span>
                                <span class="info-value ${empty recommendation.readerCode ? 'empty' : ''}">
                                    <c:choose>
                                        <c:when test="${not empty recommendation.readerCode}">#<c:out value="${recommendation.readerCode}"/></c:when>
                                        <c:otherwise>Không có</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Tên sách đề xuất</span>
                                <span class="info-value"><c:out value="${recommendation.bookTitle}"/></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Tác giả sách</span>
                                <span class="info-value"><c:out value="${recommendation.author}"/></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Cán bộ ghi nhận</span>
                                <span class="info-value"><c:out value="${recommendation.creatorName}"/> <span class="text-muted small">(ID: NV#${recommendation.createdBy})</span></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Ngày ghi nhận</span>
                                <span class="info-value"><fmt:formatDate value="${recommendation.createdAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                            </div>
                            <div class="info-row">
                                <span class="info-label">Lý do từ độc giả</span>
                                <span class="info-value ${empty recommendation.reason ? 'empty' : ''}">
                                    <c:choose>
                                        <c:when test="${not empty recommendation.reason}"><c:out value="${recommendation.reason}"/></c:when>
                                        <c:otherwise>Không ghi nhận lý do</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- CỘT 2: THAO TÁC XỬ LÝ ĐỀ XUẤT --%>
                <div class="col-12 col-lg-4">
                    <div class="card detail-card bg-white mb-4">
                        <div class="detail-card-header">
                            <i class="fa-solid fa-gavel text-primary"></i>
                            <span>Thao tác xử lý</span>
                        </div>
                        <div class="p-3">
                            <c:choose>
                                <c:when test="${recommendation.status == 'Pending'}">
                                    <p class="text-muted small mb-3">
                                        Đề xuất sách này đang chờ duyệt. Bạn có thể chỉnh sửa, xóa đề xuất hoặc thực hiện duyệt trực tiếp (Admin).
                                    </p>

                                    <%-- Nút Sửa & Xóa --%>
                                    <div class="d-flex gap-2 mb-3">
                                        <a href="${pageContext.request.contextPath}/recommend/edit?id=${recommendation.recommendationId}&from=detail" 
                                           class="btn btn-edit hover-lift w-50 py-2 text-center text-decoration-none" style="font-size: .85rem;">
                                            <i class="fa-regular fa-pen-to-square me-1"></i>Chỉnh sửa
                                        </a>
                                        <button type="button" 
                                                class="btn btn-danger hover-lift w-50 py-2" style="font-size: .85rem;"
                                                onclick="openDeleteModal(${recommendation.recommendationId}, '<c:out value="${recommendation.bookTitle}" escapeXml="true"/>')">
                                            <i class="fa-regular fa-trash-can me-1"></i>Xóa
                                        </button>
                                    </div>

                                    <%-- Panel Duyệt/Từ chối dành riêng cho Admin --%>
                                    <c:if test="${sessionScope.role == 'Admin'}">
                                        <div class="border-top pt-3 mt-3">
                                            <h6 class="fw-bold text-dark mb-3 small"><i class="fa-solid fa-user-shield me-1"></i>Quyền phê duyệt (Admin)</h6>
                                            <div class="d-flex gap-2">
                                                <form action="${pageContext.request.contextPath}/recommend/approve" method="POST" class="w-50">
                                                    <input type="hidden" name="id" value="${recommendation.recommendationId}">
                                                    <button type="submit" class="btn btn-save hover-lift w-100 py-2.5 fw-medium text-white" style="background-color: var(--success) !important; border-color: var(--success) !important; font-size: .85rem;">
                                                        <i class="fa-solid fa-check me-1"></i>Duyệt mua
                                                    </button>
                                                </form>
                                                <form action="${pageContext.request.contextPath}/recommend/reject" method="POST" class="w-50" onsubmit="return confirm('Bạn có chắc chắn muốn từ chối đề xuất này?');">
                                                    <input type="hidden" name="id" value="${recommendation.recommendationId}">
                                                    <button type="submit" class="btn btn-danger hover-lift w-100 py-2.5 fw-medium text-white" style="font-size: .85rem;">
                                                        <i class="fa-solid fa-xmark me-1"></i>Từ chối
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </c:if>
                                </c:when>

                                <c:when test="${recommendation.status == 'Approved'}">
                                    <div class="text-center py-4">
                                        <div class="rounded-circle bg-success bg-opacity-10 text-success d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 56px; height: 56px;">
                                            <i class="fa-solid fa-circle-check fs-3"></i>
                                        </div>
                                        <h6 class="fw-bold text-success mb-1">Đã phê duyệt đề xuất</h6>
                                        <p class="text-muted small mb-0">Ấn phẩm này đã được duyệt mua và đưa vào kế hoạch nhập kho thư viện.</p>
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <div class="text-center py-4">
                                        <div class="rounded-circle bg-danger bg-opacity-10 text-danger d-flex align-items-center justify-content-center mx-auto mb-3" style="width: 56px; height: 56px;">
                                            <i class="fa-solid fa-circle-xmark fs-3"></i>
                                        </div>
                                        <h6 class="fw-bold text-danger mb-1">Đề xuất bị từ chối</h6>
                                        <p class="text-muted small mb-0">Yêu cầu đề xuất sách này đã bị từ chối phê duyệt mua bổ sung.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

            </div>
            <%-- END row --%>

        </div>
    </main>

</div>

<%-- MODAL XÁC NHẬN XÓA --%>
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow rounded-3">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-danger bg-opacity-10 text-danger rounded-circle d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="deleteModalLabel">Xác nhận xóa</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <p class="mb-1" style="font-size: .9rem;">Bạn có chắc chắn muốn xóa đề xuất sách?</p>
                <p class="fw-bold mb-3 text-primary" id="delete-recommendation-title" style="font-size: 1rem;">—</p>
                <div class="rounded-3 p-3" style="background: #FEF2F2; border: 1px solid #FECACA; font-size: .82rem; color: #991B1B;">
                    <i class="fa-solid fa-circle-info me-1"></i> Hành động này không thể hoàn tác.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                <form id="delete-form" method="post" action="" class="m-0">
                    <button type="submit" class="btn btn-danger hover-lift">
                        <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<%-- FLASH TOAST --%>
<c:if test="${not empty flashMessage}">
    <div class="flash-toast ${flashType}" id="flash-toast" role="alert">
        <span class="toast-icon">
            <c:choose>
                <c:when test="${flashType == 'success'}"><i class="fa-solid fa-circle-check"></i></c:when>
                <c:otherwise><i class="fa-solid fa-circle-xmark"></i></c:otherwise>
            </c:choose>
        </span>
        <div class="toast-body small fw-medium m-0">
            <c:out value="${flashMessage}"/>
        </div>
        <button type="button" class="toast-close" onclick="closeToast()">&times;</button>
    </div>
</c:if>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openDeleteModal(recId, bookTitle) {
        document.getElementById('delete-recommendation-title').textContent = '"' + bookTitle + '"';
        document.getElementById('delete-form').action =
            '${pageContext.request.contextPath}/recommend/delete?id=' + recId;

        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    function closeToast() {
        const toast = document.getElementById('flash-toast');
        if (toast) {
            toast.style.transition = 'opacity .3s ease';
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 300);
        }
    }

    (function () {
        const toast = document.getElementById('flash-toast');
        if (toast) {
            setTimeout(closeToast, 4000);
        }
    })();
</script>
</body>
</html>
