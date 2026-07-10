<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh Sửa Danh Mục - LibraryOS</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Project CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <style>
        /* 10 PREMIUM DYNAMIC COLOR THEMES FOR CATEGORIES */
        .badge-status {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            line-height: 1;
            text-align: center;
            white-space: nowrap;
            vertical-align: baseline;
            border-radius: 9999px;
            transition: all 0.2s ease-in-out;
        }
        .badge-theme-blue {
            background-color: rgba(59, 130, 246, 0.1) !important;
            color: #1d4ed8 !important;
            border: 1px solid rgba(59, 130, 246, 0.25) !important;
        }
        .badge-theme-indigo {
            background-color: rgba(99, 102, 241, 0.1) !important;
            color: #4338ca !important;
            border: 1px solid rgba(99, 102, 241, 0.25) !important;
        }
        .badge-theme-purple {
            background-color: rgba(168, 85, 247, 0.1) !important;
            color: #6d28d9 !important;
            border: 1px solid rgba(168, 85, 247, 0.25) !important;
        }
        .badge-theme-pink {
            background-color: rgba(236, 72, 153, 0.1) !important;
            color: #be185d !important;
            border: 1px solid rgba(236, 72, 153, 0.25) !important;
        }
        .badge-theme-rose {
            background-color: rgba(244, 63, 94, 0.1) !important;
            color: #be123c !important;
            border: 1px solid rgba(244, 63, 94, 0.25) !important;
        }
        .badge-theme-red {
            background-color: rgba(239, 68, 68, 0.1) !important;
            color: #b91c1c !important;
            border: 1px solid rgba(239, 68, 68, 0.25) !important;
        }
        .badge-theme-orange {
            background-color: rgba(249, 115, 22, 0.1) !important;
            color: #c2410c !important;
            border: 1px solid rgba(249, 115, 22, 0.25) !important;
        }
        .badge-theme-amber {
            background-color: rgba(245, 158, 11, 0.1) !important;
            color: #b45309 !important;
            border: 1px solid rgba(245, 158, 11, 0.25) !important;
        }
        .badge-theme-emerald {
            background-color: rgba(16, 185, 129, 0.1) !important;
            color: #047857 !important;
            border: 1px solid rgba(16, 185, 129, 0.25) !important;
        }
        .badge-theme-teal {
            background-color: rgba(20, 184, 166, 0.1) !important;
            color: #0f766e !important;
            border: 1px solid rgba(20, 184, 166, 0.25) !important;
        }
        .badge-theme-slate {
            background-color: rgba(100, 116, 139, 0.1) !important;
            color: #334155 !important;
            border: 1px solid rgba(100, 116, 139, 0.25) !important;
        }
        .color-picker-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 8px;
            margin-bottom: 8px;
        }
        .color-dot-wrapper {
            position: relative;
            cursor: pointer;
        }
        .color-dot {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: 2px solid transparent;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 11px;
            font-weight: bold;
            box-shadow: 0 2px 4px rgba(0,0,0,0.06);
        }
        .color-dot-wrapper:hover .color-dot {
            transform: scale(1.15);
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        .color-dot-wrapper.active .color-dot {
            border-color: #334155;
            box-shadow: 0 0 0 2px rgba(51, 65, 85, 0.25);
        }
        .color-dot-wrapper.active .color-dot::after {
            content: "✓";
            font-size: 14px;
            color: white;
            text-shadow: 0 1px 2px rgba(0,0,0,0.4);
        }
        .dot-blue { background-color: #3b82f6; }
        .dot-indigo { background-color: #6366f1; }
        .dot-purple { background-color: #a855f7; }
        .dot-pink { background-color: #ec4899; }
        .dot-rose { background-color: #f43f5e; }
        .dot-red { background-color: #ef4444; }
        .dot-orange { background-color: #f97316; }
        .dot-amber { background-color: #f59e0b; }
        .dot-emerald { background-color: #10b981; }
        .dot-teal { background-color: #14b8a6; }
        .dot-slate { background-color: #64748b; }
    </style>
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH -->
    <div class="d-flex">
        
        <!-- 1. CỘT TRÁI: NHÚNG SIDEBAR -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- 2. CỘT PHẢI: KHU VỰC NỘI DUNG -->
        <main class="w-100" style="min-height: 100vh; display: flex; flex-direction: column;">
            
            <!-- Header ngang -->
            <jsp:include page="/views/layout/header.jsp"/>

            <!-- Vùng đệm p-4 -->
            <div class="container-fluid p-4 flex-grow-1">
                
                <%-- ── TIÊU ĐỀ + BREADCRUMB ── --%>
                <div class="d-flex justify-content-between align-items-start mb-4">
                    <div>
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb">
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/categories">
                                        <i class="fa-solid fa-tags me-1"></i>Quản lý danh mục
                                    </a>
                                </li>
                                <li class="breadcrumb-item">
                                    <a href="${pageContext.request.contextPath}/categories/detail?id=${category.categoryId}">
                                        <c:out value="${category.name}"/>
                                    </a>
                                </li>
                                <li class="breadcrumb-item active" aria-current="page">Chỉnh sửa</li>
                            </ol>
                        </nav>
                        <h1 class="fw-bold mt-1 mb-0 text-dark" style="font-size:1.5rem;">Chỉnh sửa danh mục</h1>
                    </div>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/categories" id="btn-back" class="btn-back hover-lift">
                            <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
                        </a>
                    </div>
                </div>


                <div class="row">
                    <div class="col-12 col-xl-8">
                        <div class="card form-card">
                            
                            <%-- Header Card --%>
                            <div class="card-header form-card-header text-white d-flex align-items-center justify-content-between">
                                <div class="d-flex align-items-center gap-2">
                                    <i class="fa-solid fa-pen-to-square fs-5 text-white"></i>
                                    <h5 class="text-white fw-bold mb-0" style="font-size:1rem;">Chỉnh sửa thông tin danh mục</h5>
                                </div>
                                <span class="header-meta-badge">ID: #${category.categoryId}</span>
                            </div>
                            
                            <%-- Form Body --%>
                            <div class="p-4">
                                <form id="editCategoryForm" action="${pageContext.request.contextPath}/categories?action=update" method="post">
                                    <input type="hidden" name="categoryId" value="${category.categoryId}">
                                    
                                    <!-- 1. Tên danh mục -->
                                    <div class="mb-4">
                                        <label for="name" class="form-label small fw-semibold text-secondary">Tên danh mục <span class="required-mark">*</span></label>
                                        <input type="text" class="form-control" id="name" name="name" 
                                               value="${category.name}" required maxlength="100" 
                                               placeholder="Ví dụ: Khoa học viễn tưởng, Kỹ năng sống...">
                                        <div class="form-hint">Nhập tên danh mục rõ ràng, ngắn gọn và không trùng lặp với danh mục hiện có.</div>
                                    </div>
                                    
                                    <!-- 2. Mô tả -->
                                    <div class="mb-4">
                                        <label for="description" class="form-label small fw-semibold text-secondary">Mô tả chi tiết</label>
                                        <textarea class="form-control" id="description" name="description" 
                                                  rows="5" maxlength="500" 
                                                  placeholder="Nhập mô tả tóm tắt về loại sách thuộc danh mục này...">${category.description}</textarea>
                                        <div class="form-hint">Tối đa 500 ký tự. Giải thích rõ các nhóm tài liệu nằm trong danh mục này.</div>
                                    </div>
                                    
                                    <!-- 3. Màu sắc danh mục -->
                                    <div class="mb-4">
                                        <label class="form-label small fw-semibold text-secondary d-flex align-items-center gap-3">
                                            <span>Màu sắc hiển thị</span>
                                            <span id="preview-badge" class="badge-status badge-theme-${category.colorTheme} px-3 py-1.5 fs-7">${category.name}</span>
                                        </label>
                                        
                                        <!-- Hidden Input to store the selected theme -->
                                        <input type="hidden" name="colorTheme" id="colorTheme" value="${category.colorTheme}">
                                        
                                        <!-- Grid of color circles -->
                                        <div class="color-picker-grid">
                                            <div class="color-dot-wrapper" data-color="indigo" title="Xanh chàm"><div class="color-dot dot-indigo"></div></div>
                                            <div class="color-dot-wrapper" data-color="blue" title="Xanh dương"><div class="color-dot dot-blue"></div></div>
                                            <div class="color-dot-wrapper" data-color="purple" title="Tím"><div class="color-dot dot-purple"></div></div>
                                            <div class="color-dot-wrapper" data-color="pink" title="Hồng"><div class="color-dot dot-pink"></div></div>
                                            <div class="color-dot-wrapper" data-color="rose" title="Hồng dâu"><div class="color-dot dot-rose"></div></div>
                                            <div class="color-dot-wrapper" data-color="red" title="Đỏ"><div class="color-dot dot-red"></div></div>
                                            <div class="color-dot-wrapper" data-color="orange" title="Cam"><div class="color-dot dot-orange"></div></div>
                                            <div class="color-dot-wrapper" data-color="amber" title="Vàng hổ phách"><div class="color-dot dot-amber"></div></div>
                                            <div class="color-dot-wrapper" data-color="emerald" title="Xanh lá"><div class="color-dot dot-emerald"></div></div>
                                            <div class="color-dot-wrapper" data-color="teal" title="Xanh ngọc"><div class="color-dot dot-teal"></div></div>
                                        </div>
                                        <div class="form-hint">Chọn một trong 10 màu sắc trên để làm nhãn phân biệt danh mục này trên giao diện.</div>
                                    </div>
                                    
                                    <!-- Phân vùng & Nút bấm -->
                                    <div class="section-divider my-4"></div>
                                    
                                    <div class="d-flex gap-2 justify-content-end">
                                        <a href="${pageContext.request.contextPath}/categories" id="btn-cancel" class="btn-cancel hover-lift px-4">
                                            Hủy bỏ
                                        </a>
                                        <button type="submit" class="btn-save hover-lift px-4">
                                            <i class="fa-solid fa-circle-check me-1"></i> Lưu thay đổi
                                        </button>
                                    </div>

                                </form>
                            </div>

                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Bootstrap JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- JavaScript ngăn rời trang khi có thay đổi chưa lưu và điều khiển chọn màu -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            const form = document.getElementById("editCategoryForm");
            const nameInput = document.getElementById("name");
            const descInput = document.getElementById("description");
            const colorThemeInput = document.getElementById("colorTheme");
            const previewBadge = document.getElementById("preview-badge");
            const colorWrappers = document.querySelectorAll(".color-dot-wrapper");
            const cancelBtn = document.getElementById("btn-cancel");
            const backBtn = document.getElementById("btn-back");

            let originalName = nameInput.value;
            let originalDesc = descInput.value;
            let originalColor = colorThemeInput.value || "indigo";

            function isDirty() {
                return nameInput.value !== originalName || 
                       descInput.value !== originalDesc || 
                       (colorThemeInput.value !== originalColor);
            }

            const colorsMap = {
                indigo: { bg: "rgba(99, 102, 241, 0.1)", text: "#4338ca", border: "rgba(99, 102, 241, 0.25)" },
                blue: { bg: "rgba(59, 130, 246, 0.1)", text: "#1d4ed8", border: "rgba(59, 130, 246, 0.25)" },
                purple: { bg: "rgba(168, 85, 247, 0.1)", text: "#6d28d9", border: "rgba(168, 85, 247, 0.25)" },
                pink: { bg: "rgba(236, 72, 153, 0.1)", text: "#be185d", border: "rgba(236, 72, 153, 0.25)" },
                rose: { bg: "rgba(244, 63, 94, 0.1)", text: "#be123c", border: "rgba(244, 63, 94, 0.25)" },
                red: { bg: "rgba(239, 68, 68, 0.1)", text: "#b91c1c", border: "rgba(239, 68, 68, 0.25)" },
                orange: { bg: "rgba(249, 115, 22, 0.1)", text: "#c2410c", border: "rgba(249, 115, 22, 0.25)" },
                amber: { bg: "rgba(245, 158, 11, 0.1)", text: "#b45309", border: "rgba(245, 158, 11, 0.25)" },
                emerald: { bg: "rgba(16, 185, 129, 0.1)", text: "#047857", border: "rgba(16, 185, 129, 0.25)" },
                teal: { bg: "rgba(20, 184, 166, 0.1)", text: "#0f766e", border: "rgba(20, 184, 166, 0.25)" }
            };

            function updatePreviewStyle(color) {
                const styles = colorsMap[color] || colorsMap['indigo'];
                previewBadge.style.backgroundColor = styles.bg;
                previewBadge.style.color = styles.text;
                previewBadge.style.borderColor = styles.border;
                previewBadge.style.borderStyle = "solid";
                previewBadge.style.borderWidth = "1px";
            }

            // Đồng bộ tên danh mục vào thẻ xem trước
            nameInput.addEventListener("input", function() {
                const text = nameInput.value.trim();
                previewBadge.textContent = text ? text : "Xem trước";
            });

            // Khởi tạo màu ban đầu
            updatePreviewStyle(originalColor);

            // Chọn màu sắc
            colorWrappers.forEach(wrapper => {
                const color = wrapper.getAttribute("data-color");
                
                // Pre-select active color dot
                if (color === originalColor) {
                    wrapper.classList.add("active");
                }

                wrapper.addEventListener("click", function() {
                    colorWrappers.forEach(w => w.classList.remove("active"));
                    wrapper.classList.add("active");
                    const newColor = wrapper.getAttribute("data-color");
                    colorThemeInput.value = newColor;
                    previewBadge.className = `badge-status badge-theme-${newColor} px-3 py-1.5 fs-7`;
                    updatePreviewStyle(newColor);
                });
            });

            const beforeUnloadHandler = function(e) {
                if (isDirty()) {
                    e.preventDefault();
                    e.returnValue = "Bạn có thay đổi chưa lưu. Bạn có chắc muốn rời đi?";
                }
            };

            // Gắn sự kiện rời trang
            window.addEventListener("beforeunload", beforeUnloadHandler);

            // Gỡ bỏ cảnh báo rời trang khi submit
            const bypassUnload = () => {
                window.removeEventListener("beforeunload", beforeUnloadHandler);
                window.onbeforeunload = null;
            };

            form.addEventListener("submit", bypassUnload);
            
            [cancelBtn, backBtn].forEach(btn => {
                if (btn) {
                    btn.addEventListener("click", function(e) {
                        if (isDirty()) {
                            if (!confirm("Bạn có thay đổi chưa lưu. Bạn có chắc chắn muốn hủy bỏ?")) {
                                e.preventDefault();
                            } else {
                                bypassUnload();
                            }
                        } else {
                            bypassUnload();
                        }
                    });
                }
            });
        });
    </script>
    <%-- ── FLASH TOAST (cục bộ tương tự Độc giả) ── --%>
    <c:if test="${not empty errorMessage}">
        <div class="flash-toast error" id="flash-toast" role="alert">
            <span class="toast-icon">
                <i class="fa-solid fa-circle-xmark"></i>
            </span>
            <div class="toast-body small fw-medium m-0">
                <c:out value="${errorMessage}"/>
            </div>
            <button type="button" class="toast-close" onclick="closeToast()">&times;</button>
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
    </c:if>
</body>
</html>
