package recommend;

/**
 * Data Transfer Object (DTO) chứa thông tin của một cuốn sách và các thông số gợi ý bổ sung.
 */
public class BookDTO {
    private int bookId;
    private int categoryId;
    private String categoryName;
    private String title;
    private String author;
    private String publisher;
    private int publishYear;
    private int borrowCount;          // Số lượt mượn (Dành cho Popular)
    private double similarityScore;   // Điểm tương đồng (Dành cho Content-Based)
    private String lastBorrowDate;    // Ngày mượn cuối cùng (Dành cho Recently Borrowed)

    public BookDTO() {}

    public BookDTO(int bookId, int categoryId, String categoryName, String title, String author, 
                   String publisher, int publishYear) {
        this.bookId = bookId;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.title = title;
        this.author = author;
        this.publisher = publisher;
        this.publishYear = publishYear;
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getPublisher() {
        return publisher;
    }

    public void setPublisher(String publisher) {
        this.publisher = publisher;
    }

    public int getPublishYear() {
        return publishYear;
    }

    public void setPublishYear(int publishYear) {
        this.publishYear = publishYear;
    }

    public int getBorrowCount() {
        return borrowCount;
    }

    public void setBorrowCount(int borrowCount) {
        this.borrowCount = borrowCount;
    }

    public double getSimilarityScore() {
        return similarityScore;
    }

    public void setSimilarityScore(double similarityScore) {
        this.similarityScore = similarityScore;
    }

    public String getLastBorrowDate() {
        return lastBorrowDate;
    }

    public void setLastBorrowDate(String lastBorrowDate) {
        this.lastBorrowDate = lastBorrowDate;
    }
}
