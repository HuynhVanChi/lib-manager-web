<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Quản lý danh sách độc giả thư viện - LibraryOS">
    <title>Quản lý Độc giả - LibraryOS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <style>


        /* ── Expiry date color ── */
        .text-expired { color: #DC2626; font-weight: 500; }
        .text-expiring-soon { color: #D97706; font-weight: 500; }
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
                    <h1 class="fw-bold m-0 text-dark" style="font-size:1.6rem;">Danh sách Độc giả</h1>
                    <p class="text-muted mb-0 mt-1" style="font-size:.85rem;">
                        Danh sách tất cả độc giả đang hoạt động trong hệ thống
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <button type="button"
                            id="btn-open-archive"
                            class="btn btn-slate hover-lift"
                            data-bs-toggle="modal"
                            data-bs-target="#archiveModal">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Thùng rác</span>
                    </button>
                    <a href="${pageContext.request.contextPath}/readers/add"
                       id="btn-add-reader"
                       class="btn btn-primary hover-lift">
                        <i class="fa-solid fa-user-plus"></i>
                        <span>Thêm độc giả</span>
                    </a>
                </div>
            </div>

            <%-- ── CARD CHÍNH ── --%>
            <div class="card-main bg-white">

                <%-- ── TOOLBAR: Tìm kiếm + Lọc ── --%>
                <div class="p-3 border-bottom">
                    <form method="get" action="${pageContext.request.contextPath}/readers"
                          class="d-flex align-items-center toolbar flex-wrap">

                        <%-- Input tìm kiếm --%>
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text"
                                   id="search-input"
                                   name="search"
                                   class="search-input"
                                   placeholder="Tìm theo tên, email, SĐT..."
                                   value="<c:out value='${search}'/>">
                        </div>

                        <%-- Dropdown lọc trạng thái --%>
                        <select name="status" id="filter-status" class="filter-select">
                            <option value="">Tất cả trạng thái</option>
                            <option value="Active"    ${statusFilter == 'Active'    ? 'selected' : ''}>Đang hoạt động</option>
                            <option value="Suspended" ${statusFilter == 'Suspended' ? 'selected' : ''}>Bị tạm đình chỉ</option>
                            <option value="Expired"   ${statusFilter == 'Expired'   ? 'selected' : ''}>Hết hạn thẻ</option>
                        </select>

                        <button type="submit" id="btn-search" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow">
                            <i class="fa-solid fa-filter me-1"></i> Lọc
                        </button>

                        <%-- Nút xóa bộ lọc nếu đang có filter --%>
                        <c:if test="${not empty search or not empty statusFilter}">
                            <a href="${pageContext.request.contextPath}/readers"
                               id="btn-clear-filter"
                               class="btn-clear-filter ms-2">
                                <i class="fa-solid fa-xmark me-1"></i> Xóa lọc
                            </a>
                        </c:if>

                        <%-- Tổng kết quả --%>
                        <span class="text-muted ms-auto" style="font-size:.82rem;">
                            <c:choose>
                                <c:when test="${not empty readers}">
                                    Hiển thị <strong>${readers.size()}</strong> độc giả
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
                        <c:when test="${not empty readers}">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                         <th style="width:50px">ID</th>
                                        <th>Họ và tên</th>
                                        <th>Email</th>
                                        <th>Số điện thoại</th>
                                        <th>Hạn thẻ</th>
                                        <th style="width:130px">Trạng thái</th>
                                        <th style="width:110px; text-align:center">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="r" items="${readers}" varStatus="loop">
                                        <tr id="reader-row-${r.readerId}">

                                            <%-- ID --%>
                                             <td class="text-muted fw-medium">#${r.readerId}</td>

                                            <%-- Họ tên --%>
                                            <td>
                                                 <div class="reader-name">
                                                     <c:out value="${r.fullName}"/>
                                                 </div>
                                            </td>

                                            <%-- Email --%>
                                            <td>
                                                <c:out value="${r.email}"/>
                                            </td>

                                            <%-- SĐT --%>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty r.phone}">
                                                        <c:out value="${r.phone}"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">—</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <%-- Hạn thẻ --%>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.membershipExpiredAt != null}">
                                                        <fmt:formatDate value="${r.membershipExpiredAt}" pattern="dd/MM/yyyy"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">—</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <%-- Trạng thái --%>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${r.status == 'Active'}">
                                                        <span class="badge-status badge-active">
                                                            <i class="fa-solid fa-circle-check me-1" style="font-size:.65rem;"></i>Hoạt động
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${r.status == 'Suspended'}">
                                                        <span class="badge-status badge-suspended">
                                                            <i class="fa-solid fa-circle-pause me-1" style="font-size:.65rem;"></i>Đình chỉ
                                                        </span>
                                                    </c:when>
                                                    <c:when test="${r.status == 'Expired'}">
                                                        <span class="badge-status badge-expired">
                                                            <i class="fa-solid fa-clock me-1" style="font-size:.65rem;"></i>Hết hạn
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-status badge-expired">
                                                            <c:out value="${r.status}"/>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>

                                            <%-- Hành động --%>
                                            <td>
                                                <div class="d-flex gap-1 justify-content-center">
                                                    <%-- Xem chi tiết --%>
                                                    <a href="${pageContext.request.contextPath}/readers/detail?id=${r.readerId}"
                                                       id="btn-detail-${r.readerId}"
                                                       class="btn-action" title="Xem chi tiết">
                                                        <i class="fa-solid fa-eye"></i>
                                                    </a>
                                                    <%-- Chỉnh sửa --%>
                                                    <a href="${pageContext.request.contextPath}/readers/edit?id=${r.readerId}"
                                                       id="btn-edit-${r.readerId}"
                                                       class="btn-action" title="Chỉnh sửa">
                                                        <i class="fa-solid fa-pen"></i>
                                                    </a>
                                                    <%-- Xóa --%>
                                                    <button type="button"
                                                            id="btn-delete-${r.readerId}"
                                                            class="btn-action danger"
                                                            title="Xóa"
                                                            onclick="openDeleteModal(${r.readerId}, '<c:out value="${r.fullName}" escapeXml="true"/>')">
                                                        <i class="fa-solid fa-trash-can"></i>
                                                    </button>
                                                </div>
                                            </td>

                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>

                        <%-- Không có dữ liệu --%>
                        <c:otherwise>
                            <div class="empty-state">
                                <div class="icon"><i class="fa-solid fa-users-slash"></i></div>
                                <h5 class="fw-semibold text-dark mb-1">Không tìm thấy độc giả nào</h5>
                                <p class="mb-3" style="font-size:.875rem;">
                                    <c:choose>
                                        <c:when test="${not empty search or not empty statusFilter}">
                                            Không có kết quả phù hợp với bộ lọc hiện tại.
                                        </c:when>
                                        <c:otherwise>
                                            Chưa có độc giả nào trong hệ thống.
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                                <c:if test="${empty search and empty statusFilter}">
                                    <a href="${pageContext.request.contextPath}/readers/add"
                                       class="btn btn-primary rounded-3 px-4 fw-medium hover-lift">
                                        <i class="fa-solid fa-user-plus me-2"></i>Thêm độc giả đầu tiên
                                    </a>
                                </c:if>
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
<%-- MODAL XÁC NHẬN XÓA (Bootstrap Modal)               --%>
<%-- ═══════════════════════════════════════════════════ --%>
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <div class="d-flex align-items-center gap-3">
                    <div class="rounded-circle d-flex align-items-center justify-content-center"
                         style="width:40px;height:40px;background:#FEE2E2;flex-shrink:0;">
                        <i class="fa-solid fa-triangle-exclamation" style="color:#DC2626;"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="deleteModalLabel">Xác nhận xóa độc giả</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <p class="mb-1" style="font-size:.9rem;">Bạn có chắc chắn muốn xóa độc giả:</p>
                <p class="fw-bold mb-3" id="delete-reader-name" style="font-size:1rem; color:var(--primary);">—</p>
                <div class="rounded-3 p-3" style="background:#FEF2F2;border:1px solid #FECACA;font-size:.82rem;color:#991B1B;">
                    <i class="fa-solid fa-info-circle me-1"></i>
                    Hành động này sẽ ẩn độc giả khỏi danh sách nhưng <strong>không xóa vĩnh viễn</strong> dữ liệu.
                    Độc giả đang mượn sách <strong>sẽ không thể xóa</strong>.
                </div>
            </div>
            <div class="modal-footer">
                <button type="button"
                        id="btn-cancel-delete"
                        class="btn btn-cancel hover-lift"
                        data-bs-dismiss="modal">
                    Hủy
                </button>
                <form id="delete-form" method="post" action="" class="m-0">
                    <button type="submit"
                            id="btn-confirm-delete"
                            class="btn btn-danger hover-lift">
                        <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<%-- ── MODAL DANH SÁCH ĐỘC GIẢ ĐÃ XÓA (Thùng rác) ── --%>
<div class="modal fade" id="archiveModal" tabindex="-1" aria-labelledby="archiveModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center" 
                         style="width: 36px; height: 36px;">
                        <i class="fa-solid fa-trash-can text-secondary"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="archiveModalLabel">Thùng rác độc giả</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body p-0">
                <c:choose>
                    <c:when test="${not empty deletedReaders}">
                        <div class="table-responsive">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th style="width: 50px;">ID</th>
                                        <th>Họ và tên</th>
                                        <th>Email</th>
                                        <th>Số điện thoại</th>
                                        <th class="text-center">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="delReader" items="${deletedReaders}">
                                        <tr>
                                            <td class="text-muted fw-medium">#<c:out value="${delReader.readerId}"/></td>
                                            <td><span class="fw-semibold text-dark"><c:out value="${delReader.fullName}"/></span></td>
                                            <td><c:out value="${delReader.email}"/></td>
                                            <td><c:out value="${delReader.phone != null ? delReader.phone : '—'}"/></td>
                                            <td class="text-center">
                                                <form method="post" action="${pageContext.request.contextPath}/readers/restore" class="m-0 d-inline">
                                                    <input type="hidden" name="readerId" value="${delReader.readerId}"/>
                                                    <button type="submit" class="btn-action" title="Khôi phục độc giả" style="color: var(--success) !important; border-color: var(--success-border) !important;">
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
                            <p class="small m-0">Thùng rác trống. Không có độc giả nào đã xóa.</p>
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
<%-- FLASH TOAST (hiển thị nếu có flashMessage)         --%>
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
    function openDeleteModal(readerId, readerName) {
        document.getElementById('delete-reader-name').textContent = '"' + readerName + '"';
        document.getElementById('delete-form').action =
            '${pageContext.request.contextPath}/readers/delete?readerId=' + readerId;

        const modal = new bootstrap.Modal(document.getElementById('deleteModal'));
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
