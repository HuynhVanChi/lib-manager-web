<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Mượn Trả & Vi Phạm - LibraryOS</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
            color: #1F2937;
        }
        
        /* Màu chủ đạo: Tím than/Chàm (#312E81) */
        :root {
            --primary-color: #312E81;
            --primary-hover: #1E1B4B;
            --secondary-color: #A78BFA;
            --bg-light: #F9FAFB;
        }

        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
            transition: all 0.2s ease-in-out;
        }
        .btn-primary:hover {
            background-color: var(--primary-hover);
            border-color: var(--primary-hover);
            transform: translateY(-1px);
        }

        .nav-tabs .nav-link {
            color: #4B5563;
            border: none;
            border-bottom: 3px solid transparent;
            font-weight: 500;
            padding: 12px 24px;
            transition: all 0.2s ease;
        }
        .nav-tabs .nav-link:hover {
            border-color: transparent;
            color: var(--primary-color);
        }
        .nav-tabs .nav-link.active {
            color: var(--primary-color);
            background-color: transparent;
            border-bottom: 3px solid var(--primary-color);
            font-weight: 600;
        }

        .table-responsive {
            border-radius: 8px;
            overflow: hidden;
        }
        
        .badge-borrowing {
            background-color: rgba(245, 158, 11, 0.1);
            color: #D97706;
            border: 1px solid rgba(245, 158, 11, 0.2);
        }
        .badge-returned {
            background-color: rgba(16, 185, 129, 0.1);
            color: #059669;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        .badge-overdue {
            background-color: rgba(239, 68, 68, 0.1);
            color: #DC2626;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
        .badge-lost {
            background-color: rgba(107, 114, 128, 0.1);
            color: #4B5563;
            border: 1px solid rgba(107, 114, 128, 0.2);
        }

        .badge-unpaid {
            background-color: rgba(239, 68, 68, 0.1);
            color: #DC2626;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
        .badge-paid {
            background-color: rgba(16, 185, 129, 0.1);
            color: #059669;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }
        .badge-waived {
            background-color: rgba(59, 130, 246, 0.1);
            color: #2563EB;
            border: 1px solid rgba(59, 130, 246, 0.2);
        }

        .search-container {
            position: relative;
        }
        .search-container i {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #9CA3AF;
        }
        .search-input {
            padding-left: 36px;
            border-radius: 8px;
            border: 1px solid #E5E7EB;
        }
        .search-input:focus {
            border-color: var(--secondary-color);
            box-shadow: 0 0 0 3px rgba(167, 139, 250, 0.25);
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
                        <div class="card border-0 shadow-sm rounded-3 h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="bg-primary bg-opacity-10 text-primary rounded-circle p-3 me-3">
                                    <i class="fa-solid fa-hand-holding-hand fs-4" style="color: var(--primary-color) !important;"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1 small uppercase fw-bold">Tổng lượt mượn</h6>
                                    <h3 class="fw-bold m-0">${borrowList.size()}</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card border-0 shadow-sm rounded-3 h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="bg-warning bg-opacity-10 text-warning rounded-circle p-3 me-3">
                                    <i class="fa-solid fa-hourglass-half fs-4"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1 small uppercase fw-bold">Đang mượn</h6>
                                    <h3 class="fw-bold m-0">
                                        <c:set var="borrowingCount" value="0"/>
                                        <c:forEach var="item" items="${borrowList}">
                                            <c:if test="${item.status == 'Borrowing'}">
                                                <c:set var="borrowingCount" value="${borrowingCount + 1}"/>
                                            </c:if>
                                        </c:forEach>
                                        ${borrowingCount}
                                    </h3>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card border-0 shadow-sm rounded-3 h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="bg-danger bg-opacity-10 text-danger rounded-circle p-3 me-3">
                                    <i class="fa-solid fa-triangle-exclamation fs-4"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1 small uppercase fw-bold">Chờ đóng phạt</h6>
                                    <h3 class="fw-bold m-0">
                                        <c:set var="unpaidFinesCount" value="0"/>
                                        <c:forEach var="fine" items="${fineList}">
                                            <c:if test="${fine.status == 'Unpaid'}">
                                                <c:set var="unpaidFinesCount" value="${unpaidFinesCount + 1}"/>
                                            </c:if>
                                        </c:forEach>
                                        ${unpaidFinesCount}
                                    </h3>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-12 col-sm-6 col-md-3">
                        <div class="card border-0 shadow-sm rounded-3 h-100">
                            <div class="card-body d-flex align-items-center">
                                <div class="bg-success bg-opacity-10 text-success rounded-circle p-3 me-3">
                                    <i class="fa-solid fa-receipt fs-4"></i>
                                </div>
                                <div>
                                    <h6 class="text-muted mb-1 small uppercase fw-bold">Đã thu phạt</h6>
                                    <h3 class="fw-bold m-0">
                                        <c:set var="totalCollected" value="0"/>
                                        <c:forEach var="fine" items="${fineList}">
                                            <c:if test="${fine.status == 'Paid'}">
                                                <c:set var="totalCollected" value="${totalCollected + fine.amount}"/>
                                            </c:if>
                                        </c:forEach>
                                        <fmt:formatNumber value="${totalCollected}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </h3>
                                </div>
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
                                <div class="d-flex flex-column flex-sm-row justify-content-between align-items-stretch align-items-sm-center gap-3 mb-4">
                                    <div class="search-container flex-grow-1" style="max-width: 400px;">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" id="borrowSearch" class="form-control search-input" placeholder="Tìm kiếm theo độc giả, email, barcode...">
                                    </div>
                                    <div class="d-flex gap-2">
                                        <select id="borrowStatusFilter" class="form-select border-0 shadow-sm bg-light" style="width: 170px;">
                                            <option value="">Tất cả trạng thái</option>
                                            <option value="Borrowing">Đang mượn</option>
                                            <option value="Returned">Đã trả</option>
                                            <option value="Overdue">Quá hạn</option>
                                            <option value="Lost">Báo mất</option>
                                        </select>
                                        <button class="btn btn-primary px-3" data-bs-toggle="modal" data-bs-target="#borrowModal">
                                            <i class="fa-solid fa-plus me-2"></i>Mượn Sách
                                        </button>
                                    </div>
                                </div>

                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Mã Phiếu</th>
                                                <th>Độc Giả</th>
                                                <th>Tên Sách</th>
                                                <th>Mã Vạch (Barcode)</th>
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
                                                    <td>
                                                        <div class="d-flex flex-column">
                                                            <span class="fw-medium">${item.reader_name}</span>
                                                            <span class="text-muted small">${item.reader_email}</span>
                                                        </div>
                                                    </td>
                                                    <td style="max-width: 250px;" class="text-truncate">${item.book_title}</td>
                                                    <td><code class="text-dark bg-light px-2 py-1 rounded">${item.barcode}</code></td>
                                                    <td>${item.borrow_date}</td>
                                                    <td>${item.due_date}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty item.return_date}">
                                                                ${item.return_date}
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="text-muted">—</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${item.status == 'Borrowing'}">
                                                                <span class="badge badge-borrowing px-2 py-1.5 rounded-pill">Đang mượn</span>
                                                            </c:when>
                                                            <c:when test="${item.status == 'Returned'}">
                                                                <span class="badge badge-returned px-2 py-1.5 rounded-pill">Đã trả</span>
                                                            </c:when>
                                                            <c:when test="${item.status == 'Overdue'}">
                                                                <span class="badge badge-overdue px-2 py-1.5 rounded-pill">Quá hạn</span>
                                                            </c:when>
                                                            <c:when test="${item.status == 'Lost'}">
                                                                <span class="badge badge-lost px-2 py-1.5 rounded-pill">Báo mất</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-end">
                                                        <c:if test="${item.status == 'Borrowing' || item.status == 'Overdue'}">
                                                            <div class="d-flex justify-content-end gap-2">
                                                                <form action="${pageContext.request.contextPath}/borrow-return" method="POST" class="d-inline">
                                                                    <input type="hidden" name="action" value="return">
                                                                    <input type="hidden" name="borrowDetailId" value="${item.borrow_detail_id}">
                                                                    <button type="submit" class="btn btn-sm btn-outline-success rounded-3 px-3 py-1.5" onclick="return confirm('Xác nhận trả sách này?')">
                                                                        <i class="fa-solid fa-rotate-left me-1"></i> Trả sách
                                                                    </button>
                                                                </form>
                                                                <form action="${pageContext.request.contextPath}/borrow-return" method="POST" class="d-inline">
                                                                    <input type="hidden" name="action" value="lost">
                                                                    <input type="hidden" name="borrowDetailId" value="${item.borrow_detail_id}">
                                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-3 px-3 py-1.5" onclick="return confirm('Xác nhận báo mất cuốn sách này? Hệ thống sẽ tạo khoản phạt đền bù.')">
                                                                        <i class="fa-solid fa-circle-question me-1"></i> Báo mất
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty borrowList}">
                                                <tr>
                                                    <td colspan="9" class="text-center py-4 text-muted">Không có dữ liệu phiếu mượn nào.</td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            
                            <!-- TAB 2: QUẢN LÝ VI PHẠM & PHÍ PHẠT -->
                            <div class="tab-pane fade" id="fines-content" role="tabpanel" aria-labelledby="fines-tab">
                                <div class="d-flex flex-column flex-sm-row justify-content-between align-items-stretch align-items-sm-center gap-3 mb-4">
                                    <div class="search-container flex-grow-1" style="max-width: 400px;">
                                        <i class="fa-solid fa-magnifying-glass"></i>
                                        <input type="text" id="finesSearch" class="form-control search-input" placeholder="Tìm theo tên độc giả, lý do phạt...">
                                    </div>
                                    <div>
                                        <select id="finesStatusFilter" class="form-select border-0 shadow-sm bg-light" style="width: 200px;">
                                            <option value="">Tất cả trạng thái phạt</option>
                                            <option value="Unpaid">Chưa đóng phạt</option>
                                            <option value="Paid">Đã đóng phạt</option>
                                            <option value="Waived">Đã miễn giảm</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Mã Phạt</th>
                                                <th>Độc Giả</th>
                                                <th>Tên Sách</th>
                                                <th>Số Tiền Phạt</th>
                                                <th>Lý Do</th>
                                                <th>Ngày Đóng</th>
                                                <th>Người Thu (Thủ thư)</th>
                                                <th>Trạng Thái</th>
                                                <th class="text-end">Hành Động</th>
                                            </tr>
                                        </thead>
                                        <tbody id="finesTableBody">
                                            <c:forEach var="fine" items="${fineList}">
                                                <tr class="fine-row" data-status="${fine.status}">
                                                    <td class="fw-semibold">#${fine.fine_id}</td>
                                                    <td><span class="fw-medium">${fine.reader_name}</span></td>
                                                    <td style="max-width: 220px;" class="text-truncate">${fine.book_title}</td>
                                                    <td class="text-danger fw-bold">
                                                        <fmt:formatNumber value="${fine.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${fine.reason == 'Overdue'}">
                                                                <span class="text-warning"><i class="fa-regular fa-clock me-1"></i> Quá hạn</span>
                                                            </c:when>
                                                            <c:when test="${fine.reason == 'Lost Book'}">
                                                                <span class="text-danger"><i class="fa-solid fa-circle-exclamation me-1"></i> Mất sách</span>
                                                            </c:when>
                                                            <c:when test="${fine.reason == 'Damaged Book'}">
                                                                <span class="text-danger"><i class="fa-solid fa-heart-broken me-1"></i> Hỏng sách</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                ${fine.reason}
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty fine.paid_at}">
                                                                ${fine.paid_at}
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
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${fine.status == 'Unpaid'}">
                                                                <span class="badge badge-unpaid px-2 py-1.5 rounded-pill">Chưa đóng</span>
                                                            </c:when>
                                                            <c:when test="${fine.status == 'Paid'}">
                                                                <span class="badge badge-paid px-2 py-1.5 rounded-pill">Đã đóng</span>
                                                            </c:when>
                                                            <c:when test="${fine.status == 'Waived'}">
                                                                <span class="badge badge-waived px-2 py-1.5 rounded-pill">Đã miễn giảm</span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-end">
                                                        <c:if test="${fine.status == 'Unpaid'}">
                                                            <div class="d-flex justify-content-end gap-2">
                                                                <form action="${pageContext.request.contextPath}/borrow-return" method="POST" class="d-inline">
                                                                    <input type="hidden" name="action" value="payFine">
                                                                    <input type="hidden" name="fineId" value="${fine.fine_id}">
                                                                    <button type="submit" class="btn btn-sm btn-success rounded-3 px-3 py-1.5" onclick="return confirm('Xác nhận thu tiền phạt cho khoản phạt này?')">
                                                                        <i class="fa-solid fa-dollar-sign me-1"></i> Thu tiền
                                                                    </button>
                                                                </form>
                                                                <form action="${pageContext.request.contextPath}/borrow-return" method="POST" class="d-inline">
                                                                    <input type="hidden" name="action" value="waiveFine">
                                                                    <input type="hidden" name="fineId" value="${fine.fine_id}">
                                                                    <button type="submit" class="btn btn-sm btn-outline-primary rounded-3 px-3 py-1.5" onclick="return confirm('Xác nhận miễn giảm khoản phạt này?')">
                                                                        <i class="fa-solid fa-handshake-angle me-1"></i> Miễn giảm
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </c:if>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty fineList}">
                                                <tr>
                                                    <td colspan="9" class="text-center py-4 text-muted">Không có phí phạt vi phạm nào được ghi nhận.</td>
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
            <div class="modal-content border-0 shadow-lg rounded-3">
                <form action="${pageContext.request.contextPath}/borrow-return" method="POST">
                    <input type="hidden" name="action" value="borrow">
                    <div class="modal-header bg-light border-bottom-0 py-3">
                        <h5 class="modal-title fw-bold text-dark" id="borrowModalLabel">Phiếu Tạo Mượn Sách Mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label for="readerId" class="form-label fw-semibold">1. Chọn Độc Giả</label>
                            <select class="form-select border shadow-sm rounded-3 py-2" name="readerId" id="readerId" required>
                                <option value="" disabled selected>-- Chọn độc giả mượn --</option>
                                <c:forEach var="r" items="${readerList}">
                                    <option value="${r.reader_id}">${r.full_name} (${r.email})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="copyId" class="form-label fw-semibold">2. Chọn Bản Sao Sách Có Sẵn</label>
                            <select class="form-select border shadow-sm rounded-3 py-2" name="copyId" id="copyId" required>
                                <option value="" disabled selected>-- Chọn mã bản sao & tên sách --</option>
                                <c:forEach var="c" items="${availableCopies}">
                                    <option value="${c.copy_id}">${c.barcode} - ${c.title}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="durationDays" class="form-label fw-semibold">3. Thời Hạn Mượn</label>
                            <select class="form-select border shadow-sm rounded-3 py-2" name="durationDays" id="durationDays" required>
                                <option value="7">7 Ngày</option>
                                <option value="14" selected>14 Ngày (Tiêu chuẩn)</option>
                                <option value="30">30 Ngày</option>
                                <option value="60">60 Ngày (Học tập chuyên sâu)</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 py-3 bg-light rounded-bottom-3">
                        <button type="button" class="btn btn-light rounded-3 px-4" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn btn-primary rounded-3 px-4">Tạo Phiếu Mượn</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Bộ lọc tìm kiếm nhanh trực tiếp trên Frontend -->
    <script>
        document.addEventListener("DOMContentLoaded", function () {
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

            if (borrowSearch) borrowSearch.addEventListener("input", filterBorrowTable);
            if (borrowStatusFilter) borrowStatusFilter.addEventListener("change", filterBorrowTable);

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

            if (finesSearch) finesSearch.addEventListener("input", filterFinesTable);
            if (finesStatusFilter) finesStatusFilter.addEventListener("change", filterFinesTable);
        });
    </script>
</body>
</html>
