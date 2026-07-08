<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết Danh Mục: ${category.name} - LibraryOS</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH -->
    <div class="d-flex">
        
        <!-- 1. CỘT TRÁI: NHÚNG SIDEBAR -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- 2. CỘT PHẢI: KHU VỰC NỘI DUNG -->
        <main class="w-100" style="min-height: 100vh; display: flex; flex-direction: column;">
            
            <!-- Header ngang -->
            <jsp:include page="/views/layout/header.jsp"/>

            <!-- Vùng đệm p-4 -->
            <div class="container-fluid p-4 flex-grow-1">
                
                <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/categories">
                                        <i class="fa-solid fa-tags me-1"></i>Quản lý danh mục
                                    </a>
                                </li>
                                <li class="breadcrumb-item active" aria-current="page">Chi tiết</li>
                            </ol>
                        </nav>
                        <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">Chi tiết danh mục</h1>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/categories" class="btn-back hover-lift">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                        </a>
                    </div>
                </div>

                <div class="row g-4">
                    
                    <!-- CỘT TRÁI: THÔNG TIN HỒ SƠ DANH MỤC (4/12) -->
                    <div class="col-12 col-lg-4">
                        <div class="card card-main bg-white p-4 border-0">
                            
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="bg-primary text-white rounded-3 d-flex align-items-center justify-content-center" style="width: 48px; height: 48px;">
                                    <i class="fa-solid fa-tags fs-4"></i>
                                </div>
                                <div>
                                    <h4 class="fw-bold text-dark mb-1" style="font-size:1.25rem;">${category.name}</h4>
                                    <span class="text-muted small">Mã số: <strong>#${category.categoryId}</strong></span>
                                </div>
                            </div>

                            <hr class="text-muted my-3">

                            <div class="mb-4 small text-secondary">
                                <div class="mb-3">
                                    <div class="fw-semibold text-dark mb-1">Mô tả chi tiết:</div>
                                    <p class="text-muted m-0 text-wrap lh-base" style="font-size:0.85rem;">
                                        ${not empty category.description ? category.description : "Không có mô tả chi tiết."}
                                    </p>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-5 fw-semibold">Ngày tạo:</div>
                                    <div class="col-7 text-dark">${category.createdAt}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-5 fw-semibold">Tổng đầu sách:</div>
                                    <div class="col-7 text-dark fw-bold">${fn:length(booksList)} đầu sách</div>
                                </div>
                            </div>

                            <div class="d-flex flex-column gap-2 mt-4">
                                <a href="${pageContext.request.contextPath}/categories?action=edit&id=${category.categoryId}" class="btn btn-primary w-100 hover-lift py-2.5">
                                    <i class="fa-solid fa-pen-to-square me-1"></i> Chỉnh sửa danh mục
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: DANH SÁCH ĐẦU SÁCH THUỘC DANH MỤC (8/12) -->
                    <div class="col-12 col-lg-8">
                        <div class="form-card bg-white h-100">
                            
                            <%-- Header Card --%>
                            <div class="form-card-header">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-book fs-5 text-white"></i>
                                    <h5 class="text-white fw-bold mb-0" style="font-size:1rem;">Danh sách sách thuộc danh mục</h5>
                                </div>
                            </div>
                            
                            <div class="p-0">
                                <div class="table-responsive">
                                    <table class="table-custom m-0">
                                        <thead>
                                            <tr>
                                                <th class="ps-4" style="width: 80px;">#</th>
                                                <th style="width: 70px;">Bìa</th>
                                                <th>Tên sách & Tác giả</th>
                                                <th>Nhà xuất bản & Năm</th>
                                                <th style="width: 150px;">Số lượng cuốn</th>
                                                <th style="width: 100px; text-align: center;">Xem</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty booksList}">
                                                    <tr>
                                                        <td colspan="6" class="text-center py-5 text-muted">
                                                            <i class="fa-solid fa-folder-open fs-2 mb-3 d-block text-secondary"></i>
                                                            Không có đầu sách nào thuộc danh mục này.
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="b" items="${booksList}" varStatus="loop">
                                                        <tr>
                                                            <td class="ps-4 text-muted fw-medium">${loop.index + 1}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${not empty b.imagePath}">
                                                                        <img src="${pageContext.request.contextPath}/${b.imagePath}" 
                                                                             alt="${b.title}" 
                                                                             style="width: 38px; height: 50px; object-fit: cover; border-radius: 4px; border: 1px solid var(--border);" 
                                                                             class="shadow-sm">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="book-cover-placeholder-mini" style="width: 38px; height: 50px; background: #e0e7ff; border-radius: 4px; border: 1px solid var(--border); display: inline-flex; align-items: center; justify-content: center; color: #312E81; font-size: 0.9rem;">
                                                                            <i class="fa-solid fa-book"></i>
                                                                        </div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <span class="fw-bold text-dark d-block">${b.title}</span>
                                                                <span class="text-muted small"><i class="fa-regular fa-user me-1"></i>${b.author}</span>
                                                                <div class="text-muted" style="font-size: 0.72rem; margin-top: 2px;">ID: #${b.bookId}</div>
                                                            </td>
                                                            <td>
                                                                <span class="d-block text-dark">${b.publisher}</span>
                                                                <span class="text-muted small">${b.publishYear != 0 ? b.publishYear : 'Chưa cập nhật'}</span>
                                                            </td>
                                                            <td>
                                                                <span class="badge-status badge-restore-custom fw-semibold">${b.availableCopies} / ${b.totalCopies} sẵn sàng</span>
                                                            </td>
                                                            <td class="text-center">
                                                                <a href="${pageContext.request.contextPath}/books?action=detail&id=${b.bookId}" class="btn-action hover-lift" title="Xem chi tiết đầu sách">
                                                                    <i class="fa-solid fa-eye text-primary"></i>
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
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

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
