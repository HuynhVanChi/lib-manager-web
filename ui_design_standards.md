# Hướng dẫn Quy chuẩn Giao diện & Tích hợp (UI Design Standards & Integration Guide)
## Dự án: Library Management System (LibraryOS)

Tài liệu này cung cấp hướng dẫn chi tiết dành cho lập trình viên về cách nhúng, sử dụng và kết hợp các thành phần giao diện từ tệp CSS dùng chung nhằm xây dựng các trang giao diện đồng bộ, nhất quán và dễ bảo trì.

---

## 1. Hướng dẫn nhúng Stylesheet dùng chung (Import Guide)

Để tất cả các tùy chỉnh CSS có hiệu lực chính xác và đè lên được các thiết lập mặc định của Bootstrap, tệp `style.css` phải được nhúng vào thẻ `<head>` của trang JSP theo quy tắc sau:

### Thứ tự nhúng chuẩn trong `<head>`:
1.  **Bootstrap CSS** (Thư viện cơ sở)
2.  **FontAwesome CSS** (Bộ biểu tượng)
3.  **style.css** (Tệp dùng chung - luôn đặt dưới cùng để có độ ưu tiên cao nhất)

### Cú pháp nhúng chuẩn trong JSP:
Sử dụng thẻ biểu thức JSP để sinh ra đường dẫn tuyệt đối động, tránh lỗi đường dẫn khi chuyển tiếp thư mục:
```html
<head>
    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
</head>
```

---

## 2. Hệ thống Biến màu chuẩn (Design Tokens)

Trong các thẻ `<style>` nội bộ hoặc file CSS bổ sung, lập trình viên nên sử dụng biến màu CSS thay vì mã màu hex tĩnh để dễ thay đổi chủ đề màu sắc sau này:

| Biến CSS | Màu sắc | Mục đích sử dụng |
| :--- | :--- | :--- |
| `var(--primary)` | `#312E81` (Indigo đậm) | Màu nền nút chính, viền nút phụ, màu text tiêu đề bảng. |
| `var(--primary-light)` | `#4338CA` (Indigo sáng) | Trạng thái Hover/Active của nút bấm chính. |
| `var(--primary-soft)` | `#EEF2FF` (Tím/xanh nhạt) | Màu nền của Header bảng, màu nền nút phụ khi hover, nút action. |
| `var(--secondary)` | `#A78BFA` (Tím Lavender) | Sử dụng làm viền trạng thái trung gian, highlight nhẹ. |
| `var(--bg-page)` | `#F9FAFB` (Xám trắng) | Màu nền mặc định của body toàn bộ trang web. |
| `var(--text-dark)` | `#111827` (Đen xám) | Chữ nội dung chính, chữ trong bảng, tiêu đề lớn. |
| `var(--text-muted)` | `#6B7280` (Xám trung tính) | Chữ ghi chú phụ, nhãn tiêu đề (label), icon trang trí. |
| `var(--border)` | `#E5E7EB` (Xám nhạt) | Đường kẻ bảng, viền card, đường ngăn cách (divider). |
| `var(--radius)` | `10px` | Độ bo góc tiêu chuẩn của card, bảng dữ liệu. |

---

## 3. Hệ thống Nút bấm & Hiệu ứng Chuyển động (Buttons & Motions)

Tất cả các nút bấm được tách biệt giữa **Kiểu dáng nút** (Base Class) và **Hiệu ứng chuyển động tương tác** (Motion Class).

### Lớp kiểu dáng nút cơ sở (Base Classes)
*   `.btn-primary`, `.btn-save`, `.btn-edit`: Định dạng nút dạng đặc (Solid) màu tím Indigo, chữ trắng, bo góc 8px.
*   `.btn-danger`: Định dạng nút dạng đặc (Solid) màu đỏ nguy hiểm (cảnh báo, xóa), chữ trắng, bo góc 8px.
*   `.btn-slate`: Định dạng nút dạng đặc (Solid) màu xám Slate (lưu trữ, thùng rác, lịch sử), chữ trắng, bo góc 8px.
*   `.btn-back`, `.btn-cancel`: Định dạng nút viền mảnh (Outline), chữ và viền màu tím Indigo, nền trắng.
*   `.btn-action`: Nút tác vụ dạng icon hình vuông (32x32px) cuối mỗi dòng bảng dữ liệu.

### Lớp hiệu ứng chuyển động tương tác (Motion Classes)
*   `.hover-lift`: Khi di chuột vào nút, nút sẽ **nhấc lên 3D** (`translateY(-1px)`) và **tỏa bóng bóng mờ** (màu tím đối với nút thường, màu đỏ đối với nút `.btn-danger`, màu xám Slate đối với nút `.btn-slate`). Thích hợp cho các nút hành động lưu trữ, tạo mới, quay lại, xóa, khôi phục, thùng rác.
*   `.hover-glow`: Khi di chuột vào nút, nút sẽ **tỏa bóng mờ** tại chỗ, **không dịch chuyển** (không có `translateY`). Thích hợp cho các nút lọc tác vụ tĩnh trên thanh công cụ tìm kiếm.

### Ví dụ áp dụng thực tế:

#### Nút Lưu/Thêm mới (Solid + Nâng nổi 3D):
```html
<button type="submit" class="btn btn-save hover-lift">
    <i class="fa-solid fa-floppy-disk me-2"></i> Lưu dữ liệu
</button>
```

#### Nút Chỉnh sửa (Solid + Nâng nổi 3D):
```html
<a href="..." class="btn-edit hover-lift">
    <i class="fa-solid fa-user-pen me-2"></i> Chỉnh sửa
</a>
```

#### Nút Thùng rác / Lưu trữ (Xám Slate + Nâng nổi 3D + Đổ bóng xám):
```html
<button type="button" class="btn btn-slate hover-lift">
    <i class="fa-solid fa-trash-can me-2"></i> Thùng rác
</button>
```

#### Nút Xác nhận xóa (Nguy hiểm + Nâng nổi 3D + Đổ bóng đỏ):
```html
<button type="submit" class="btn btn-danger hover-lift">
    <i class="fa-solid fa-trash-can me-2"></i> Xác nhận xóa
</button>
```

#### Nút Hủy/Quay lại (Outline + Nâng nổi 3D):
```html
<a href="..." class="btn btn-cancel hover-lift text-decoration-none">
    <i class="fa-solid fa-arrow-left me-2"></i> Quay lại
</a>
```

#### Nút Lọc dữ liệu (Solid + Tỏa sáng tĩnh):
```html
<button type="submit" class="btn btn-primary hover-glow">
    <i class="fa-solid fa-filter me-1"></i> Lọc
</button>
```

---

## 4. Hệ thống Bảng dữ liệu (Data Tables)

Để tạo bảng dữ liệu, lập trình viên sử dụng lớp `.table-custom`. Lớp này đã loại bỏ hoàn toàn các viền dọc thô cứng và tích hợp hiệu ứng hover mượt mà cho từng dòng.

### Cấu trúc mã HTML chuẩn:
```html
<div class="table-responsive">
    <table class="table-custom">
        <thead>
            <tr>
                <th style="width: 50px;">#</th>
                <th>Cột thông tin A</th>
                <th>Cột thông tin B</th>
                <th class="text-end">Hành động</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>1</td>
                <td>Dữ liệu dòng 1</td>
                <td>Dữ liệu dòng 1</td>
                <td class="text-end">
                    <!-- Nút hành động nhanh cuối dòng -->
                    <a href="..." class="btn-action" title="Xem chi tiết">
                        <i class="fa-solid fa-eye"></i>
                    </a>
                </td>
            </tr>
        </tbody>
    </table>
</div>
```

---

## 5. Lưới hiển thị thông tin chi tiết (Metadata Grid Layout)

Dành cho các trang xem chi tiết (như chi tiết độc giả, chi tiết nhật ký), thông tin chung cần được trình bày gọn gàng, chia cột tự động co giãn (Responsive Grid). Sử dụng tổ hợp lớp `.meta-grid`:

*   `.meta-grid`: Khung bao ngoài, chia cột tự động với khoảng cách 20px, đệm trong 24px.
*   `.meta-item`: Khối bao quanh từng cặp nhãn-giá trị.
*   `.meta-label`: Nhãn tiêu đề thông tin (nhỏ, chữ hoa, màu xám nhạt).
*   `.meta-value`: Giá trị thông tin hiển thị chính (đen đậm).

### Cấu trúc mã HTML chuẩn:
```html
<div class="card detail-card bg-white">
    <div class="detail-card-header">
        <i class="fa-solid fa-circle-info text-primary"></i>
        <span>Thông tin chi tiết</span>
    </div>
    <div class="meta-grid">
        <div class="meta-item">
            <span class="meta-label">Mã tài liệu</span>
            <span class="meta-value">#DOC-9982</span>
        </div>
        <div class="meta-item">
            <span class="meta-label">Người khởi tạo</span>
            <span class="meta-value">Nguyễn Văn A</span>
        </div>
        <div class="meta-item">
            <span class="meta-label">Ngày hiệu lực</span>
            <span class="meta-value">07/07/2026</span>
        </div>
    </div>
</div>
```

---

## 6. Nhãn trạng thái (Status Badges)

Badges trạng thái được thiết kế dạng viên thuốc bo tròn (`border-radius: 20px`), chữ đậm sắc nét, nền màu phấn pastel nhẹ nhàng dịu mắt. Sử dụng lớp `.badge-status` kết hợp với màu trạng thái cụ thể:

| Trạng thái | Lớp CSS kết hợp | Màu sắc | Ví dụ |
| :--- | :--- | :--- | :--- |
| **Hoạt động / INSERT** | `.badge-status badge-active` | Nền xanh lá nhạt, chữ xanh lá đậm | `Hoạt động` |
| **Cập nhật / Thông tin** | `.badge-status badge-info-custom` | Nền xanh dương nhạt, chữ xanh dương đậm | `Đang cập nhật` |
| **Quá hạn / Khóa / DELETE** | `.badge-status badge-danger-custom` | Nền đỏ nhạt, chữ đỏ đậm | `Đã xóa` |
| **Khôi phục / Đặc biệt** | `.badge-status badge-restore-custom` | Nền tím nhạt, chữ tím đậm | `Được khôi phục` |
| **Hết hạn / Khóa tạm thời** | `.badge-status badge-expired` | Nền xám nhạt, chữ xám đậm | `Hết hạn thẻ` |
| **Đình chỉ / Cảnh báo** | `.badge-status badge-suspended` | Nền vàng nhạt, chữ vàng đậm | `Tạm đình chỉ` |

### Mã HTML chuẩn:
```html
<span class="badge-status badge-active">Hoạt động</span>
<span class="badge-status badge-suspended">Tạm đình chỉ</span>
```

---

## 7. Giao diện báo cáo trống (Empty States)

Khi bảng dữ liệu không có kết quả do tìm kiếm hoặc cơ sở dữ liệu trống, sử dụng khối `.empty-state` để thông báo trực quan cho người dùng.

### Cấu trúc mã HTML chuẩn:
```html
<div class="empty-state">
    <div class="icon">
        <i class="fa-regular fa-folder-open"></i>
    </div>
    <h5 class="fw-bold text-dark">Không tìm thấy kết quả</h5>
    <p class="text-muted small mb-4">Vui lòng kiểm tra lại từ khóa hoặc bộ lọc của bạn.</p>
    <!-- Nút hành động đính kèm (nếu cần thiết) -->
    <a href="${pageContext.request.contextPath}/readers/add" class="btn btn-primary hover-lift">
        <i class="fa-solid fa-user-plus me-2"></i>Thêm mới độc giả
    </a>
</div>
```

---

## 8. Đường dẫn điều hướng (Breadcrumbs)
Mặc định trong `style.css`, thẻ `.breadcrumb` đã được thu nhỏ xuống cỡ chữ tinh tế `.75rem !important`. Lập trình viên chỉ cần sử dụng lớp Bootstrap chuẩn, giao diện sẽ tự động thu nhỏ:
```html
<ol class="breadcrumb">
    <li class="breadcrumb-item"><a href="/dashboard">Trang chủ</a></li>
    <li class="breadcrumb-item active" aria-current="page">Danh sách độc giả</li>
</ol>
```

---

## 9. Hệ thống Hộp thoại Cảnh báo (Premium Modals)
Mọi hộp thoại xác nhận cảnh báo (đặc biệt là xác nhận xóa) đều được ghi đè tự động bởi `style.css` để tăng tính thẩm mỹ (bo góc `14px`, bóng đổ sâu, hiệu ứng xoay 90 độ cho nút đóng).

### Cấu trúc mã HTML mẫu cho Modal Xóa:
```html
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header d-flex align-items-center">
                <div class="d-flex align-items-center gap-2">
                    <div class="bg-danger bg-opacity-10 text-danger rounded-circle d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <h6 class="modal-title fw-bold m-0" id="deleteModalLabel">Xác nhận xóa</h6>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Đóng"></button>
            </div>
            <div class="modal-body">
                <p class="mb-1" style="font-size: .9rem;">Bạn có chắc chắn muốn xóa?</p>
                <p class="fw-bold mb-3 text-primary" id="delete-item-name" style="font-size: 1rem;">—</p>
                <div class="rounded-3 p-3" style="background: #FEF2F2; border: 1px solid #FECACA; font-size: .82rem; color: #991B1B;">
                    <i class="fa-solid fa-circle-info me-1"></i> Hành động này không thể hoàn tác.
                </div>
            </div>
            <div class="modal-footer">
                <!-- Nút hủy và Nút xóa đã quy chuẩn -->
                <button type="button" class="btn btn-cancel hover-lift" data-bs-dismiss="modal">Hủy</button>
                <form id="delete-form" method="post" action="" class="m-0">
                    <button type="submit" class="btn btn-danger hover-lift">
                        <i class="fa-solid fa-trash-can me-1"></i> Xác nhận xóa
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
```

---

## 10. Hệ thống Thông báo nổi (Flash Toasts)
Toàn bộ thông báo nổi phản hồi kết quả (Thành công, Thất bại) đều được tập trung hóa thiết kế trong `style.css` với hiệu ứng trượt nhẹ từ phải sang trái (`slideIn`).

### Cấu trúc mã HTML mẫu cho Flash Toast:
```html
<c:if test="${not empty flashMessage}">
    <div class="flash-toast ${flashType}" id="flash-toast" role="alert">
        <span class="toast-icon">
            <c:choose>
                <c:when test="${flashType == 'success'}">
                    <i class="fa-solid fa-circle-check"></i>
                </c:when>
                <c:otherwise>
                    <i class="fa-solid fa-circle-xmark"></i>
                </c:otherwise>
            </c:choose>
        </span>
        <div class="toast-body small fw-medium m-0">
            <c:out value="${flashMessage}"/>
        </div>
        <button type="button" class="toast-close" onclick="closeToast()">&times;</button>
    </div>
</c:if>
```

### Hàm Javascript đóng tự động và thủ công:
```javascript
function closeToast() {
    const toast = document.getElementById('flash-toast');
    if (toast) {
        toast.style.transition = 'opacity .3s ease';
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 300);
    }
}

// Tự động ẩn sau 4 giây
setTimeout(closeToast, 4000);
```

---

## 11. Những điều Lưu ý (Checklist cho Lập trình viên)

*   [x] **NÊN:** Luôn nhúng `style.css` dưới cùng trong khối `<head>` sau Bootstrap.
*   [x] **NÊN:** Kết hợp các class cơ bản và class chuyển động (VD: `class="btn btn-cancel hover-lift"`).
*   [x] **NÊN:** Sử dụng lưới `.meta-grid` cho các thông tin chung thay vì tự chia dòng bảng thủ công.
*   [x] **NÊN:** Sử dụng tiền tố `${pageContext.request.contextPath}` trước liên kết dẫn tới `/assets/css/style.css`.
*   [ ] **KHÔNG NÊN:** Viết cứng mã màu hexa vào các thẻ style cục bộ. Hãy sử dụng các biến màu CSS có sẵn (Design Tokens).
*   [ ] **KHÔNG NÊN:** Sử dụng class chuyển động `.hover-lift` cho các nút lọc dữ liệu ở toolbar để tránh làm dịch chuyển dòng tìm kiếm gây khó chịu cho người dùng. Hãy dùng `.hover-glow`.
