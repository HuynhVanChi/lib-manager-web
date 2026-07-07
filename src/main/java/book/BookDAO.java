package book;

import common.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    /**
     * Tìm tất cả các đầu sách đang hoạt động (chưa bị xóa mềm), hỗ trợ tìm kiếm và lọc theo danh mục.
     */
    public List<Book> findAllActive(String searchQuery, Integer categoryId) {
        List<Book> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT b.*, c.name AS category_name, " +
            "(SELECT COUNT(*) FROM book_copies WHERE book_id = b.book_id AND deleted_at IS NULL) AS total_copies, " +
            "(SELECT COUNT(*) FROM book_copies WHERE book_id = b.book_id AND status = 'Available' AND deleted_at IS NULL) AS available_copies " +
            "FROM books b " +
            "JOIN categories c ON b.category_id = c.category_id " +
            "WHERE b.deleted_at IS NULL"
        );

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            sql.append(" AND (b.title LIKE ? OR b.author LIKE ? OR b.publisher LIKE ?)");
        }
        if (categoryId != null && categoryId > 0) {
            sql.append(" AND b.category_id = ?");
        }
        sql.append(" ORDER BY b.book_id DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                String searchPattern = "%" + searchQuery.trim() + "%";
                pstmt.setString(paramIndex++, searchPattern);
                pstmt.setString(paramIndex++, searchPattern);
                pstmt.setString(paramIndex++, searchPattern);
            }
            if (categoryId != null && categoryId > 0) {
                pstmt.setInt(paramIndex++, categoryId);
            }

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Book b = new Book();
                    b.setBookId(rs.getInt("book_id"));
                    b.setCategoryId(rs.getInt("category_id"));
                    b.setCategoryName(rs.getString("category_name"));
                    b.setTitle(rs.getString("title"));
                    b.setAuthor(rs.getString("author"));
                    b.setPublisher(rs.getString("publisher"));
                    b.setPublishYear(rs.getInt("publish_year"));
                    b.setCreatedAt(rs.getTimestamp("created_at"));
                    b.setUpdatedAt(rs.getTimestamp("updated_at"));
                    b.setTotalCopies(rs.getInt("total_copies"));
                    b.setAvailableCopies(rs.getInt("available_copies"));
                    list.add(b);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tìm đầu sách theo ID.
     */
    public Book findById(int id) {
        String sql = "SELECT b.*, c.name AS category_name, " +
                     "(SELECT COUNT(*) FROM book_copies WHERE book_id = b.book_id AND deleted_at IS NULL) AS total_copies, " +
                     "(SELECT COUNT(*) FROM book_copies WHERE book_id = b.book_id AND status = 'Available' AND deleted_at IS NULL) AS available_copies " +
                     "FROM books b JOIN categories c ON b.category_id = c.category_id WHERE b.book_id = ? AND b.deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Book b = new Book();
                    b.setBookId(rs.getInt("book_id"));
                    b.setCategoryId(rs.getInt("category_id"));
                    b.setCategoryName(rs.getString("category_name"));
                    b.setTitle(rs.getString("title"));
                    b.setAuthor(rs.getString("author"));
                    b.setPublisher(rs.getString("publisher"));
                    b.setPublishYear(rs.getInt("publish_year"));
                    b.setCreatedAt(rs.getTimestamp("created_at"));
                    b.setUpdatedAt(rs.getTimestamp("updated_at"));
                    b.setTotalCopies(rs.getInt("total_copies"));
                    b.setAvailableCopies(rs.getInt("available_copies"));
                    return b;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Thêm mới đầu sách.
     */
    public int insert(Book book) throws SQLException {
        String sql = "INSERT INTO books (category_id, title, author, publisher, publish_year) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, book.getCategoryId());
            pstmt.setString(2, book.getTitle());
            pstmt.setString(3, book.getAuthor());
            pstmt.setString(4, book.getPublisher());
            if (book.getPublishYear() != null && book.getPublishYear() > 0) {
                pstmt.setInt(5, book.getPublishYear());
            } else {
                pstmt.setNull(5, Types.INTEGER);
            }
            
            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }

    /**
     * Cập nhật đầu sách.
     */
    public boolean update(Book book) throws SQLException {
        String sql = "UPDATE books SET category_id = ?, title = ?, author = ?, publisher = ?, publish_year = ? WHERE book_id = ? AND deleted_at IS NULL";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, book.getCategoryId());
            pstmt.setString(2, book.getTitle());
            pstmt.setString(3, book.getAuthor());
            pstmt.setString(4, book.getPublisher());
            if (book.getPublishYear() != null && book.getPublishYear() > 0) {
                pstmt.setInt(5, book.getPublishYear());
            } else {
                pstmt.setNull(5, Types.INTEGER);
            }
            pstmt.setInt(6, book.getBookId());
            
            return pstmt.executeUpdate() > 0;
        }
    }

    /**
     * Xóa mềm đầu sách và toàn bộ cuốn sách con (sử dụng Transaction để đảm bảo an toàn).
     * Bị chặn nếu có cuốn sách con nào đang mượn ('Borrowed').
     */
    public boolean softDelete(int bookId, int userId) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // 1. Kiểm tra xem có cuốn sách nào đang mượn không
            String checkSql = "SELECT COUNT(*) FROM book_copies WHERE book_id = ? AND status = 'Borrowed' AND deleted_at IS NULL";
            try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
                pstmt.setInt(1, bookId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new SQLException("Không thể xóa sách: Có các cuốn sách con của tựa đề này đang được mượn bởi độc giả.");
                    }
                }
            }

            // 2. Xóa mềm các cuốn sách con (book_copies)
            String deleteCopiesSql = "UPDATE book_copies SET deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE book_id = ? AND deleted_at IS NULL";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteCopiesSql)) {
                pstmt.setInt(1, userId);
                pstmt.setInt(2, bookId);
                pstmt.executeUpdate();
            }

            // 3. Xóa mềm đầu sách (books)
            String deleteBookSql = "UPDATE books SET deleted_at = CURRENT_TIMESTAMP, deleted_by = ? WHERE book_id = ? AND deleted_at IS NULL";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteBookSql)) {
                pstmt.setInt(1, userId);
                pstmt.setInt(2, bookId);
                int affected = pstmt.executeUpdate();
                
                if (affected == 0) {
                    throw new SQLException("Xóa mềm đầu sách thất bại hoặc đầu sách đã bị xóa trước đó.");
                }
            }

            conn.commit(); // Thành công hết thì commit
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback(); // Rollback toàn bộ nếu có lỗi
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    // ==========================================
    // CÁC HÀM THỐNG KÊ PHỤC VỤ SUMMARY CARDS
    // ==========================================

    public int countTotalActiveBooks() {
        String sql = "SELECT COUNT(*) FROM books WHERE deleted_at IS NULL";
        return fetchCount(sql);
    }

    public int countTotalBookCopies() {
        String sql = "SELECT COUNT(*) FROM book_copies WHERE deleted_at IS NULL";
        return fetchCount(sql);
    }

    public int countAvailableCopies() {
        String sql = "SELECT COUNT(*) FROM book_copies WHERE status = 'Available' AND deleted_at IS NULL";
        return fetchCount(sql);
    }

    public int countDamagedOrLostCopies() {
        String sql = "SELECT COUNT(*) FROM book_copies WHERE status IN ('Damaged', 'Lost') AND deleted_at IS NULL";
        return fetchCount(sql);
    }

    public List<java.util.Map<String, Object>> findAuditLogsByBookId(int bookId) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT a.*, u.full_name FROM audit_logs a " +
                     "LEFT JOIN users u ON a.user_id = u.user_id " +
                     "WHERE (a.table_name = 'books' AND a.record_id = ?) " +
                     "OR (a.table_name = 'book_copies' AND a.record_id IN (SELECT copy_id FROM book_copies WHERE book_id = ?)) " +
                     "ORDER BY a.log_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookId);
            pstmt.setInt(2, bookId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> log = new java.util.HashMap<>();
                    log.put("logId", rs.getInt("log_id"));
                    log.put("action", rs.getString("action"));
                    log.put("tableName", rs.getString("table_name"));
                    log.put("recordId", rs.getInt("record_id"));
                    log.put("oldValues", rs.getString("old_values"));
                    log.put("newValues", rs.getString("new_values"));
                    log.put("createdAt", rs.getTimestamp("created_at"));
                    log.put("fullName", rs.getString("full_name"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<java.util.Map<String, Object>> findBorrowHistoryByBookId(int bookId) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT bd.*, bc.barcode, r.full_name AS reader_name, u.full_name AS staff_name " +
                     "FROM borrow_details bd " +
                     "JOIN book_copies bc ON bd.copy_id = bc.copy_id " +
                     "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                     "JOIN readers r ON br.reader_id = r.reader_id " +
                     "LEFT JOIN users u ON br.user_id = u.user_id " +
                     "WHERE bc.book_id = ? " +
                     "ORDER BY bd.borrow_detail_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> history = new java.util.HashMap<>();
                    history.put("borrowDetailId", rs.getInt("borrow_detail_id"));
                    history.put("barcode", rs.getString("barcode"));
                    history.put("readerName", rs.getString("reader_name"));
                    history.put("staffName", rs.getString("staff_name"));
                    history.put("borrowDate", rs.getDate("borrow_date"));
                    history.put("dueDate", rs.getDate("due_date"));
                    history.put("returnDate", rs.getDate("return_date"));
                    history.put("status", rs.getString("status"));
                    list.add(history);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private int fetchCount(String sql) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
