<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List,categories.Category"%>
<%-- Hỗ trợ JSTL Core --%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isTrashView ? "Thùng rác Danh mục" : "Quản lý Danh mục"} - LibraryOS</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <link href="${pageContext.request.contextPath}/assets/css/category-colors.css" rel="stylesheet" type="text/css">
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
        }
        .badge-soft-purple {
            background-color: rgba(167, 139, 250, 0.15);
            color: #6d28d9;
            font-weight: 500;
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
                

                <!-- Tiêu đề trang & Nút chức năng -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="fw-bold m-0 text-dark">Danh mục sách</h2>
                        <p class="text-muted small m-0 mt-1">Quản lý các danh mục phân loại đầu sách</p>
                    </div>
                    
                    <div class="d-flex gap-2">
                        <button type="button"
                                id="btn-open-archive"
                                class="btn btn-slate d-flex align-items-center gap-2 px-4 py-2 rounded-3 fw-semibold shadow-sm hover-lift"
                                data-bs-toggle="modal"
                                data-bs-target="#archiveModal">
                            <i class="fa-solid fa-trash-can"></i>
                            <span>Thùng rác</span>
                        </button>
                        <a href="${pageContext.request.contextPath}/categories?action=add"
                           id="btn-add-category"
                           class="btn btn-primary d-flex align-items-center gap-2 px-4 py-2 rounded-3 fw-semibold shadow-sm hover-lift">
                            <i class="fa-solid fa-plus"></i>
                            <span>Thêm danh mục</span>
                        </a>
                    </div>
                </div>

                <!-- Khối chính (card-main) chứa cả bộ lọc và bảng dữ liệu -->
                <div class="card-main bg-white">
                    
                    <%-- ── TOOLBAR: Tìm kiếm ── --%>
                    <div class="p-3 border-bottom">
                        <form method="get" action="${pageContext.request.contextPath}/categories"
                              class="d-flex align-items-center toolbar flex-wrap">
                            
                            <%-- Input tìm kiếm --%>
                            <div class="search-wrapper">
                                <i class="fa-solid fa-magnifying-glass search-icon"></i>
                                <input type="text"
                                       id="search-input"
                                       name="query"
                                       class="search-input"
                                       placeholder="Tìm theo tên danh mục, mô tả..."
                                       value="<c:out value='${searchQuery}'/>">
                            </div>

                            <%-- Nút Lọc tĩnh --%>
                            <button type="submit" id="btn-search" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow">
                                <i class="fa-solid fa-filter me-1"></i> Lọc
                            </button>

                            <%-- Nút Xóa lọc --%>
                            <c:if test="${not empty searchQuery}">
                                <a href="${pageContext.request.contextPath}/categories${isTrashView ? '?trash=true' : ''}"
                                   id="btn-clear-filter"
                                   class="btn btn-outline-secondary px-3 py-2 rounded-3 fw-medium text-decoration-none ms-2">
                                    <i class="fa-solid fa-xmark me-1"></i> Xóa lọc
                                </a>
                            </c:if>

                            <%-- Tổng kết quả --%>
                            <span class="text-muted ms-auto" style="font-size:.82rem;">
                                <c:choose>
                                    <c:when test="${not empty activeCategories}">
                                        Hiển thị <strong>${activeCategories.size()}</strong> danh mục
                                    </c:when>
                                    <c:otherwise>Không có kết quả</c:otherwise>
                                </c:choose>
                            </span>
                        </form>
                    </div>

                    <%-- ── BẢNG DANH SÁCH ── --%>
                    <div class="table-responsive">
                        <c:choose>
                            <c:when test="${not empty activeCategories}">
                                <table class="table-custom">
                                    <thead>
                                        <tr>
                                            <th class="ps-4" style="width: 80px;">#</th>
                                            <th style="width: 250px;">Tên Danh Mục</th>
                                            <th>Mô Tả Chi Tiết</th>
                                            <th style="width: 200px;">Ngày Tạo</th>
                                            <th style="width: 140px; text-align: center;">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="cat" items="${activeCategories}" varStatus="loop">
                                            <tr>
                                                <td class="ps-4 text-muted fw-medium">${loop.index + 1}</td>
                                                <td>
                                                    <div class="d-flex flex-column align-items-start">
                                                        <span class="badge-status badge-theme-${cat.colorTheme} px-3 py-1.5 fs-7">${cat.name}</span>
                                                        <span class="text-muted mt-1 ps-2.5" style="font-size: 0.72rem;">ID: #${cat.categoryId}</span>
                                                    </div>
                                                </td>
                                                <td class="text-muted" style="max-width: 400px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                    ${cat.description != null && !cat.description.isEmpty() ? cat.description : "Không có mô tả"}
                                                </td>
                                                <td>${cat.createdAt}</td>
                                                <td>
                                                    <div class="d-flex gap-1 justify-content-center">
                                                        <a href="${pageContext.request.contextPath}/categories?action=detail&id=${cat.categoryId}" class="btn-action" title="Xem chi tiết">
                                                            <i class="fa-solid fa-eye"></i>
                                                        </a>
                                                        <a href="${pageContext.request.contextPath}/categories?action=edit&id=${cat.categoryId}" class="btn-action" title="Sửa">
                                                            <i class="fa-solid fa-pen"></i>
                                                        </a>
                                                        <button class="btn-action danger btn-delete-trigger" 
                                                                data-id="${cat.categoryId}" data-name="${cat.name}" title="Xóa">
                                                            <i class="fa-solid fa-trash-can"></i>
                                                        </button>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="icon"><i class="fa-solid fa-tags"></i></div>
                                    <h5 class="fw-semibold text-dark mb-1">Không tìm thấy danh mục nào</h5>
                                    <p class="mb-3" style="font-size:.875rem;">
                                        <c:choose>
                                            <c:when test="${not empty searchQuery}">
                                                Không có danh mục nào phù hợp với từ khóa tìm kiếm.
                                            </c:when>
                                            <c:otherwise>
                                                Chưa có danh mục nào hoạt động trong hệ thống. Hãy bấm nút phía trên bên phải để khởi tạo!
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- ======================================================= -->
    <!-- 3. CÁC MODAL HỘP THOẠI (BOOTSTRAP)                    -->
    <!-- ======================================================= -->

    <!-- Modal: Xác nhận xóa mềm -->
    <div class="modal fade" id="deleteCategoryModal" tabindex="-1" aria-labelledby="deleteCategoryModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow rounded-3">
                <div class="modal-header">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rounded-circle d-flex align-items-center justify-content-center"
                             style="width:40px;height:40px;background:#FEE2E2;flex-shrink:0;">
                            <i class="fa-solid fa-triangle-exclamation" style="color:#DC2626;"></i>
                        </div>
                        <h6 class="modal-title fw-bold m-0" id="deleteCategoryModalLabel">Xác nhận xóa danh mục</h6>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <form action="${pageContext.request.contextPath}/categories?action=delete" method="post" class="m-0">
                    <input type="hidden" id="deleteCategoryId" name="categoryId">
                    <div class="modal-body">
                        <p class="mb-1" style="font-size:.9rem;">Bạn có chắc chắn muốn xóa danh mục:</p>
                        <p class="fw-bold mb-3" id="deleteCategoryName" style="font-size:1rem; color:var(--primary);">—</p>
                        <div class="rounded-3 p-3" style="background:#FEF2F2;border:1px solid #FECACA;font-size:.82rem;color:#991B1B;">
                            <i class="fa-solid fa-info-circle me-1"></i>
                            Hành động này sẽ ẩn danh mục khỏi danh sách nhưng <strong>không xóa vĩnh viễn</strong> dữ liệu.
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-danger hover-lift">
                            <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Modal: Thùng rác danh mục -->
    <div class="modal fade" id="archiveModal" tabindex="-1" aria-labelledby="archiveModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content">
                <div class="modal-header d-flex align-items-center">
                    <div class="d-flex align-items-center gap-2">
                        <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center" 
                             style="width: 36px; height: 36px;">
                            <i class="fa-solid fa-trash-can text-secondary"></i>
                        </div>
                        <h6 class="modal-title fw-bold m-0" id="archiveModalLabel">Thùng rác danh mục</h6>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <div class="modal-body p-0">
                    <c:choose>
                        <c:when test="${not empty deletedCategories}">
                            <div class="table-responsive" style="max-height: 290px; overflow-y: auto;">
                                <table class="table-custom m-0">
                                    <thead style="position: sticky; top: 0; z-index: 10;">
                                        <tr>
                                            <th class="ps-4" style="width: 80px;">Mã</th>
                                            <th>Tên danh mục</th>
                                            <th>Mô tả chi tiết</th>
                                            <th class="text-center" style="width: 140px;">Hành động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="delCat" items="${deletedCategories}">
                                            <tr>
                                                <td class="ps-4 fw-semibold text-secondary">#<c:out value="${delCat.categoryId}"/></td>
                                                <td><span class="badge-status badge-theme-${delCat.colorTheme} px-3 py-1.5 fs-7"><c:out value="${delCat.name}"/></span></td>
                                                <td class="text-muted"><c:out value="${delCat.description != null ? delCat.description : '—'}"/></td>
                                                <td class="text-center">
                                                    <form method="post" action="${pageContext.request.contextPath}/categories?action=restore" class="m-0 d-inline">
                                                        <input type="hidden" name="categoryId" value="${delCat.categoryId}"/>
                                                        <button type="submit" class="btn-action hover-lift" title="Khôi phục danh mục" style="color: #15803D !important; border-color: #86EFAC !important;">
                                                            <i class="fa-solid fa-trash-can-arrow-up"></i>
                                                        </button>
                                                    </form>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5 text-muted">
                                <i class="fa-regular fa-folder-open fs-2 mb-2 opacity-50"></i>
                                <p class="small m-0">Thùng rác trống. Không có danh mục nào đã xóa.</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Đóng</button>
                </div>
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
    <!-- Script tương tác Modal (Tách ra từ categories.jsp) -->
    <script src="${pageContext.request.contextPath}/assets/categories/categories-jsp.js"></script>
</body>
</html>