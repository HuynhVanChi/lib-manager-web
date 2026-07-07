<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map,book.Book,book.BookCopy"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ Sơ Chi Tiết Sách - LibraryOS</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
        }
        .bg-indigo-brand {
            background-color: #312E81 !important;
        }
        .text-indigo-brand {
            color: #312E81 !important;
        }
        .btn-indigo-brand {
            background-color: #312E81;
            color: #ffffff;
            border: none;
            transition: all 0.2s ease-in-out;
        }
        .btn-indigo-brand:hover {
            background-color: #1e1b4b;
            color: #ffffff;
            transform: translateY(-1px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
        .btn-outline-indigo-brand {
            border: 2px solid #312E81;
            color: #312E81;
            background-color: transparent;
            font-weight: 600;
        }
        .btn-outline-indigo-brand:hover {
            background-color: #312E81;
            color: #ffffff;
        }
        .card-custom {
            border: none;
            border-radius: 12px;
        }
        .table-premium th {
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            color: #4b5563;
            background-color: #f3f4f6;
            border-bottom: 2px solid #e5e7eb;
        }
        .table-premium td {
            font-size: 0.875rem;
            color: #1f2937;
        }
        /* Custom badges */
        .badge-soft-purple {
            background-color: rgba(167, 139, 250, 0.15);
            color: #6d28d9;
            font-weight: 500;
        }
        .badge-soft-success {
            background-color: rgba(34, 197, 94, 0.1);
            color: #15803d;
            border: 1px solid rgba(34, 197, 94, 0.2);
        }
        .badge-soft-warning {
            background-color: rgba(245, 158, 11, 0.1);
            color: #b45309;
            border: 1px solid rgba(245, 158, 11, 0.2);
        }
        .badge-soft-danger {
            background-color: rgba(239, 68, 68, 0.1);
            color: #b91c1c;
            border: 1px solid rgba(239, 68, 68, 0.2);
        }
        .badge-soft-secondary {
            background-color: rgba(107, 114, 128, 0.1);
            color: #4b5563;
            border: 1px solid rgba(107, 114, 128, 0.2);
        }
        .book-cover-placeholder {
            width: 100%;
            height: 250px;
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #312E81;
            font-size: 3rem;
            box-shadow: inset 0 0 20px rgba(49, 46, 129, 0.1);
        }
    </style>
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
                
                <!-- Thanh hướng dẫn điều hướng (Breadcrumbs) -->
                <nav aria-label="breadcrumb" class="mb-4">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/books" class="text-indigo-brand text-decoration-none fw-medium">Quản lý Sách</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Hồ sơ chi tiết</li>
                    </ol>
                </nav>

                <!-- Bố cục 2 Cột chính -->
                <div class="row g-4">
                    
                    <!-- CỘT TRÁI: THÔNG TIN HỒ SƠ ĐẦU SÁCH (4/12) -->
                    <div class="col-12 col-lg-4">
                        <div class="card card-custom shadow-sm bg-white p-4">
                            <div class="book-cover-placeholder mb-4">
                                <i class="fa-solid fa-book"></i>
                            </div>
                            
                            <h4 class="fw-bold text-dark mb-1">${book.title}</h4>
                            <p class="text-muted small mb-3"><i class="fa-regular fa-user me-1"></i>Tác giả: <strong>${book.author}</strong></p>
                            
                            <div class="mb-3">
                                <span class="badge badge-soft-purple rounded-pill px-3 py-1.5 fs-7">${book.categoryName}</span>
                            </div>

                            <hr class="text-muted my-3">

                            <div class="mb-4 small text-secondary">
                                <div class="row mb-2">
                                    <div class="col-4 fw-semibold">Nhà xuất bản:</div>
                                    <div class="col-8 text-dark">${book.publisher}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-4 fw-semibold">Năm xuất bản:</div>
                                    <div class="col-8 text-dark">${book.publishYear != 0 ? book.publishYear : 'Chưa cập nhật'}</div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-4 fw-semibold">Ngày thêm:</div>
                                    <div class="col-8 text-dark"><span class="small font-monospace">${book.createdAt}</span></div>
                                </div>
                                <div class="row mb-2">
                                    <div class="col-4 fw-semibold">Tóm tắt:</div>
                                    <div class="col-8 text-dark">Tác phẩm văn học/tài liệu tham khảo chuyên ngành được lưu giữ trong hệ thống LibraryOS.</div>
                                </div>
                            </div>

                            <div class="d-flex flex-column gap-2 mt-4">
                                <a href="${pageContext.request.contextPath}/books?action=edit&id=${book.bookId}" class="btn btn-outline-indigo-brand rounded-3 py-2 fw-semibold w-100">
                                    <i class="fa-solid fa-pen-to-square me-1"></i> Chỉnh sửa đầu sách
                                </a>
                                <a href="${pageContext.request.contextPath}/books?action=copies&id=${book.bookId}" class="btn btn-indigo-brand rounded-3 py-2 fw-semibold w-100">
                                    <i class="fa-solid fa-boxes-stacked me-1"></i> Quản lý bản sao (${book.totalCopies})
                                </a>
                                <a href="${pageContext.request.contextPath}/books" class="btn btn-light rounded-3 py-2 fw-semibold w-100 text-secondary">
                                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại danh sách
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- CỘT PHẢI: DANH SÁCH BẢN SAO (8/12) -->
                    <div class="col-12 col-lg-8">
                        <div class="card card-custom shadow-sm bg-white p-4">
                            <h5 class="fw-bold text-dark mb-4">
                                <i class="fa-solid fa-boxes-stacked text-indigo-brand me-2"></i>Danh sách bản sao hiện có
                            </h5>
                            
                            <div class="table-responsive">
                                <table class="table table-hover align-middle table-premium m-0">
                                    <thead>
                                        <tr>
                                            <th class="ps-3 py-2" style="width: 80px;">Mã</th>
                                            <th>Mã vạch (Barcode)</th>
                                            <th>Vị trí kệ sách</th>
                                            <th class="pe-3" style="width: 180px;">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty copiesList}">
                                                <tr>
                                                    <td colspan="4" class="text-center py-5 text-muted">
                                                        <i class="fa-solid fa-box-open fs-2 mb-3 d-block text-secondary"></i>
                                                        Chưa có bản sao nào trong kho.
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="c" items="${copiesList}">
                                                    <tr>
                                                        <td class="ps-3 fw-semibold text-secondary">#${c.copyId}</td>
                                                        <td><span class="font-monospace fw-bold text-indigo-brand">${c.barcode}</span></td>
                                                        <td>${empty c.locationShelf ? 'Chưa xếp kệ' : c.locationShelf}</td>
                                                        <td class="pe-3">
                                                            <c:choose>
                                                                <c:when test="${c.status == 'Available'}">
                                                                    <span class="badge badge-soft-success rounded-pill px-2.5 py-1.5 fw-medium">Available</span>
                                                                </c:when>
                                                                <c:when test="${c.status == 'Borrowed'}">
                                                                    <span class="badge badge-soft-warning rounded-pill px-2.5 py-1.5 fw-medium">Borrowed</span>
                                                                </c:when>
                                                                <c:when test="${c.status == 'Damaged'}">
                                                                    <span class="badge badge-soft-danger rounded-pill px-2.5 py-1.5 fw-medium">Damaged</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-soft-secondary rounded-pill px-2.5 py-1.5 fw-medium">${c.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
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
        </main>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
