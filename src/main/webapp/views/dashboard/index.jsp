<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Thống kê - LibraryOS</title>
    
    <!-- 1. Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- 2. FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <!-- 3. Stylesheet dùng chung của dự án -->
    <link href="${pageContext.request.contextPath}/assets/css/style.css" rel="stylesheet" type="text/css">
    <!-- Nhúng Font chữ Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-page);
            color: var(--text-dark);
        }

        /* Tùy chỉnh màu sắc tĩnh cho các thẻ thống kê stat-card */
        .stat-total {
            background: var(--primary-soft);
            color: var(--primary);
        }
        .stat-total .stat-icon {
            background: rgba(49, 46, 129, 0.12);
            color: var(--primary);
        }

        .stat-titles {
            background: #F5F3FF;
            color: #6D28D9;
        }
        .stat-titles .stat-icon {
            background: rgba(109, 40, 217, 0.12);
            color: #6D28D9;
        }

        .stat-readers {
            background: #FFF1F2;
            color: #BE123C;
        }
        .stat-readers .stat-icon {
            background: rgba(190, 18, 60, 0.12);
            color: #BE123C;
        }

        .stat-borrows {
            background: #F0FDFA;
            color: #0F766E;
        }
        .stat-borrows .stat-icon {
            background: rgba(15, 118, 110, 0.12);
            color: #0F766E;
        }

        .stat-borrowing {
            background: #FEF3C7;
            color: #D97706;
        }
        .stat-borrowing .stat-icon {
            background: rgba(217, 119, 6, 0.12);
            color: #D97706;
        }

        .stat-overdue {
            background: #FEF2F2;
            color: #B91C1C;
        }
        .stat-overdue .stat-icon {
            background: rgba(185, 28, 28, 0.12);
            color: #B91C1C;
        }

        .stat-in-stock {
            background: #F0FDF4;
            color: #15803D;
        }
        .stat-in-stock .stat-icon {
            background: rgba(21, 128, 61, 0.12);
            color: #15803D;
        }

        /* Thống kê chi tiết & Biểu đồ */
        .chart-card {
            border-radius: var(--card-border-radius);
            border: none;
            background: #ffffff;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            margin-bottom: 24px;
        }

        .chart-container {
            position: relative;
            width: 100%;
            height: 300px;
        }

        /* Biểu đồ Doughnut/Pie cần chiều cao thấp hơn một chút */
        .chart-container-small {
            position: relative;
            width: 100%;
            height: 250px;
        }

        /* Biểu đồ Top 10 cần cao hơn để hiển thị đủ 10 dòng ngang */
        .chart-container-top10 {
            position: relative;
            width: 100%;
            height: 380px;
        }

        /* Skeleton Loading Effect */
        .skeleton {
            background: linear-gradient(90deg, #f3f4f6 25%, #e5e7eb 50%, #f3f4f6 75%);
            background-size: 200% 100%;
            animation: loading 1.5s infinite;
            border-radius: 4px;
        }
        @keyframes loading {
            0% { background-position: 200% 0; }
            100% { background-position: -200% 0; }
        }

        .skeleton-text {
            height: 24px;
            width: 80%;
            margin-bottom: 8px;
        }
        .skeleton-number {
            height: 36px;
            width: 50%;
        }
        .skeleton-chart {
            height: 280px;
            width: 100%;
            border-radius: 8px;
        }

        /* Nút chuyển đổi thời gian trên biểu đồ */
        .btn-group .btn {
            transition: background-color 0.2s ease, color 0.2s ease, box-shadow 0.2s ease;
        }
        .btn-group .btn:hover:not(.btn-toggle-active) {
            background-color: var(--primary-soft) !important;
            color: var(--primary-light) !important;
        }
        .btn-toggle-active {
            background-color: var(--primary) !important;
            color: #ffffff !important;
            border-color: var(--primary) !important;
            box-shadow: 0 4px 12px rgba(49, 46, 129, 0.25) !important;
        }
        .btn-toggle-active:hover {
            background-color: var(--primary-light) !important;
            border-color: var(--primary-light) !important;
            box-shadow: 0 6px 16px rgba(49, 46, 129, 0.4) !important;
        }

        /* Xử lý bảng xếp hạng đẹp */
        .rank-list {
            margin: 0;
            padding: 0;
            list-style: none;
        }
        .rank-item {
            display: flex;
            align-items: center;
            padding: 12px 16px;
            border-bottom: 1px solid #f3f4f6;
            transition: background-color 0.2s ease;
        }
        .rank-item:last-child {
            border-bottom: none;
        }
        .rank-item:hover {
            background-color: #f9fafb;
        }
        .rank-badge {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background-color: #e5e7eb;
            color: #4b5563;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.8rem;
            font-weight: 700;
            margin-right: 12px;
            flex-shrink: 0;
        }
        .rank-item:nth-child(1) .rank-badge {
            background-color: #fef3c7;
            color: #d97706;
        }
        .rank-item:nth-child(2) .rank-badge {
            background-color: #f3f4f6;
            color: #4b5563;
        }
        .rank-item:nth-child(3) .rank-badge {
            background-color: #ffedd5;
            color: #ea580c;
        }
        .rank-title {
            font-weight: 500;
            font-size: 0.925rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex-grow: 1;
        }
        .rank-value {
            font-weight: 600;
            font-size: 0.9rem;
            color: var(--primary-color);
            margin-left: 12px;
            flex-shrink: 0;
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
                


                <!-- Tiêu đề trang & Nút tải lại -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div>
                        <h2 class="fw-bold m-0 text-dark" style="letter-spacing: -0.5px;">Tổng quan Thư viện</h2>
                        <p class="text-muted mb-0 small">Báo cáo trực quan tình hình mượn trả và tồn kho sách thực tế.</p>
                    </div>
                    <button class="btn btn-save hover-lift fw-medium" id="btn-refresh">
                        <i class="fa-solid fa-arrows-rotate me-1"></i> Tải lại dữ liệu
                    </button>
                </div>

                <!-- KHU VỰC LỖI (ẨN MẶC ĐỊNH) -->
                <div class="alert alert-danger d-none border-0 shadow-sm rounded-3 p-3 mb-4" id="error-container">
                    <div class="d-flex align-items-center">
                        <i class="fa-solid fa-circle-exclamation fs-4 me-3"></i>
                        <div class="flex-grow-1">
                            <h5 class="alert-heading fw-semibold mb-1">Không thể tải dữ liệu thống kê</h5>
                            <p class="mb-0 small" id="error-message">Đã xảy ra lỗi kết nối đến cơ sở dữ liệu.</p>
                        </div>
                        <button class="btn btn-danger hover-lift btn-sm px-3" id="btn-retry">Thử lại</button>
                    </div>
                </div>

                <!-- ======================================================== -->
                <!-- 7 KPI CARDS - THỐNG KÊ CHỈ SỐ TỔNG HỢP                    -->
                <!-- ======================================================== -->
                <div class="row g-3 mb-4" id="kpi-grid">
                    <!-- KPI 1: Tổng số sách -->
                    <div class="col-12 col-md-6 col-lg-3">
                        <div class="stat-card stat-total h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Tổng số cuốn sách</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-cubes"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-total-books">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI 2: Tổng số đầu sách -->
                    <div class="col-12 col-md-6 col-lg-3">
                        <div class="stat-card stat-titles h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Tổng số đầu sách</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-book"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-total-titles">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI 3: Tổng số độc giả -->
                    <div class="col-12 col-md-6 col-lg-3">
                        <div class="stat-card stat-readers h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Tổng số độc giả</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-users"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-total-readers">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI 4: Tổng số lượt mượn -->
                    <div class="col-12 col-md-6 col-lg-3">
                        <div class="stat-card stat-borrows h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Tổng số lượt mượn</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-clipboard-list"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-total-borrows">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI 5: Số sách đang mượn -->
                    <div class="col-12 col-md-4 col-lg-4">
                        <div class="stat-card stat-borrowing h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Sách đang mượn ngoài</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-book-open"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-borrowing">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI 6: Sách quá hạn -->
                    <div class="col-12 col-md-4 col-lg-4">
                        <div class="stat-card stat-overdue h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Sách bị quá hạn trả</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-overdue">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>

                    <!-- KPI 7: Sách còn trong kho -->
                    <div class="col-12 col-md-4 col-lg-4">
                        <div class="stat-card stat-in-stock h-100">
                            <div class="d-flex justify-content-between align-items-start w-100 mb-2">
                                <span class="stat-label">Sách sẵn sàng trong kho</span>
                                <div class="stat-icon m-0">
                                    <i class="fa-solid fa-warehouse"></i>
                                </div>
                            </div>
                            <div class="stat-value" id="kpi-in-stock">
                                <div class="skeleton skeleton-number"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ======================================================== -->
                <!-- TRẠNG THÁI TRỐNG (EMPTY STATE - ẨN MẶC ĐỊNH)               -->
                <!-- ======================================================== -->
                <div class="empty-state d-none" id="empty-state">
                    <div class="icon">
                        <i class="fa-solid fa-chart-line"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Chưa có dữ liệu thống kê</h5>
                    <p class="text-muted small mb-0">Hiện tại hệ thống thư viện chưa ghi nhận bất kỳ lượt mượn trả sách nào. Hãy thực hiện mượn sách để kích hoạt số liệu thống kê tự động.</p>
                </div>

                <!-- ======================================================== -->
                <!-- BIỂU ĐỒ & BẢNG THỐNG KÊ CHI TIẾT                          -->
                <!-- ======================================================== -->
                <div id="dashboard-content-grid">
                    <!-- HÀNG 1: BIỂU ĐỒ LƯỢT MƯỢN THEO THỜI GIAN & TOP THỂ LOẠI -->
                    <div class="row">
                        <!-- Biểu đồ lượt mượn -->
                        <div class="col-12 col-lg-8">
                            <div class="card chart-card shadow-sm p-4 h-100">
                                <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                                    <div>
                                        <h5 class="fw-bold m-0 text-dark">Thống kê Lượt Mượn Sách</h5>
                                        <span class="text-muted small">Biểu đồ giám sát lượt mượn sách phát sinh.</span>
                                    </div>
                                    <!-- Nút bấm chuyển đổi Ngày, Tuần, Tháng -->
                                    <div class="btn-group border rounded-3 p-1 bg-light shadow-sm" role="group">
                                        <button type="button" class="btn btn-sm btn-light border-0 rounded-2 px-3 btn-toggle-active" id="btn-trend-day">Ngày</button>
                                        <button type="button" class="btn btn-sm btn-light border-0 rounded-2 px-3" id="btn-trend-week">Tuần</button>
                                        <button type="button" class="btn btn-sm btn-light border-0 rounded-2 px-3" id="btn-trend-month">Tháng</button>
                                    </div>
                                </div>
                                
                                <div class="chart-container" id="trend-chart-wrapper">
                                    <canvas id="trendChart"></canvas>
                                </div>
                                <div class="skeleton-chart skeleton d-none" id="trend-chart-skeleton"></div>
                            </div>
                        </div>

                        <!-- Top Thể loại -->
                        <div class="col-12 col-lg-4">
                            <div class="card chart-card shadow-sm p-4 h-100">
                                <h5 class="fw-bold mb-1 text-dark">Thể Loại Đọc Nhiều Nhất</h5>
                                <p class="text-muted small mb-3">Tỷ lệ lượt mượn phân bổ theo các danh mục.</p>
                                
                                <div class="chart-container" id="category-chart-wrapper">
                                    <canvas id="categoryChart"></canvas>
                                </div>
                                <div class="skeleton-chart skeleton d-none" id="category-chart-skeleton"></div>
                            </div>
                        </div>
                    </div>

                    <!-- HÀNG 2: TOP SÁCH & TOP TÁC GIẢ -->
                    <div class="row">
                        <!-- Top 10 Sách -->
                        <div class="col-12 col-lg-6">
                            <div class="card chart-card shadow-sm p-4 h-100">
                                <h5 class="fw-bold mb-1 text-dark">Top 10 Sách Được Mượn Nhiều Nhất</h5>
                                <p class="text-muted small mb-3">Biểu đồ so sánh số lần mượn của các tựa sách hàng đầu.</p>
                                
                                <div class="chart-container-top10" id="book-chart-wrapper">
                                    <canvas id="bookChart"></canvas>
                                </div>
                                <div class="skeleton-chart skeleton d-none" id="book-chart-skeleton"></div>
                            </div>
                        </div>

                        <!-- Top Tác giả -->
                        <div class="col-12 col-lg-6">
                            <div class="card chart-card shadow-sm p-4 h-100">
                                <h5 class="fw-bold mb-1 text-dark">Top 10 Tác Giả Đọc Nhiều Nhất</h5>
                                <p class="text-muted small mb-3">Thống kê tổng số cuốn sách được đọc theo từng tác giả.</p>
                                
                                <div class="chart-container-top10" id="author-chart-wrapper">
                                    <canvas id="authorChart"></canvas>
                                </div>
                                <div class="skeleton-chart skeleton d-none" id="author-chart-skeleton"></div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>
    </div>

    <!-- Nhúng Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Nhúng thư viện vẽ biểu đồ Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <!-- AJAX LOGIC & VẼ BIỂU ĐỒ -->
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            // Trạng thái lưu trữ dữ liệu
            let dashboardData = null;
            let currentTrendMode = "day"; // "day", "week", "month"

            // Các Chart instances để hủy trước khi vẽ lại
            let trendChartInstance = null;
            let categoryChartInstance = null;
            let bookChartInstance = null;
            let authorChartInstance = null;

            // DOM Elements
            const btnRefresh = document.getElementById("btn-refresh");
            const btnRetry = document.getElementById("btn-retry");
            const errorContainer = document.getElementById("error-container");
            const errorMessage = document.getElementById("error-message");
            const kpiGrid = document.getElementById("kpi-grid");
            const emptyState = document.getElementById("empty-state");
            const contentGrid = document.getElementById("dashboard-content-grid");

            // Buttons trend
            const btnTrendDay = document.getElementById("btn-trend-day");
            const btnTrendWeek = document.getElementById("btn-trend-week");
            const btnTrendMonth = document.getElementById("btn-trend-month");

            // Khởi chạy
            loadDashboardData();

            // Đăng ký sự kiện
            btnRefresh.addEventListener("click", loadDashboardData);
            btnRetry.addEventListener("click", loadDashboardData);

            btnTrendDay.addEventListener("click", () => switchTrendMode("day"));
            btnTrendWeek.addEventListener("click", () => switchTrendMode("week"));
            btnTrendMonth.addEventListener("click", () => switchTrendMode("month"));

            /**
             * Thực hiện gọi AJAX lên Servlet để lấy toàn bộ dữ liệu.
             */
            function loadDashboardData() {
                // 1. Hiển thị Skeleton Loading trên các con số và biểu đồ
                showSkeletonLoading(true);
                errorContainer.classList.add("d-none");
                emptyState.classList.add("d-none");
                contentGrid.classList.remove("d-none");

                // 2. Fetch API
                fetch("${pageContext.request.contextPath}/dashboard?action=api")
                    .then(response => {
                        if (!response.ok) {
                            throw new Error("HTTP error! status: " + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        dashboardData = data;
                        showSkeletonLoading(false);
                        
                        // Kiểm tra nếu dữ liệu trống hoàn toàn (Chưa mượn cuốn nào)
                        if (!data.metrics || data.metrics.totalBorrows === 0) {
                            renderKPIs(data.metrics); // Vẫn hiển thị các KPI cơ bản bằng 0
                            contentGrid.classList.add("d-none");
                            emptyState.classList.remove("d-none");
                        } else {
                            renderKPIs(data.metrics);
                            renderCharts();
                        }
                    })
                    .catch(err => {
                        console.error("Lỗi khi tải dữ liệu dashboard:", err);
                        showSkeletonLoading(false);
                        errorMessage.textContent = err.message || "Không thể kết nối đến máy chủ thư viện.";
                        errorContainer.classList.remove("d-none");
                    });
            }

            /**
             * Bật/Tắt Skeleton Loading trực quan.
             */
            function showSkeletonLoading(isLoading) {
                const kpiSelectors = [
                    "kpi-total-books", "kpi-total-titles", "kpi-total-readers",
                    "kpi-total-borrows", "kpi-borrowing", "kpi-overdue", "kpi-in-stock"
                ];

                if (isLoading) {
                    // KPI skeleton
                    kpiSelectors.forEach(id => {
                        const el = document.getElementById(id);
                        if (el) el.innerHTML = `<div class="skeleton skeleton-number"></div>`;
                    });

                    // Chart skeleton
                    document.getElementById("trend-chart-wrapper").classList.add("d-none");
                    document.getElementById("trend-chart-skeleton").classList.remove("d-none");

                    document.getElementById("category-chart-wrapper").classList.add("d-none");
                    document.getElementById("category-chart-skeleton").classList.remove("d-none");

                    document.getElementById("book-chart-wrapper").classList.add("d-none");
                    document.getElementById("book-chart-skeleton").classList.remove("d-none");

                    document.getElementById("author-chart-wrapper").classList.add("d-none");
                    document.getElementById("author-chart-skeleton").classList.remove("d-none");
                } else {
                    document.getElementById("trend-chart-wrapper").classList.remove("d-none");
                    document.getElementById("trend-chart-skeleton").classList.add("d-none");

                    document.getElementById("category-chart-wrapper").classList.remove("d-none");
                    document.getElementById("category-chart-skeleton").classList.add("d-none");

                    document.getElementById("book-chart-wrapper").classList.remove("d-none");
                    document.getElementById("book-chart-skeleton").classList.add("d-none");

                    document.getElementById("author-chart-wrapper").classList.remove("d-none");
                    document.getElementById("author-chart-skeleton").classList.add("d-none");
                }
            }

            /**
             * Render các giá trị số vào thẻ KPI.
             */
            function renderKPIs(metrics) {
                if (!metrics) return;
                document.getElementById("kpi-total-books").textContent = metrics.totalBooks.toLocaleString("vi-VN");
                document.getElementById("kpi-total-titles").textContent = metrics.totalBookTitles.toLocaleString("vi-VN");
                document.getElementById("kpi-total-readers").textContent = metrics.totalReaders.toLocaleString("vi-VN");
                document.getElementById("kpi-total-borrows").textContent = metrics.totalBorrows.toLocaleString("vi-VN");
                document.getElementById("kpi-borrowing").textContent = metrics.totalCurrentlyBorrowed.toLocaleString("vi-VN");
                document.getElementById("kpi-overdue").textContent = metrics.totalOverdue.toLocaleString("vi-VN");
                document.getElementById("kpi-in-stock").textContent = metrics.totalInStock.toLocaleString("vi-VN");
            }

            /**
             * Vẽ tất cả các biểu đồ bằng dữ liệu từ API.
             */
            function renderCharts() {
                if (!dashboardData) return;

                // 1. Vẽ biểu đồ xu hướng (Line Chart)
                drawTrendChart();

                // 2. Vẽ biểu đồ thể loại (Pie Chart)
                drawCategoryChart();

                // 3. Vẽ biểu đồ top sách (Horizontal Bar Chart)
                drawBookChart();

                // 4. Vẽ biểu đồ top tác giả (Doughnut Chart)
                drawAuthorChart();
            }

            /**
             * Chuyển đổi chế độ xem xu hướng (Ngày, Tuần, Tháng) trên Line Chart.
             */
            function switchTrendMode(mode) {
                if (currentTrendMode === mode || !dashboardData) return;
                
                currentTrendMode = mode;
                
                // Cập nhật trạng thái Active trên UI
                btnTrendDay.classList.remove("btn-toggle-active");
                btnTrendWeek.classList.remove("btn-toggle-active");
                btnTrendMonth.classList.remove("btn-toggle-active");

                if (mode === "day") btnTrendDay.classList.add("btn-toggle-active");
                else if (mode === "week") btnTrendWeek.classList.add("btn-toggle-active");
                else if (mode === "month") btnTrendMonth.classList.add("btn-toggle-active");

                // Vẽ lại biểu đồ xu hướng
                drawTrendChart();
            }

            /**
             * Chi tiết vẽ Line Chart
             */
            function drawTrendChart() {
                let list = [];
                if (currentTrendMode === "day") {
                    list = dashboardData.borrowByDay || [];
                } else if (currentTrendMode === "week") {
                    list = dashboardData.borrowByWeek || [];
                } else if (currentTrendMode === "month") {
                    list = dashboardData.borrowByMonth || [];
                }

                const labels = list.map(item => item.label);
                const values = list.map(item => item.value);

                if (trendChartInstance) {
                    trendChartInstance.destroy();
                }

                const ctx = document.getElementById("trendChart").getContext("2d");
                
                // Gradient mượt cho vùng dưới nét vẽ
                const gradient = ctx.createLinearGradient(0, 0, 0, 300);
                gradient.addColorStop(0, 'rgba(79, 70, 229, 0.3)');
                gradient.addColorStop(1, 'rgba(79, 70, 229, 0.0)');

                trendChartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Số lượt mượn',
                            data: values,
                            borderColor: '#312E81',
                            borderWidth: 3,
                            backgroundColor: gradient,
                            fill: true,
                            tension: 0.35,
                            pointBackgroundColor: '#4F46E5',
                            pointHoverRadius: 7,
                            pointHoverBackgroundColor: '#ffffff',
                            pointHoverBorderColor: '#312E81',
                            pointHoverBorderWidth: 3
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    stepSize: 1,
                                    color: '#9CA3AF'
                                },
                                grid: {
                                    color: '#E5E7EB',
                                    drawBorder: false
                                }
                            },
                            x: {
                                ticks: { color: '#9CA3AF' },
                                grid: { display: false }
                            }
                        }
                    }
                });
            }

            /**
             * Chi tiết vẽ Pie Chart (Top thể loại)
             */
            function drawCategoryChart() {
                const list = dashboardData.topCategories || [];
                const labels = list.map(item => item.label);
                const values = list.map(item => item.value);

                if (categoryChartInstance) {
                    categoryChartInstance.destroy();
                }

                // Nếu thể loại trống hoàn toàn
                if (list.length === 0) {
                    labels.push("Chưa có dữ liệu");
                    values.push(1);
                }

                const ctx = document.getElementById("categoryChart").getContext("2d");
                categoryChartInstance = new Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: labels,
                        datasets: [{
                            data: values,
                            backgroundColor: [
                                '#312E81', // Tím Indigo chủ đạo
                                '#4F46E5', // Tím nhạt
                                '#8B5CF6', // Tím Violet
                                '#A78BFA', // Tím pastel
                                '#EC4899', // Hồng đậm
                                '#F43F5E', // Hồng san hô
                                '#10B981', // Xanh ngọc
                                '#3B82F6', // Xanh dương
                                '#F59E0B', // Cam vàng
                                '#6B7280'  // Xám
                            ],
                            borderWidth: 2,
                            borderColor: '#ffffff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    boxWidth: 14,
                                    font: { size: 14, family: 'Inter, sans-serif' },
                                    padding: 12,
                                    color: '#1F2937',
                                    // Cắt ngắn nhãn quá dài
                                    generateLabels: function(chart) {
                                        const original = Chart.overrides.pie.plugins.legend.labels.generateLabels(chart);
                                        return original.map(label => {
                                            if (label.text && label.text.length > 20) {
                                                label.text = label.text.substring(0, 18) + '…';
                                            }
                                            return label;
                                        });
                                    }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                        const pct = total > 0 ? ((context.parsed / total) * 100).toFixed(1) : 0;
                                        return ` ${context.label}: ${context.parsed} lượt (${pct}%)`;
                                    }
                                }
                            }
                        }
                    }
                });
            }

            /**
             * Chi tiết vẽ Bar Chart (Top 10 Sách)
             */
            function drawBookChart() {
                const list = dashboardData.top10Books || [];
                // Rút ngắn tên nhãn nếu quá dài cho biểu đồ cột ngang
                const labels = list.map(item => {
                    let lbl = item.label;
                    return lbl.length > 25 ? lbl.substring(0, 22) + "..." : lbl;
                });
                const values = list.map(item => item.value);

                if (bookChartInstance) {
                    bookChartInstance.destroy();
                }

                const ctx = document.getElementById("bookChart").getContext("2d");
                bookChartInstance = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels.reverse(), // Đảo lại để cột dài nhất nằm trên cùng
                        datasets: [{
                            data: values.reverse(),
                            backgroundColor: '#312E81',
                            borderRadius: 6,
                            barThickness: 16
                        }]
                    },
                    options: {
                        indexAxis: 'y', // Xoay ngang biểu đồ cột
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false }
                        },
                        scales: {
                            x: {
                                beginAtZero: true,
                                ticks: { stepSize: 1, color: '#9CA3AF' },
                                grid: { color: '#E5E7EB' }
                            },
                            y: {
                                ticks: { color: '#4B5563', font: { size: 11 } },
                                grid: { display: false }
                            }
                        }
                    }
                });
            }

            /**
             * Chi tiết vẽ Doughnut Chart (Top 10 Tác giả)
             */
            function drawAuthorChart() {
                const list = dashboardData.topAuthors || [];
                const labels = list.map(item => item.label);
                const values = list.map(item => item.value);

                if (authorChartInstance) {
                    authorChartInstance.destroy();
                }

                const ctx = document.getElementById("authorChart").getContext("2d");
                authorChartInstance = new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: labels,
                        datasets: [{
                            data: values,
                            backgroundColor: [
                                '#312E81', // Tím Indigo chủ đạo
                                '#4F46E5', // Tím nhạt
                                '#0D9488', // Teal ngọc
                                '#D97706', // Cam hổ phách
                                '#10B981', // Xanh lục
                                '#EC4899', // Hồng san hô
                                '#3B82F6', // Xanh nước biển
                                '#8B5CF6', // Tím
                                '#EF4444', // Đỏ
                                '#6B7280'  // Xám
                            ],
                            borderWidth: 2,
                            borderColor: '#ffffff'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '55%',
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    boxWidth: 14,
                                    font: { size: 14, family: 'Inter, sans-serif' },
                                    padding: 12,
                                    color: '#1F2937',
                                    generateLabels: function(chart) {
                                        const original = Chart.overrides.doughnut.plugins.legend.labels.generateLabels(chart);
                                        return original.map(label => {
                                            if (label.text && label.text.length > 20) {
                                                label.text = label.text.substring(0, 18) + '\u2026';
                                            }
                                            return label;
                                        });
                                    }
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                        const pct = total > 0 ? ((context.parsed / total) * 100).toFixed(1) : 0;
                                        return ` ${context.label}: ${context.parsed} lượt (${pct}%)`;
                                    }
                                }
                            }
                        }
                    }
                });
            }
        });
    </script>

</body>
</html>
