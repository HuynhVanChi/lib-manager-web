<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Mượn Trả & Vi Phạm - LibraryOS</title>
    
    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        /* Tùy chỉnh màu sắc thẻ thống kê nhanh theo nghiệp vụ */
        .stat-borrow-total   { background: var(--primary-soft); color: var(--primary); }
        .stat-borrow-total   .stat-icon { background: rgba(49,46,129,.12); color: var(--primary); }
        
        .stat-borrowing      { background: #FFF7ED; color: #C2410C; }
        .stat-borrowing      .stat-icon { background: rgba(194,65,12,.12); color: #C2410C; }
        
        .stat-fine-unpaid    { background: #FEF2F2; color: #DC2626; }
        .stat-fine-unpaid    .stat-icon { background: rgba(220,38,38,.12); color: #DC2626; }
        
        .stat-fine-paid      { background: #F0FDF4; color: #15803D; }
        .stat-fine-paid      .stat-icon { background: rgba(21,128,61,.12); color: #15803D; }

        /* Ghi đè CSS bổ sung cho tab bootstrap */
        .nav-tabs .nav-link {
            color: var(--text-muted);
            border: none;
            border-bottom: 3px solid transparent;
            font-weight: 500;
            padding: 12px 24px;
            transition: all 0.2s ease;
        }
        .nav-tabs .nav-link:hover {
            border-color: transparent;
            color: var(--primary);
        }
        .nav-tabs .nav-link.active {
            color: var(--primary);
            background-color: transparent;
            border-bottom: 3px solid var(--primary);
            font-weight: 600;
        }
    </style>
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
            <div class="container-fluid p-4 flex-grow-1">

                <!-- Alert hiển thị thông báo -->
                <c:if test="${not empty sessionScope.successMsg}">
                    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm rounded-3 mb-4" role="alert">
                        <i class="fa-solid fa-circle-check me-2"></i> ${sessionScope.successMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% session.removeAttribute("successMsg"); %>
                </c:if>
                <c:if test="${not empty sessionScope.errorMsg}">
                    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm rounded-3 mb-4" role="alert">
                        <i class="fa-solid fa-triangle-exclamation me-2"></i> ${sessionScope.errorMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                    <% session.removeAttribute("errorMsg"); %>
                </c:if>

                <!-- Thống kê nhanh ở trên cùng -->
                <div class="row g-3 mb-4">
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="stat-card stat-borrow-total h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Tổng lượt mượn</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-hand-holding-hand"></i>
                                </div>
                            </div>
                            <div class="stat-value">${borrowList.size()}</div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="stat-card stat-borrowing h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Đang mượn</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-hourglass-half"></i>
                                </div>
                            </div>
                            <div class="stat-value">
                                <c:set var="borrowingCount" value="0"/>
                                <c:forEach var="item" items="${borrowList}">
                                    <c:if test="${item.status == 'Borrowing'}">
                                        <c:set var="borrowingCount" value="${borrowingCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${borrowingCount}
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="stat-card stat-fine-unpaid h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Chờ đóng phạt</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                </div>
                            </div>
                            <div class="stat-value">
                                <c:set var="unpaidFinesCount" value="0"/>
                                <c:forEach var="fine" items="${fineList}">
                                    <c:if test="${fine.status == 'Unpaid'}">
                                        <c:set var="unpaidFinesCount" value="${unpaidFinesCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                                ${unpaidFinesCount}
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="stat-card stat-fine-paid h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Đã thu phạt</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-receipt"></i>
                                </div>
                            </div>
                            <div class="stat-value">
                                <c:set var="totalCollected" value="0"/>
                                <c:forEach var="fine" items="${fineList}">
                                    <c:if test="${fine.status == 'Paid'}">
                                        <c:set var="totalCollected" value="${totalCollected + fine.amount}"/>
                                    </c:if>
                                </c:forEach>
                                <fmt:formatNumber value="${totalCollected}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- TABS CONTAINER -->
                <div class="card border-0 shadow-sm rounded-3">
                    <div class="card-header bg-white border-bottom-0 pt-3 px-4">
                        <ul class="nav nav-tabs card-header-tabs" id="libraryTabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="borrow-tab" data-bs-toggle="tab" data-bs-target="#borrow-content" type="button" role="tab" aria-controls="borrow-content" aria-selected="true">
                                    <i class="fa-solid fa-hand-holding-hand me-2"></i>Mượn Trả Sách
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="fines-tab" data-bs-toggle="tab" data-bs-target="#fines-content" type="button" role="tab" aria-controls="fines-content" aria-selected="false">
                                    <i class="fa-solid fa-triangle-exclamation me-2"></i>Quản lý Vi Phạm & Phí Phạt
                                </button>
                            </li>
                        </ul>
                    </div>
                    <div class="card-body p-4">
                        <div class="tab-content" id="libraryTabsContent">
                            
                            <!-- TAB 1: MƯỢN TRẢ SÁCH -->
                            <div class="tab-pane fade show active" id="borrow-content" role="tabpanel" aria-labelledby="borrow-tab">
                                <div class="toolbar d-flex align-items-center flex-wrap gap-2 mb-4">
                                    <div class="search-wrapper">
                                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                        <input type="text" id="borrowSearch" class="search-input" placeholder="Tìm theo độc giả, email, mã sách...">
                                    </div>
                                    <select id="borrowStatusFilter" class="filter-select" style="width: 180px;">
                                        <option value="">Tất cả trạng thái</option>
                                        <option value="Borrowing">Đang mượn</option>
                                        <option value="Returned">Đã trả</option>
                                        <option value="Overdue">Quá hạn</option>
                                        <option value="Lost">Báo mất</option>
                                    </select>
                                    <button type="button" id="btnFilterBorrow" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow" style="height: 40px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fa-solid fa-filter me-1"></i> Lọc
                                    </button>
                                    <a href="${pageContext.request.contextPath}/borrow-return/create" class="btn btn-primary d-flex align-items-center gap-2 px-4 py-2 rounded-3 fw-semibold shadow-sm hover-lift ms-auto text-decoration-none" style="height: 40px;">
                                        <i class="fa-solid fa-plus"></i>
                                        <span>Tạo Phiếu Mượn</span>
                                    </a>
                                </div>

                                <div class="table-responsive">
                                    <table class="table-custom">
                                        <thead>
                                            <tr>
                                                <th style="width: 100px;">Mã Phiếu</th>
                                                <th>Độc Giả</th>
                                                <th>Tên Sách</th>
                                                <th class="text-nowrap">Mã sách</th>
                                                <th>Ngày Mượn</th>
                                                <th>Hạn Trả</th>
                                                <th>Ngày Trả</th>
                                                <th>Trạng Thái</th>
                                                <th class="text-end">Hành Động</th>
                                            </tr>
                                        </thead>
                                        <tbody id="borrowTableBody">
                                            <c:forEach var="item" items="${borrowList}">
                                                <tr class="borrow-row" data-status="${item.status}">
                                                    <td class="fw-semibold">#${item.borrow_detail_id}</td>
                                                    <td class="text-nowrap">
                                                        <div class="d-flex flex-column">
                                                            <span class="fw-medium text-dark text-nowrap">${item.reader_name}</span>
                                                            <span class="text-muted small text-nowrap">${item.reader_email}</span>
                                                        </div>
                                                    </td>
                                                    <td style="max-width: 250px;" class="text-truncate fw-medium">${item.book_title}</td>
                                                    <td class="text-nowrap"><code class="text-dark bg-light px-2 py-1 rounded border small">${item.barcode}</code></td>
                                                    <td class="text-nowrap">${item.borrow_date}</td>
                                                    <td class="text-nowrap">${item.due_date}</td>
                                                    <td class="text-nowrap">
                                                        <c:choose>
                                                            <c:when test="${not empty item.return_date}">
                                                                ${item.return_date}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">—</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
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
                                                                <span class="badge-status badge-expired text-nowrap">Báo mất</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-end text-nowrap">
                                                        <div class="d-flex justify-content-end gap-1">
                                                            <a href="${pageContext.request.contextPath}/borrow-return/detail?id=${item.borrow_detail_id}" class="btn-action" title="Xem chi tiết">
                                                                <i class="fa-solid fa-eye"></i>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/borrow-return/edit?id=${item.borrow_detail_id}" class="btn-action" title="Chỉnh sửa">
                                                                <i class="fa-solid fa-pen"></i>
                                                            </a>
                                                            <button type="button" class="btn-action" title="Xóa" data-bs-toggle="modal" data-bs-target="#deleteModal" data-id="${item.borrow_detail_id}" data-name="Phiếu mượn #${item.borrow_detail_id}" data-type="borrow">
                                                                <i class="fa-solid fa-trash text-muted"></i>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty borrowList}">
                                                <tr>
                                                    <td colspan="9" class="text-center py-4">
                                                        <div class="empty-state py-4">
                                                            <div class="icon">
                                                                <i class="fa-regular fa-folder-open"></i>
                                                            </div>
                                                            <h5 class="fw-bold text-dark">Chưa có dữ liệu phiếu mượn</h5>
                                                            <p class="text-muted small mb-0">Hệ thống chưa ghi nhận bất kỳ lượt mượn sách nào.</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- TAB 2: QUẢN LÝ VI PHẠM & PHÍ PHẠT -->
                            <div class="tab-pane fade" id="fines-content" role="tabpanel" aria-labelledby="fines-tab">
                                <div class="toolbar d-flex align-items-center flex-wrap gap-2 mb-4">
                                    <div class="search-wrapper">
                                        <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                        <input type="text" id="finesSearch" class="search-input" placeholder="Tìm theo tên độc giả, lý do phạt...">
                                    </div>
                                    <select id="finesStatusFilter" class="filter-select" style="width: 220px;">
                                        <option value="">Tất cả trạng thái phạt</option>
                                        <option value="Unpaid">Chưa đóng phạt</option>
                                        <option value="Paid">Đã đóng phạt</option>
                                        <option value="Waived">Đã miễn giảm</option>
                                    </select>
                                    <button type="button" id="btnFilterFines" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow" style="height: 40px; display: flex; align-items: center; justify-content: center;">
                                        <i class="fa-solid fa-filter me-1"></i> Lọc
                                    </button>
                                </div>

                                <div class="table-responsive">
                                    <table class="table-custom">
                                        <thead>
                                            <tr>
                                                <th style="width: 100px;">Mã Phạt</th>
                                                <th>Độc Giả</th>
                                                <th>Tên Sách</th>
                                                <th>Số Tiền Phạt</th>
                                                <th>Lý Do</th>
                                                <th>Ngày Đóng</th>
                                                <th>Người Thu</th>
                                                <th>Trạng Thái</th>
                                                <th class="text-end">Hành Động</th>
                                            </tr>
                                        </thead>
                                        <tbody id="finesTableBody">
                                            <c:forEach var="fine" items="${fineList}">
                                                <tr class="fine-row" data-status="${fine.status}">
                                                    <td class="fw-semibold">#${fine.fine_id}</td>
                                                    <td class="text-nowrap"><span class="fw-medium text-dark text-nowrap">${fine.reader_name}</span></td>
                                                    <td style="max-width: 220px;" class="text-truncate fw-medium">${fine.book_title}</td>
                                                    <td class="text-danger fw-bold">
                                                        <fmt:formatNumber value="${fine.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                    <td class="text-nowrap">
                                                        <c:set var="translatedReason" value="${fine.reason}" />
                                                        <c:set var="translatedReason" value="${fn:replace(translatedReason, 'Overdue', 'Quá hạn')}" />
                                                        <c:set var="translatedReason" value="${fn:replace(translatedReason, 'Damaged Book', 'Hỏng sách')}" />
                                                        <c:set var="translatedReason" value="${fn:replace(translatedReason, 'Lost Book', 'Mất sách')}" />
                                                        <c:choose>
                                                            <c:when test="${translatedReason == 'Quá hạn'}">
                                                                <span class="text-warning fw-medium text-nowrap">Quá hạn</span>
                                                            </c:when>
                                                            <c:when test="${translatedReason == 'Mất sách'}">
                                                                <span class="text-danger fw-medium text-nowrap">Mất sách</span>
                                                            </c:when>
                                                            <c:when test="${translatedReason == 'Hỏng sách'}">
                                                                <span class="text-danger fw-medium text-nowrap">Hỏng sách</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-secondary fw-medium text-nowrap">${translatedReason}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-nowrap">
                                                        <c:choose>
                                                            <c:when test="${not empty fine.paid_at}">
                                                                <fmt:formatDate value="${fine.paid_at}" pattern="yyyy-MM-dd"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">—</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty fine.receiver_name}">
                                                                ${fine.receiver_name}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">—</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-nowrap">
                                                        <c:choose>
                                                            <c:when test="${fine.status == 'Unpaid'}">
                                                                <span class="badge-status badge-danger-custom text-nowrap">Chưa đóng</span>
                                                            </c:when>
                                                            <c:when test="${fine.status == 'Paid'}">
                                                                <span class="badge-status badge-active text-nowrap">Đã đóng</span>
                                                            </c:when>
                                                            <c:when test="${fine.status == 'Waived'}">
                                                                <span class="badge-status badge-info-custom text-nowrap">Đã miễn giảm</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-end text-nowrap">
                                                        <div class="d-flex justify-content-end gap-1">
                                                            <a href="${pageContext.request.contextPath}/borrow-return/fine-detail?id=${fine.fine_id}" class="btn-action" title="Xem chi tiết">
                                                                <i class="fa-solid fa-eye"></i>
                                                            </a>
                                                            <a href="${pageContext.request.contextPath}/borrow-return/fine-edit?id=${fine.fine_id}" class="btn-action" title="Chỉnh sửa">
                                                                <i class="fa-solid fa-pen"></i>
                                                            </a>
                                                            <button type="button" class="btn-action" title="Xóa" data-bs-toggle="modal" data-bs-target="#deleteModal" data-id="${fine.fine_id}" data-name="Khoản phạt #${fine.fine_id}" data-type="fine">
                                                                <i class="fa-solid fa-trash text-muted"></i>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty fineList}">
                                                <tr>
                                                    <td colspan="9" class="text-center py-4">
                                                        <div class="empty-state py-4">
                                                            <div class="icon">
                                                                <i class="fa-regular fa-folder-open"></i>
                                                            </div>
                                                            <h5 class="fw-bold text-dark">Chưa có phí phạt vi phạm nào</h5>
                                                            <p class="text-muted small mb-0">Hệ thống chưa ghi nhận bất kỳ khoản phạt vi phạm nào.</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>

            </div>
        </main>
        
    </div>

    <!-- MODAL MƯỢN SÁCH -->
    <div class="modal fade" id="borrowModal" tabindex="-1" aria-labelledby="borrowModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <form action="${pageContext.request.contextPath}/borrow-return" method="POST" class="m-0">
                    <input type="hidden" name="action" value="borrow">
                    <div class="modal-header d-flex align-items-center">
                        <div class="d-flex align-items-center gap-2">
                            <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                                <i class="fa-solid fa-hand-holding-hand"></i>
                            </div>
                            <h6 class="modal-title fw-bold m-0" id="borrowModalLabel">Tạo Phiếu Mượn Sách Mới</h6>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="readerId" class="form-label">Chọn Độc Giả <span class="required-mark">*</span></label>
                            <select class="form-select" name="readerId" id="readerId" required>
                                <option value="" disabled selected>-- Chọn độc giả mượn --</option>
                                <c:forEach var="r" items="${readerList}">
                                    <option value="${r.reader_id}">${r.full_name} (${r.email})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="copyId" class="form-label">Chọn Bản Sao Sách Có Sẵn <span class="required-mark">*</span></label>
                            <select class="form-select" name="copyId" id="copyId" required>
                                <option value="" disabled selected>-- Chọn mã bản sao & tên sách --</option>
                                <c:forEach var="c" items="${availableCopies}">
                                    <option value="${c.copy_id}">${c.barcode} - ${c.title}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="durationDays" class="form-label">Thời Hạn Mượn <span class="required-mark">*</span></label>
                            <select class="form-select" name="durationDays" id="durationDays" required>
                                <option value="7">7 Ngày</option>
                                <option value="14" selected>14 Ngày (Tiêu chuẩn)</option>
                                <option value="30">30 Ngày</option>
                                <option value="60">60 Ngày (Học tập chuyên sâu)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary hover-lift">
                            <i class="fa-solid fa-floppy-disk me-1"></i> Tạo Phiếu Mượn
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- MODAL XÓA CHUNG -->
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
                    <p class="mb-1" style="font-size: .9rem;">Bạn có chắc chắn muốn xóa?</p>
                    <p class="fw-bold mb-3 text-primary" id="delete-item-name" style="font-size: 1rem;">—</p>
                    <div class="rounded-3 p-3" style="background: #FEF2F2; border: 1px solid #FECACA; font-size: .82rem; color: #991B1B;">
                        <i class="fa-solid fa-circle-info me-1"></i> Hành động này không thể hoàn tác.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                    <form id="delete-form" method="post" action="${pageContext.request.contextPath}/borrow-return/delete" class="m-0">
                        <input type="hidden" name="id" id="delete-item-id" value="">
                        <button type="submit" class="btn btn-danger hover-lift">
                            <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Bộ lọc tìm kiếm nhanh trực tiếp trên Frontend và Modal -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            // Kiểm tra và tự động chuyển sang tab Vi phạm nếu URL có tham số ?tab=fines
            const urlParams = new URLSearchParams(window.location.search);
            const tabParam = urlParams.get('tab');
            if (tabParam === 'fines') {
                const finesTabEl = document.getElementById('fines-tab');
                if (finesTabEl) {
                    const tab = new bootstrap.Tab(finesTabEl);
                    tab.show();
                }
            }

            // Bộ tìm kiếm và lọc tab Mượn trả
            const borrowSearch = document.getElementById("borrowSearch");
            const borrowStatusFilter = document.getElementById("borrowStatusFilter");
            const borrowRows = document.querySelectorAll(".borrow-row");

            function filterBorrowTable() {
                const query = borrowSearch.value.toLowerCase().trim();
                const statusVal = borrowStatusFilter.value;

                borrowRows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    const status = row.getAttribute("data-status");

                    const matchesQuery = query === "" || text.includes(query);
                    const matchesStatus = statusVal === "" || status === statusVal;

                    if (matchesQuery && matchesStatus) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            }

            const btnFilterBorrow = document.getElementById("btnFilterBorrow");
            if (btnFilterBorrow) btnFilterBorrow.addEventListener("click", filterBorrowTable);
            if (borrowSearch) {
                borrowSearch.addEventListener("keypress", function(e) {
                    if (e.key === "Enter") {
                        filterBorrowTable();
                    }
                });
            }

            // Bộ tìm kiếm và lọc tab Phí phạt
            const finesSearch = document.getElementById("finesSearch");
            const finesStatusFilter = document.getElementById("finesStatusFilter");
            const fineRows = document.querySelectorAll(".fine-row");

            function filterFinesTable() {
                const query = finesSearch.value.toLowerCase().trim();
                const statusVal = finesStatusFilter.value;

                fineRows.forEach(row => {
                    const text = row.textContent.toLowerCase();
                    const status = row.getAttribute("data-status");

                    const matchesQuery = query === "" || text.includes(query);
                    const matchesStatus = statusVal === "" || status === statusVal;

                    if (matchesQuery && matchesStatus) {
                        row.style.display = "";
                    } else {
                        row.style.display = "none";
                    }
                });
            }

            const btnFilterFines = document.getElementById("btnFilterFines");
            if (btnFilterFines) btnFilterFines.addEventListener("click", filterFinesTable);
            if (finesSearch) {
                finesSearch.addEventListener("keypress", function(e) {
                    if (e.key === "Enter") {
                        filterFinesTable();
                    }
                });
            }

            // Cấu hình modal xóa động
            const deleteModalEl = document.getElementById('deleteModal');
            if (deleteModalEl) {
                deleteModalEl.addEventListener('show.bs.modal', function (event) {
                    const button = event.relatedTarget;
                    const itemId = button.getAttribute('data-id');
                    const itemName = button.getAttribute('data-name');
                    const itemType = button.getAttribute('data-type');
                    
                    const deleteItemName = deleteModalEl.querySelector('#delete-item-name');
                    const deleteItemId = deleteModalEl.querySelector('#delete-item-id');
                    const deleteForm = deleteModalEl.querySelector('#delete-form');
                    
                    deleteItemName.textContent = itemName;
                    deleteItemId.value = itemId;
                    
                    if (itemType === 'fine') {
                        deleteForm.action = '${pageContext.request.contextPath}/borrow-return/delete-fine';
                    } else {
                        deleteForm.action = '${pageContext.request.contextPath}/borrow-return/delete';
                    }
                });
            }
        });
    </script>
</body>
</html>
