<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Phiếu Mượn #${item.borrow_detail_id} - LibraryOS</title>
    
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
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/borrow-return/detail?id=${item.borrow_detail_id}">
                                    Phiếu mượn #${item.borrow_detail_id}
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">Chỉnh sửa</li>
                        </ol>
                    </nav>
                    <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                        Chỉnh sửa phiếu mượn #${item.borrow_detail_id}
                    </h1>
                </div>

                <%-- ── FORM CARD ── --%>
                <div class="form-card bg-white">

                    <%-- Header card --%>
                    <div class="form-card-header">
                        <div class="d-flex align-items-center gap-3">
                            <div class="rounded-circle d-flex align-items-center justify-content-center"
                                 style="width:44px;height:44px;background:rgba(255,255,255,.2);flex-shrink:0;">
                                <i class="fa-solid fa-file-signature text-white fs-5"></i>
                            </div>
                            <div>
                                <h5 class="text-white fw-bold mb-0">Chỉnh Sửa Phiếu Mượn</h5>
                                <p class="text-white mb-0" style="opacity:.75;font-size:.82rem;">
                                    Cập nhật thông tin chi tiết phiếu mượn sách
                                </p>
                            </div>
                        </div>
                    </div>

                    <%-- Body form --%>
                    <div class="p-4">
                        <form action="${pageContext.request.contextPath}/borrow-return/edit" method="POST" class="m-0" id="form-edit-borrow">
                            <input type="hidden" name="borrowDetailId" value="${item.borrow_detail_id}">
                            
                            <div class="row">
                                <%-- CỘT TRÁI: THÔNG TIN MƯỢN TRẢ --%>
                                <div class="col-lg-6 col-12 border-end pe-lg-4">
                                    <div class="section-divider">
                                        <i class="fa-solid fa-id-card me-2"></i>Thông tin mượn trả
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label text-muted">Độc giả</label>
                                        <input type="text" class="form-control bg-light text-muted" value="${item.reader_name} (${item.reader_email})" disabled style="opacity: 0.7;">
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label class="form-label text-muted">Sách mượn</label>
                                        <input type="text" class="form-control bg-light text-muted" value="${item.barcode} - ${item.book_title}" disabled style="opacity: 0.7;">
                                    </div>

                                    <div class="mb-3">
                                        <label for="borrowDate" class="form-label">Ngày Mượn <span class="required-mark">*</span></label>
                                        <input type="date" class="form-control" name="borrowDate" id="borrowDate" value="${item.borrow_date}" required>
                                    </div>

                                    <div class="mb-3">
                                        <label for="dueDate" class="form-label">Hạn Phải Trả <span class="required-mark">*</span></label>
                                        <input type="date" class="form-control" name="dueDate" id="dueDate" value="${item.due_date}" required>
                                    </div>

                                    <div class="mb-3">
                                        <label for="returnDate" class="form-label">Ngày Thực Trả</label>
                                        <input type="date" class="form-control" name="returnDate" id="returnDate" value="${item.return_date}">
                                        <div class="form-hint">Để trống nếu độc giả chưa trả sách.</div>
                                    </div>
                                </div>
                                
                                <%-- CỘT PHẢI: TRẠNG THÁI & HIỆN TRẠNG --%>
                                <div class="col-lg-6 col-12 ps-lg-4 mt-4 mt-lg-0">
                                    <div class="section-divider">
                                        <i class="fa-solid fa-gears me-2"></i>Trạng thái & Hiện trạng
                                    </div>

                                    <div class="mb-3">
                                        <label for="status" class="form-label">Trạng Thái Phiếu Mượn <span class="required-mark">*</span></label>
                                        <select class="form-select" name="status" id="status" required>
                                            <option value="Borrowing" ${item.status == 'Borrowing' ? 'selected' : ''}>Đang mượn</option>
                                            <option value="Returned" ${item.status == 'Returned' ? 'selected' : ''}>Đã trả</option>
                                            <option value="Overdue" ${item.status == 'Overdue' ? 'selected' : ''}>Quá hạn</option>
                                            <option value="Lost" ${item.status == 'Lost' ? 'selected' : ''}>Báo mất</option>
                                        </select>
                                    </div>

                                    <div class="mb-3">
                                        <label for="bookCondition" class="form-label">Hiện Trạng Sách Khi Trả <span class="required-mark">*</span></label>
                                        <select class="form-select" name="bookCondition" id="bookCondition" required>
                                            <option value="Bình thường" ${item.book_condition == 'Bình thường' || empty item.book_condition ? 'selected' : ''}>Bình thường (Không phạt)</option>
                                            <option value="Rách nhẹ" ${item.book_condition == 'Rách nhẹ' ? 'selected' : ''}>Rách nhẹ (Phạt 20% giá sách, tối thiểu 15k)</option>
                                            <option value="Rách nặng" ${item.book_condition == 'Rách nặng' ? 'selected' : ''}>Rách nặng (Phạt 80% giá sách)</option>
                                            <option value="Mất sách" ${item.book_condition == 'Mất sách' ? 'selected' : ''}>Mất sách (Phạt Giá sách + 20k)</option>
                                        </select>
                                        <div class="form-hint">Chọn hiện trạng thực tế của sách để hệ thống tự động ghi nhận biên bản phạt (nếu có vi phạm).</div>
                                    </div>

                                    <div class="mb-3">
                                        <label for="notes" class="form-label">Ghi Chú</label>
                                        <textarea class="form-control" name="notes" id="notes" rows="3" placeholder="Nhập ghi chú hoặc thông tin chi tiết về hiện trạng sách/vi phạm...">${item.notes}</textarea>
                                    </div>

                                    <div class="alert alert-info mb-0" style="font-size: 0.85rem;">
                                        <strong><i class="fa-solid fa-circle-info"></i> Quy định phạt vi phạm:</strong>
                                        <ul class="mb-0 mt-1 ps-3">
                                             <li><strong>Trễ hạn trả sách:</strong> Phạt 5.000đ/ngày, giới hạn tối đa bằng giá tiền sách.</li>
                                             <li><strong>Hỏng sách nhẹ:</strong> Phạt 20% giá sách, tối thiểu 15.000đ.</li>
                                             <li><strong>Hỏng sách nặng:</strong> Phạt 80% giá sách.</li>
                                             <li><strong>Mất sách:</strong> Phạt Giá sách + 20.000đ (Không cộng dồn trễ hạn).</li>
                                             <li><strong>Giới hạn:</strong> Tổng tiền phạt trễ + hỏng không vượt quá số tiền phạt mất sách (Giá sách + 20.000đ).</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            
                            <%-- ── FOOTER: Nút hành động ── --%>
                            <div class="d-flex align-items-center gap-3 mt-4 pt-3 border-top">
                                <button type="submit" id="btn-save" class="btn btn-save hover-lift">
                                    <i class="fa-solid fa-floppy-disk me-2"></i>Lưu thay đổi
                                </button>
                                <a href="${pageContext.request.contextPath}/borrow-return"
                                   id="btn-cancel"
                                   class="btn btn-cancel text-decoration-none hover-lift">
                                    <i class="fa-solid fa-arrow-left me-2"></i>Hủy
                                </a>
                                <span class="text-muted ms-auto" style="font-size:.78rem;">
                                    <span class="required-mark">*</span> Trường bắt buộc
                                </span>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // ── Hiệu ứng loading khi submit ──
        document.getElementById('form-edit-borrow').addEventListener('submit', function () {
            const btn = document.getElementById('btn-save');
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Đang lưu...';
        });
    </script>
</body>
</html>
