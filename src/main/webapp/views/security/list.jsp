<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="security.TaiKhoan" %>
<%
    List<TaiKhoan> accounts = (List<TaiKhoan>) request.getAttribute("accounts");
    List<TaiKhoan> deletedAccounts = (List<TaiKhoan>) request.getAttribute("deletedAccounts"); // Danh sách tài khoản trong thùng rác
    String search            = (String) request.getAttribute("search");
    String roleFilter        = (String) request.getAttribute("roleFilter");
    String toastMsg          = (String) request.getAttribute("toastMessage");
    String toastType         = (String) request.getAttribute("toastType");
    if (search     == null) search     = "";
    if (roleFilter == null) roleFilter = "";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Quản lý tài khoản nhân sự - LibraryOS">
    <title>Quản lý Nhân sự - LibraryOS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
</head>

<body class="m-0 p-0">
<div class="d-flex">

    <%-- Nhúng Sidebar chung của nhóm --%>
    <jsp:include page="/views/layout/sidebar.jsp"/>

    <main class="w-100">

        <%-- Nhúng Header chung của nhóm --%>
        <jsp:include page="/views/layout/header.jsp"/>

        <div class="container-fluid p-4">

            <%-- ===== Toast / Alert ===== --%>
            <% if (toastMsg != null) {
                String toastCls = "success".equals(toastType) ? "success" : "error";
                String iconCls  = "success".equals(toastType) ? "fa-circle-check" : "fa-circle-xmark";
            %>
            <div class="flash-toast <%=toastCls%>" id="flash-toast" role="alert">
                <span class="toast-icon">
                    <i class="fa-solid <%=iconCls%>"></i>
                </span>
                <span style="font-size:.875rem;font-weight:500;flex:1;">
                    <%=toastMsg%>
                </span>
                <button type="button" class="toast-close" onclick="closeToast()" aria-label="Đóng">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
            <% } %>

            <%-- ===== Tiêu đề + Nhóm nút Hành động ===== --%>
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h1 class="fw-bold m-0 text-dark" style="font-size:1.6rem;">Danh sách Nhân sự</h1>
                    <p class="text-muted mb-0 mt-1" style="font-size:.85rem;">
                        Danh sách tất cả tài khoản nhân sự và vai trò trong hệ thống
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <%-- NÚT THÙNG RÁC (Được tích hợp từ list.jsp) --%>
                    <button type="button"
                            id="btn-open-archive"
                            class="btn btn-slate d-flex align-items-center gap-2 px-4 py-2 rounded-3 fw-semibold shadow-sm hover-lift"
                            data-bs-toggle="modal"
                            data-bs-target="#archiveModal">
                        <i class="fa-solid fa-trash-can"></i>
                        <span>Thùng rác</span>
                    </button>

                    <%-- NÚT THÊM TÀI KHOẢN --%>
                    <a href="${pageContext.request.contextPath}/accounts?action=add"
                       id="btn-add-account"
                       class="btn btn-primary d-flex align-items-center gap-2 px-4 py-2 rounded-3 fw-semibold shadow-sm hover-lift text-decoration-none">
                        <i class="fa-solid fa-user-plus"></i>
                        <span>Thêm tài khoản</span>
                    </a>
                </div>
            </div>

            <%-- ===== CARD CHÍNH ===== --%>
            <div class="card-main bg-white">

                <%-- ── TOOLBAR: Tìm kiếm + Lọc ── --%>
                <div class="p-3 border-bottom">
                    <form method="get" action="${pageContext.request.contextPath}/accounts" id="form-filter"
                          class="d-flex align-items-center toolbar flex-wrap">

                        <%-- Input tìm kiếm --%>
                        <div class="search-wrapper">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text"
                                   id="input-search"
                                   name="search"
                                   class="search-input"
                                   placeholder="Tìm theo tên đăng nhập, họ tên..."
                                   value="<%=search%>"
                                   autocomplete="off">
                        </div>

                        <%-- Dropdown lọc vai trò --%>
                        <select name="role" id="select-role" class="filter-select">
                            <option value="">Tất cả vai trò</option>
                            <option value="Admin"  <%="Admin".equals(roleFilter)  ? "selected":""%>>Quản trị viên (Admin)</option>
                            <option value="Staff"  <%="Staff".equals(roleFilter)  ? "selected":""%>>Thủ thư (Staff)</option>
                        </select>

                        <button type="submit" id="btn-filter" class="btn btn-primary px-3 py-2 rounded-3 fw-medium shadow-sm hover-glow">
                            <i class="fa-solid fa-filter me-1"></i> Lọc
                        </button>

                        <%-- Nút xóa bộ lọc --%>
                        <% if (!search.isEmpty() || !roleFilter.isEmpty()) { %>
                            <a href="${pageContext.request.contextPath}/accounts"
                               id="btn-reset"
                               class="btn btn-outline-secondary px-3 py-2 rounded-3 fw-medium text-decoration-none">
                                <i class="fa-solid fa-xmark me-1"></i> Xóa lọc
                            </a>
                        <% } %>

                        <%-- Tổng kết quả --%>
                        <span class="text-muted ms-auto" style="font-size:.82rem;">
                            <% if (accounts == null || accounts.isEmpty()) { %>
                                Không có kết quả
                            <% } else { %>
                                Hiển thị <strong><%=accounts.size()%></strong> tài khoản
                            <% } %>
                        </span>
                    </form>
                </div>

                <%-- ── BẢNG DANH SÁCH ── --%>
                <div class="table-responsive">
                    <table class="table-custom">
                        <thead>
                            <tr>
                                <th style="width: 50px;">ID</th>
                                <th>Tên đăng nhập</th>
                                <th>Họ và tên</th>
                                <th style="width: 150px;">Vai trò</th>
                                <th style="width: 200px;">Ngày tạo</th>
                                <th style="width: 110px; text-align: center;">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                           if (accounts == null || accounts.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="6">
                                    <div class="empty-state">
                                        <div class="icon"><i class="fa-solid fa-users-slash"></i></div>
                                        <h5 class="fw-semibold text-dark mb-1">Không tìm thấy tài khoản nào</h5>
                                        <p class="mb-3" style="font-size:.875rem;">
                                            Không có kết quả phù hợp với bộ lọc hiện tại.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        <%
                            } else {
                               for (security.TaiKhoan tk : accounts) {
                                    String badge = "Admin".equalsIgnoreCase(tk.getRole())
                                        ? "<span class='badge-status badge-active'><i class='fa-solid fa-user-shield me-1' style='font-size:.65rem;'></i>Admin</span>"
                                        : "<span class='badge-status badge-info-custom'><i class='fa-solid fa-user-tie me-1' style='font-size:.65rem;'></i>Thủ thư</span>";
                                    String created = (tk.getCreatedAt() != null)
                                        ? tk.getCreatedAt().toString().substring(0, 19) : "—";
                        %>
                            <tr>
                                <td class="text-muted fw-medium">#<%=tk.getUserId()%></td>
                                <td>
                                    <div class="fw-semibold"><a href="${pageContext.request.contextPath}/accounts?action=detail&userId=<%=tk.getUserId()%>" class="text-decoration-none text-primary hover-underline"><%=tk.getUsername()%></a></div>
                                </td>
                                <td><%=tk.getFullName()%></td>
                                <td><%=badge%></td>
                                <td class="text-muted" style="font-size:.85rem;"><%=created%></td>
                                <td>
                                    <div class="d-flex gap-1 justify-content-center">
                                        <a href="${pageContext.request.contextPath}/accounts?action=detail&userId=<%=tk.getUserId()%>"
                                           class="btn-action text-decoration-none"
                                           title="Xem chi tiết">
                                            <i class="fa-solid fa-eye"></i>
                                        </a>
                                        <a href="${pageContext.request.contextPath}/accounts?action=edit&userId=<%=tk.getUserId()%>"
                                           class="btn-action text-decoration-none"
                                           title="Chỉnh sửa">
                                            <i class="fa-solid fa-pen"></i>
                                        </a>
                                        <button type="button"
                                                class="btn-action danger"
                                                title="Xóa"
                                                data-id="<%=tk.getUserId()%>"
                                                data-fullname="<%=tk.getFullName()%>"
                                                onclick="openDel(this)">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <%  
                               }
                            } %>
                        </tbody>
                    </table>
                </div>

            </div><%-- end card-main --%>

        </div><%-- end container --%>
    </main>
</div>


<%-- ========== MODAL XÓA TÀI KHOẢN ========== --%>
<div class="modal fade" id="modalDel" tabindex="-1" aria-labelledby="modalDelLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-danger bg-opacity-10 text-danger rounded-circle d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="modalDelLabel">Xác nhận xóa tài khoản</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <form action="${pageContext.request.contextPath}/accounts" method="POST" class="m-0">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="userId" id="del-userId">
                <div class="modal-body">
                    <p class="mb-1" style="font-size: .9rem;">Bạn có chắc chắn muốn xóa tài khoản của:</p>
                    <p class="fw-bold mb-3 text-primary" id="del-name" style="font-size: 1rem;">—</p>
                    <div class="rounded-3 p-3" style="background: #FEF2F2; border: 1px solid #FECACA; font-size: .82rem; color: #991B1B;">
                        <i class="fa-solid fa-circle-info me-1"></i> Hành động này sẽ chuyển tài khoản vào thùng rác và ẩn khỏi danh sách chính.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger hover-lift" id="btn-xac-nhan-xoa">
                        <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>


<%-- ── MODAL DANH SÁCH TÀI KHOẢN ĐÃ XÓA (Thùng rác tích hợp từ list.jsp) ── --%>
<div class="modal fade" id="archiveModal" tabindex="-1" aria-labelledby="archiveModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-secondary bg-opacity-10 text-secondary rounded-circle d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                        <i class="fa-solid fa-trash-can text-secondary"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="archiveModalLabel">Thùng rác tài khoản nhân sự</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body p-0">
                <% if (deletedAccounts != null && !deletedAccounts.isEmpty()) { %>
                        <div class="table-responsive">
                            <table class="table-custom">
                                <thead>
                                    <tr>
                                        <th style="width: 60px;">ID</th>
                                        <th>Tên đăng nhập</th>
                                        <th>Họ và tên</th>
                                        <th style="width: 120px;">Vai trò</th>
                                        <th style="width: 110px;" class="text-center">Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (security.TaiKhoan delTk : deletedAccounts) { 
                                        String delBadge = "Admin".equalsIgnoreCase(delTk.getRole())
                                            ? "<span class='badge-status badge-active'><i class='fa-solid fa-user-shield me-1' style='font-size:.65rem;'></i>Admin</span>"
                                            : "<span class='badge-status badge-info-custom'><i class='fa-solid fa-user-tie me-1' style='font-size:.65rem;'></i>Thủ thư</span>";
                                    %>
                                        <tr>
                                            <td>#<%=delTk.getUserId()%></td>
                                            <td><span class="fw-semibold text-dark"><%=delTk.getUsername()%></span></td>
                                            <td><%=delTk.getFullName()%></td>
                                            <td><%=delBadge%></td>
                                            <td class="text-center">
                                                <%-- Form gửi yêu cầu khôi phục tài khoản --%>
                                                <form method="POST" action="${pageContext.request.contextPath}/accounts" class="m-0 d-inline">
                                                    <input type="hidden" name="action" value="restore"/>
                                                    <input type="hidden" name="userId" value="<%=delTk.getUserId()%>"/>
                                                    <button type="submit" class="btn-action hover-lift" title="Khôi phục tài khoản" style="color: #15803D !important; border-color: #86EFAC !important;">
                                                        <i class="fa-solid fa-trash-can-arrow-up"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                <% } else { %>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-regular fa-folder-open fs-2 mb-2 opacity-50"></i>
                            <p class="small m-0">Thùng rác trống. Không có tài khoản nào đã xóa.</p>
                        </div>
                <% } %>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Xử lý bộ đếm thời gian Debounce cho ô tìm kiếm
    let searchTimeout = null;

    document.getElementById('input-search').addEventListener('input', function() {
        clearTimeout(searchTimeout);
        searchTimeout = setTimeout(() => {
            document.getElementById('form-filter').submit();
        }, 400);
    });

    // Tự động giữ tiêu điểm (focus) vào ô tìm kiếm
    window.addEventListener('DOMContentLoaded', (event) => {
        const searchInput = document.getElementById('input-search');
        const urlParams = new URLSearchParams(window.location.search);
        const hasSearchParam = urlParams.has('search');

        if (searchInput && hasSearchParam) {
            searchInput.focus();
            if (searchInput.value.trim() !== "") {
                const val = searchInput.value;
                searchInput.value = '';
                searchInput.value = val;
            }
        }
    });

    // Hàm điều khiển hiển thị Modal Xóa 
    function openDel(button) {
        var id = button.getAttribute('data-id');
        var fullName = button.getAttribute('data-fullname');

        document.getElementById('del-userId').value  = id;
        document.getElementById('del-name').textContent = fullName;
        new bootstrap.Modal(document.getElementById('modalDel')).show();
    }

    // ── Đóng flash toast ──
    function closeToast() {
        const toast = document.getElementById('flash-toast');
        if (toast) {
            toast.style.transition = 'opacity .3s ease';
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 300);
        }
    }

    // ── Tự động đóng toast sau 4 giây ──
    (function () {
        const toast = document.getElementById('flash-toast');
        if (toast) {
            setTimeout(closeToast, 4000);
        }
    })();
</script>
</body>
</html>