<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Thêm đề xuất sách mới - LibraryOS">
    <title>Thêm Đề xuất Sách - LibraryOS</title>

    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
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
                            <a href="${pageContext.request.contextPath}/recommend">
                                <i class="fa-solid fa-book-open-reader me-1"></i>Đề xuất sách
                            </a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">Tạo mới</li>
                    </ol>
                </nav>
                <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                    Ghi nhận đề xuất sách
                </h1>
            </div>

            <%-- ── FORM CARD ── --%>
            <div class="card form-card">

                <%-- Header card --%>
                <div class="card-header form-card-header text-white d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center"
                             style="width:44px;height:44px;background:rgba(255,255,255,.2);flex-shrink:0;">
                            <i class="fa-solid fa-plus text-white fs-5"></i>
                        </div>
                        <div>
                            <h5 class="mb-0 fw-bold">Yêu cầu đề xuất sách</h5>
                            <p class="text-white mb-0" style="opacity:.75;font-size:.82rem;">
                                Ghi nhận thông tin độc giả và thông tin ấn phẩm cần đề xuất mua bổ sung
                            </p>
                        </div>
                    </div>
                </div>

                <%-- Body form --%>
                <div class="card-body p-4">

                    <%-- Thông báo lỗi toàn cục --%>
                    <c:if test="${not empty error}">
                        <div class="global-error" id="global-error-banner">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <c:out value="${error}"/>
                        </div>
                    </c:if>

                    <%-- Form thêm mới --%>
                    <form method="post"
                          action="${pageContext.request.contextPath}/recommend/add"
                          id="form-add-recommendation"
                          novalidate>

                        <div class="row">
                            <%-- CỘT TRÁI: THÔNG TIN ĐỘC GIẢ --%>
                            <div class="col-lg-6 col-12 border-end pe-lg-4">
                                <div class="section-divider">
                                    <i class="fa-solid fa-user me-2"></i>Thông tin độc giả đề xuất
                                </div>

                                <%-- Họ và tên độc giả --%>
                                <div class="mb-3">
                                    <label for="readerName" class="form-label">
                                        Họ và tên độc giả <span class="required-mark">*</span>
                                    </label>
                                    <input type="text"
                                           id="readerName"
                                           name="readerName"
                                           class="form-control"
                                           placeholder="Ví dụ: Nguyễn Văn An"
                                           value="<c:out value='${readerName}'/>"
                                           maxlength="150"
                                           required>
                                </div>

                                <%-- Số điện thoại --%>
                                <div class="mb-3">
                                    <label for="readerPhone" class="form-label">Số điện thoại độc giả</label>
                                    <input type="tel"
                                           id="readerPhone"
                                           name="readerPhone"
                                           class="form-control"
                                           placeholder="Ví dụ: 0912345678"
                                           value="<c:out value='${readerPhone}'/>"
                                           maxlength="20">
                                </div>



                                <%-- Lý do đề xuất --%>
                                <div class="mb-3">
                                    <label for="reason" class="form-label">Lý do đề xuất của độc giả</label>
                                    <textarea class="form-control" 
                                              id="reason" 
                                              name="reason" 
                                              rows="3" 
                                              placeholder="Ví dụ: Học sinh mượn để nghiên cứu làm đồ án tốt nghiệp..."
                                    ><c:out value="${reason}"/></textarea>
                                </div>
                            </div>

                            <%-- CỘT PHẢI: THÔNG TIN ẤN PHẨM --%>
                            <div class="col-lg-6 col-12 ps-lg-4 mt-4 mt-lg-0">
                                <div class="section-divider">
                                    <i class="fa-solid fa-book me-2"></i>Thông tin ấn phẩm đề xuất
                                </div>

                                <%-- Tên sách --%>
                                <div class="mb-3">
                                    <label for="bookTitle" class="form-label">
                                        Tên sách đề xuất <span class="required-mark">*</span>
                                    </label>
                                    <input type="text"
                                           id="bookTitle"
                                           name="bookTitle"
                                           class="form-control"
                                           placeholder="Ví dụ: Clean Code"
                                           value="<c:out value='${bookTitle}'/>"
                                           maxlength="255"
                                           required>
                                </div>

                                <%-- Tác giả --%>
                                <div class="mb-3">
                                    <label for="author" class="form-label">
                                        Tác giả <span class="required-mark">*</span>
                                    </label>
                                    <input type="text"
                                           id="author"
                                           name="author"
                                           class="form-control"
                                           placeholder="Ví dụ: Robert C. Martin"
                                           value="<c:out value='${author}'/>"
                                           maxlength="150"
                                           required>
                                </div>
                            </div>
                        </div>

                        <%-- ── FOOTER: Nút hành động ── --%>
                        <div class="d-flex align-items-center gap-3 mt-4 pt-3 border-top">
                            <button type="submit" id="btn-save" class="btn btn-save hover-lift">
                                <i class="fa-solid fa-floppy-disk me-2"></i>Lưu đề xuất
                            </button>
                            <a href="${pageContext.request.contextPath}/recommend"
                               id="btn-cancel"
                               class="btn btn-cancel hover-lift text-decoration-none">
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
</body>
</html>
