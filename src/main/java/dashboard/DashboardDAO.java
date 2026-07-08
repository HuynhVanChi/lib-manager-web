package dashboard;

import common.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object (DAO) thực hiện các truy vấn tối ưu cho trang Dashboard.
 * Sử dụng PreparedStatement chống SQL Injection và try-with-resources để tự động đóng tài nguyên.
 */
public class DashboardDAO {

    /**
     * Lấy 7 chỉ số KPI chính của thư viện.
     */
    public DashboardMetricsDTO getDashboardMetrics() throws SQLException {
        int totalBooks = 0;
        int totalBookTitles = 0;
        int totalReaders = 0;
        int totalBorrows = 0;
        int totalCurrentlyBorrowed = 0;
        int totalOverdue = 0;
        int totalInStock = 0;

        String sqlBooks = "SELECT COUNT(*) FROM book_copies WHERE deleted_at IS NULL";
        String sqlTitles = "SELECT COUNT(*) FROM books WHERE deleted_at IS NULL";
        String sqlReaders = "SELECT COUNT(*) FROM readers WHERE deleted_at IS NULL";
        String sqlBorrows = "SELECT COUNT(*) FROM borrow_details";
        String sqlCurrentlyBorrowed = "SELECT COUNT(*) FROM borrow_details WHERE return_date IS NULL AND status IN ('Borrowing', 'Overdue')";
        String sqlOverdue = "SELECT COUNT(*) FROM borrow_details WHERE return_date IS NULL AND (status = 'Overdue' OR due_date < CURDATE())";
        String sqlInStock = "SELECT COUNT(*) FROM book_copies WHERE status = 'Available' AND deleted_at IS NULL";

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Tổng số bản sao sách
            try (PreparedStatement ps = conn.prepareStatement(sqlBooks);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalBooks = rs.getInt(1);
            }
            
            // 2. Tổng số đầu sách
            try (PreparedStatement ps = conn.prepareStatement(sqlTitles);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalBookTitles = rs.getInt(1);
            }

            // 3. Tổng số độc giả
            try (PreparedStatement ps = conn.prepareStatement(sqlReaders);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalReaders = rs.getInt(1);
            }

            // 4. Tổng số lượt mượn
            try (PreparedStatement ps = conn.prepareStatement(sqlBorrows);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalBorrows = rs.getInt(1);
            }

            // 5. Tổng số sách đang mượn
            try (PreparedStatement ps = conn.prepareStatement(sqlCurrentlyBorrowed);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCurrentlyBorrowed = rs.getInt(1);
            }

            // 6. Tổng số sách quá hạn
            try (PreparedStatement ps = conn.prepareStatement(sqlOverdue);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalOverdue = rs.getInt(1);
            }

            // 7. Tổng số sách còn trong kho
            try (PreparedStatement ps = conn.prepareStatement(sqlInStock);
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalInStock = rs.getInt(1);
            }
        }
        return new DashboardMetricsDTO(totalBooks, totalBookTitles, totalReaders, totalBorrows, totalCurrentlyBorrowed, totalOverdue, totalInStock);
    }

    /**
     * Lấy danh sách Top 10 sách được mượn nhiều nhất.
     */
    public List<ChartDataPointDTO> getTop10Books() throws SQLException {
        List<ChartDataPointDTO> list = new ArrayList<>();
        String sql = "SELECT b.title, b.author, COUNT(bd.borrow_detail_id) AS borrow_count " +
                     "FROM borrow_details bd " +
                     "JOIN book_copies bc ON bd.copy_id = bc.copy_id " +
                     "JOIN books b ON bc.book_id = b.book_id " +
                     "WHERE b.deleted_at IS NULL AND bc.deleted_at IS NULL " +
                     "GROUP BY b.book_id, b.title, b.author " +
                     "ORDER BY borrow_count DESC " +
                     "LIMIT 10";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String title = rs.getString("title");
                String author = rs.getString("author");
                String label = title + (author != null && !author.trim().isEmpty() ? " (" + author + ")" : "");
                list.add(new ChartDataPointDTO(label, rs.getDouble("borrow_count")));
            }
        }
        return list;
    }

    /**
     * Lấy danh sách Top tác giả được đọc nhiều nhất.
     */
    public List<ChartDataPointDTO> getTopAuthors() throws SQLException {
        List<ChartDataPointDTO> list = new ArrayList<>();
        String sql = "SELECT b.author, COUNT(bd.borrow_detail_id) AS borrow_count " +
                     "FROM borrow_details bd " +
                     "JOIN book_copies bc ON bd.copy_id = bc.copy_id " +
                     "JOIN books b ON bc.book_id = b.book_id " +
                     "WHERE b.deleted_at IS NULL AND bc.deleted_at IS NULL AND b.author IS NOT NULL AND b.author <> '' " +
                     "GROUP BY b.author " +
                     "ORDER BY borrow_count DESC " +
                     "LIMIT 10";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ChartDataPointDTO(rs.getString("author"), rs.getDouble("borrow_count")));
            }
        }
        return list;
    }

    /**
     * Lấy danh sách Top thể loại được mượn nhiều nhất.
     */
    public List<ChartDataPointDTO> getTopCategories() throws SQLException {
        List<ChartDataPointDTO> list = new ArrayList<>();
        String sql = "SELECT c.name AS category_name, COUNT(bd.borrow_detail_id) AS borrow_count " +
                     "FROM borrow_details bd " +
                     "JOIN book_copies bc ON bd.copy_id = bc.copy_id " +
                     "JOIN books b ON bc.book_id = b.book_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE c.deleted_at IS NULL AND b.deleted_at IS NULL AND bc.deleted_at IS NULL " +
                     "GROUP BY c.category_id, c.name " +
                     "ORDER BY borrow_count DESC " +
                     "LIMIT 10";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ChartDataPointDTO(rs.getString("category_name"), rs.getDouble("borrow_count")));
            }
        }
        return list;
    }

    /**
     * Lấy số lượt mượn theo khối 4 giờ (chỉ trong ngày hôm nay).
     * Đã áp dụng Data Padding cho đủ 6 khung giờ (mỗi khung 4 tiếng).
     */
    public List<ChartDataPointDTO> getBorrowCountByDay() throws SQLException {
        Map<Integer, Double> map = new LinkedHashMap<>();
        // Khởi tạo 6 khung giờ, mỗi khung 4 tiếng (tương ứng block_index từ 0 đến 5)
        for (int i = 0; i < 6; i++) {
            map.put(i, 0.0);
        }

        String sql = "SELECT FLOOR(HOUR(created_at) / 4) AS block_index, COUNT(*) AS count " +
                     "FROM borrow_details " +
                     "WHERE DATE(created_at) = CURDATE() " +
                     "GROUP BY block_index";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int blockIndex = rs.getInt("block_index");
                double count = rs.getDouble("count");
                if (map.containsKey(blockIndex)) {
                    map.put(blockIndex, count);
                }
            }
        }

        String[] labels = {
            "00:00-04:00",
            "04:00-08:00",
            "08:00-12:00",
            "12:00-16:00",
            "16:00-20:00",
            "20:00-00:00"
        };

        List<ChartDataPointDTO> list = new ArrayList<>();
        for (Map.Entry<Integer, Double> entry : map.entrySet()) {
            list.add(new ChartDataPointDTO(labels[entry.getKey()], entry.getValue()));
        }
        return list;
    }

    /**
     * Lấy số lượt mượn theo ngày trong tuần (7 ngày gần nhất, bao gồm cả hôm nay).
     * Đã áp dụng Data Padding để đảm bảo không bị đứt gãy biểu đồ nếu có ngày không phát sinh lượt mượn.
     */
    public List<ChartDataPointDTO> getBorrowCountByWeek() throws SQLException {
        Map<String, Double> map = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("dd/MM");

        // Khởi tạo 7 ngày gần nhất với giá trị mặc định bằng 0.0
        for (int i = 6; i >= 0; i--) {
            LocalDate date = today.minusDays(i);
            map.put(date.format(formatter), 0.0);
        }

        String sql = "SELECT borrow_date, COUNT(*) AS count " +
                     "FROM borrow_details " +
                     "WHERE borrow_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                     "GROUP BY borrow_date";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String dateStr = rs.getString("borrow_date");
                double count = rs.getDouble("count");
                if (map.containsKey(dateStr)) {
                    map.put(dateStr, count);
                }
            }
        }

        List<ChartDataPointDTO> list = new ArrayList<>();
        for (Map.Entry<String, Double> entry : map.entrySet()) {
            LocalDate date = LocalDate.parse(entry.getKey(), formatter);
            list.add(new ChartDataPointDTO(date.format(displayFormatter), entry.getValue()));
        }
        return list;
    }

    /**
     * Lấy số lượt mượn theo tuần trong tháng hiện tại (Tuần 1, 2, 3, 4).
     * Đã áp dụng Data Padding để đảm bảo hiển thị đủ 4 tuần.
     */
    public List<ChartDataPointDTO> getBorrowCountByMonth() throws SQLException {
        Map<String, Double> map = new LinkedHashMap<>();
        map.put("Tuần 1", 0.0);
        map.put("Tuần 2", 0.0);
        map.put("Tuần 3", 0.0);
        map.put("Tuần 4", 0.0);

        String sql = "SELECT " +
                     "  CASE " +
                     "    WHEN DAY(borrow_date) <= 7 THEN 'Tuần 1' " +
                     "    WHEN DAY(borrow_date) <= 14 THEN 'Tuần 2' " +
                     "    WHEN DAY(borrow_date) <= 21 THEN 'Tuần 3' " +
                     "    ELSE 'Tuần 4' " +
                     "  END AS week_of_month, " +
                     "  COUNT(*) AS count " +
                     "FROM borrow_details " +
                     "WHERE borrow_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01') " +
                     "GROUP BY week_of_month";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String weekLabel = rs.getString("week_of_month");
                double count = rs.getDouble("count");
                if (map.containsKey(weekLabel)) {
                    map.put(weekLabel, count);
                }
            }
        }

        List<ChartDataPointDTO> list = new ArrayList<>();
        for (Map.Entry<String, Double> entry : map.entrySet()) {
            list.add(new ChartDataPointDTO(entry.getKey(), entry.getValue()));
        }
        return list;
    }
}
