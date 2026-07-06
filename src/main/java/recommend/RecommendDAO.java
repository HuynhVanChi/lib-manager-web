package recommend;

import common.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object (DAO) thực hiện các thuật toán gợi ý sách khác nhau.
 * Tất cả truy vấn sử dụng PreparedStatement chống SQL Injection và lọc các bản ghi đã xóa mềm (deleted_at IS NULL).
 */
public class RecommendDAO {

    /**
     * Lấy toàn bộ danh sách sách để hiển thị ở bộ chọn (Dropdown / Search)
     */
    public List<BookDTO> getAllBooks() throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year " +
                     "FROM books b " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL " +
                     "ORDER BY b.title ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRowToBook(rs));
            }
        }
        return list;
    }

    /**
     * Thuật toán 1: Sách phổ biến (Popular Books) - Được mượn nhiều nhất mọi thời đại.
     */
    public List<BookDTO> getPopularBooks(int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year, " +
                     "COUNT(bd.borrow_detail_id) AS borrow_count " +
                     "FROM books b " +
                     "JOIN book_copies bc ON b.book_id = bc.book_id " +
                     "JOIN borrow_details bd ON bc.copy_id = bd.copy_id " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL AND bc.deleted_at IS NULL " +
                     "GROUP BY b.book_id, b.title, b.author, c.name, b.publisher, b.publish_year " +
                     "ORDER BY borrow_count DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookDTO book = mapRowToBook(rs);
                    book.setBorrowCount(rs.getInt("borrow_count"));
                    list.add(book);
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán 2: Sách mới nhất (Newest Books) - Sắp xếp theo ngày tạo hoặc ID giảm dần.
     */
    public List<BookDTO> getNewestBooks(int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year " +
                     "FROM books b " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL " +
                     "ORDER BY b.created_at DESC, b.book_id DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToBook(rs));
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán 3: Sách cùng thể loại (Same Category) - Gợi ý sách có cùng thể loại với sách đang xem.
     */
    public List<BookDTO> getBooksBySameCategory(int bookId, int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year " +
                     "FROM books b " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL " +
                     "  AND b.category_id = (SELECT category_id FROM books WHERE book_id = ? AND deleted_at IS NULL) " +
                     "  AND b.book_id <> ? " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, bookId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToBook(rs));
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán 4: Sách cùng tác giả (Same Author) - Gợi ý sách có cùng tác giả với sách đang xem.
     */
    public List<BookDTO> getBooksBySameAuthor(int bookId, int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year " +
                     "FROM books b " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL " +
                     "  AND b.author = (SELECT author FROM books WHERE book_id = ? AND deleted_at IS NULL) " +
                     "  AND b.book_id <> ? " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, bookId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToBook(rs));
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán 5: Sách được mượn gần đây (Recently Borrowed) - Sắp xếp theo ngày mượn mới nhất.
     */
    public List<BookDTO> getRecentlyBorrowedBooks(int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year, " +
                     "MAX(bd.borrow_date) AS last_borrow_date " +
                     "FROM books b " +
                     "JOIN book_copies bc ON b.book_id = bc.book_id " +
                     "JOIN borrow_details bd ON bc.copy_id = bd.copy_id " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL AND bc.deleted_at IS NULL " +
                     "GROUP BY b.book_id, b.title, b.author, c.name, b.publisher, b.publish_year " +
                     "ORDER BY last_borrow_date DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookDTO book = mapRowToBook(rs);
                    book.setLastBorrowDate(rs.getString("last_borrow_date"));
                    list.add(book);
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán 6: Sách ngẫu nhiên (Random Recommendation) - Tải ngẫu nhiên một số sách.
     */
    public List<BookDTO> getRandomBooks(int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year " +
                     "FROM books b " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL " +
                     "ORDER BY RAND() " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToBook(rs));
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán nâng cao 7: Content-Based Recommendation (Gợi ý dựa trên nội dung).
     * Điểm tương đồng: Cùng thể loại (+5đ), Cùng tác giả (+3đ), Cùng nhà xuất bản (+1đ).
     */
    public List<BookDTO> getContentBasedRecommendations(int bookId, int limit) throws SQLException {
        List<BookDTO> list = new ArrayList<>();
        String sql = "SELECT b.book_id, b.title, b.author, c.name AS category_name, b.publisher, b.publish_year, " +
                     "((CASE WHEN b.category_id = target.category_id THEN 5 ELSE 0 END) + " +
                     " (CASE WHEN b.author = target.author THEN 3 ELSE 0 END) + " +
                     " (CASE WHEN b.publisher = target.publisher THEN 1 ELSE 0 END)) AS similarity_score " +
                     "FROM books b " +
                     "CROSS JOIN (SELECT category_id, author, publisher FROM books WHERE book_id = ?) target " +
                     "LEFT JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.deleted_at IS NULL AND b.book_id <> ? " +
                     "ORDER BY similarity_score DESC, b.title ASC " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, bookId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BookDTO book = mapRowToBook(rs);
                    book.setSimilarityScore(rs.getDouble("similarity_score"));
                    list.add(book);
                }
            }
        }
        return list;
    }

    /**
     * Thuật toán nâng cao 8: Hybrid Recommendation (Gợi ý kết hợp).
     * Kết hợp: 50% Content-based, 30% Popular, 20% Random. Loại bỏ trùng lặp và loại bỏ chính sách đang xem.
     */
    public List<BookDTO> getHybridRecommendations(int bookId, int limit) throws SQLException {
        Map<Integer, BookDTO> map = new LinkedHashMap<>();

        // 1. Lấy Content-based
        List<BookDTO> contentBased = getContentBasedRecommendations(bookId, limit);
        for (BookDTO book : contentBased) {
            if (book.getSimilarityScore() > 0) { // Chỉ lấy sách có tương đồng nhất định
                map.put(book.getBookId(), book);
            }
        }

        // 2. Lấy sách phổ biến (nếu chưa đủ limit)
        if (map.size() < limit) {
            List<BookDTO> popular = getPopularBooks(limit * 2);
            for (BookDTO book : popular) {
                if (book.getBookId() != bookId && !map.containsKey(book.getBookId())) {
                    map.put(book.getBookId(), book);
                    if (map.size() >= limit) break;
                }
            }
        }

        // 3. Lấy sách ngẫu nhiên (nếu vẫn chưa đủ limit)
        if (map.size() < limit) {
            List<BookDTO> random = getRandomBooks(limit * 2);
            for (BookDTO book : random) {
                if (book.getBookId() != bookId && !map.containsKey(book.getBookId())) {
                    map.put(book.getBookId(), book);
                    if (map.size() >= limit) break;
                }
            }
        }

        // Chuyển kết quả sang danh sách và rút gọn về đúng limit
        List<BookDTO> result = new ArrayList<>(map.values());
        if (result.size() > limit) {
            return result.subList(0, limit);
        }
        return result;
    }

    /**
     * Helper ánh xạ dữ liệu từ ResultSet sang BookDTO.
     */
    private BookDTO mapRowToBook(ResultSet rs) throws SQLException {
        return new BookDTO(
            rs.getInt("book_id"),
            0, // category_id không cần thiết ở tầng hiển thị, có thể để mặc định
            rs.getString("category_name"),
            rs.getString("title"),
            rs.getString("author"),
            rs.getString("publisher"),
            rs.getInt("publish_year")
        );
    }
}
