<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Phiếu Mượn #${item.borrow_detail_id} - LibraryOS</title>
    
    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH -->
    <div class="d-flex">
        
        <!-- SIDEBAR -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- NỘI DUNG CHÍNH -->
        <main class="w-100 min-vh-100 d-flex flex-column">
            
            <!-- HEADER -->
            <jsp:include page="/views/layout/header.jsp"/>

            <!-- VÙNG ĐỆM NỘI DUNG -->
            <div class="container-fluid p-4">

                <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
                <div class="mb-4">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/borrow-return">
                                    <i class="fa-solid fa-house-chimney me-1"></i>Mượn trả & Vi phạm
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">Chi tiết phiếu mượn #${item.borrow_detail_id}</li>
                        </ol>
                    </nav>
                    <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                        Chi tiết phiếu mượn #${item.borrow_detail_id}
                    </h1>
                </div>

                <%-- ── FORM CARD ── --%>
                <div class="form-card bg-white">

                    <%-- Header card --%>
                    <div class="form-card-header">
                        <div class="d-flex align-items-center justify-content-between gap-3">
                            <div class="d-flex align-items-center gap-3">
                                <div class="rounded-circle d-flex align-items-center justify-content-center"
                                     style="width:44px;height:44px;background:rgba(255,255,255,.2);flex-shrink:0;">
                                    <i class="fa-solid fa-circle-info text-white fs-5"></i>
                                </div>
                                <div>
                                    <h5 class="text-white fw-bold mb-0">Chi Tiết Phiếu Mượn Sách</h5>
                                    <p class="text-white mb-0" style="opacity:.75;font-size:.82rem;">
                                        Thông tin đầy đủ của lượt mượn sách
                                    </p>
                                </div>
                            </div>
                            <span class="badge bg-white text-primary fw-bold px-3 py-1.5 rounded">#${item.borrow_detail_id}</span>
                        </div>
                    </div>

                    <div class="p-4">
                        
                        <div class="row mb-4">
                            <!-- Hàng 1, Cột bên trái: Độc giả -->
                            <div class="col-lg-6 col-12 border-end pe-lg-4">
                                <div class="section-divider mt-0 mb-3">Thông tin độc giả</div>
                                <table class="table table-borderless table-sm mb-4">
                                    <tr>
                                        <td class="text-muted text-nowrap" style="width: 160px;">Họ tên:</td>
                                        <td class="fw-bold text-dark text-nowrap">${item.reader_name}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Email:</td>
                                        <td class="fw-medium">${item.reader_email}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Số điện thoại:</td>
                                        <td class="fw-medium">${not empty item.reader_phone ? item.reader_phone : '<span class="text-muted">—</span>'}</td>
                                    </tr>
                                </table>
                            </div>

                            <!-- Hàng 1, Cột bên phải: Sách mượn -->
                            <div class="col-lg-6 col-12 ps-lg-4 mt-4 mt-lg-0">
                                <div class="section-divider mt-0 mb-3">Thông tin sách mượn</div>
                                <table class="table table-borderless table-sm mb-4">
                                    <tr>
                                        <td class="text-muted text-nowrap" style="width: 160px;">Tên sách:</td>
                                        <td class="fw-bold text-dark">${item.book_title}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Mã sách:</td>
                                        <td><code class="text-dark bg-light px-2 py-0.5 rounded border small">${item.barcode}</code></td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <div class="row mb-4">
                            <!-- Hàng 2, Cột bên trái: Lịch trình thời gian -->
                            <div class="col-lg-6 col-12 border-end pe-lg-4">
                                <div class="section-divider mt-0 mb-3">Lịch trình thời gian</div>
                                <table class="table table-borderless table-sm mb-4 mb-lg-0">
                                    <tr>
                                        <td class="text-muted text-nowrap" style="width: 160px;">Ngày mượn:</td>
                                        <td class="fw-medium text-nowrap"><i class="fa-regular fa-calendar-check me-1"></i> ${item.borrow_date}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Hạn phải trả:</td>
                                        <td class="fw-medium text-warning text-nowrap"><i class="fa-regular fa-clock me-1"></i> ${item.due_date}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Ngày thực trả:</td>
                                        <td class="fw-medium text-success text-nowrap">
                                            <c:choose>
                                                <c:when test="${not empty item.return_date}">
                                                    <i class="fa-regular fa-calendar-plus me-1"></i> ${item.return_date}
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="text-muted"><i class="fa-regular fa-circle-question me-1"></i> Chưa trả sách</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <!-- Hàng 2, Cột bên phải: Trạng thái vận hành -->
                            <div class="col-lg-6 col-12 ps-lg-4 mt-4 mt-lg-0">
                                <div class="section-divider mt-0 mb-3">Trạng thái vận hành</div>
                                <table class="table table-borderless table-sm">
                                    <tr>
                                        <td class="text-muted text-nowrap" style="width: 160px;">Trạng thái phiếu:</td>
                                        <td class="text-nowrap">
                                            <c:choose>
                                                <c:when test="${item.status == 'Borrowing'}">
                                                    <span class="badge-status badge-suspended text-nowrap">Đang mượn</span>
                                                </c:when>
                                                <c:when test="${item.status == 'Returned'}">
                                                    <span class="badge-status badge-active text-nowrap">Đã trả</span>
                                                </c:when>
                                                <c:when test="${item.status == 'Overdue'}">
                                                    <span class="badge-status badge-danger-custom text-nowrap">Quá hạn</span>
                                                </c:when>
                                                <c:when test="${item.status == 'Lost'}">
                                                    <span class="badge-status badge-danger-custom text-nowrap">Báo mất</span>
                                                </c:when>
                                            </c:choose>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Hiện trạng sách:</td>
                                        <td class="text-nowrap">
                                            <c:choose>
                                                <c:when test="${item.book_condition == 'Mất sách'}">
                                                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25 px-2.5 py-1 fw-semibold text-nowrap" style="font-size: .8rem;">Mất sách</span>
                                                </c:when>
                                                <c:when test="${item.book_condition == 'Rách nặng'}">
                                                    <span class="badge bg-warning bg-opacity-10 text-warning border border-warning border-opacity-25 px-2.5 py-1 fw-semibold text-nowrap" style="font-size: .8rem;">Rách nặng</span>
                                                </c:when>
                                                <c:when test="${item.book_condition == 'Rách nhẹ'}">
                                                    <span class="badge bg-info bg-opacity-10 text-info border border-info border-opacity-25 px-2.5 py-1 fw-semibold text-nowrap" style="font-size: .8rem;">Rách nhẹ</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-success bg-opacity-10 text-success border border-success border-opacity-25 px-2.5 py-1 fw-semibold text-nowrap" style="font-size: .8rem;">Bình thường</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <!-- CÁC KHOẢN PHẠT ĐI KÈM NẾU CÓ -->
                        <div class="section-divider">Danh sách khoản phạt phát sinh</div>
                        <div class="table-responsive mb-4">
                            <table class="table table-bordered table-sm text-center align-middle">
                                <thead class="table-light">
                                    <tr>
                                        <th>Mã Phạt</th>
                                        <th>Số Tiền Phạt</th>
                                        <th>Lý Do</th>
                                        <th>Ngày Thanh Toán</th>
                                        <th>Trạng Thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="f" items="${fines}">
                                        <tr>
                                            <td class="fw-semibold">#${f.fine_id}</td>
                                            <td class="text-danger fw-bold">
                                                <fmt:formatNumber value="${f.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </td>
                                             <td>
                                                 <c:set var="translatedReason" value="${f.reason}" />
                                                 <c:set var="translatedReason" value="${fn:replace(translatedReason, 'Overdue', 'Quá hạn')}" />
                                                 <c:set var="translatedReason" value="${fn:replace(translatedReason, 'Damaged Book', 'Hỏng sách')}" />
                                                 <c:set var="translatedReason" value="${fn:replace(translatedReason, 'Lost Book', 'Mất sách')}" />
                                                 <c:choose>
                                                     <c:when test="${fn:contains(translatedReason, ',')}">
                                                         <span class="text-danger fw-medium">${translatedReason}</span>
                                                     </c:when>
                                                     <c:when test="${translatedReason == 'Quá hạn'}">
                                                         <span class="text-warning fw-medium">Quá hạn</span>
                                                     </c:when>
                                                     <c:when test="${translatedReason == 'Mất sách'}">
                                                         <span class="text-danger fw-medium">Mất sách</span>
                                                     </c:when>
                                                     <c:when test="${translatedReason == 'Hỏng sách'}">
                                                         <span class="text-danger fw-medium">Hỏng sách</span>
                                                     </c:when>
                                                     <c:otherwise>
                                                         <span class="text-secondary fw-medium">${translatedReason}</span>
                                                     </c:otherwise>
                                                 </c:choose>
                                             </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty f.paid_at}">${f.paid_at}</c:when>
                                                    <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${f.status == 'Unpaid'}"><span class="badge bg-danger text-white">Chưa đóng</span></c:when>
                                                    <c:when test="${f.status == 'Paid'}"><span class="badge bg-success text-white">Đã đóng</span></c:when>
                                                    <c:when test="${f.status == 'Waived'}"><span class="badge bg-secondary text-white">Miễn giảm</span></c:when>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty fines}">
                                        <tr>
                                            <td colspan="5" class="text-muted py-3 text-center">Không phát sinh khoản phạt nào cho lượt mượn này.</td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>

                        <%-- ── FOOTER: Nút hành động ── --%>
                        <div class="d-flex align-items-center gap-3 mt-4 pt-3 border-top">
                            <a href="${pageContext.request.contextPath}/borrow-return/edit?id=${item.borrow_detail_id}"
                               class="btn btn-save text-decoration-none hover-lift">
                                <i class="fa-solid fa-pen-to-square me-2"></i>Chỉnh sửa phiếu
                            </a>
                            <a href="${pageContext.request.contextPath}/borrow-return"
                               id="btn-cancel"
                               class="btn btn-cancel text-decoration-none hover-lift">
                                <i class="fa-solid fa-arrow-left me-2"></i>Hủy
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
