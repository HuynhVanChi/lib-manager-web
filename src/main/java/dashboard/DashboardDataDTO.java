package dashboard;

import java.util.List;

/**
 * DTO tổng hợp chứa toàn bộ dữ liệu cần thiết của trang Dashboard.
 * Lớp này sẽ được chuyển đổi trực tiếp sang định dạng JSON để trả về cho Client.
 */
public class DashboardDataDTO {
    private DashboardMetricsDTO metrics;               // 7 chỉ số KPI chính
    
    // Biểu đồ lượt mượn theo thời gian
    private List<ChartDataPointDTO> borrowByDay;        // 7 ngày gần nhất
    private List<ChartDataPointDTO> borrowByWeek;       // 8 tuần gần nhất
    private List<ChartDataPointDTO> borrowByMonth;      // 12 tháng gần nhất
    
    // Các bảng thống kê Top 10
    private List<ChartDataPointDTO> top10Books;         // Top 10 sách mượn nhiều nhất
    private List<ChartDataPointDTO> topAuthors;         // Top tác giả được mượn nhiều nhất
    private List<ChartDataPointDTO> topCategories;      // Top thể loại được mượn nhiều nhất

    public DashboardDataDTO() {}

    public DashboardDataDTO(DashboardMetricsDTO metrics, 
                            List<ChartDataPointDTO> borrowByDay, 
                            List<ChartDataPointDTO> borrowByWeek, 
                            List<ChartDataPointDTO> borrowByMonth, 
                            List<ChartDataPointDTO> top10Books, 
                            List<ChartDataPointDTO> topAuthors, 
                            List<ChartDataPointDTO> topCategories) {
        this.metrics = metrics;
        this.borrowByDay = borrowByDay;
        this.borrowByWeek = borrowByWeek;
        this.borrowByMonth = borrowByMonth;
        this.top10Books = top10Books;
        this.topAuthors = topAuthors;
        this.topCategories = topCategories;
    }

    public DashboardMetricsDTO getMetrics() {
        return metrics;
    }

    public void setMetrics(DashboardMetricsDTO metrics) {
        this.metrics = metrics;
    }

    public List<ChartDataPointDTO> getBorrowByDay() {
        return borrowByDay;
    }

    public void setBorrowByDay(List<ChartDataPointDTO> borrowByDay) {
        this.borrowByDay = borrowByDay;
    }

    public List<ChartDataPointDTO> getBorrowByWeek() {
        return borrowByWeek;
    }

    public void setBorrowByWeek(List<ChartDataPointDTO> borrowByWeek) {
        this.borrowByWeek = borrowByWeek;
    }

    public List<ChartDataPointDTO> getBorrowByMonth() {
        return borrowByMonth;
    }

    public void setBorrowByMonth(List<ChartDataPointDTO> borrowByMonth) {
        this.borrowByMonth = borrowByMonth;
    }

    public List<ChartDataPointDTO> getTop10Books() {
        return top10Books;
    }

    public void setTop10Books(List<ChartDataPointDTO> top10Books) {
        this.top10Books = top10Books;
    }

    public List<ChartDataPointDTO> getTopAuthors() {
        return topAuthors;
    }

    public void setTopAuthors(List<ChartDataPointDTO> topAuthors) {
        this.topAuthors = topAuthors;
    }

    public List<ChartDataPointDTO> getTopCategories() {
        return topCategories;
    }

    public void setTopCategories(List<ChartDataPointDTO> topCategories) {
        this.topCategories = topCategories;
    }
}
