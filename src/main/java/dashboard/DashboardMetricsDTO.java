package dashboard;

/**
 * Data Transfer Object (DTO) chứa 7 chỉ số KPI chính của hệ thống thư viện.
 */
public class DashboardMetricsDTO {
    private int totalBooks;             // Tổng số bản sao sách vật lý
    private int totalBookTitles;        // Tổng số đầu sách (tựa sách)
    private int totalReaders;           // Tổng số độc giả
    private int totalBorrows;           // Tổng số lượt mượn (lịch sử)
    private int totalCurrentlyBorrowed; // Tổng số sách đang được mượn
    private int totalOverdue;           // Tổng số sách quá hạn
    private int totalInStock;           // Tổng số sách còn lại trong kho (Available)

    public DashboardMetricsDTO() {}

    public DashboardMetricsDTO(int totalBooks, int totalBookTitles, int totalReaders, int totalBorrows, 
                               int totalCurrentlyBorrowed, int totalOverdue, int totalInStock) {
        this.totalBooks = totalBooks;
        this.totalBookTitles = totalBookTitles;
        this.totalReaders = totalReaders;
        this.totalBorrows = totalBorrows;
        this.totalCurrentlyBorrowed = totalCurrentlyBorrowed;
        this.totalOverdue = totalOverdue;
        this.totalInStock = totalInStock;
    }

    public int getTotalBooks() {
        return totalBooks;
    }

    public void setTotalBooks(int totalBooks) {
        this.totalBooks = totalBooks;
    }

    public int getTotalBookTitles() {
        return totalBookTitles;
    }

    public void setTotalBookTitles(int totalBookTitles) {
        this.totalBookTitles = totalBookTitles;
    }

    public int getTotalReaders() {
        return totalReaders;
    }

    public void setTotalReaders(int totalReaders) {
        this.totalReaders = totalReaders;
    }

    public int getTotalBorrows() {
        return totalBorrows;
    }

    public void setTotalBorrows(int totalBorrows) {
        this.totalBorrows = totalBorrows;
    }

    public int getTotalCurrentlyBorrowed() {
        return totalCurrentlyBorrowed;
    }

    public void setTotalCurrentlyBorrowed(int totalCurrentlyBorrowed) {
        this.totalCurrentlyBorrowed = totalCurrentlyBorrowed;
    }

    public int getTotalOverdue() {
        return totalOverdue;
    }

    public void setTotalOverdue(int totalOverdue) {
        this.totalOverdue = totalOverdue;
    }

    public int getTotalInStock() {
        return totalInStock;
    }

    public void setTotalInStock(int totalInStock) {
        this.totalInStock = totalInStock;
    }
}
