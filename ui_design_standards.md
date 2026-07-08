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

## 11. Hệ thống Thanh điều hướng (Premium Sidebar)
Thanh điều hướng bên trái được thiết kế cố định sát mép trái (`position: fixed`) theo dải màu Gradient chuyển tiếp dọc từ màu tối đậm (`#1E1B4B`) sang màu tím sáng hover (`var(--primary-light)` - `#4338CA`) với độ tương phản văn bản cao, hiệu ứng hover nhấc nhẹ 3D tỏa bóng, vạch chỉ vị trí active màu tím Lavender (`var(--secondary)`), và **2 họa tiết hình tròn mờ đặt lệch ở góc dưới nền** để tạo chiều sâu thẩm mỹ ở vùng chân trang. Nội dung chính của trang (`<main>`) đứng cạnh sidebar sẽ tự động được đẩy lùi `260px` sang phải để tránh đè lấp nhờ quy tắc chọn `.sidebar-custom + main` toàn cục.

> [!TIP]
> **Cấu trúc Flexbox cân đối thị giác:** Cụm tiêu đề ở đầu sidebar sử dụng kỹ thuật bọc trong container `.logo-inner` có `width: 100%`, áp dụng `display: flex`, `padding-left: 20px` (để lệch nhẹ sang phải giúp cả khối cân bằng) và `gap: 12px` để điều hướng khoảng cách chuẩn chỉnh giữa Hộp Icon và chữ `LibraryOS`.
> 
> **Hiệu ứng đổ bóng cho Icon:** Để tăng độ nổi bật trên nền gradient tím tối, Icon cuốn sách mở sử dụng màu trắng `#ffffff` nguyên bản kết hợp hiệu ứng đổ bóng mờ nhẹ `text-shadow: 0 2px 4px rgba(0, 0, 0, 0.25)` mang lại chiều sâu sắc nét.

### Cấu trúc mã HTML mẫu cho Sidebar:
```html
<div class="d-flex flex-column vh-100 sticky-top shadow-lg sidebar-scroll sidebar-custom">
    <!-- Tiêu đề & Logo (Khung ngoài 100%, khung trong dùng flex để tùy biến padding/gap) -->
    <div class="logo-area">
        <div class="logo-inner">
            <div class="logo-icon-box">
                <i class="fa-solid fa-book-open"></i>
            </div>
            <span class="logo-text">LibraryOS</span>
        </div>
    </div>
    
    <!-- Danh sách Menu -->
    <div class="nav flex-column px-3 mb-auto">
        <a href="/dashboard" class="nav-link d-flex align-items-center mb-1 rounded py-2 px-3 menu-link active">
            <i class="fa-solid fa-chart-pie" style="width: 32px; font-size: 1.15rem;"></i> Dashboard
        </a>
        <!-- Các liên kết khác... -->
    </div>
</div>
```

---

## 12. Thẻ Thống kê Nhanh (Quick Stats Cards)
Mẫu thẻ hiển thị các số liệu thống kê nhanh (Quick Stats) được thiết kế theo 2 phương án bố cục linh hoạt trong `style.css`. Tất cả các thẻ đều dùng nền trắng đồng nhất với bóng đổ xám nhạt dịu nhẹ. Hộp biểu tượng `.stat-icon` và tiêu đề `.stat-label` được đồng bộ màu sắc theo các lớp ngữ cảnh nghiệp vụ.

### Thiết kế 1: Dạng Chuẩn (Standard Layout - Grid Card)
Bố cục thẻ dọc chuẩn thích hợp làm các ô lưới độc lập.
*   **Card Background**: Màu trắng tinh (`#ffffff`), viền mờ `1px solid rgba(0, 0, 0, 0.05)`, bóng đổ trung tính `box-shadow: 0 4px 15px rgba(0, 0, 0, 0.04)`.
*   **Icon Box**: Nằm ở góc trên bên phải hoặc bên cạnh tiêu đề, kích thước to hơn (`46x46px`, `font-size: 1.3rem`, bo góc `10px`).
*   **Contextual Theme Color**: Áp dụng các lớp `.stat-primary`, `.stat-success`, `.stat-danger`, `.stat-warning` lên thẻ cha để tự động đồng bộ màu tiêu đề và màu nền mờ hộp icon.

#### Cấu trúc mã HTML mẫu:
```html
<div class="stat-card stat-primary h-100">
    <div class="d-flex justify-content-between align-items-center mb-2">
        <span class="stat-label">Tổng lần mượn</span>
        <!-- Hộp icon tự động nhận nền tint và màu icon đồng bộ từ thẻ cha -->
        <div class="stat-icon m-0">
            <i class="fa-solid fa-book-open"></i>
        </div>
    </div>
    <!-- Số liệu chính -->
    <div class="stat-value">1,240</div>
</div>
```

### Thiết kế 2: Dạng Gọn Gàng (Compact Row Layout)
Bố cục thẻ ngang gọn gàng (cao bằng 3/4 thẻ thường), biểu tượng nằm bên trái (được thu nhỏ gọn hơn `36x36px` để cân đối), tiêu đề và số liệu nằm cạnh nhau ở bên phải theo trục dọc.

#### Cấu trúc mã HTML mẫu:
```html
<div class="stat-card stat-card-compact stat-success">
    <!-- Icon nằm bên trái -->
    <div class="stat-icon">
        <i class="fa-solid fa-book-bookmark"></i>
    </div>
    <!-- Nội dung tiêu đề trên, số liệu dưới nằm bên phải -->
    <div class="stat-content">
        <span class="stat-label">Đang mượn</span>
        <span class="stat-value">12</span>
    </div>
</div>
```

### Các lớp ngữ cảnh đồng bộ màu sắc:
Áp dụng các lớp sau lên thẻ `.stat-card` để đồng bộ màu sắc của Tiêu đề `.stat-label` và nền mờ của Hộp Icon `.stat-icon`:
*   `.stat-primary`: Tím Indigo (Nền icon mờ, chữ label & icon màu `#4F46E5`).
*   `.stat-success`: Xanh lá (Nền icon mờ, chữ label & icon màu `#15803D`).
*   `.stat-danger`: Đỏ (Nền icon mờ, chữ label & icon màu `#DC2626`).
*   `.stat-warning`: Vàng hổ phách (Nền icon mờ, chữ label & icon màu `#D97706`).
*   `.stat-info`: Xanh dương (Nền icon mờ, chữ label & icon màu `#2563EB`).

---

---

## 13. Biểu mẫu Nhập liệu chuẩn hóa (Standardized Forms)
Toàn bộ hệ thống Form (Card form, input text, select option, validation state error, field-error feedback, form-hint và section-divider) đều đã được tập trung hóa trong `style.css` để bảo đảm độ đồng bộ trải nghiệm nhập dữ liệu cao cấp.

### Cấu trúc mã HTML mẫu cho Biểu mẫu Form:
```html
<div class="card form-card">
    <!-- Header của card form có dải màu Gradient -->
    <div class="card-header form-card-header text-white d-flex align-items-center justify-content-between">
        <div>
            <h5 class="mb-0 fw-bold">[Tiêu Đề Biểu Mẫu]</h5>
            <!-- Meta badge hiển thị ID/Ngày tạo nếu là form Edit -->
            <div class="header-meta-badge">
                <i class="fa-solid fa-hashtag"></i> ID: 123
            </div>
        </div>
    </div>
    <div class="card-body p-4">
        <!-- Division Section -->
        <div class="section-divider">Thông tin cơ bản</div>
        
        <div class="mb-3">
            <label class="form-label">Họ và tên <span class="required-mark">*</span></label>
            <input type="text" class="form-control" placeholder="Nhập tên..." required>
            <!-- Lớp lỗi invalid (nếu backend phát hiện lỗi) -->
            <input type="text" class="form-control is-invalid">
            <div class="field-error">
                <i class="fa-solid fa-circle-exclamation"></i> Tên không hợp lệ
            </div>
            <!-- Lớp hiển thị chú thích nhỏ -->
            <div class="form-hint">Nhập đầy đủ cả họ và tên đệm.</div>
        </div>
    </div>
</div>
```

---

## 14. Trang Chi tiết thông tin chuẩn hóa (Standardized Details Pages)
Trang chi tiết đối tượng (như chi tiết độc giả, chi tiết sách...) được đồng bộ thông qua các thành phần: Banner Hero đầu trang, Lưới thông tin Metadata (`.info-grid`) và Danh sách Metadata hàng ngang (`.info-list`).

### Cấu trúc mã HTML mẫu cho Banner Hero của trang Chi tiết:
```html
<div class="details-hero">
    <div class="d-flex align-items-center gap-3 mb-3">
        <!-- Avatar đại diện hình tròn -->
        <div class="details-avatar">
            <i class="fa-solid fa-user"></i>
        </div>
        <div>
            <h2 class="details-hero-name">[Tên Đối Tượng]</h2>
            <div class="details-hero-email">[Thông tin phụ / Email]</div>
        </div>
        <!-- Trạng thái nổi trong Hero -->
        <div class="ms-auto">
            <span class="badge-status badge-active">Hoạt động</span>
        </div>
    </div>
    <!-- Các pill thông tin nhanh -->
    <div class="d-flex gap-2 flex-wrap">
        <span class="details-hero-pill"><i class="fa-solid fa-hashtag"></i> ID: 123</span>
    </div>
</div>
```

### Cấu trúc Lưới 2 Cột hiển thị Metadata (.info-grid):
Dành cho thông tin chi tiết nằm trong khối thẻ `.card` có viền ngăn giữa các ô thông tin:
```html
<div class="info-grid">
    <div class="info-row">
        <span class="info-label">Mã độc giả</span>
        <span class="info-value">1001</span>
    </div>
    <div class="info-row">
        <span class="info-label">Số điện thoại</span>
        <!-- Lớp empty nếu không có dữ liệu để in nghiêng mờ -->
        <span class="info-value empty">Chưa cung cấp</span>
    </div>
</div>
```

### Cấu trúc Danh sách hàng dọc (.info-list):
Dành cho thông tin dạng dòng (nhãn bên trái, giá trị bên phải):
```html
<div class="info-list">
    <div class="info-list-row">
        <span class="info-list-label">Ngày tạo thẻ</span>
        <span class="info-list-value">01/01/2026</span>
    </div>
</div>
```

---

## 15. Những điều Lưu ý (Checklist cho Lập trình viên)

*   [x] **NÊN:** Luôn nhúng `style.css` dưới cùng trong khối `<head>` sau Bootstrap.
*   [x] **NÊN:** Kết hợp các class cơ bản và class chuyển động (VD: `class="btn btn-cancel hover-lift"`).
*   [x] **NÊN:** Sử dụng lưới `.meta-grid` hoặc `.info-grid` cho các thông tin chung thay vì tự chia dòng bảng thủ công.
*   [x] **NÊN:** Sử dụng tiền tố `${pageContext.request.contextPath}` trước liên kết dẫn tới `/assets/css/style.css`.
*   [x] **NÊN:** Sử dụng tệp `header.jsp` tiêu chuẩn để hiển thị tiêu đề động góc trái. Tiêu đề động tự động nhận diện URL gốc từ attribute `javax.servlet.forward.request_uri` (để tránh lỗi forward của Servlet) và ánh xạ sang tên module tương ứng.
*   [x] **NÊN:** Đặt tên tiêu đề trong phần thân trang (`main container`) khác biệt so với tiêu đề Header để tránh lặp nội dung. Ví dụ: ở trang danh sách nên dùng từ *Danh sách độc giả*, *Danh sách nhật ký hệ thống*... ở trang chi tiết dùng *Hồ sơ độc giả*, trang thêm/sửa dùng *Thêm độc giả mới*, *Chỉnh sửa thông tin độc giả*...
*   [x] **NÊN:** Đảm bảo thêm thuộc tính `flex-shrink: 0;` cho tất cả khối thông tin tài khoản người dùng và nút Đăng xuất ở góc phải Header để tránh bị bóp méo hình ảnh (avatar tròn bị biến dạng thành hình oval) khi màn hình co giãn.
*   [ ] **KHÔNG NÊN:** Viết cứng mã màu hexa vào các thẻ style cục bộ. Hãy sử dụng các biến màu CSS có sẵn (Design Tokens).
*   [ ] **KHÔNG NÊN:** Sử dụng class chuyển động `.hover-lift` cho các nút lọc dữ liệu ở toolbar để tránh làm dịch chuyển dòng tìm kiếm gây khó chịu cho người dùng. Hãy dùng `.hover-glow`.
