<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo Phiếu Mượn Sách Mới - LibraryOS</title>
    
    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Custom dropdown styles to avoid bootstrap conflict */
        .search-dropdown-menu {
            position: absolute;
            top: 100%;
            left: 0;
            z-index: 1000;
            display: none;
            width: 100%;
            background-color: #fff;
            border: 1px solid #E5E7EB;
            border-radius: 8px;
            box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1);
            max-height: 250px;
            overflow-y: auto;
            padding: 0;
            margin-top: 4px;
        }
        .search-dropdown-item {
            width: 100%;
            padding: 10px 16px;
            text-align: left;
            background: none;
            border: none;
            border-bottom: 1px solid #F3F4F6;
            transition: background-color 0.2s;
            cursor: pointer;
            display: block;
        }
        .search-dropdown-item:last-child {
            border-bottom: none;
        }
        .search-dropdown-item:hover {
            background-color: #F3F4F6;
        }
        .preset-btn {
            border-radius: 6px;
            font-size: 0.85rem;
            padding: 4px 12px;
            transition: all 0.2s ease;
        }
        .preset-btn:hover {
            background-color: var(--primary);
            color: #fff;
            border-color: var(--primary);
        }
    </style>
</head>
<body class="m-0 p-0 bg-light">

    <!-- KHUNG LAYOUT CHÍNH -->
    <div class="d-flex">
        
        <!-- SIDEBAR -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- NỘI DUNG CHÍNH -->
        <main class="w-100 min-vh-100 d-flex flex-column">
            
            <!-- HEADER -->
            <jsp:include page="/views/layout/header.jsp"/>

            <!-- VÙNG ĐỆM NỘI DUNG -->
            <div class="container-fluid p-4 flex-grow-1">

                <!-- Breadcrumbs điều hướng -->
                <div class="mb-3">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="${pageContext.request.contextPath}/borrow-return">
                                    <i class="fa-solid fa-house-chimney me-1"></i>Mượn trả & Vi phạm
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <i class="fa-solid fa-file-invoice me-1"></i>Tạo phiếu mượn
                            </li>
                        </ol>
                    </nav>
                </div>

                <!-- BIỂU MẪU NHẬP LIỆU CHUẨN HÓA -->
                <div class="card form-card mx-auto shadow-sm">
                    <div class="card-header form-card-header text-white">
                        <h5 class="mb-0 fw-bold"><i class="fa-solid fa-file-invoice me-2"></i>Tạo Phiếu Mượn Sách Mới</h5>
                    </div>
                    <div class="card-body p-4">
                        <form action="${pageContext.request.contextPath}/borrow-return/create" method="POST" class="m-0">
                            
                            <div class="section-divider">Thông tin phiếu mượn</div>
                            
                            <div class="mb-3">
                                <label for="readerSearch" class="form-label fw-medium">Chọn Độc Giả <span class="required-mark">*</span></label>
                                <div class="position-relative">
                                    <input type="text" id="readerSearch" class="form-control" placeholder="Tìm kiếm độc giả theo tên, mã, email, số điện thoại..." autocomplete="off" required>
                                    <input type="hidden" name="readerId" id="readerId" required>
                                    <div id="readerDropdown" class="search-dropdown-menu shadow-sm border">
                                        <c:forEach var="r" items="${readerList}">
                                            <button type="button" class="search-dropdown-item reader-option" 
                                                    data-id="${r.reader_id}" 
                                                    data-name="${r.full_name}" 
                                                    data-email="${r.email}" 
                                                    data-phone="${r.phone}">
                                                <div class="fw-semibold text-dark">${r.full_name}</div>
                                                <div class="text-muted small">Mã: #${r.reader_id} | Email: ${r.email} ${not empty r.phone ? ' | SĐT: '.concat(r.phone) : ''}</div>
                                            </button>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="form-hint">Nhấp vào ô và gõ để lọc nhanh độc giả.</div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="copySearch" class="form-label fw-medium">Chọn Sách Cần Mượn <span class="required-mark">*</span></label>
                                <div class="position-relative">
                                    <input type="text" id="copySearch" class="form-control" placeholder="Tìm kiếm sách theo mã bản sao, tên sách..." autocomplete="off" required>
                                    <input type="hidden" name="copyId" id="copyId" required>
                                    <div id="copyDropdown" class="search-dropdown-menu shadow-sm border">
                                        <c:forEach var="c" items="${availableCopies}">
                                            <button type="button" class="search-dropdown-item copy-option" 
                                                    data-id="${c.copy_id}" 
                                                    data-title="${c.title}" 
                                                    data-barcode="${c.barcode}">
                                                <div class="fw-semibold text-dark">${c.title}</div>
                                                <div class="text-muted small">Mã bản sao: ${c.barcode}</div>
                                            </button>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="form-hint">Nhấp vào ô và gõ để tìm theo mã hoặc tiêu đề sách.</div>
                            </div>
                            
                            <div class="mb-4" style="max-width: 450px;">
                                <label class="form-label fw-medium">Thời hạn mượn (tối đa 3 tháng) <span class="required-mark">*</span></label>
                                <div class="d-flex gap-2 align-items-center mb-2">
                                    <input type="number" id="durationValue" class="form-control" style="width: 100px;" min="1" max="90" value="14" required>
                                    <select id="durationUnit" class="form-select" style="width: 120px;">
                                        <option value="days" selected>Ngày</option>
                                        <option value="months">Tháng</option>
                                    </select>
                                    <input type="hidden" name="durationDays" id="durationDays" value="14">
                                </div>
                                <div class="d-flex flex-wrap gap-2">
                                    <button type="button" class="btn btn-outline-secondary btn-sm preset-btn" data-val="7" data-unit="days">7 ngày</button>
                                    <button type="button" class="btn btn-outline-secondary btn-sm preset-btn" data-val="14" data-unit="days">14 ngày</button>
                                    <button type="button" class="btn btn-outline-secondary btn-sm preset-btn" data-val="1" data-unit="months">1 tháng</button>
                                    <button type="button" class="btn btn-outline-secondary btn-sm preset-btn" data-val="3" data-unit="months">3 tháng</button>
                                </div>
                            </div>
                            
                            <div class="d-flex gap-2 justify-content-end mt-4">
                                <a href="${pageContext.request.contextPath}/borrow-return" class="btn btn-cancel hover-lift">
                                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại
                                </a>
                                <button type="submit" class="btn btn-save hover-lift">
                                    <i class="fa-solid fa-floppy-disk me-1"></i> Tạo phiếu mượn
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- jQuery & Bootstrap 5 JS Bundle -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Hàm loại bỏ dấu tiếng Việt để tìm kiếm không dấu
        function removeVietnameseAccents(str) {
            if (!str) return "";
            return str.normalize("NFD")
                      .replace(/[\u0300-\u036f]/g, "")
                      .replace(/đ/g, "d")
                      .replace(/Đ/g, "d");
        }

        document.addEventListener("DOMContentLoaded", function() {
            // --- 1. XỬ LÝ ĐỘC GIẢ (READER) ---
            const readerSearch = document.getElementById("readerSearch");
            const readerId = document.getElementById("readerId");
            const readerDropdown = document.getElementById("readerDropdown");
            const readerOptions = document.querySelectorAll(".reader-option");

            readerSearch.addEventListener("focus", () => {
                readerDropdown.style.display = "block";
            });

            readerSearch.addEventListener("input", () => {
                const query = removeVietnameseAccents(readerSearch.value.toLowerCase().trim());
                readerDropdown.style.display = "block";
                readerOptions.forEach(opt => {
                    const name = removeVietnameseAccents((opt.getAttribute("data-name") || "").toLowerCase());
                    const id = (opt.getAttribute("data-id") || "").toLowerCase();
                    const email = removeVietnameseAccents((opt.getAttribute("data-email") || "").toLowerCase());
                    const phone = (opt.getAttribute("data-phone") || "").toLowerCase();
                    
                    if (name.includes(query) || id.includes(query) || email.includes(query) || phone.includes(query)) {
                        opt.style.setProperty("display", "block", "important");
                    } else {
                        opt.style.setProperty("display", "none", "important");
                    }
                });
            });

            readerOptions.forEach(opt => {
                opt.addEventListener("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    const id = this.getAttribute("data-id");
                    const name = this.getAttribute("data-name");
                    readerSearch.value = name;
                    readerId.value = id;
                    readerDropdown.style.display = "none";
                });
            });

            // --- 2. XỬ LÝ SÁCH (BOOK COPY) ---
            const copySearch = document.getElementById("copySearch");
            const copyId = document.getElementById("copyId");
            const copyDropdown = document.getElementById("copyDropdown");
            const copyOptions = document.querySelectorAll(".copy-option");

            copySearch.addEventListener("focus", () => {
                copyDropdown.style.display = "block";
            });

            copySearch.addEventListener("input", () => {
                const query = removeVietnameseAccents(copySearch.value.toLowerCase().trim());
                copyDropdown.style.display = "block";
                copyOptions.forEach(opt => {
                    const title = removeVietnameseAccents((opt.getAttribute("data-title") || "").toLowerCase());
                    const barcode = (opt.getAttribute("data-barcode") || "").toLowerCase();
                    
                    if (title.includes(query) || barcode.includes(query)) {
                        opt.style.setProperty("display", "block", "important");
                    } else {
                        opt.style.setProperty("display", "none", "important");
                    }
                });
            });

            copyOptions.forEach(opt => {
                opt.addEventListener("click", function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    const id = this.getAttribute("data-id");
                    const title = this.getAttribute("data-title");
                    const barcode = this.getAttribute("data-barcode");
                    copySearch.value = barcode + " - " + title;
                    copyId.value = id;
                    copyDropdown.style.display = "none";
                });
            });

            // Đóng menu khi click ra ngoài
            document.addEventListener("click", function(e) {
                if (!readerSearch.contains(e.target) && !readerDropdown.contains(e.target)) {
                    readerDropdown.style.display = "none";
                }
                if (!copySearch.contains(e.target) && !copyDropdown.contains(e.target)) {
                    copyDropdown.style.display = "none";
                }
            });

            // --- 3. XỬ LÝ THỜI HẠN MƯỢN ---
            const durationValue = document.getElementById("durationValue");
            const durationUnit = document.getElementById("durationUnit");
            const durationDays = document.getElementById("durationDays");
            const presetBtns = document.querySelectorAll(".preset-btn");

            function updateDurationDays() {
                let val = parseInt(durationValue.value) || 1;
                const unit = durationUnit.value;
                if (unit === "months") {
                    if (val > 3) {
                        val = 3;
                        durationValue.value = 3;
                    }
                    durationDays.value = val * 30;
                } else {
                    if (val > 90) {
                        val = 90;
                        durationValue.value = 90;
                    }
                    durationDays.value = val;
                }
            }

            durationValue.addEventListener("input", updateDurationDays);
            durationUnit.addEventListener("change", function() {
                const unit = durationUnit.value;
                if (unit === "months") {
                    durationValue.setAttribute("max", "3");
                    if (parseInt(durationValue.value) > 3) {
                        durationValue.value = 3;
                    }
                } else {
                    durationValue.setAttribute("max", "90");
                }
                updateDurationDays();
            });

            presetBtns.forEach(btn => {
                btn.addEventListener("click", function() {
                    const val = this.getAttribute("data-val");
                    const unit = this.getAttribute("data-unit");
                    durationValue.value = val;
                    durationUnit.value = unit;
                    if (unit === "months") {
                        durationValue.setAttribute("max", "3");
                    } else {
                        durationValue.setAttribute("max", "90");
                    }
                    updateDurationDays();
                });
            });
        });
    </script>
</body>
</html>
