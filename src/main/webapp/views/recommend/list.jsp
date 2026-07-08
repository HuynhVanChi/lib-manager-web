<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Danh sách đề xuất sách từ độc giả - LibraryOS">
    <title>Danh sách Đề xuất Sách - LibraryOS</title>

    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <style>
        /* Override hover-lift shadow màu cho nút Duyệt (xanh lá) */
        .btn-approve.hover-lift:hover {
            box-shadow: 0 3px 8px rgba(21, 128, 61, 0.2) !important;
        }
        /* Override hover-lift shadow màu cho nút Từ chối (đỏ) */
        .btn-reject.hover-lift:hover {
            box-shadow: 0 3px 8px rgba(185, 28, 28, 0.2) !important;
        }

        /* Hiệu ứng gạch chéo icon giống FontAwesome -slash */
        .icon-slashed-wrapper {
            position: relative;
            display: inline-block;
            line-height: 1;
            color: rgba(107, 114, 128, 0.35); /* var(--text-muted) ở mức opacity 0.35 */
        }
        .icon-slashed-wrapper i {
            color: rgba(107, 114, 128, 0.35);
        }
        .icon-slashed-wrapper::after {
            content: "";
            position: absolute;
            top: 50%;
            left: 50%;
            box-sizing: content-box; /* Bắt buộc dùng content-box để không bị ép mất màu nền do border-box */
            width: 4px;
            height: 120%;
            background-color: rgba(107, 114, 128, 0.35); /* Màu gạch chéo giống hệt màu icon */
            border: 3px solid #ffffff; /* Tạo đường viền trắng cắt đứt icon bên dưới */
            transform: translate(-50%, -50%) rotate(-45deg);
            transform-origin: center;
            border-radius: 4px;
        }
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



            <%-- ── TIÊU ĐỀ TRANG ── --%>
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="fw-bold m-0 text-dark" style="font-size:1.6rem;">Danh sách Đề xuất Sách</h1>
                    <p class="text-muted mb-0 mt-1" style="font-size:.85rem;">
                        Danh sách các yêu cầu đề xuất mua bổ sung sách từ độc giả được ghi nhận nội bộ
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <button type="button"
                            id="btn-open-archive"
                            class="btn btn-slate hover-lift d-flex align-items-center gap-2"
                            data-bs-toggle="modal"
                            data-bs-target="#archiveModal">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Thùng rác</span>
                    </button>
                    <a href="${pageContext.request.contextPath}/recommend/add"
                       id="btn-add-recommendation"
                       class="btn btn-save hover-lift d-flex align-items-center gap-2 text-decoration-none">
                        <i class="fa-solid fa-plus"></i>
                        <span>Thêm đề xuất sách</span>
                    </a>
                </div>
            </div>

            <%-- ── CARD CHÍNH ── --%>
            <div class="card-main bg-white">

                <%-- ── TOOLBAR: Tìm kiếm + Lọc ── --%>
                <div class="p-3 border-bottom">
                    <form method="get" action="${pageContext.request.contextPath}/recommend"
                          class="d-flex align-items-center toolbar flex-wrap">

                        <%-- Input tìm kiếm --%>
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text"
                                   id="search-input"
                                   name="keyword"
                                   class="search-input"
                                   placeholder="Tìm theo tên sách, tác giả, độc giả..."
                                   value="<c:out value='${keyword}'/>">
                        </div>

                        <%-- Dropdown lọc trạng thái --%>
                        <select name="status" id="filter-status" class="filter-select">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Pending"  ${statusFilter == 'Pending'  ? 'selected' : ''}>Chờ xử lý</option>
                            <option value="Approved" ${statusFilter == 'Approved' ? 'selected' : ''}>Đã duyệt</option>
                            <option value="Rejected" ${statusFilter == 'Rejected' ? 'selected' : ''}>Từ chối</option>
                        </select>

                        <button type="submit" id="btn-search" class="btn btn-primary hover-glow px-3 py-2 rounded-3 fw-medium shadow-sm">
                            <i class="fa-solid fa-filter me-1"></i> Lọc
                        </button>

                        <%-- Nút xóa bộ lọc nếu đang có filter --%>
                        <c:if test="${not empty keyword or not empty statusFilter}">
                            <a href="${pageContext.request.contextPath}/recommend"
                               id="btn-clear-filter"
                               class="btn btn-outline-secondary px-3 py-2 rounded-3 fw-medium text-decoration-none ms-2">
                                <i class="fa-solid fa-xmark me-1"></i> Xóa lọc
                            </a>
                        </c:if>

                        <%-- Tổng kết quả --%>
                        <span class="text-muted ms-auto" style="font-size:.82rem;">
                            <c:choose>
                                <c:when test="${not empty recommendationsList}">
                                    Hiển thị <strong>${recommendationsList.size()}</strong> đề xuất
                                </c:when>
                                <c:otherwise>Không có kết quả</c:otherwise>
                            </c:choose>
                        </span>
                    </form>
                </div>

                <%-- ── BẢNG DANH SÁCH ── --%>
                <div class="table-responsive">
                    <c:choose>
                        <%-- Có dữ liệu --%>
                        <c:when test="${not empty recommendationsList}">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th style="width:50px">#</th>
                                        <th>Họ và tên độc giả</th>
                                        <th>Số điện thoại</th>
                                        <th>Sách đề xuất</th>
                                        <th style="width:130px">Trạng thái</th>
                                        <th style="width:180px; text-align:center">Xét duyệt</th>
                                        <th class="text-end" style="width:120px">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="rec" items="${recommendationsList}" varStatus="loop">
                                        <tr id="recommendation-row-${rec.recommendationId}">

                                            <%-- STT --%>
                                            <td class="text-muted fw-medium">${loop.index + 1}</td>

                                            <%-- Họ tên độc giả --%>
                                            <td>
                                                <div class="reader-name">
                                                    <c:out value="${rec.readerName}"/>
                                                </div>
                                                <div class="reader-email">
                                                    ID: #<c:out value="${rec.recommendationId}"/>
                                                </div>
                                            </td>

                                            <%-- Số điện thoại --%>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty rec.readerPhone}">
                                                        <c:out value="${rec.readerPhone}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">—</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <%-- Sách đề xuất --%>
                                            <td>
                                                <div class="reader-name">
                                                    <c:out value="${rec.bookTitle}"/>
                                                </div>
                                                <div class="reader-email">
                                                    Tác giả: <c:out value="${rec.author}"/>
                                                </div>
                                            </td>

                                            <%-- Trạng thái --%>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${rec.status == 'Pending'}">
                                                        <span class="badge-status badge-suspended">Chờ xử lý</span>
                                                    </c:when>
                                                    <c:when test="${rec.status == 'Approved'}">
                                                        <span class="badge-status badge-active">Đã duyệt</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-status badge-danger-custom">Từ chối</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <%-- Xét duyệt (Quick approve/reject) --%>
                                            <td style="text-align:center;">
                                                <c:choose>
                                                    <c:when test="${rec.status == 'Pending' and sessionScope.role == 'Admin'}">
                                                        <div class="d-flex gap-2 justify-content-center flex-wrap">
                                                            <%-- Nút Duyệt --%>
                                                            <button type="button"
                                                                    class="btn btn-approve hover-lift text-white rounded-1"
                                                                    style="font-size:0.62rem;padding:2px 7px;line-height:1.5;font-weight:600;letter-spacing:.3px;background:#16a34a;border-color:#16a34a;"
                                                                    title="Phê duyệt đề xuất"
                                                                    onclick="openApproveModal(${rec.recommendationId}, '<c:out value="${rec.bookTitle}" escapeXml="true"/>')">
                                                                <i class="fa-solid fa-check" style="font-size:0.55rem;"></i> Duyệt
                                                            </button>
                                                            <%-- Nút Từ chối --%>
                                                            <button type="button"
                                                                    class="btn btn-reject hover-lift text-white rounded-1"
                                                                    style="font-size:0.62rem;padding:2px 7px;line-height:1.5;font-weight:600;letter-spacing:.3px;background:#dc2626;border-color:#dc2626;"
                                                                    title="Từ chối đề xuất"
                                                                    onclick="openRejectModal(${rec.recommendationId}, '<c:out value="${rec.bookTitle}" escapeXml="true"/>')">
                                                                <i class="fa-solid fa-xmark" style="font-size:0.55rem;"></i> Từ chối
                                                            </button>
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${rec.status == 'Pending'}">
                                                        <span class="text-muted" style="font-size: .8rem;">Chờ Admin duyệt</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted" style="font-size: .8rem;">Đã quyết định</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <%-- Hành động --%>
                                            <c:choose>
                                                <c:when test="${rec.status == 'Pending'}">
                                                    <td class="text-end">
                                                        <div class="d-flex gap-1 justify-content-end">
                                                            <a href="${pageContext.request.contextPath}/recommend/detail?id=${rec.recommendationId}"
                                                               class="btn-action" title="Xem chi tiết">
                                                                <i class="fa-solid fa-eye"></i>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/recommend/edit?id=${rec.recommendationId}"
                                                               class="btn-action" title="Chỉnh sửa">
                                                                <i class="fa-solid fa-pen"></i>
                                                            </a>
                                                            <button type="button"
                                                                    class="btn-action danger"
                                                                    title="Xóa"
                                                                    onclick="openDeleteModal(${rec.recommendationId}, '<c:out value="${rec.bookTitle}" escapeXml="true"/>')">
                                                                <i class="fa-solid fa-trash-can"></i>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </c:when>
                                                <c:otherwise>
                                                    <td class="text-center">
                                                        <a href="${pageContext.request.contextPath}/recommend/detail?id=${rec.recommendationId}"
                                                           class="btn-action" title="Xem chi tiết">
                                                            <i class="fa-solid fa-eye"></i>
                                                        </a>
                                                    </td>
                                                </c:otherwise>
                                            </c:choose>

                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>

                        <%-- Không có dữ liệu --%>
                        <c:otherwise>
                            <div class="empty-state">
                                <div class="icon" style="opacity: 1;">
                                    <span class="icon-slashed-wrapper">
                                        <i class="fa-solid fa-book-open-reader"></i>
                                    </span>
                                </div>
                                <h5 class="fw-semibold text-dark mb-1">Không tìm thấy phiếu đề xuất sách</h5>
                                <p class="mb-3" style="font-size:.875rem;">Vui lòng kiểm tra lại từ khóa hoặc bộ lọc của bạn.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <%-- END TABLE --%>

            </div>
            <%-- END CARD --%>

        </div>
        <%-- END container-fluid --%>
    </main>

</div>

<%-- ═══════════════════════════════════════════════════ --%>
<%-- MODAL XÁC NHẬN XÓA (Premium Modal)                 --%>
<%-- ═══════════════════════════════════════════════════ --%>
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
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
                    <i class="fa-solid fa-circle-info me-1"></i> Hành động này sẽ chuyển đề xuất vào Thùng rác.
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

<%-- ── MODAL DANH SÁCH ĐỀ XUẤT ĐÃ XÓA (Thùng rác) ── --%>
<div class="modal fade" id="archiveModal" tabindex="-1" aria-labelledby="archiveModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center" 
                         style="width: 36px; height: 36px;">
                        <i class="fa-solid fa-trash-can text-secondary"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="archiveModalLabel">Thùng rác đề xuất</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body p-0">
                <c:choose>
                    <c:when test="${not empty deletedRecommendations}">
                        <div class="table-responsive">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th style="width: 50px;">ID</th>
                                        <th>Độc giả</th>
                                        <th>Sách đề xuất</th>
                                        <th>Tác giả</th>
                                        <th class="text-end" style="width: 100px;">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="del" items="${deletedRecommendations}">
                                        <tr>
                                            <td><c:out value="${del.recommendationId}"/></td>
                                            <td><span class="fw-semibold text-dark"><c:out value="${del.readerName}"/></span></td>
                                            <td><c:out value="${del.bookTitle}"/></td>
                                            <td><c:out value="${del.author}"/></td>
                                            <td class="text-end">
                                                <form method="post" action="${pageContext.request.contextPath}/recommend/restore" class="m-0 d-inline">
                                                    <input type="hidden" name="id" value="${del.recommendationId}"/>
                                                    <button type="submit" class="btn-action hover-lift" title="Khôi phục đề xuất" style="color: #15803D !important; border-color: #86EFAC !important;">
                                                        <i class="fa-solid fa-trash-can-arrow-up"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-regular fa-folder-open fs-2 mb-2 opacity-50"></i>
                            <p class="small m-0">Thùng rác trống. Không có đề xuất nào đã xóa.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<%-- ═══════════════════════════════════════════════════ --%>
<%-- MODAL XÁC NHẬN DUYỆT ĐỀ XUẤT                      --%>
<%-- ═══════════════════════════════════════════════════ --%>
<div class="modal fade" id="approveModal" tabindex="-1" aria-labelledby="approveModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-success bg-opacity-10 text-success rounded-circle d-flex align-items-center justify-content-center" style="width:36px;height:36px;">
                        <i class="fa-solid fa-circle-check"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="approveModalLabel">Xác nhận phê duyệt</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <p class="mb-1" style="font-size:.9rem;">Bạn có chắc chắn muốn <strong class="text-success">PHÊ DUYỆT</strong> đề xuất sách?</p>
                <p class="fw-bold mb-3 text-primary" id="approve-book-title" style="font-size:1rem;">—</p>
                <div class="rounded-3 p-3" style="background:#F0FDF4;border:1px solid #BBF7D0;font-size:.82rem;color:#15803D;">
                    <i class="fa-solid fa-circle-info me-1"></i> Sau khi duyệt, đề xuất sẽ chuyển sang trạng thái <strong>Đã duyệt</strong>.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                <form id="approve-form" method="post" action="" class="m-0">
                    <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/recommend">
                    <button type="submit" class="btn btn-save hover-lift" style="background:#15803D!important;border-color:#15803D!important;">
                        <i class="fa-solid fa-circle-check me-1"></i> Xác nhận duyệt
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<%-- ═══════════════════════════════════════════════════ --%>
<%-- MODAL XÁC NHẬN TỪ CHỐI ĐỀ XUẤT                    --%>
<%-- ═══════════════════════════════════════════════════ --%>
<div class="modal fade" id="rejectModal" tabindex="-1" aria-labelledby="rejectModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-danger bg-opacity-10 text-danger rounded-circle d-flex align-items-center justify-content-center" style="width:36px;height:36px;">
                        <i class="fa-solid fa-circle-xmark"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="rejectModalLabel">Xác nhận từ chối</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <p class="mb-1" style="font-size:.9rem;">Bạn có chắc chắn muốn <strong class="text-danger">TỪ CHỐI</strong> đề xuất sách?</p>
                <p class="fw-bold mb-3 text-primary" id="reject-book-title" style="font-size:1rem;">—</p>
                <div class="rounded-3 p-3" style="background:#FEF2F2;border:1px solid #FECACA;font-size:.82rem;color:#991B1B;">
                    <i class="fa-solid fa-triangle-exclamation me-1"></i> Đề xuất sẽ chuyển sang trạng thái <strong>Từ chối</strong> và không thể chỉnh sửa.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                <form id="reject-form" method="post" action="" class="m-0">
                    <input type="hidden" name="redirectUrl" value="${pageContext.request.contextPath}/recommend">
                    <button type="submit" class="btn btn-danger hover-lift">
                        <i class="fa-solid fa-circle-xmark me-1"></i> Xác nhận từ chối
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<%-- ═══════════════════════════════════════════════════ --%>
<%-- FLASH TOAST (Premium Toast)                        --%>
<%-- ═══════════════════════════════════════════════════ --%>
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
    // ── Mở modal xóa và điền tên + action URL ──
    function openDeleteModal(recId, bookTitle) {
        document.getElementById('delete-recommendation-title').textContent = '"' + bookTitle + '"';
        document.getElementById('delete-form').action =
            '${pageContext.request.contextPath}/recommend/delete?id=' + recId;
        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
        modal.show();
    }

    // ── Mở modal duyệt đề xuất ──
    function openApproveModal(recId, bookTitle) {
        document.getElementById('approve-book-title').textContent = '"' + bookTitle + '"';
        document.getElementById('approve-form').action =
            '${pageContext.request.contextPath}/recommend/approve?id=' + recId;
        const modal = new bootstrap.Modal(document.getElementById('approveModal'));
        modal.show();
    }

    // ── Mở modal từ chối đề xuất ──
    function openRejectModal(recId, bookTitle) {
        document.getElementById('reject-book-title').textContent = '"' + bookTitle + '"';
        document.getElementById('reject-form').action =
            '${pageContext.request.contextPath}/recommend/reject?id=' + recId;
        const modal = new bootstrap.Modal(document.getElementById('rejectModal'));
        modal.show();
    }

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
</script>
</body>
</html>
