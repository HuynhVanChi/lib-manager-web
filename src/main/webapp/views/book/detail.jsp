<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map,book.Book,book.BookCopy"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Chi Tiết Sách - LibraryOS</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/assets/css/category-colors.css" rel="stylesheet" type="text/css">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH: Cột trái (Sidebar) + Cột phải (Content) -->
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
                                    <a href="${pageContext.request.contextPath}/books">
                                        <i class="fa-solid fa-book me-1"></i>Quản lý sách
                                    </a>
                                </li>
                                <li class="breadcrumb-item active" aria-current="page">Chi tiết</li>
                            </ol>
                        </nav>
                        <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">Hồ sơ chi tiết đầu sách</h1>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/books" id="btn-back" class="btn-back hover-lift">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                        </a>
                    </div>
                </div>

                <!-- Bố cục 2 Cột chính -->
                <div class="row g-4">
                    
                    <!-- CỘT TRÁI: THÔNG TIN HỒ SƠ ĐẦU SÁCH (4/12) -->
                    <div class="col-12 col-lg-4">
                        <div class="card card-main bg-white p-4 border-0">
                            <c:choose>
                                <c:when test="${not empty book.imagePath}">
                                    <div class="mb-4 text-center" style="height: 320px; overflow: hidden; border-radius: 8px; border: 1px solid var(--border);">
                                        <img src="${pageContext.request.contextPath}/${book.imagePath}" 
                                             alt="${book.title}" 
                                             class="w-100 h-100 shadow-sm" 
                                             style="object-fit: cover;">
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="book-cover-placeholder mb-4" style="height: 320px; background: linear-gradient(135deg, var(--primary-soft), var(--secondary)); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 3rem; box-shadow: inset 0 0 20px rgba(49, 46, 129, 0.1);">
                                        <i class="fa-solid fa-book"></i>
                                    </div>
                                </c:otherwise>
                             </c:choose>
                            
                            <h4 class="fw-bold text-dark mb-1" style="font-size:1.35rem;">${book.title}</h4>
                            <p class="text-muted small mb-1"><i class="fa-regular fa-user me-1"></i>Tác giả: <strong>${book.author}</strong></p>
                            
                            <div class="mb-3">
                                <span class="badge-status badge-theme-${book.categoryColorTheme} px-3 py-1.5 fs-7">${book.categoryName}</span>
                            </div>

                            <hr class="text-muted my-3">

                            <div class="mb-2 small text-secondary">
                                <div class="row mb-2">
                                    <div class="col-5 fw-semibold">Nhà xuất bản:</div>
                                    <div class="col-7 text-dark">${book.publisher}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-5 fw-semibold text-nowrap">Năm xuất bản:</div>
                                    <div class="col-7 text-dark">${book.publishYear != 0 ? book.publishYear : 'Chưa cập nhật'}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-5 fw-semibold">Giá nhập:</div>
                                    <div class="col-7 text-dark fw-bold text-primary">
                                        <fmt:formatNumber value="${book.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-5 fw-semibold">Ngày thêm:</div>
                                    <div class="col-7 text-dark"><span class="small font-monospace">${book.createdAt}</span></div>
                                </div>

                            </div>

                            <div class="d-flex flex-column gap-2 mt-2">
                                <a href="${pageContext.request.contextPath}/books?action=edit&id=${book.bookId}" class="btn btn-primary w-100 hover-lift py-2.5">
                                    <i class="fa-solid fa-pen-to-square me-1"></i> Chỉnh sửa đầu sách
                                </a>
                                <a href="${pageContext.request.contextPath}/books?action=copies&id=${book.bookId}" class="btn-back w-100 hover-lift py-2.5">
                                    <i class="fa-solid fa-boxes-stacked me-1"></i> Quản lý cuốn sách (${book.totalCopies})
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: DANH SÁCH CUỐN SÁCH (8/12) -->
                    <div class="col-12 col-lg-8">
                        <div class="card detail-card bg-white h-100">
                            
                            <%-- Header Card --%>
                            <div class="detail-card-header">
                                <i class="fa-solid fa-boxes-stacked text-primary"></i>
                                Danh sách cuốn sách hiện có
                            </div>
                            
                            <div class="p-0">
                                <c:choose>
                                    <c:when test="${empty copiesList}">
                                        <div class="empty-state p-5">
                                            <div class="icon"><i class="fa-solid fa-box-open text-muted"></i></div>
                                            <h5 class="fw-bold text-dark mb-1">Chưa có cuốn sách nào</h5>
                                            <p class="text-muted small mb-4">Đầu sách này hiện chưa có cuốn sách vật lý nào trong kho.</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table-custom m-0">
                                                <thead>
                                                    <tr>
                                                        <th class="ps-4" style="width: 80px;">ID</th>
                                                        <th>Mã vạch & ID</th>
                                                        <th>Giá nhập</th>
                                                        <th>Vị trí kệ sách</th>
                                                        <th style="width: 180px;">Trạng thái</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="c" items="${copiesList}" varStatus="loop">
                                                        <tr>
                                                            <td class="ps-4 text-muted fw-medium">#${c.copyId}</td>
                                                            <td>
                                                                <span class="font-monospace fw-bold text-dark">${c.barcode}</span>
                                                                <div class="text-muted" style="font-size: 0.75rem; margin-top: 2px;">ID: #${c.copyId}</div>
                                                            </td>
                                                            <td class="fw-semibold text-dark">
                                                                <fmt:formatNumber value="${c.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                            </td>
                                                            <td>${empty c.locationShelf ? 'Chưa xếp kệ' : c.locationShelf}</td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${c.status == 'Available'}">
                                                                        <span class="badge-status badge-active">
                                                                            <i class="fa-solid fa-circle-check me-1" style="font-size:.65rem;"></i>Sẵn có
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Borrowed'}">
                                                                        <span class="badge-status badge-info-custom">
                                                                            <i class="fa-solid fa-book-open me-1" style="font-size:.65rem;"></i>Đang mượn
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Damaged'}">
                                                                        <span class="badge-status badge-suspended">
                                                                            <i class="fa-solid fa-triangle-exclamation me-1" style="font-size:.65rem;"></i>Bị hỏng
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Lost'}">
                                                                        <span class="badge-status badge-danger-custom">
                                                                            <i class="fa-solid fa-circle-question me-1" style="font-size:.65rem;"></i>Bị mất
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Decommissioned'}">
                                                                        <span class="badge-status badge-expired">
                                                                            <i class="fa-solid fa-box-archive me-1" style="font-size:.65rem;"></i>Thanh lý
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge-status badge-expired">${c.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
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
