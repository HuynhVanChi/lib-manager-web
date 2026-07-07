<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chỉnh sửa thông tin độc giả - LibraryOS">
    <title>Chỉnh sửa Độc giả - LibraryOS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <style>
        /* ── Card form ── */
        .form-card {
            border: none;
            border-radius: var(--radius);
            box-shadow: 0 1px 4px rgba(0,0,0,.07), 0 4px 16px rgba(0,0,0,.05);
            max-width: 1000px;
        }
        .form-card-header {
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            border-radius: var(--radius) var(--radius) 0 0;
            padding: 24px 28px;
        }

        /* ── Reader info badge (hiển thị ID và ngày tạo) ── */
        .reader-meta-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255,255,255,.15);
            border-radius: 20px;
            padding: 4px 12px;
            font-size: .75rem;
            color: rgba(255,255,255,.85);
            margin-top: 8px;
        }

        /* ── Form fields ── */
        .form-label {
            font-size: .83rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 6px;
        }
        .required-mark { color: var(--error); margin-left: 3px; }

        .form-control, .form-select {
            border: 1.5px solid var(--border);
            border-radius: 8px;
            padding: 10px 14px;
            font-size: .9rem;
            transition: border-color .2s, box-shadow .2s;
            background-color: #fff;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--border-focus);
            box-shadow: 0 0 0 3px rgba(49,46,129,.1);
            outline: none;
        }

        /* ── Trạng thái lỗi ── */
        .form-control.is-invalid, .form-select.is-invalid {
            border-color: var(--error);
            background-image: none;
        }
        .form-control.is-invalid:focus, .form-select.is-invalid:focus {
            box-shadow: 0 0 0 3px rgba(220,38,38,.12);
        }
        .field-error {
            font-size: .78rem;
            color: var(--error);
            margin-top: 5px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        /* ── Input hint ── */
        .form-hint {
            font-size: .75rem;
            color: var(--text-muted);
            margin-top: 4px;
        }

        /* ── Section divider ── */
        .section-divider {
            font-size: .75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .8px;
            color: var(--text-muted);
            border-bottom: 1px solid var(--border);
            padding-bottom: 8px;
            margin-bottom: 20px;
        }

        /* ── Global error banner ── */
        .global-error {
            background: var(--error-bg);
            border: 1.5px solid var(--error-border);
            border-radius: 8px;
            padding: 12px 16px;
            font-size: .875rem;
            color: var(--error);
            margin-bottom: 20px;
        }

        /* ── Change indicator: highlight field đang thay đổi ── */
        .form-control.changed, .form-select.changed {
            border-color: var(--secondary);
            background-color: #FEFCE8;
        }

        /* ── Detail link ── */
        .btn-detail-link {
            font-size: .82rem;
            color: var(--text-muted);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            transition: color .15s;
        }
        .btn-detail-link:hover { color: var(--primary); }
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

            <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
            <div class="mb-4">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/readers">
                                <i class="fa-solid fa-users me-1"></i>Độc giả
                            </a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/readers/detail?id=${reader.readerId}">
                                <c:out value="${reader.fullName}"/>
                            </a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">Chỉnh sửa</li>
                    </ol>
                </nav>
                <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                    Chỉnh sửa thông tin độc giả
                </h1>
            </div>

            <%-- ── FORM CARD ── --%>
            <div class="form-card bg-white">

                <%-- Header card --%>
                <div class="form-card-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center"
                             style="width:44px;height:44px;background:rgba(255,255,255,.15);flex-shrink:0;">
                            <i class="fa-solid fa-user-pen text-white fs-5"></i>
                        </div>
                        <div>
                            <h5 class="text-white fw-bold mb-0">
                                <c:out value="${reader.fullName}"/>
                            </h5>
                            <div class="reader-meta-badge">
                                <i class="fa-solid fa-hashtag" style="font-size:.7rem;"></i>
                                ID: ${reader.readerId}
                                &nbsp;·&nbsp;
                                <i class="fa-regular fa-calendar" style="font-size:.7rem;"></i>
                                Tạo: <fmt:formatDate value="${reader.createdAt}" pattern="dd/MM/yyyy"/>
                            </div>
                        </div>
                        <%-- Link xem chi tiết từ form edit --%>
                        <a href="${pageContext.request.contextPath}/readers/detail?id=${reader.readerId}"
                           class="btn-detail-link ms-auto"
                           title="Xem chi tiết độc giả">
                            <i class="fa-solid fa-arrow-up-right-from-square" style="color:rgba(255,255,255,.6);"></i>
                            <span style="color:rgba(255,255,255,.6);">Xem chi tiết</span>
                        </a>
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

                    <%-- Form chỉnh sửa --%>
                    <form method="post"
                          action="${pageContext.request.contextPath}/readers/edit"
                          id="form-edit-reader"
                          novalidate>

                        <%-- Hidden field: reader_id để servlet biết đang edit ai --%>
                        <input type="hidden" name="readerId" value="${reader.readerId}">

                        <%-- ─ PHẦN: THÔNG TIN CÁ NHÂN ─ --%>
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
                                    <div class="form-hint">Để trống nếu không giới hạn thời hạn thẻ.</div>
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
                                                ${reader.status == 'Active' ? 'selected' : ''}>
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
                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu thay đổi
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
    // ── Đánh dấu field đã thay đổi so với giá trị ban đầu ──
    (function () {
        const inputs = document.querySelectorAll('#form-edit-reader input, #form-edit-reader select');
        inputs.forEach(function (el) {
            if (el.type === 'hidden') return;
            const original = el.value;
            el.addEventListener('input', function () {
                if (el.value !== original) {
                    el.classList.add('changed');
                } else {
                    el.classList.remove('changed');
                }
            });
        });
    })();

    // ── Cảnh báo khi rời trang nếu đang có thay đổi chưa lưu ──
    (function () {
        let hasChanges = false;
        const inputs = document.querySelectorAll('#form-edit-reader input, #form-edit-reader select');

        inputs.forEach(function (el) {
            if (el.type === 'hidden') return;
            el.addEventListener('change', function () { hasChanges = true; });
        });

        // Khi submit form: tắt cảnh báo
        document.getElementById('form-edit-reader').addEventListener('submit', function () {
            hasChanges = false;
            const btn = document.getElementById('btn-save');
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i>Đang lưu...';
        });

        window.addEventListener('beforeunload', function (e) {
            if (hasChanges) {
                e.preventDefault();
                e.returnValue = '';
            }
        });
    })();
</script>
</body>
</html>
