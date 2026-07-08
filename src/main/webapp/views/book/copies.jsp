<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,book.Book,book.BookCopy"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Bản Sao - LibraryOS</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
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
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/books">
                                <i class="fa-solid fa-book me-1"></i>Quản lý sách
                            </a>
                        </li>
                        <li class="breadcrumb-item">
                            <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}">
                                ${book.title}
                            </a>
                        </li>
                        <li class="breadcrumb-item active" aria-current="page">Quản lý cuốn sách</li>
                    </ol>
                </nav>


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
                <div class="d-flex align-items-center justify-content-between mb-4 mt-2">
                    <div>
                        <h1 class="fw-bold text-dark m-0" style="font-size:1.6rem; letter-spacing: -0.5px;">Quản lý cuốn sách</h1>
                        <div class="mt-2 p-2 px-3 bg-primary text-white border-0 rounded-3 d-inline-flex align-items-center gap-2 shadow-sm">
                            <span class="badge bg-white text-primary px-2 py-1 fs-8 text-uppercase fw-bold shadow-sm">Đầu sách</span>
                            <span class="fw-bold text-white fs-6">${book.title}</span>
                            <span class="text-white-50 fs-7">| Tác giả: <strong class="text-white">${book.author}</strong></span>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/books?action=detail&id=${book.bookId}" class="btn-back hover-lift">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại chi tiết
                    </a>
                </div>

                <!-- Thống kê nhanh bản sao của đầu sách này -->
                <div class="row g-3 mb-4">
                    <div class="col-6 col-md-3">
                        <div class="card card-main bg-white p-3 border-0 d-flex flex-row align-items-center justify-content-between">
                            <div>
                                <span class="text-muted small fw-medium d-block">Tổng số cuốn sách</span>
                                <span class="fs-4 fw-bold text-dark mt-1 d-block">${book.totalCopies}</span>
                            </div>
                            <div class="rounded-circle d-flex align-items-center justify-content-center bg-light text-primary" style="width:48px;height:48px;">
                                <i class="fa-solid fa-copy fs-5"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="card card-main bg-white p-3 border-0 d-flex flex-row align-items-center justify-content-between">
                            <div>
                                <span class="text-muted small fw-medium d-block">Sẵn có (Available)</span>
                                <span class="fs-4 fw-bold text-success mt-1 d-block">${book.availableCopies}</span>
                            </div>
                            <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:48px;height:48px;background:rgba(34,197,94,0.1);color:#15803d;">
                                <i class="fa-solid fa-circle-check fs-5"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="card card-main bg-white p-3 border-0 d-flex flex-row align-items-center justify-content-between">
                            <div>
                                <span class="text-muted small fw-medium d-block">Đang cho mượn</span>
                                <span class="fs-4 fw-bold text-warning mt-1 d-block">${borrowedCount}</span>
                            </div>
                            <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:48px;height:48px;background:rgba(245,158,11,0.1);color:#b45309;">
                                <i class="fa-solid fa-book-open fs-5"></i>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-md-3">
                        <div class="card card-main bg-white p-3 border-0 d-flex flex-row align-items-center justify-content-between">
                            <div>
                                <span class="text-muted small fw-medium d-block">Hỏng / Mất / Hủy</span>
                                <span class="fs-4 fw-bold text-danger mt-1 d-block">${damagedCount + lostCount}</span>
                            </div>
                            <div class="rounded-circle d-flex align-items-center justify-content-center" style="width:48px;height:48px;background:rgba(239,68,68,0.1);color:#b91c1c;">
                                <i class="fa-solid fa-triangle-exclamation fs-5"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bố cục 2 Cột: Danh sách bản sao & Thêm nhanh -->
                <div class="row g-4">
                    <!-- Cột 1: Danh sách bản sao (8/12) -->
                    <div class="col-12 col-lg-8">
                        <div class="form-card bg-white h-100">
                            
                            <%-- Header Card --%>
                            <div class="form-card-header">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-list-check fs-5 text-white"></i>
                                    <h5 class="text-white fw-bold mb-0" style="font-size:1rem;">Danh sách cuốn sách hiện tại</h5>
                                </div>
                            </div>
                            
                            <div class="p-0">
                                <c:choose>
                                    <c:when test="${empty copiesList}">
                                        <div class="empty-state p-5">
                                            <div class="icon"><i class="fa-solid fa-box-open text-muted"></i></div>
                                            <h5 class="fw-semibold text-dark mb-1">Chưa có cuốn sách nào</h5>
                                            <p class="text-muted small mb-0">Đầu sách này hiện chưa có cuốn sách vật lý nào trong kho. Hãy nhập cuốn sách mới ở khung bên cạnh.</p>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="table-responsive">
                                            <table class="table-custom m-0">
                                                <thead>
                                                     <tr>
                                                         <th class="ps-4" style="width: 80px;">#</th>
                                                         <th>Mã vạch & ID</th>
                                                         <th>Giá nhập</th>
                                                         <th>Vị trí kệ sách</th>
                                                         <th style="width: 180px;">Trạng thái</th>
                                                         <th style="width: 140px; text-align: center;">Hành động</th>
                                                     </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="c" items="${copiesList}" varStatus="loop">
                                                        <tr id="row-copy-${c.copyId}" style="transition: background-color 0.3s ease;">
                                                            <td class="ps-4 text-muted fw-medium">${loop.index + 1}</td>
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
                                                                        <span class="badge-status badge-success">
                                                                            <i class="fa-solid fa-circle-check me-1" style="font-size:.65rem;"></i>Sẵn có
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Borrowed'}">
                                                                        <span class="badge-status badge-info">
                                                                            <i class="fa-solid fa-book-open me-1" style="font-size:.65rem;"></i>Đang mượn
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Damaged'}">
                                                                        <span class="badge-status badge-warning">
                                                                            <i class="fa-solid fa-triangle-exclamation me-1" style="font-size:.65rem;"></i>Bị hỏng
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Lost'}">
                                                                        <span class="badge-status badge-danger">
                                                                            <i class="fa-solid fa-circle-question me-1" style="font-size:.65rem;"></i>Bị mất
                                                                        </span>
                                                                    </c:when>
                                                                    <c:when test="${c.status == 'Decommissioned'}">
                                                                        <span class="badge-status badge-secondary">
                                                                            <i class="fa-solid fa-box-archive me-1" style="font-size:.65rem;"></i>Thanh lý
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="badge-status badge-secondary">${c.status}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="text-center">
                                                                 <div class="d-flex justify-content-center gap-1">
                                                                     <c:choose>
                                                                         <c:when test="${c.status == 'Borrowed'}">
                                                                             <!-- Edit location shelf only -->
                                                                             <button type="button" class="btn-action btn-edit-copy-trigger" title="Sửa vị trí kệ (Sách đang mượn)"
                                                                                     data-id="${c.copyId}" data-barcode="${c.barcode}" data-location="${c.locationShelf}" data-status="${c.status}" data-price="${c.price}">
                                                                                 <i class="fa-solid fa-lock text-secondary"></i>
                                                                             </button>
                                                                             <!-- Delete copy disabled -->
                                                                             <button type="button" class="btn-action danger" disabled title="Sách đang được mượn, không thể xóa" style="opacity: 0.4; cursor: not-allowed;">
                                                                                 <i class="fa-solid fa-trash-can"></i>
                                                                             </button>
                                                                         </c:when>
                                                                         <c:otherwise>
                                                                             <!-- Edit copy -->
                                                                             <button type="button" class="btn-action btn-edit-copy-trigger" title="Sửa"
                                                                                     data-id="${c.copyId}" data-barcode="${c.barcode}" data-location="${c.locationShelf}" data-status="${c.status}" data-price="${c.price}">
                                                                                 <i class="fa-solid fa-pen"></i>
                                                                             </button>
                                                                             <!-- Delete copy -->
                                                                             <button type="button" class="btn-action danger btn-delete-copy-trigger" title="Xóa"
                                                                                     data-id="${c.copyId}" data-barcode="${c.barcode}">
                                                                                 <i class="fa-solid fa-trash-can"></i>
                                                                             </button>
                                                                         </c:otherwise>
                                                                     </c:choose>
                                                                 </div>
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
                    
                    <!-- Cột 2: Khung nhập/sửa bản sao (4/12) -->
                    <div class="col-12 col-lg-4">
                        <div class="form-card bg-white" id="copyFormCard" style="transition: all 0.3s ease; border: 1px solid rgba(0,0,0,.08);">
                            
                            <%-- Header Card --%>
                            <div class="form-card-header" id="copyFormHeader" style="transition: all 0.3s ease;">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-circle-plus fs-5 text-white" id="copyFormIcon"></i>
                                    <h5 class="text-white fw-bold mb-0" id="copyFormTitle" style="font-size:1rem;">Nhập nhanh cuốn sách mới</h5>
                                </div>
                            </div>
                            
                            <div class="p-4">
                                <form id="copyForm" action="${pageContext.request.contextPath}/books?action=insertCopy" method="post">
                                    <!-- Hidden fields -->
                                    <input type="hidden" name="bookId" value="${book.bookId}">
                                    <input type="hidden" name="copyId" id="formCopyId" value="">

                                    <div class="mb-3">
                                        <label class="form-label" id="labelLocationShelf">Vị trí xếp kệ <span class="required-mark">*</span></label>
                                        <input type="text" class="form-control" name="locationShelf" id="formLocationShelf" required placeholder="Ví dụ: Kệ A1-01, Kệ B3...">
                                        <div class="form-hint" id="hintLocationShelf">Vị trí lưu trữ cuốn sách vật lý trong thư viện.</div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label" id="labelPrice">Giá nhập cuốn sách (VND) <span class="required-mark">*</span></label>
                                        <input type="number" class="form-control" name="price" id="formPrice" min="0" step="1000" value="${book.price != null ? book.price : '0'}" required placeholder="Ví dụ: 79000">
                                        <div class="form-hint" id="hintPrice">Mặc định giá nhập đầu sách (<fmt:formatNumber value="${book.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>).</div>
                                    </div>

                                    <div class="mb-4" id="formQuantityGroup">
                                        <label class="form-label">Số lượng cuốn nhập kho <span class="required-mark">*</span></label>
                                        <input type="number" class="form-control" name="quantity" id="formQuantity" min="1" max="50" value="1" required>
                                        <div class="form-hint">Tối đa 50 cuốn cho mỗi lần thêm.</div>
                                    </div>

                                    <div class="mb-4 d-none" id="formStatusGroup">
                                        <label class="form-label">Trạng thái cuốn sách <span class="required-mark">*</span></label>
                                        <select class="form-select" id="formCopyStatus" name="status">
                                            <option value="Available">Sẵn sàng cho mượn (Available)</option>
                                            <option value="Borrowed" id="optionBorrowed" disabled>Đang cho mượn - Khóa (Borrowed)</option>
                                            <option value="Damaged">Bị hỏng (Damaged)</option>
                                            <option value="Lost"> Bị mất (Lost)</option>
                                            <option value="Decommissioned">Thanh lý (Decommissioned)</option>
                                        </select>
                                        <div class="text-muted small mt-2 d-none" id="borrowedWarning" style="font-size:.78rem;">
                                            <i class="fa-solid fa-triangle-exclamation text-warning me-1"></i>
                                            Sách đang có độc giả mượn. Không được thay đổi trạng thái lúc này để tránh làm lệch dữ liệu mượn trả!
                                        </div>
                                    </div>

                                    <div class="d-flex gap-2 mt-4">
                                        <button type="button" id="btnCancelEdit" class="btn btn-secondary hover-lift flex-grow-1 py-2.5 d-none">
                                            Hủy bỏ
                                        </button>
                                        <button type="submit" id="btnSubmitForm" class="btn btn-save hover-lift flex-grow-1 py-2.5">
                                            <i class="fa-solid fa-plus me-1" id="btnSubmitIcon"></i> <span id="btnSubmitText">Xác nhận nhập kho</span>
                                        </button>
                                    </div>
                                    
                                    <div class="alert alert-light border-0 small rounded-3 mt-4 mb-0 text-muted" id="formBarcodeHint" style="background-color: #f8fafc; font-size:.8rem;">
                                        <i class="fa-solid fa-circle-info me-2 text-primary"></i>
                                        Mã vạch (Barcode) sẽ được tự động sinh theo ID đầu sách (Ví dụ: ID đầu sách: <strong>#${book.bookId}</strong> -> <code>BK${book.bookId}-xxx</code>).
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    </div>

    <!-- Modal phụ: Xác nhận xóa Bản sao -->
    <div class="modal fade" id="deleteCopyModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" style="max-width: 380px;">
            <div class="modal-content border-0 shadow rounded-3 overflow-hidden">
                <form action="${pageContext.request.contextPath}/books?action=deleteCopy" method="post">
                    <input type="hidden" id="deleteCopyId" name="copyId">
                    <div class="modal-body p-4 text-center">
                        <i class="fa-solid fa-circle-exclamation text-danger fs-1 mb-3"></i>
                        <h5 class="fw-bold mb-2 text-dark">Xóa cuốn sách</h5>
                        <p class="text-muted small mb-4">Bạn có chắc chắn muốn xóa cuốn sách có mã vạch <span class="fw-bold text-dark" id="deleteCopyBarcode"></span> ra khỏi kho thư viện?</p>
                        
                        <div class="d-flex gap-2 justify-content-center">
                            <button type="button" class="btn btn-secondary px-4 py-2 rounded-3 flex-grow-1" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-danger px-4 py-2 rounded-3 flex-grow-1 hover-lift">Đồng ý xóa</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <%-- ── FLASH TOAST (cục bộ tương tự Độc giả) ── --%>
    <%
        String msg = (String) session.getAttribute("message");
        String msgType = (String) session.getAttribute("messageType");
        if (msg != null) {
            session.removeAttribute("message");
            session.removeAttribute("messageType");
            String resolvedType = "success".equals(msgType) ? "success" : "error";
    %>
        <div class="flash-toast <%= resolvedType %>" id="flash-toast" role="alert">
            <span class="toast-icon">
                <% if ("success".equals(resolvedType)) { %>
                    <i class="fa-solid fa-circle-check"></i>
                <% } else { %>
                    <i class="fa-solid fa-circle-xmark"></i>
                <% } %>
            </span>
            <span style="font-size:.875rem;font-weight:500;flex:1;">
                <%= msg %>
            </span>
            <button class="toast-close" onclick="closeToast()" aria-label="Đóng">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <script>
            function closeToast() {
                const toast = document.getElementById('flash-toast');
                if (toast) {
                    toast.style.transition = 'opacity .3s ease';
                    toast.style.opacity = '0';
                    setTimeout(() => toast.remove(), 300);
                }
            }
            (function () {
                const toast = document.getElementById('flash-toast');
                if (toast) {
                    setTimeout(closeToast, 3500);
                }
            })();
        </script>
    <%
        }
    %>
    <script>
        const contextPath = "${pageContext.request.contextPath}";
    </script>
    <script src="${pageContext.request.contextPath}/assets/book/copies-jsp.js"></script>
</body>
</html>
