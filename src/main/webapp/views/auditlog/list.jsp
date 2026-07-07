<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Nhật ký đối soát hệ thống - LibraryOS">
    <title>Nhật ký Hệ thống (Audit Logs) - LibraryOS</title>

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

            <%-- ── TIÊU ĐỀ TRANG ── --%>
            <div class="mb-4">
                <h1 class="fw-bold m-0 text-dark" style="font-size:1.6rem;">Danh sách nhật ký hệ thống</h1>
                <p class="text-muted mb-0 mt-1" style="font-size:.85rem;">
                    Giám sát lịch sử thay đổi dữ liệu của toàn bộ thư viện (Chỉ dành cho Admin)
                </p>
            </div>

            <%-- ── CARD CHÍNH ── --%>
            <div class="card-main bg-white">

                <%-- ── TOOLBAR: Tìm kiếm + Lọc ── --%>
                <div class="p-3 border-bottom">
                    <form method="get" action=""
                          class="d-flex align-items-center toolbar flex-wrap">

                        <%-- Tìm kiếm --%>
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text"
                                   id="search-input"
                                   name="search"
                                   class="search-input"
                                   placeholder="Tìm thủ thư hoặc bảng..."
                                   value="<c:out value='${search}'/>">
                        </div>

                        <%-- Lọc hành động --%>
                        <select name="action" id="filter-action" class="filter-select">
                            <option value="">Tất cả hành động</option>
                            <option value="INSERT"  ${actionFilter == 'INSERT'  ? 'selected' : ''}>INSERT (Thêm mới)</option>
                            <option value="UPDATE"  ${actionFilter == 'UPDATE'  ? 'selected' : ''}>UPDATE (Chỉnh sửa)</option>
                            <option value="DELETE"  ${actionFilter == 'DELETE'  ? 'selected' : ''}>DELETE (Xóa)</option>
                            <option value="RESTORE" ${actionFilter == 'RESTORE' ? 'selected' : ''}>RESTORE (Khôi phục)</option>
                        </select>

                        <%-- Lọc bảng dữ liệu --%>
                        <select name="table" id="filter-table" class="filter-select">
                            <option value="">Tất cả bảng dữ liệu</option>
                            <option value="readers"         ${tableFilter == 'readers'         ? 'selected' : ''}>Độc giả (readers)</option>
                            <option value="books"           ${tableFilter == 'books'           ? 'selected' : ''}>Đầu sách (books)</option>
                            <option value="book_copies"     ${tableFilter == 'book_copies'     ? 'selected' : ''}>Bản sao sách (book_copies)</option>
                            <option value="categories"      ${tableFilter == 'categories'      ? 'selected' : ''}>Danh mục sách (categories)</option>
                            <option value="users"           ${tableFilter == 'users'           ? 'selected' : ''}>Nhân sự / Thủ thư (users)</option>
                            <option value="borrow_records"  ${tableFilter == 'borrow_records'  ? 'selected' : ''}>Phiếu mượn (borrow_records)</option>
                            <option value="borrow_details"  ${tableFilter == 'borrow_details'  ? 'selected' : ''}>Chi tiết mượn (borrow_details)</option>
                            <option value="fines"           ${tableFilter == 'fines'           ? 'selected' : ''}>Phí phạt (fines)</option>
                            <option value="book_recommends" ${tableFilter == 'book_recommends' ? 'selected' : ''}>Đề xuất sách (book_recommends)</option>
                        </select>

                        <button type="submit" id="btn-search" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow">
                            <i class="fa-solid fa-filter me-1"></i> Lọc
                        </button>

                        <%-- Xóa bộ lọc --%>
                        <c:if test="${not empty search or not empty actionFilter or not empty tableFilter}">
                            <a href="${pageContext.request.contextPath}/AuditLogs"
                               id="btn-clear-filter"
                               class="btn btn-outline-secondary px-3 py-2 rounded-3 fw-medium text-decoration-none">
                                <i class="fa-solid fa-xmark me-1"></i> Xóa lọc
                            </a>
                        </c:if>

                        <span class="text-muted ms-auto" style="font-size:.82rem;">
                            Tải tối đa <strong>150 logs</strong> mới nhất
                        </span>
                    </form>
                </div>

                <%-- ── BẢNG DANH SÁCH NHẬT KÝ ── --%>
                <div class="table-responsive">
                    <c:choose>
                        <c:when test="${not empty logs}">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th style="width:50px">ID</th>
                                        <th>Người thực hiện</th>
                                        <th>Hành động</th>
                                        <th>Bảng tác động</th>
                                        <th>ID Bản ghi</th>
                                        <th>Thời gian</th>
                                        <th style="width:100px; text-align:center">Chi tiết</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="log" items="${logs}">
                                        <tr id="log-row-${log.logId}">
                                            <td class="text-muted fw-medium">${log.logId}</td>
                                            <td>
                                                <div class="fw-semibold text-dark">
                                                    <c:out value="${log.userFullName}"/>
                                                </div>
                                                <div class="text-muted" style="font-size:0.78rem;">
                                                    User ID: #${log.userId != null ? log.userId : '—'}
                                                </div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${log.action == 'INSERT'}">
                                                        <span class="badge-status badge-active">Thêm mới</span>
                                                    </c:when>
                                                    <c:when test="${log.action == 'UPDATE'}">
                                                        <span class="badge-status badge-info-custom">Chỉnh sửa</span>
                                                    </c:when>
                                                    <c:when test="${log.action == 'DELETE'}">
                                                        <span class="badge-status badge-danger-custom">Xóa</span>
                                                    </c:when>
                                                    <c:when test="${log.action == 'RESTORE'}">
                                                        <span class="badge-status badge-restore-custom">Khôi phục</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-status badge-expired"><c:out value="${log.action}"/></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <span class="fw-medium">
                                                    <c:choose>
                                                        <c:when test="${log.tableName == 'readers'}">Độc giả</c:when>
                                                        <c:when test="${log.tableName == 'books'}">Đầu sách</c:when>
                                                        <c:when test="${log.tableName == 'book_copies'}">Bản sao sách</c:when>
                                                        <c:when test="${log.tableName == 'categories'}">Danh mục sách</c:when>
                                                        <c:when test="${log.tableName == 'users'}">Nhân sự / Thủ thư</c:when>
                                                        <c:when test="${log.tableName == 'borrow_records'}">Phiếu mượn</c:when>
                                                        <c:when test="${log.tableName == 'borrow_details'}">Chi tiết mượn</c:when>
                                                        <c:when test="${log.tableName == 'fines'}">Phí phạt</c:when>
                                                        <c:when test="${log.tableName == 'book_recommends'}">Đề xuất sách</c:when>
                                                        <c:otherwise><c:out value="${log.tableName}"/></c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <small class="text-muted d-block" style="font-size:0.75rem;">
                                                    (${log.tableName})
                                                </small>
                                            </td>
                                            <td>
                                                <span class="badge bg-light text-dark border fw-medium" style="font-size: 0.8rem; font-family: monospace;">
                                                    #${log.recordId}
                                                </span>
                                            </td>
                                            <td>
                                                <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                                            </td>
                                            <td>
                                                <div class="d-flex justify-content-center">
                                                    <a href="${pageContext.request.contextPath}/AuditLogs?action=detail&id=${log.logId}"
                                                       class="btn-action"
                                                       title="Xem dữ liệu thay đổi">
                                                        <i class="fa-solid fa-eye"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:when>
                        <c:otherwise>
                            <div class="empty-state">
                                <div class="icon"><i class="fa-solid fa-receipt"></i></div>
                                <h5 class="fw-semibold text-dark mb-1">Không tìm thấy nhật ký nào</h5>
                                <p class="mb-3" style="font-size:.875rem;">
                                    <c:choose>
                                        <c:when test="${not empty search or not empty actionFilter or not empty tableFilter}">
                                            Không có kết quả phù hợp với bộ lọc hiện tại.
                                        </c:when>
                                        <c:otherwise>
                                            Chưa có nhật ký nào trong hệ thống.
                                        </c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
            <%-- END CARD --%>

        </div>
    </main>

</div>

</body>
</html>
