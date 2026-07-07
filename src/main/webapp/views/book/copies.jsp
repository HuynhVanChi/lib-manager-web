<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,book.Book,book.BookCopy"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Bản Sao - LibraryOS</title>
    
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
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="text-indigo-brand text-decoration-none fw-medium">${book.title}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Quản lý bản sao</li>
                    </ol>
                </nav>

                <!-- Hiển thị thông báo Flash (nếu có) -->
                <%
                    String msg = (String) session.getAttribute("message");
                    String msgType = (String) session.getAttribute("messageType");
                    if (msg != null) {
                        session.removeAttribute("message");
                        session.removeAttribute("messageType");
                %>
                    <div class="alert alert-<%= msgType %> alert-dismissible fade show rounded-3 shadow-sm border-0 px-4 py-3 mb-4" role="alert">
                        <div class="d-flex align-items-center">
                            <i class="fa-solid <%= "success".equals(msgType) ? "fa-circle-check text-success" : "fa-circle-exclamation text-danger" %> fs-5 me-3"></i>
                            <div class="fw-semibold text-dark"><%= msg %></div>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <%
                    }
                %>

                <!-- Tính toán thống kê nhanh bản sao bằng JSTL -->
                <c:set var="damagedCount" value="0"/>
                <c:set var="lostCount" value="0"/>
                <c:set var="borrowedCount" value="0"/>
                <c:forEach var="c" items="${copiesList}">
                    <c:if test="${c.status == 'Damaged'}"><c:set var="damagedCount" value="${damagedCount + 1}"/></c:if>
                    <c:if test="${c.status == 'Lost'}"><c:set var="lostCount" value="${lostCount + 1}"/></c:if>
                    <c:if test="${c.status == 'Borrowed'}"><c:set var="borrowedCount" value="${borrowedCount + 1}"/></c:if>
                </c:forEach>

                <!-- Header Tên sách -->
                <div class="d-flex align-items-center justify-content-between mb-4">
                    <div>
                        <h3 class="fw-bold text-dark m-0">Quản lý bản sao vật lý</h3>
                        <p class="text-muted m-0 mt-1">Đầu sách: <span class="fw-semibold text-indigo-brand">${book.title}</span> (Tác giả: ${book.author})</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="btn btn-light rounded-3 d-flex align-items-center gap-2">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại chi tiết
                    </a>
                </div>

                <!-- Thống kê nhanh bản sao của đầu sách này -->
                <div class="row g-3 mb-4">
                    <div class="col-6 col-md-3">
                        <div class="card card-custom shadow-sm bg-white p-3 text-center">
                            <span class="text-muted small fw-medium d-block">Tổng số bản sao</span>
                            <span class="fs-4 fw-bold text-dark mt-1 d-block">${book.totalCopies}</span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="card card-custom shadow-sm bg-white p-3 text-center">
                            <span class="text-muted small fw-medium d-block">Sẵn có (Available)</span>
                            <span class="fs-4 fw-bold text-success mt-1 d-block">${book.availableCopies}</span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="card card-custom shadow-sm bg-white p-3 text-center">
                            <span class="text-muted small fw-medium d-block">Đang cho mượn</span>
                            <span class="fs-4 fw-bold text-warning mt-1 d-block">${borrowedCount}</span>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="card card-custom shadow-sm bg-white p-3 text-center">
                            <span class="text-muted small fw-medium d-block">Hỏng / Mất / Thanh lý</span>
                            <span class="fs-4 fw-bold text-danger mt-1 d-block">${damagedCount + lostCount}</span>
                        </div>
                    </div>
                </div>

                <!-- Bố cục 2 Cột: Danh sách bản sao & Thêm nhanh -->
                <div class="row g-4">
                    <!-- Cột 1: Danh sách bản sao (8/12) -->
                    <div class="col-12 col-lg-8">
                        <div class="card card-custom shadow-sm h-100">
                            <div class="card-header bg-white border-0 py-3 d-flex align-items-center justify-content-between">
                                <h6 class="fw-bold text-dark m-0">
                                    <i class="fa-solid fa-list-check me-1 text-indigo-brand"></i> Danh sách bản sao hiện tại
                                </h6>
                            </div>
                            
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle table-premium m-0">
                                        <thead>
                                            <tr>
                                                <th class="ps-4 py-3" style="width: 80px;">Mã</th>
                                                <th>Mã vạch (Barcode)</th>
                                                <th>Vị trí kệ sách</th>
                                                <th style="width: 180px;">Trạng thái</th>
                                                <th class="text-end pe-4" style="width: 240px;">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty copiesList}">
                                                    <tr>
                                                        <td colspan="5" class="text-center py-5 text-muted">
                                                            <i class="fa-solid fa-box-open fs-2 mb-3 d-block text-secondary"></i>
                                                            Đầu sách này hiện chưa có bản sao nào trong kho.
                                                        </td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="c" items="${copiesList}">
                                                        <tr>
                                                            <td class="ps-4 fw-semibold text-secondary">#${c.copyId}</td>
                                                            <td><span class="font-monospace fw-bold text-indigo-brand">${c.barcode}</span></td>
                                                            <td>${empty c.locationShelf ? 'Chưa xếp kệ' : c.locationShelf}</td>
                                                            <td>
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
                                                            <td class="text-end pe-4">
                                                                <div class="d-flex justify-content-end gap-1.5">
                                                                    <!-- Trạng thái 'Borrowed' thì hạn chế hành động -->
                                                                    <c:choose>
                                                                        <c:when test="${c.status == 'Borrowed'}">
                                                                            <button class="btn btn-outline-secondary btn-sm rounded-3 py-1 btn-edit-copy-trigger" 
                                                                                    data-id="${c.copyId}" data-barcode="${c.barcode}" data-location="${c.locationShelf}" data-status="${c.status}">
                                                                                <i class="fa-solid fa-lock"></i> Sửa vị trí
                                                                            </button>
                                                                            <button class="btn btn-light btn-sm rounded-3 py-1 text-muted" disabled title="Sách đang được mượn, không thể xóa">
                                                                                <i class="fa-solid fa-ban"></i> Xóa
                                                                            </button>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <button class="btn btn-outline-indigo-brand btn-sm rounded-3 btn-edit-copy-trigger"
                                                                                    data-id="${c.copyId}" data-barcode="${c.barcode}" data-location="${c.locationShelf}" data-status="${c.status}">
                                                                                <i class="fa-solid fa-pen"></i> Sửa
                                                                            </button>
                                                                            <button class="btn btn-outline-danger btn-sm rounded-3 btn-delete-copy-trigger"
                                                                                    data-id="${c.copyId}" data-barcode="${c.barcode}">
                                                                                <i class="fa-solid fa-trash-can"></i> Xóa
                                                                            </button>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
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

                    <!-- Cột 2: Thêm nhanh bản sao (4/12) -->
                    <div class="col-12 col-lg-4">
                        <div class="card card-custom shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <h6 class="fw-bold text-dark m-0">
                                    <i class="fa-solid fa-circle-plus me-1 text-indigo-brand"></i> Nhập nhanh bản sao mới
                                </h6>
                            </div>
                            <div class="card-body p-4 pt-1">
                                <form action="${pageContext.request.contextPath}/books?action=insertCopy" method="post">
                                    <!-- Hidden bookId -->
                                    <input type="hidden" name="bookId" value="${book.bookId}">

                                    <div class="mb-3">
                                        <label class="form-label small fw-semibold text-secondary">Vị trí xếp kệ <span class="text-danger">*</span></label>
                                        <input type="text" class="form-control rounded-3" name="locationShelf" required placeholder="Ví dụ: Kệ A1-01, Kệ B3...">
                                        <div class="form-text text-muted">Vị trí lưu trữ cuốn sách vật lý trong thư viện.</div>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label small fw-semibold text-secondary">Số lượng cuốn nhập kho <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control rounded-3" name="quantity" min="1" max="50" value="1" required>
                                        <div class="form-text text-muted">Tối đa 50 cuốn cho mỗi lần thêm.</div>
                                    </div>

                                    <button type="submit" class="btn btn-indigo-brand rounded-3 w-100 py-2.5 fw-semibold">
                                        <i class="fa-solid fa-plus-circle me-1"></i> Xác nhận nhập kho
                                    </button>
                                    
                                    <div class="alert alert-light border-0 small rounded-3 mt-4 mb-0 text-muted" style="background-color: #f8fafc;">
                                        <i class="fa-solid fa-circle-info me-2 text-indigo-brand"></i>
                                        Mã vạch (Barcode) sẽ được hệ thống tự động sinh theo cấu trúc viết tắt của tựa đề (Ví dụ: <strong>${book.title}</strong> sẽ tự động sinh mã dạng <code>[VIẾT_TẮT]-xxx</code>).
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Modal phụ: Chỉnh sửa vị trí/trạng thái Bản sao -->
    <div class="modal fade" id="editCopyModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 400px;">
            <div class="modal-content border-0 shadow rounded-3">
                <form id="editCopyForm" action="${pageContext.request.contextPath}/books?action=updateCopy" method="post">
                    <input type="hidden" id="editCopyId" name="copyId">
                    
                    <div class="modal-header bg-indigo-brand text-white border-0 py-2.5 rounded-top-3">
                        <h6 class="modal-title fw-bold">
                            <i class="fa-solid fa-pen-to-square me-1"></i>Sửa Bản Sao: <span id="editCopyBarcodeLabel" class="text-warning"></span>
                        </h6>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>

                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold text-secondary">Vị trí kệ sách <span class="text-danger">*</span></label>
                            <input type="text" class="form-control rounded-3" id="editCopyLocation" name="locationShelf" required>
                        </div>
                        
                        <div class="mb-0">
                            <label class="form-label small fw-semibold text-secondary">Trạng thái cuốn sách</label>
                            <select class="form-select rounded-3" id="editCopyStatus" name="status">
                                <option value="Available">Available (Sẵn sàng cho mượn)</option>
                                <option value="Borrowed" id="optionBorrowed" disabled>Borrowed (Đang cho mượn - Khóa)</option>
                                <option value="Damaged">Damaged (Bị hỏng)</option>
                                <option value="Lost">Lost (Bị mất)</option>
                                <option value="Decommissioned">Decommissioned (Thanh lý/Hủy)</option>
                            </select>
                            <div class="text-muted small mt-2 d-none" id="borrowedWarning">
                                <i class="fa-solid fa-triangle-exclamation text-warning me-1"></i>
                                Sách đang có độc giả mượn. Không được thay đổi trạng thái lúc này để tránh làm lệch dữ liệu mượn trả!
                            </div>
                        </div>
                    </div>

                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="button" class="btn btn-light rounded-3 btn-sm px-4 py-2" data-bs-dismiss="modal">Hủy bỏ</button>
                        <button type="submit" class="btn btn-indigo-brand rounded-3 btn-sm px-4 py-2">Xác nhận lưu</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal phụ: Xác nhận xóa Bản sao -->
    <div class="modal fade" id="deleteCopyModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 380px;">
            <div class="modal-content border-0 shadow rounded-3">
                <form action="${pageContext.request.contextPath}/books?action=deleteCopy" method="post">
                    <input type="hidden" id="deleteCopyId" name="copyId">
                    <div class="modal-body p-4 text-center">
                        <i class="fa-solid fa-circle-exclamation text-danger fs-1 mb-3"></i>
                        <h5 class="fw-bold mb-2">Xóa bản sao sách</h5>
                        <p class="text-muted small mb-4">Bạn có chắc chắn muốn xóa bản sao có mã vạch <span class="fw-bold text-dark" id="deleteCopyBarcode"></span> ra khỏi kho thư viện?</p>
                        
                        <div class="d-flex gap-2 justify-content-center">
                            <button type="button" class="btn btn-light rounded-3 px-4 py-2 flex-grow-1" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-danger rounded-3 px-4 py-2 flex-grow-1">Đồng ý xóa</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/book/copies-jsp.js"></script>
</body>
</html>
