<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="security.TaiKhoan" %>
<%
    List<TaiKhoan> accounts = (List<TaiKhoan>) request.getAttribute("accounts");
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
    <title>Quản lý Nhân sự - LibraryOS</title>
    <!-- Nhúng Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
     <!-- Nhúng FontAwesome (Nếu cần dùng icon trong nội dung) -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Nhúng phông chữ "Outfit" từ thư viện Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --indigo:       #312E81;
            --indigo-mid:   #4338CA;
            --violet:       #A78BFA;
            --pink:         #F9A8D4;
            --bg:           #F9FAFB;
            --white:        #FFFFFF;
            --text-main:    #1E1B4B;
            --text-muted:   #6B7280;
        }
        * { font-family: 'Outfit', sans-serif;
        }
        body { background: var(--bg);
        }

        /* ---- Sidebar override để dùng màu chủ đạo ---- */
        /* Sidebar layout của nhóm vẫn giữ nguyên */

        /* ---- Alert (toast) ---- */
        .alert-indigo {
            background: #EEF2FF;
            border-left: 4px solid var(--indigo-mid);
            color: var(--indigo); border-radius: 10px;
        }
        .alert-rose {
            background: #FFF1F2;
            border-left: 4px solid #F43F5E;
            color: #BE123C; border-radius: 10px;
        }

        /* ---- Toolbar card ---- */
        .toolbar-card {
            background: var(--white);
            border-radius: 14px;
            box-shadow: 0 1px 3px rgba(49,46,129,.07), 0 4px 8px rgba(49,46,129,.05);
            border: 1px solid #EEF2FF; padding: 18px 20px; margin-bottom: 20px;
        }
        .search-wrap { position: relative;
        }
        .search-wrap .search-icon {
            position: absolute;
            left: 12px; top: 50%; transform: translateY(-50%);
            color: var(--text-muted); pointer-events: none;
        }
        .search-input {
            padding-left: 36px;
            border-radius: 10px;
            border: 1px solid #DDE3F4; background: #F5F7FF;
            transition: border-color .2s, box-shadow .2s;
        }
        .search-input:focus {
            border-color: var(--violet);
            box-shadow: 0 0 0 3px rgba(167,139,250,.18);
            background: #fff;
        }
        .select-role {
            border-radius: 10px;
            border: 1px solid #DDE3F4;
            background: #F5F7FF; transition: border-color .2s;
        }
        .select-role:focus {
            border-color: var(--violet);
            box-shadow: 0 0 0 3px rgba(167,139,250,.18);
        }

        /* ---- Buttons ---- */
        .btn-dreamy {
            background: linear-gradient(135deg, var(--violet) 0%, var(--pink) 100%);
            border: none; color: #fff; border-radius: 10px; font-weight: 600;
            padding: 8px 20px; transition: all .25s ease;
            box-shadow: 0 3px 10px rgba(167,139,250,.35);
        }
        .btn-dreamy:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(167,139,250,.5);
            color: #fff;
        }
        .btn-dreamy-outline {
            background: transparent;
            border: 1.5px solid var(--violet); color: var(--violet);
            border-radius: 10px; font-weight: 500;
            padding: 7px 18px; transition: all .2s;
        }
        .btn-dreamy-outline:hover {
            background: var(--violet);
            color: #fff;
        }

        /* ---- Table card ---- */
        .table-card {
            background: var(--white);
            border-radius: 14px;
            box-shadow: 0 1px 3px rgba(49,46,129,.07), 0 4px 8px rgba(49,46,129,.05);
            border: 1px solid #EEF2FF; overflow: hidden;
        }
        .table thead th {
            background: #F5F3FF;
            color: var(--indigo);
            font-weight: 600; font-size: .83rem;
            letter-spacing: .04em; text-transform: uppercase;
            border-bottom: 2px solid #DDE3F4; padding: 14px 16px;
        }
        .table tbody tr { transition: background .15s;
        }
        .table tbody tr:hover { background: #F9F7FF;
        }
        .table tbody td {
            color: var(--text-main);
            vertical-align: middle;
            padding: 13px 16px; border-bottom: 1px solid #EEF2FF;
        }

        /* ---- Badge vai trò ---- */
        .badge-admin {
            background: #EDE9FE;
            color: #6D28D9;
            border-radius: 20px; padding: 4px 12px;
            font-size: .78rem; font-weight: 600;
        }
        .badge-staff {
            background: #FCE7F3;
            color: #BE185D;
            border-radius: 20px; padding: 4px 12px;
            font-size: .78rem; font-weight: 600;
        }

        /* ---- Action buttons ---- */
        .btn-edit {
            background: #EDE9FE;
            color: #6D28D9; border: none;
            border-radius: 8px; padding: 5px 12px; font-size: .82rem;
            font-weight: 500; transition: all .2s;
        }
        .btn-edit:hover { background: #DDD6FE;
        }
        .btn-del {
            background: #FFF1F2;
            color: #E11D48; border: none;
            border-radius: 8px; padding: 5px 12px; font-size: .82rem;
            font-weight: 500; transition: all .2s;
        }
        .btn-del:hover { background: #FFE4E6;
        }

        /* ---- Empty state ---- */
        .empty-state { padding: 48px 0;
        color: var(--text-muted); }

        /* ---- Modal tweaks ---- */
        .modal-header-indigo {
            background: linear-gradient(135deg, var(--indigo) 0%, var(--indigo-mid) 100%);
            color: #fff; border-radius: 14px 14px 0 0; border: none;
        }
        .modal-header-gold {
            background: linear-gradient(135deg, #92400e 0%, #D97706 100%);
            color: #fff; border-radius: 14px 14px 0 0; border: none;
        }
        .modal-header-rose {
            background: linear-gradient(135deg, #BE123C 0%, #F43F5E 100%);
            color: #fff; border-radius: 14px 14px 0 0; border: none;
        }
        .modal-content { border: none;
        border-radius: 16px; box-shadow: 0 20px 50px rgba(49,46,129,.18); }
        .modal-label { font-size: .82rem;
        font-weight: 600; color: var(--text-muted); margin-bottom: 5px; }
        .modal-input {
            border-radius: 10px;
            border: 1px solid #DDE3F4;
            background: #F5F7FF; transition: border-color .2s, box-shadow .2s;
        }
        .modal-input:focus {
            border-color: var(--violet);
            box-shadow: 0 0 0 3px rgba(167,139,250,.18);
            background: #fff;
        }

        /* ---- Page title ---- */
        .page-title { color: var(--indigo);
        font-weight: 700; font-size: 1.4rem; }
        .page-subtitle { color: var(--text-muted); font-size: .85rem;
        }
    </style>
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
                String alertCls = "success".equals(toastType) ? "alert-indigo" : "alert-rose";
                String iconCls  = "success".equals(toastType) ? "fa-circle-check" : "fa-circle-exclamation";
            %>
            <div class="alert <%=alertCls%> alert-dismissible fade show d-flex align-items-center gap-2 mb-4 p-3" role="alert">
                <i class="fa-solid <%=iconCls%>"></i>
                <span><%=toastMsg%></span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <%-- ===== Tiêu đề + Nút Thêm ===== --%>
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <p class="page-title mb-0">
                        <i class="fa-solid fa-users-gear me-2" style="color:#A78BFA;"></i>Quản lý Nhân sự
                    </p>
                    <span class="page-subtitle">Danh sách tài khoản hệ thống</span>
                </div>
                <button class="btn btn-dreamy" data-bs-toggle="modal" data-bs-target="#modalAdd" id="btn-them-moi">
                    <i class="fa-solid fa-plus me-1"></i> Thêm tài khoản
                </button>
            </div>

            <%-- ===== Toolbar tìm kiếm & lọc ===== --%>
            <div class="toolbar-card">
                <form action="${pageContext.request.contextPath}/accounts" method="GET" id="form-filter" class="row g-3 align-items-end">
                    <div class="col-12 col-md-5">
                        <label class="form-label small fw-semibold text-secondary mb-1">Tìm kiếm</label>
                        <div class="search-wrap">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" name="search" id="input-search"
                                   class="form-control search-input"
                                   placeholder="Nhập tên đăng nhập hoặc họ tên..."
                                   value="<%=search%>" autocomplete="off">
                        </div>
                    </div>
                    <div class="col-12 col-md-3">
                        <label class="form-label small fw-semibold text-secondary mb-1">Vai trò</label>
                        <select name="role" id="select-role" class="form-select select-role">
                            <option value="">-- Tất cả vai trò --</option>
                            <option value="Admin"  <%="Admin".equals(roleFilter)  ? "selected":""%>>Quản trị viên (Admin)</option>
                            <option value="Staff"  <%="Staff".equals(roleFilter)  ? "selected":""%>>Thủ thư (Staff)</option>
                        </select>
                    </div>
                    <div class="col-12 col-md-4 d-flex gap-2 align-items-end">
                        <button type="submit" class="btn btn-dreamy" id="btn-filter">
                            <i class="fa-solid fa-filter me-1"></i> Lọc
                        </button>
                        <% if (!search.isEmpty() || !roleFilter.isEmpty()) { %>
                        <a href="${pageContext.request.contextPath}/accounts" class="btn btn-dreamy-outline" id="btn-reset">
                            <i class="fa-solid fa-rotate-left me-1"></i> Đặt lại
                        </a>
                        <% } %>
                    </div>
                </form>
            </div>

            <%-- ===== Bảng dữ liệu ===== --%>
            <div class="table-card">
                <div class="table-responsive">
                    <table class="table mb-0">
                        <thead>
                            <tr>
                                <th class="ps-4">#</th>
                                <th>Tên đăng nhập</th>
                                <th>Họ và tên</th>
                                <th>Vai trò</th>
                                <th>Ngày tạo</th>
                                <th class="text-end pe-4">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                           if (accounts == null || accounts.isEmpty()) {
                        %>
                            <tr>
                                <td colspan="6" class="text-center empty-state">
                                    <i class="fa-regular fa-folder-open fs-3 d-block mb-2" style="color:#C4B5FD;"></i>
                                    Không tìm thấy tài khoản phù hợp nào.
                                </td>
                            </tr>
                        <%
                            } else {
                               for (security.TaiKhoan tk : accounts) {
                                    String badge = "Admin".equalsIgnoreCase(tk.getRole())
                                        ? "<span class='badge-admin'><i class='fa-solid fa-user-shield me-1'></i>Admin</span>"
                                        : "<span class='badge-staff'><i class='fa-solid fa-user-tie me-1'></i>Thủ thư</span>";
                                    String created = (tk.getCreatedAt() != null)
                                        ? tk.getCreatedAt().toString().substring(0, 19) : "—";
                        %>
                            <tr>
                                <td class="ps-4 fw-semibold" style="color:#6D28D9;">#<%=tk.getUserId()%></td>
                                <td><strong><%=tk.getUsername()%></strong></td>
                                <td><%=tk.getFullName()%></td>
                                <td><%=badge%></td>
                                <td class="text-muted" style="font-size:.85rem;"><%=created%></td>
                                <td class="text-end pe-4">
                                    <button class="btn-edit me-1"
                                            data-id="<%=tk.getUserId()%>"
                                            data-username="<%=tk.getUsername()%>"
                                            data-fullname="<%=tk.getFullName()%>"
                                            data-role="<%=tk.getRole()%>"
                                            onclick="openEdit(this)">
                                            <i class="fa-solid fa-pen-to-square me-1"></i>Sửa
                                    </button>
                                    <button class="btn-del"
                                            data-id="<%=tk.getUserId()%>"
                                            data-fullname="<%=tk.getFullName()%>"
                                            onclick="openDel(this)">
                                        <i class="fa-solid fa-trash-can me-1"></i>Xóa
                                    </button>
                                </td>
                            </tr>
                        <%  }
                            } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><%-- end container --%>
    </main>
</div>

<%-- ========== MODAL THÊM TÀI KHOẢN ========== --%>
<div class="modal fade" id="modalAdd" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header modal-header-indigo py-3">
                <h5 class="modal-title fw-bold">
                    <i class="fa-solid fa-user-plus me-2"></i>Thêm tài khoản mới
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/accounts" method="POST">
                <input type="hidden" name="action" value="create">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="modal-label">Tên đăng nhập <span class="text-danger">*</span></label>
                        <input type="text" name="username" class="form-control modal-input" placeholder="Nhập tên đăng nhập" required id="add-username">
                    </div>
                    <div class="mb-3">
                        <label class="modal-label">Mật khẩu <span class="text-danger">*</span></label>
                        <input type="password" name="password" class="form-control modal-input" placeholder="Nhập mật khẩu" required id="add-password">
                    </div>
                    <div class="mb-3">
                        <label class="modal-label">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" name="fullName" class="form-control modal-input" placeholder="Nhập họ và tên" required id="add-fullname">
                    </div>
                    <div>
                        <label class="modal-label">Vai trò <span class="text-danger">*</span></label>
                        <select name="role" class="form-select modal-input" required id="add-role">
                            <option value="Staff">Thủ thư (Staff)</option>
                            <option value="Admin">Quản trị viên (Admin)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light rounded-bottom" style="border-radius: 0 0 14px 14px;">
                    <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-dreamy px-4" id="btn-tao-tai-khoan">Tạo tài khoản</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ========== MODAL SỬA TÀI KHOẢN ========== --%>
<div class="modal fade" id="modalEdit" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header modal-header-gold py-3">
                <h5 class="modal-title fw-bold">
                    <i class="fa-solid fa-user-gear me-2"></i>Chỉnh sửa tài khoản
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/accounts" method="POST">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="userId" id="edit-userId">
                <div class="modal-body p-4">
                    <div class="mb-3">
                        <label class="modal-label">Tên đăng nhập <span class="text-danger">*</span></label>
                        <input type="text" name="username" id="edit-username" class="form-control modal-input" required>
                    </div>
                    <div class="mb-3">
                        <label class="modal-label">Mật khẩu mới
                            <span class="text-muted fw-normal">(để trống nếu giữ nguyên)</span>
                        </label>
                        <input type="password" name="password" id="edit-password" class="form-control modal-input" placeholder="Nhập mật khẩu mới">
                    </div>
                    <div class="mb-3">
                        <label class="modal-label">Họ và tên <span class="text-danger">*</span></label>
                        <input type="text" name="fullName" id="edit-fullname" class="form-control modal-input" required>
                    </div>
                    <div>
                        <label class="modal-label">Vai trò <span class="text-danger">*</span></label>
                        <select name="role" id="edit-role" class="form-select modal-input" required>
                            <option value="Staff">Thủ thư (Staff)</option>
                            <option value="Admin">Quản trị viên (Admin)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light" style="border-radius: 0 0 14px 14px;">
                    <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-dreamy px-4" id="btn-luu-thay-doi">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ========== MODAL XÓA TÀI KHOẢN ========== --%>
<div class="modal fade" id="modalDel" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header modal-header-rose py-3">
                <h5 class="modal-title fw-bold">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>Xác nhận xóa
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/accounts" method="POST">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="userId" id="del-userId">
                <div class="modal-body p-4 text-center">
                    <div style="font-size:3rem; color:#F43F5E; margin-bottom:12px;">
                        <i class="fa-solid fa-circle-minus"></i>
                    </div>
                    <h5 class="fw-bold" style="color:#1E1B4B;">Bạn chắc chắn muốn xóa?</h5>
                    <p class="text-muted mb-0">
                        Tài khoản của <strong id="del-name" class="text-dark"></strong> sẽ bị vô hiệu hóa và không thể đăng nhập nữa.
                    </p>
                </div>
                <div class="modal-footer border-0 bg-light" style="border-radius: 0 0 14px 14px;">
                    <button type="button" class="btn btn-secondary btn-sm px-3" data-bs-dismiss="modal">Hủy</button>
                    <button type="submit" class="btn btn-danger px-4 fw-semibold" id="btn-xac-nhan-xoa">
                        <i class="fa-solid fa-trash me-1"></i>Đồng ý xóa
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Xử lý bộ đếm thời gian Debounce cho ô tìm kiếm
    let searchTimeout = null;

    document.getElementById('input-search').addEventListener('input', function() {
        clearTimeout(searchTimeout);
        // Sau khi người dùng ngừng gõ 400ms thì form sẽ tự động submit
        searchTimeout = setTimeout(() => {
            document.getElementById('form-filter').submit();
        }, 400);
    });

    // Tự động giữ tiêu điểm (focus) vào ô tìm kiếm và đưa con trỏ xuống cuối chuỗi sau khi trang load lại
    window.addEventListener('DOMContentLoaded', (event) => {
        const searchInput = document.getElementById('input-search');
        
        // Kiểm tra xem trên URL có tham số "search" và nó có giá trị hay không
        const urlParams = new URLSearchParams(window.location.search);
        const hasSearchParam = urlParams.has('search');

        if (searchInput && hasSearchParam) {
            searchInput.focus(); // Chỉ focus khi trang reload do hành động tìm kiếm
            
            // Nếu ô tìm kiếm có chữ thì đưa con trỏ xuống cuối chuỗi
            if (searchInput.value.trim() !== "") {
                const val = searchInput.value;
                searchInput.value = '';
                searchInput.value = val;
            }
        }
    });

    // Hàm điều khiển hiển thị Modal Sửa 
    function openEdit(button) {
        var id = button.getAttribute('data-id');
        var username = button.getAttribute('data-username');
        var fullName = button.getAttribute('data-fullname');
        var role = button.getAttribute('data-role');

        document.getElementById('edit-userId').value   = id;
        document.getElementById('edit-username').value = username;
        document.getElementById('edit-fullname').value = fullName;
        document.getElementById('edit-role').value     = role;
        document.getElementById('edit-password').value = '';
        new bootstrap.Modal(document.getElementById('modalEdit')).show();
    }

    // Hàm điều khiển hiển thị Modal Xóa 
    function openDel(button) {
        var id = button.getAttribute('data-id');
        var fullName = button.getAttribute('data-fullname');

        document.getElementById('del-userId').value  = id;
        document.getElementById('del-name').textContent = fullName;
        new bootstrap.Modal(document.getElementById('modalDel')).show();
    }
</script>
</body>
</html>