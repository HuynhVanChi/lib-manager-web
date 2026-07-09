<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Thêm độc giả mới vào hệ thống - LibraryOS">
    <title>Thêm Độc giả - LibraryOS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

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
            <div class="mb-4">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/readers">
                                <i class="fa-solid fa-users me-1"></i>Độc giả
                            </a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">Thêm mới</li>
                    </ol>
                </nav>
                <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                    Thêm độc giả mới
                </h1>
            </div>

            <%-- ── FORM CARD ── --%>
            <div class="card form-card">

                <%-- Header card --%>
                <div class="card-header form-card-header text-white d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center"
                             style="width:44px;height:44px;background:rgba(255,255,255,.2);flex-shrink:0;">
                            <i class="fa-solid fa-user-plus text-white fs-5"></i>
                        </div>
                        <div>
                            <h5 class="text-white fw-bold mb-0">Thông tin độc giả</h5>
                            <p class="text-white mb-0" style="opacity:.75;font-size:.82rem;">
                                Điền đầy đủ thông tin để tạo tài khoản độc giả mới
                            </p>
                        </div>
                    </div>
                </div>

                <%-- Body form --%>
                <div class="p-4">

                    <%-- Thông báo lỗi toàn cục --%>
                    <c:if test="${not empty globalError}">
                        <div class="global-error" id="global-error-banner">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <c:out value="${globalError}"/>
                        </div>
                    </c:if>

                    <%-- Form thêm mới --%>
                    <form method="post"
                          action="${pageContext.request.contextPath}/readers/add"
                          id="form-add-reader"
                          novalidate>

                        <div class="row">
                            <%-- CỘT TRÁI: THÔNG TIN CÁ NHÂN --%>
                            <div class="col-lg-6 col-12 border-end pe-lg-4">
                                <div class="section-divider">
                                    <i class="fa-solid fa-id-card me-2"></i>Thông tin cá nhân
                                </div>

                                <%-- Họ và tên --%>
                                <div class="mb-3">
                                    <label for="fullName" class="form-label">
                                        Họ và tên <span class="required-mark">*</span>
                                    </label>
                                    <input type="text"
                                           id="fullName"
                                           name="fullName"
                                           class="form-control ${not empty fieldErrors['fullName'] ? 'is-invalid' : ''}"
                                           placeholder="Ví dụ: Nguyễn Văn An"
                                           value="<c:out value='${reader.fullName}'/>"
                                           maxlength="150"
                                           autocomplete="name">
                                    <c:if test="${not empty fieldErrors['fullName']}">
                                        <div class="field-error" id="error-fullName">
                                            <i class="fa-solid fa-circle-exclamation"></i>
                                            <c:out value="${fieldErrors['fullName']}"/>
                                        </div>
                                    </c:if>
                                </div>

                                <%-- Email --%>
                                <div class="mb-3">
                                    <label for="email" class="form-label">
                                        Email <span class="required-mark">*</span>
                                    </label>
                                    <input type="email"
                                           id="email"
                                           name="email"
                                           class="form-control ${not empty fieldErrors['email'] ? 'is-invalid' : ''}"
                                           placeholder="Ví dụ: nguyenvanan@gmail.com"
                                           value="<c:out value='${reader.email}'/>"
                                           maxlength="100"
                                           autocomplete="email">
                                    <c:if test="${not empty fieldErrors['email']}">
                                        <div class="field-error" id="error-email">
                                            <i class="fa-solid fa-circle-exclamation"></i>
                                            <c:out value="${fieldErrors['email']}"/>
                                        </div>
                                    </c:if>
                                    <div class="form-hint">
                                        <i class="fa-solid fa-circle-info me-1"></i>
                                        Email dùng làm định danh duy nhất, không thể trùng với độc giả khác.
                                    </div>
                                </div>

                                <%-- Số điện thoại --%>
                                <div class="mb-3">
                                    <label for="phone" class="form-label">Số điện thoại</label>
                                    <input type="tel"
                                           id="phone"
                                           name="phone"
                                           class="form-control ${not empty fieldErrors['phone'] ? 'is-invalid' : ''}"
                                           placeholder="Ví dụ: 0912345678"
                                           value="<c:out value='${reader.phone}'/>"
                                           maxlength="20"
                                           autocomplete="tel">
                                    <c:if test="${not empty fieldErrors['phone']}">
                                        <div class="field-error" id="error-phone">
                                            <i class="fa-solid fa-circle-exclamation"></i>
                                            <c:out value="${fieldErrors['phone']}"/>
                                        </div>
                                    </c:if>
                                    <div class="form-hint">Không bắt buộc. Nếu nhập thì không được trùng với độc giả khác.</div>
                                </div>
                            </div>

                            <%-- CỘT PHẢI: THẺ THÀNH VIÊN --%>
                            <div class="col-lg-6 col-12 ps-lg-4 mt-4 mt-lg-0">
                                <div class="section-divider">
                                    <i class="fa-solid fa-id-badge me-2"></i>Thẻ thành viên
                                </div>

                                <%-- Ngày hết hạn thẻ --%>
                                <div class="mb-3">
                                    <label for="membershipExpiredAt" class="form-label">Ngày hết hạn thẻ</label>
                                    <input type="date"
                                           id="membershipExpiredAt"
                                           name="membershipExpiredAt"
                                           class="form-control"
                                           value="<c:if test='${reader.membershipExpiredAt != null}'><fmt:formatDate value='${reader.membershipExpiredAt}' pattern='yyyy-MM-dd'/></c:if>">
                                    <div class="form-hint">Không bắt buộc. Để trống nếu chưa xác định.</div>
                                </div>

                                <%-- Trạng thái --%>
                                <div class="mb-3">
                                    <label for="status" class="form-label">
                                        Trạng thái <span class="required-mark">*</span>
                                    </label>
                                    <select id="status"
                                            name="status"
                                            class="form-select ${not empty fieldErrors['status'] ? 'is-invalid' : ''}">
                                        <option value="Active"
                                                ${reader.status == null || reader.status == 'Active' ? 'selected' : ''}>
                                            Đang hoạt động (Active)
                                        </option>
                                        <option value="Suspended"
                                                ${reader.status == 'Suspended' ? 'selected' : ''}>
                                            Bị đình chỉ (Suspended)
                                        </option>
                                        <option value="Expired"
                                                ${reader.status == 'Expired' ? 'selected' : ''}>
                                            Hết hạn thẻ (Expired)
                                        </option>
                                    </select>
                                    <c:if test="${not empty fieldErrors['status']}">
                                        <div class="field-error" id="error-status">
                                            <i class="fa-solid fa-circle-exclamation"></i>
                                            <c:out value="${fieldErrors['status']}"/>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <%-- ── FOOTER: Nút hành động ── --%>
                        <div class="d-flex align-items-center gap-3 mt-4 pt-3 border-top">
                            <button type="submit" id="btn-save" class="btn btn-save hover-lift">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu độc giả
                            </button>
                            <a href="${pageContext.request.contextPath}/readers"
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
                <%-- END Body --%>

            </div>
            <%-- END FORM CARD --%>

        </div>
    </main>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ── Ngăn chọn ngày trong quá khứ cho hạn thẻ ──
    (function () {
        const dateInput = document.getElementById('membershipExpiredAt');
        if (dateInput && !dateInput.value) {
            // Đặt min là ngày hôm nay nếu chưa có giá trị
            const today = new Date().toISOString().split('T')[0];
            dateInput.min = today;
        }
    })();

    // ── Hiệu ứng loading khi submit ──
    document.getElementById('form-add-reader').addEventListener('submit', function () {
        const btn = document.getElementById('btn-save');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Đang lưu...';
    });
</script>
</body>
</html>
