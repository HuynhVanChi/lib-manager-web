<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chi tiết nhật ký hệ thống - LibraryOS">
    <title>Chi tiết Nhật ký Hệ thống - LibraryOS</title>

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

        <div class="container-fluid p-4" style="max-width: 1100px;">

            <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
            <div class="d-flex justify-content-between align-items-start mb-4">
                <div>
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/AuditLogs">
                                    <i class="fa-solid fa-clock-rotate-left me-1"></i>Nhật ký hệ thống
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">Chi tiết nhật ký #${log.logId}</li>
                        </ol>
                    </nav>
                    <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">
                        Chi tiết nhật ký #${log.logId}
                    </h1>
                </div>
                <div>
                    <a href="${pageContext.request.contextPath}/AuditLogs" id="btn-back" class="btn-back hover-lift">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                    </a>
                </div>
            </div>

            <%-- ── CARD 1: THÔNG TIN CHUNG ── --%>
            <div class="card detail-card bg-white">
                <div class="detail-card-header">
                    <i class="fa-solid fa-circle-info text-primary"></i>
                    <span>Thông tin chung nhật ký</span>
                </div>
                <div class="meta-grid">
                    <div class="meta-item">
                        <span class="meta-label">Người thực hiện</span>
                        <span class="meta-value">
                            <c:out value="${log.userFullName != null ? log.userFullName : 'Hệ thống'}"/>
                            <small class="text-muted fw-normal d-block" style="font-size: 0.75rem;">
                                ID: #${log.userId != null ? log.userId : '—'}
                            </small>
                        </span>
                    </div>
                    <div class="meta-item">
                        <span class="meta-label">Thời gian</span>
                        <span class="meta-value">
                            <fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
                        </span>
                    </div>
                    <div class="meta-item">
                        <span class="meta-label">Hành động</span>
                        <span class="mt-1">
                            <c:choose>
                                <c:when test="${log.action == 'INSERT'}">
                                    <span class="badge-status badge-active">INSERT (Thêm mới)</span>
                                </c:when>
                                <c:when test="${log.action == 'UPDATE'}">
                                    <span class="badge-status badge-info-custom">UPDATE (Cập nhật)</span>
                                </c:when>
                                <c:when test="${log.action == 'DELETE'}">
                                    <span class="badge-status badge-danger-custom">DELETE (Xóa)</span>
                                </c:when>
                                <c:when test="${log.action == 'RESTORE'}">
                                    <span class="badge-status badge-restore-custom">RESTORE (Khôi phục)</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-status badge-expired"><c:out value="${log.action}"/></span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div class="meta-item">
                        <span class="meta-label">Đối tượng tác động</span>
                        <span class="meta-value">
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
                            <small class="text-muted fw-normal" style="font-size: 0.8rem; font-family: monospace;">
                                #${log.recordId}
                            </small>
                        </span>
                    </div>
                </div>
            </div>

            <%-- ── CARD 2: ĐỐI CHIẾU THAY ĐỔI DỮ LIỆU ── --%>
            <div class="card detail-card bg-white">
                <div class="detail-card-header">
                    <i class="fa-solid fa-code-compare text-primary"></i>
                    <span>Bảng đối chiếu thuộc tính dữ liệu</span>
                </div>
                <div class="p-4">
                    <div class="table-responsive border rounded-3">
                        <table class="table-custom">
                            <thead class="table-light">
                                <tr>
                                    <th style="width:30%;">Trường thông tin</th>
                                    <th style="width:35%; color:#DC2626;">Dữ liệu cũ (Trước thay đổi)</th>
                                    <th style="width:35%; color:#15803D;">Dữ liệu mới (Sau thay đổi)</th>
                                </tr>
                            </thead>
                            <tbody id="diff-table-body">
                                <c:choose>
                                    <c:when test="${not empty diffs}">
                                        <c:forEach var="diff" items="${diffs}">
                                            <tr style="${diff.changed and log.action == 'UPDATE' ? 'background-color: #FEFCE8;' : ''}">
                                                <td>
                                                    <div class="fw-semibold text-dark"><c:out value="${diff.friendlyName}"/></div>
                                                    <div class="text-muted" style="font-size:0.75rem; font-family:monospace;"><c:out value="${diff.fieldKey}"/></div>
                                                </td>
                                                <td class="text-danger font-monospace" style="word-break: break-all;">
                                                    <c:out value="${diff.oldValue}"/>
                                                </td>
                                                <td class="text-success font-monospace" style="word-break: break-all;">
                                                    <c:out value="${diff.newValue}"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="3" class="text-center text-muted py-4">Không có chi tiết dữ liệu thay đổi.</td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
