<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Khoản Phạt #${item.fine_id} - LibraryOS</title>
    
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
                            <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/borrow-return/fine-detail?id=${item.fine_id}"><i class="fa-solid fa-file-invoice me-1"></i>Chi tiết phạt #${item.fine_id}</a></li>
                            <li class="breadcrumb-item active" aria-current="page"><i class="fa-solid fa-pen me-1"></i>Chỉnh sửa khoản phạt</li>
                        </ol>
                    </nav>
                </div>

                <!-- BIỂU MẪU NHẬP LIỆU CHUẨN HÓA -->
                <div class="card form-card mx-auto shadow-sm" style="max-width: 800px;">
                    <div class="card-header form-card-header text-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 fw-bold"><i class="fa-solid fa-file-signature me-2"></i>Chỉnh Sửa Khoản Phạt</h5>
                        <button type="button" class="btn btn-success btn-sm hover-lift px-3 fw-bold" id="btnConfirmPayment">
                            <i class="fa-solid fa-check-double me-1"></i> Xác nhận đóng phạt
                        </button>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/borrow-return/fine-edit" method="POST" class="m-0">
                            <input type="hidden" name="fineId" value="${item.fine_id}">
                            
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label text-muted">Độc giả:</label>
                                    <input type="text" class="form-control bg-light" value="${item.reader_name}" readonly>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted">Tên sách:</label>
                                    <input type="text" class="form-control bg-light" value="${item.book_title}" readonly>
                                </div>
                            </div>

                            <div class="section-divider">Thông tin phạt tiền</div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label for="amount" class="form-label">Số Tiền Phạt (VND) <span class="required-mark">*</span></label>
                                    <input type="number" class="form-control" name="amount" id="amount" value="${item.amount}" step="1000" min="0" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label d-block">Lý Do Phạt (Có thể chọn nhiều) <span class="required-mark">*</span></label>
                                    <div class="d-flex flex-column gap-2 mt-2">
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" name="reason" id="reasonOverdue" value="Overdue" ${item.reason.contains('Overdue') ? 'checked' : ''}>
                                            <label class="form-check-label" for="reasonOverdue">Quá hạn trả sách (Overdue)</label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" name="reason" id="reasonDamaged" value="Damaged Book" ${item.reason.contains('Damaged Book') ? 'checked' : ''}>
                                            <label class="form-check-label" for="reasonDamaged">Hỏng sách (Damaged Book)</label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="checkbox" name="reason" id="reasonLost" value="Lost Book" ${item.reason.contains('Lost Book') ? 'checked' : ''}>
                                            <label class="form-check-label" for="reasonLost">Mất sách (Lost Book)</label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label for="status" class="form-label">Trạng Thái Khoản Phạt <span class="required-mark">*</span></label>
                                    <select class="form-select" name="status" id="status" required>
                                        <option value="Unpaid" ${item.status == 'Unpaid' ? 'selected' : ''}>Chưa đóng phạt</option>
                                        <option value="Paid" ${item.status == 'Paid' ? 'selected' : ''}>Đã đóng phạt</option>
                                        <option value="Waived" ${item.status == 'Waived' ? 'selected' : ''}>Đã miễn giảm</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="paidAt" class="form-label">Ngày Đóng Phạt (Nếu có)</label>
                                    <input type="datetime-local" class="form-control" name="paidAt" id="paidAt" value="${item.paid_at}">
                                    <div class="form-hint">Để trống nếu chưa thu tiền phạt. Mốc thời gian mặc định là ngày giờ hiện tại khi lưu.</div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label for="notes" class="form-label">Ghi Chú</label>
                                <textarea class="form-control" name="notes" id="notes" rows="3" placeholder="Nhập ghi chú hoặc thông tin chi tiết về hiện trạng sách/vi phạm...">${item.notes}</textarea>
                            </div>

                            <div class="d-flex gap-2 justify-content-end mt-4 border-top pt-3">
                                <a href="${pageContext.request.contextPath}/borrow-return?tab=fines" class="btn btn-cancel hover-lift">
                                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                                </a>
                                <button type="submit" class="btn btn-save hover-lift">
                                    <i class="fa-solid fa-floppy-disk me-1"></i> Lưu thay đổi
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Script tự động điền thanh toán -->
    <script>
        document.getElementById('btnConfirmPayment').addEventListener('click', function() {
            const statusSelect = document.getElementById('status');
            const paidAtInput = document.getElementById('paidAt');
            
            // Cập nhật trạng thái sang Paid
            statusSelect.value = 'Paid';
            
            // Format ngày giờ hiện tại sang định dạng YYYY-MM-DDThh:mm
            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            
            paidAtInput.value = `${year}-${month}-${day}T${hours}:${minutes}`;
            
            // Đổi màu viền báo hiệu
            statusSelect.style.borderColor = '#10B981';
            paidAtInput.style.borderColor = '#10B981';
            
            alert('Đã cập nhật trạng thái "Đã đóng phạt" và điền thời gian hôm nay.\nVui lòng bấm "Lưu thay đổi" để xác nhận!');
        });

        // Đảm bảo chọn ít nhất một checkbox
        document.querySelector('form').addEventListener('submit', function(e) {
            const checkedReasons = document.querySelectorAll('input[name="reason"]:checked');
            if (checkedReasons.length === 0) {
                alert('Vui lòng chọn ít nhất một lý do phạt!');
                e.preventDefault();
            }
        });
    </script>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
