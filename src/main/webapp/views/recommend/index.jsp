<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gợi ý Sách thông minh - LibraryOS</title>
    
    <!-- Nhúng Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Nhúng FontAwesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- Nhúng Font chữ Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #F9FAFB;
            color: #1F2937;
        }

        :root {
            --primary-color: #312E81;
            --primary-light: #4F46E5;
            --accent-purple: #A78BFA;
            --card-border-radius: 14px;
        }

        /* Giao diện Thẻ sách (Book Card) */
        .book-card {
            border-radius: var(--card-border-radius);
            border: none;
            background: #ffffff;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            overflow: hidden;
            display: flex;
            flex-direction: column;
            height: 100%;
        }
        
        .book-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }

        /* Bìa sách giả lập cực đẹp dùng Gradient */
        .book-cover {
            height: 200px;
            background: linear-gradient(135deg, var(--primary-color) 0%, #4F46E5 100%);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 20px;
            color: #ffffff;
            position: relative;
            overflow: hidden;
            border-bottom: 4px solid var(--accent-purple);
        }

        .book-cover::after {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 12px;
            height: 100%;
            background: rgba(255, 255, 255, 0.06);
            box-shadow: 2px 0 5px rgba(0, 0, 0, 0.1);
        }

        .book-cover-title {
            font-weight: 700;
            font-size: 1.05rem;
            line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
        }

        .book-cover-author {
            font-size: 0.75rem;
            opacity: 0.85;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .book-info {
            padding: 16px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .book-title {
            font-weight: 600;
            font-size: 0.95rem;
            color: #111827;
            margin-bottom: 4px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            line-height: 1.4;
        }

        .book-author {
            font-size: 0.825rem;
            color: #4B5563;
            margin-bottom: 8px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .book-meta {
            font-size: 0.75rem;
            color: #9CA3AF;
            border-top: 1px solid #f3f4f6;
            padding-top: 10px;
            margin-top: auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* Thẻ phụ hiển thị điểm gợi ý hoặc lượt mượn */
        .badge-recommend {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 6px;
        }

        /* Tabs thiết kế đẹp mắt */
        .recommend-nav-link {
            color: #4B5563;
            font-weight: 500;
            border: none !important;
            padding: 10px 18px !important;
            border-radius: 8px !important;
            transition: all 0.2s ease;
        }
        .recommend-nav-link.active {
            background-color: var(--primary-color) !important;
            color: #ffffff !important;
            font-weight: 600;
            box-shadow: 0 4px 12px rgba(49, 46, 129, 0.15);
        }
        .recommend-nav-link:hover:not(.active) {
            background-color: #e5e7eb;
            color: #111827;
        }

        /* Thẻ hiển thị cuốn sách mục tiêu */
        .target-book-card {
            border-radius: var(--card-border-radius);
            background: linear-gradient(135deg, #1e1b4b 0%, #312E81 100%);
            color: #ffffff;
            border: none;
            padding: 24px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }

        /* Skeleton loader cho sách */
        .skeleton-cover {
            height: 200px;
            border-radius: 12px 12px 0 0;
        }
        .skeleton-text {
            height: 18px;
            margin-bottom: 8px;
            border-radius: 4px;
        }
        .skeleton-line-long {
            width: 85%;
        }
        .skeleton-line-short {
            width: 45%;
        }
        
        .skeleton-pulse {
            background: linear-gradient(90deg, #f3f4f6 25%, #e5e7eb 50%, #f3f4f6 75%);
            background-size: 200% 100%;
            animation: pulse 1.5s infinite;
        }
        @keyframes pulse {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        /* Giao diện tìm kiếm sách */
        .search-select {
            border-radius: 10px;
            padding: 12px;
            border: 1px solid #d1d5db;
            font-weight: 500;
            font-size: 0.95rem;
            color: #1f2937;
            box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            transition: border-color 0.2s ease;
        }
        .search-select:focus {
            outline: none;
            border-color: var(--primary-light);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.15);
        }
    </style>
</head>
<body class="m-0 p-0">

    <div class="d-flex">
        <!-- 1. CỘT TRÁI: NHÚNG SIDEBAR DÙNG CHUNG -->
        <jsp:include page="/views/layout/sidebar.jsp"/>

        <!-- 2. CỘT PHẢI: KHU VỰC NỘI DUNG CHÍNH -->
        <main class="w-100" style="min-height: 100vh;">
            <jsp:include page="/views/layout/header.jsp"/>

            <div class="container-fluid p-4">
                
                <!-- Tiêu đề trang -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="fw-bold m-0 text-dark" style="letter-spacing: -0.5px;">Gợi ý Sách thông minh</h2>
                        <p class="text-muted mb-0 small">Hệ thống phân tích hành vi mượn trả và đặc tính sách để đề xuất cuốn sách phù hợp.</p>
                    </div>
                </div>

                <!-- ======================================================== -->
                <!-- PHẦN 1: GỢI Ý TỔNG QUÁT (GENERAL RECOMMENDATIONS)         -->
                <!-- ======================================================== -->
                <div class="card border-0 shadow-sm rounded-3 p-4 mb-5">
                    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                        <h5 class="fw-bold m-0 text-dark">
                            <i class="fa-solid fa-compass text-primary me-2"></i> Khám phá Thư viện
                        </h5>
                        
                        <!-- Nav Tabs gợi ý tổng quát -->
                        <ul class="nav nav-pills gap-1 bg-light p-1 rounded-3" id="general-tabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link recommend-nav-link active" id="tab-popular" data-type="popular" type="button">Sách phổ biến</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link recommend-nav-link" id="tab-newest" data-type="newest" type="button">Sách mới nhất</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link recommend-nav-link" id="tab-recent" data-type="recent" type="button">Mượn gần đây</button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link recommend-nav-link" id="tab-random" data-type="random" type="button">Gợi ý ngẫu nhiên</button>
                            </li>
                        </ul>
                    </div>

                    <!-- Lưới hiển thị sách -->
                    <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-6 g-4" id="general-books-grid">
                        <!-- Thẻ sách tải bằng JS ở đây -->
                    </div>

                    <!-- Trạng thái trống / Lỗi cho gợi ý tổng quát -->
                    <div class="text-center py-5 d-none" id="general-empty">
                        <i class="fa-solid fa-book-open fs-2 text-muted mb-3"></i>
                        <p class="text-muted mb-0 small">Không tìm thấy sách nào trong mục này.</p>
                    </div>
                </div>

                <!-- ======================================================== -->
                <!-- PHẦN 2: GỢI Ý THEO SÁCH ĐANG XEM (CONTEXTUAL RECOMMENDATIONS) -->
                <!-- ======================================================== -->
                <div class="card border-0 shadow-sm rounded-3 p-4">
                    <h5 class="fw-bold mb-3 text-dark">
                        <i class="fa-solid fa-lightbulb text-warning me-2"></i> Gợi ý theo ngữ cảnh sách đang xem
                    </h5>
                    
                    <!-- Lưới chọn sách mục tiêu -->
                    <div class="row g-4 mb-4">
                        <div class="col-12 col-lg-5">
                            <label class="form-label fw-semibold small text-secondary">Chọn cuốn sách bạn đang xem:</label>
                            <select class="form-select search-select w-100" id="select-target-book">
                                <option value="" disabled selected>-- Chọn một sách từ thư viện --</option>
                                <c:forEach var="book" items="${allBooks}">
                                    <option value="${book.bookId}" 
                                            data-title="<c:out value="${book.title}"/>"
                                            data-author="<c:out value="${book.author}"/>"
                                            data-category="<c:out value="${book.categoryName}"/>"
                                            data-publisher="<c:out value="${book.publisher}"/>"
                                            data-year="${book.publishYear}">
                                        <c:out value="${book.title}"/> (${book.author})
                                    </option>
                                </c:forEach>
                            </select>
                            <p class="text-muted small mt-2">Hệ thống sẽ dựa vào cuốn sách này để tìm kiếm các sách tương tự hoặc cùng chủ đề.</p>
                        </div>
                        
                        <!-- Hiển thị sách mục tiêu -->
                        <div class="col-12 col-lg-7">
                            <div class="target-book-card h-100 d-flex flex-column justify-content-center" id="target-book-view">
                                <div class="text-center py-4" id="target-placeholder">
                                    <i class="fa-solid fa-arrow-left fs-3 mb-3 text-white-50"></i>
                                    <h6 class="fw-medium">Hãy chọn một cuốn sách ở bên trái để xem phân tích gợi ý!</h6>
                                </div>
                                <div class="d-none" id="target-details">
                                    <span class="badge bg-warning text-dark mb-2 small fw-semibold" id="target-detail-category">Danh mục</span>
                                    <h4 class="fw-bold mb-1" id="target-detail-title">Tiêu đề sách mục tiêu</h4>
                                    <p class="text-white-50 mb-3 small" id="target-detail-author">Tác giả</p>
                                    <div class="row g-3 border-top border-white-10 pt-3 text-white-50 small">
                                        <div class="col-6">
                                            <i class="fa-solid fa-building me-1"></i> Nhà xuất bản: <span class="text-white fw-medium" id="target-detail-publisher">-</span>
                                        </div>
                                        <div class="col-6">
                                            <i class="fa-solid fa-calendar me-1"></i> Năm xuất bản: <span class="text-white fw-medium" id="target-detail-year">-</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Khu vực kết quả gợi ý theo ngữ cảnh -->
                    <div class="d-none" id="contextual-recommendations-wrapper">
                        <hr class="my-4 text-muted opacity-25">
                        
                        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                            <h6 class="fw-bold m-0 text-dark">
                                <i class="fa-solid fa-wand-magic-sparkles text-primary me-2"></i> Danh sách đề xuất liên quan
                            </h6>
                            
                            <!-- Nav tabs cho gợi ý liên quan -->
                            <ul class="nav nav-pills gap-1 bg-light p-1 rounded-3" id="context-tabs" role="tablist">
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link recommend-nav-link active" id="tab-hybrid" data-type="hybrid" type="button">Gợi ý kết hợp (Hybrid)</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link recommend-nav-link" id="tab-content-based" data-type="content-based" type="button">Content-Based</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link recommend-nav-link" id="tab-same-category" data-type="same-category" type="button">Cùng thể loại</button>
                                </li>
                                <li class="nav-item" role="presentation">
                                    <button class="nav-link recommend-nav-link" id="tab-same-author" data-type="same-author" type="button">Cùng tác giả</button>
                                </li>
                            </ul>
                        </div>

                        <!-- Lưới hiển thị sách gợi ý ngữ cảnh -->
                        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-6 g-4" id="context-books-grid">
                            <!-- Tải bằng JS -->
                        </div>

                        <!-- Trạng thái trống cho gợi ý ngữ cảnh -->
                        <div class="text-center py-5 d-none" id="context-empty">
                            <i class="fa-solid fa-face-meh fs-2 text-muted mb-3"></i>
                            <p class="text-muted mb-0 small">Hệ thống chưa tìm thấy cuốn sách nào khác đủ độ tương thích với điều kiện lọc này.</p>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Nhúng JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Định cấu hình API URL
            const apiBaseURL = "${pageContext.request.contextPath}/recommends?action=api";

            // 1. Logic cho Gợi ý Tổng quát
            const generalTabs = document.querySelectorAll("#general-tabs .recommend-nav-link");
            const generalGrid = document.getElementById("general-books-grid");
            const generalEmpty = document.getElementById("general-empty");

            generalTabs.forEach(tab => {
                tab.addEventListener("click", function() {
                    generalTabs.forEach(t => t.classList.remove("active"));
                    this.classList.add("active");
                    loadGeneralRecommendations(this.getAttribute("data-type"));
                });
            });

            // Tự động tải tab phổ biến đầu tiên
            loadGeneralRecommendations("popular");

            function loadGeneralRecommendations(type) {
                // Hiển thị Skeleton Loaders
                showBooksSkeleton(generalGrid, 6);
                generalEmpty.classList.add("d-none");

                fetch(apiBaseURL + "&type=" + type)
                    .then(response => {
                        if (!response.ok) throw new Error("Lỗi HTTP: " + response.status);
                        return response.json();
                    })
                    .then(books => {
                        generalGrid.innerHTML = "";
                        if (books.length === 0) {
                            generalEmpty.classList.remove("d-none");
                        } else {
                            books.forEach(book => {
                                generalGrid.appendChild(createBookCard(book, type));
                            });
                        }
                    })
                    .catch(err => {
                        console.error("Lỗi tải gợi ý tổng quát:", err);
                        generalGrid.innerHTML = `
                            <div class="col-12 text-center text-danger py-4">
                                <i class="fa-solid fa-circle-exclamation fs-3 mb-2"></i>
                                <p class="small mb-0">Không thể tải dữ liệu: ${err.message || 'Lỗi kết nối'}</p>
                            </div>`;
                    });
            }

            // 2. Logic cho Gợi ý theo Ngữ cảnh Sách
            const selectTargetBook = document.getElementById("select-target-book");
            const targetPlaceholder = document.getElementById("target-placeholder");
            const targetDetails = document.getElementById("target-details");
            const contextualWrapper = document.getElementById("contextual-recommendations-wrapper");
            
            const targetTitle = document.getElementById("target-detail-title");
            const targetAuthor = document.getElementById("target-detail-author");
            const targetCategory = document.getElementById("target-detail-category");
            const targetPublisher = document.getElementById("target-detail-publisher");
            const targetYear = document.getElementById("target-detail-year");

            const contextTabs = document.querySelectorAll("#context-tabs .recommend-nav-link");
            const contextGrid = document.getElementById("context-books-grid");
            const contextEmpty = document.getElementById("context-empty");

            let activeBookId = null;

            selectTargetBook.addEventListener("change", function() {
                const selectedOption = this.options[this.selectedIndex];
                activeBookId = selectedOption.value;

                // Cập nhật thẻ sách mục tiêu
                targetTitle.textContent = selectedOption.getAttribute("data-title");
                targetAuthor.textContent = "Tác giả: " + selectedOption.getAttribute("data-author");
                targetCategory.textContent = selectedOption.getAttribute("data-category");
                targetPublisher.textContent = selectedOption.getAttribute("data-publisher") || "Chưa cập nhật";
                targetYear.textContent = selectedOption.getAttribute("data-year") || "Chưa rõ";

                targetPlaceholder.classList.add("d-none");
                targetDetails.classList.remove("d-none");
                contextualWrapper.classList.remove("d-none");

                // Kích hoạt tab Hybrid mặc định
                contextTabs.forEach(t => t.classList.remove("active"));
                document.getElementById("tab-hybrid").classList.add("active");

                loadContextRecommendations(activeBookId, "hybrid");
            });

            contextTabs.forEach(tab => {
                tab.addEventListener("click", function() {
                    if (!activeBookId) return;
                    contextTabs.forEach(t => t.classList.remove("active"));
                    this.classList.add("active");
                    loadContextRecommendations(activeBookId, this.getAttribute("data-type"));
                });
            });

            function loadContextRecommendations(bookId, type) {
                showBooksSkeleton(contextGrid, 6);
                contextEmpty.classList.add("d-none");

                fetch(apiBaseURL + "&type=" + type + "&bookId=" + bookId)
                    .then(response => {
                        if (!response.ok) throw new Error("Lỗi HTTP: " + response.status);
                        return response.json();
                    })
                    .then(books => {
                        contextGrid.innerHTML = "";
                        if (books.length === 0) {
                            contextEmpty.classList.remove("d-none");
                        } else {
                            books.forEach(book => {
                                contextGrid.appendChild(createBookCard(book, type));
                            });
                        }
                    })
                    .catch(err => {
                        console.error("Lỗi tải gợi ý ngữ cảnh:", err);
                        contextGrid.innerHTML = `
                            <div class="col-12 text-center text-danger py-4">
                                <i class="fa-solid fa-circle-exclamation fs-3 mb-2"></i>
                                <p class="small mb-0">Không thể tải dữ liệu gợi ý: ${err.message || 'Lỗi kết nối'}</p>
                            </div>`;
                    });
            }

            // 3. Helper render HTML Card sách
            function createBookCard(book, type) {
                const col = document.createElement("div");
                col.className = "col";

                // Sinh bìa sách gradient ngẫu nhiên dựa trên ID sách để đồng bộ
                const gradients = [
                    "linear-gradient(135deg, #312E81 0%, #4F46E5 100%)", // Indigo
                    "linear-gradient(135deg, #1E3A8A 0%, #3B82F6 100%)", // Blue
                    "linear-gradient(135deg, #065F46 0%, #10B981 100%)", // Emerald
                    "linear-gradient(135deg, #701A75 0%, #D946EF 100%)", // Fuchsia
                    "linear-gradient(135deg, #78350F 0%, #F59E0B 100%)"  // Amber
                ];
                const gradient = gradients[book.bookId % gradients.length];

                // Xác định nhãn đặc biệt hiển thị thêm trên Card
                let badgeHTML = "";
                if (type === "popular" && book.borrowCount > 0) {
                    badgeHTML = `<span class="badge-recommend bg-indigo-subtle text-indigo" style="background-color: #E0E7FF; color: #312E81;">
                                    <i class="fa-solid fa-fire me-1"></i> ${book.borrowCount} lượt mượn
                                 </span>`;
                } else if (type === "content-based" && book.similarityScore > 0) {
                    // Hiển thị điểm tương đồng
                    badgeHTML = `<span class="badge-recommend bg-success-subtle text-success" style="background-color: #DCFCE7; color: #16A34A;">
                                    <i class="fa-solid fa-circle-check me-1"></i> Khớp: ${Math.round(book.similarityScore / 9 * 100)}%
                                 </span>`;
                } else if (type === "recent" && book.lastBorrowDate) {
                    // Hiển thị ngày mượn gần đây
                    const dateParts = book.lastBorrowDate.split("-");
                    const formattedDate = dateParts.length === 3 ? dateParts[2] + "/" + dateParts[1] : book.lastBorrowDate;
                    badgeHTML = `<span class="badge-recommend bg-teal-subtle text-teal" style="background-color: #CCFBF1; color: #0D9488;">
                                    <i class="fa-regular fa-clock me-1"></i> Mượn: ${formattedDate}
                                 </span>`;
                } else {
                    // Mặc định hiển thị danh mục
                    badgeHTML = `<span class="badge bg-light text-dark border font-weight-semibold" style="font-size: 0.7rem; border-radius: 6px;">
                                    ${book.categoryName || 'Sách'}
                                 </span>`;
                }

                // Cắt bớt tiêu đề nếu quá dài để cân đối giao diện
                const displayTitle = book.title.length > 40 ? book.title.substring(0, 37) + "..." : book.title;

                col.innerHTML = `
                    <div class="card book-card shadow-sm h-100">
                        <div class="book-cover" style="background: ${gradient};">
                            <span class="small fw-semibold text-white-50"><i class="fa-solid fa-bookmark me-1"></i> LibraryOS</span>
                            <div class="book-cover-title">${displayTitle}</div>
                            <div class="book-cover-author">${book.author || 'Vô danh'}</div>
                        </div>
                        <div class="book-info">
                            <div class="book-title" title="${book.title}">${book.title}</div>
                            <div class="book-author" title="${book.author || 'Ẩn danh'}">${book.author || 'Tác giả ẩn danh'}</div>
                            <div class="book-meta">
                                ${badgeHTML}
                                <span class="text-muted fw-medium" style="font-size: 0.725rem;">NXB: ${book.publishYear || '-'}</span>
                            </div>
                        </div>
                    </div>`;
                return col;
            }

            // 4. Helper hiển thị bộ xương giả lập tải sách
            function showBooksSkeleton(gridElement, count) {
                gridElement.innerHTML = "";
                for (let i = 0; i < count; i++) {
                    const col = document.createElement("div");
                    col.className = "col";
                    col.innerHTML = `
                        <div class="card book-card h-100">
                            <div class="skeleton-cover skeleton-pulse"></div>
                            <div class="card-body p-3">
                                <div class="skeleton-text skeleton-pulse skeleton-line-long"></div>
                                <div class="skeleton-text skeleton-pulse skeleton-line-short mb-3"></div>
                                <div class="d-flex justify-content-between pt-2 border-top border-light">
                                    <div class="skeleton-text skeleton-pulse" style="width: 50%; height: 14px;"></div>
                                    <div class="skeleton-text skeleton-pulse" style="width: 30%; height: 14px;"></div>
                                </div>
                            </div>
                        </div>`;
                    gridElement.appendChild(col);
                }
            }
        });
    </script>
</body>
</html>
