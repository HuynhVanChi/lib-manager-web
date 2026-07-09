<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi Tiết Khoản Phạt #${item.fine_id} - LibraryOS</title>
    
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
            <div class="container-fluid p-4 flex-grow-1">

                <!-- Breadcrumbs điều hướng -->
                <div class="mb-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/borrow-return?tab=fines"><i class="fa-solid fa-house-chimney me-1"></i>Mượn trả & Vi phạm</a></li>
                            <li class="breadcrumb-item active" aria-current="page"><i class="fa-solid fa-file-invoice me-1"></i>Chi tiết khoản phạt #${item.fine_id}</li>
                        </ol>
                    </nav>
                </div>

                <!-- KHUNG THÔNG TIN CHI TIẾT -->
                <div class="card form-card mx-auto shadow-sm" style="max-width: 800px;">
                    <div class="card-header form-card-header text-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 fw-bold"><i class="fa-solid fa-receipt me-2"></i>Chi Tiết Khoản Phạt Vi Phạm</h5>
                        <span class="badge bg-white text-primary fw-bold px-3 py-1.5 rounded">#${item.fine_id}</span>
                    </div>
                    <div class="card-body p-4">
                        
                        <div class="row g-4 mb-4">
                            <!-- Độc Giả -->
                            <div class="col-md-6 border-end">
                                <div class="section-divider mt-0 mb-3">Thông tin độc giả vi phạm</div>
                                <table class="table table-borderless table-sm">
                                    <tr>
                                        <td class="text-muted" style="width: 130px;">Họ tên độc giả:</td>
                                        <td class="fw-bold text-dark">${item.reader_name}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Email độc giả:</td>
                                        <td class="fw-medium">${item.reader_email}</td>
                                    </tr>
                                </table>
                            </div>

                            <!-- Sách -->
                            <div class="col-md-6">
                                <div class="section-divider mt-0 mb-3">Thông tin sách liên quan</div>
                                <table class="table table-borderless table-sm">
                                    <tr>
                                        <td class="text-muted" style="width: 130px;">Tên sách:</td>
                                        <td class="fw-bold text-dark">${item.book_title}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Mã sách:</td>
                                        <td><code class="text-dark bg-light px-2 py-0.5 rounded border small">${item.barcode}</code></td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Mã phiếu mượn:</td>
                                        <td><a href="${pageContext.request.contextPath}/borrow-return/detail?id=${item.borrow_detail_id}" class="fw-bold text-decoration-none">#${item.borrow_detail_id}</a></td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Ngày mượn:</td>
                                        <td class="fw-medium">${item.borrow_date}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Hạn trả:</td>
                                        <td class="fw-medium text-warning">${item.due_date}</td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Ngày trả:</td>
                                        <td class="fw-medium text-success">
                                            <c:choose>
                                                <c:when test="${not empty item.return_date}">${item.return_date}</c:when>
                                                <c:otherwise><span class="text-muted">Chưa trả</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <div class="row g-4 mb-4">
                            <!-- Chi tiết phạt -->
                            <div class="col-md-6 border-end">
                                <div class="section-divider mt-0 mb-3">Thông tin số tiền phạt</div>
                                <table class="table table-borderless table-sm">
                                    <tr>
                                        <td class="text-muted" style="width: 130px;">Số tiền phạt:</td>
                                        <td class="fw-bold text-danger" style="font-size: 1.1rem;">
                                            <fmt:formatNumber value="${item.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted">Lý do phạt:</td>
                                        <td class="fw-bold">
                                            <c:set var="firstReason" value="true" />
                                            <c:if test="${item.reason.contains('Overdue')}">
                                                <span class="text-warning">Quá hạn</span>
                                                <c:set var="firstReason" value="false" />
                                            </c:if>
                                            <c:if test="${item.reason.contains('Damaged Book')}">
                                                <c:if test="${not firstReason}">, </c:if>
                                                <span class="text-danger">Hỏng sách</span>
                                                <c:set var="firstReason" value="false" />
                                            </c:if>
                                            <c:if test="${item.reason.contains('Lost Book')}">
                                                <c:if test="${not firstReason}">, </c:if>
                                                <span class="text-danger">Mất sách</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </table>
                            </div>

                            <!-- Trạng thái phạt -->
                            <div class="col-md-6">
                                <div class="section-divider mt-0 mb-3">Thông tin thanh toán</div>
                                <table class="table table-borderless table-sm">
                                    <tr>
                                        <td class="text-muted text-nowrap" style="width: 130px;">Trạng thái đóng:</td>
                                        <td class="text-nowrap">
                                            <c:choose>
                                                <c:when test="${item.status == 'Unpaid'}"><span class="badge bg-danger text-white px-2.5 py-1 text-nowrap" style="font-size: .8rem;">Chưa đóng</span></c:when>
                                                <c:when test="${item.status == 'Paid'}"><span class="badge bg-success text-white px-2.5 py-1 text-nowrap" style="font-size: .8rem;">Đã đóng</span></c:when>
                                                <c:when test="${item.status == 'Waived'}"><span class="badge bg-secondary text-white px-2.5 py-1 text-nowrap" style="font-size: .8rem;">Đã miễn giảm</span></c:when>
                                            </c:choose>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="text-muted text-nowrap">Ngày đóng tiền:</td>
                                        <td class="fw-medium text-success text-nowrap">
                                            <c:choose>
                                                <c:when test="${not empty item.paid_at}"><i class="fa-regular fa-calendar-check me-1"></i> <fmt:formatDate value="${item.paid_at}" pattern="yyyy-MM-dd"/></c:when>
                                                <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>

                        <!-- Ghi chú nếu có -->
                        <c:if test="${not empty item.notes}">
                            <div class="section-divider">Ghi chú từ thủ thư</div>
                            <div class="p-3 bg-light rounded border mb-4 text-dark" style="font-size: .9rem; line-height: 1.5;">
                                <c:out value="${item.notes}" />
                            </div>
                        </c:if>

                        <!-- Các Nút Điều Hướng -->
                        <div class="d-flex gap-2 justify-content-end mt-4 border-top pt-3">
                            <a href="${pageContext.request.contextPath}/borrow-return?tab=fines" class="btn btn-cancel hover-lift">
                                <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                            </a>
                            <a href="${pageContext.request.contextPath}/borrow-return/fine-edit?id=${item.fine_id}" class="btn btn-primary hover-lift">
                                <i class="fa-solid fa-pen-to-square me-1"></i> Chỉnh sửa khoản phạt
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
