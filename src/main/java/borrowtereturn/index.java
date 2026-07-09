package borrowtereturn;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Date;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import common.DBConnection;
import common.AuditLogger;

@WebServlet("/borrow-return/*")
public class index extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    public void init() throws ServletException {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            try {
                stmt.executeUpdate("ALTER TABLE borrow_details ADD COLUMN book_condition VARCHAR(100) DEFAULT 'Bình thường'");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE borrow_details ADD COLUMN notes TEXT DEFAULT NULL");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE fines ADD COLUMN notes TEXT DEFAULT NULL");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE books ADD COLUMN price DECIMAL(10,2) DEFAULT 100000.00");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
            try {
                stmt.executeUpdate("ALTER TABLE fines ADD COLUMN original_amount DECIMAL(10,2) DEFAULT NULL");
            } catch (SQLException e) {
                // Tắt lỗi nếu cột đã tồn tại
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();

        if (path == null || path.equals("/")) {
            handleList(request, response);
        } else if (path.equals("/create")) {
            handleCreateForm(request, response);
        } else if (path.equals("/detail")) {
            handleDetail(request, response);
        } else if (path.equals("/edit")) {
            handleEditForm(request, response);
        } else if (path.equals("/fine-detail")) {
            handleFineDetail(request, response);
        } else if (path.equals("/fine-edit")) {
            handleFineEditForm(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Map<String, Object>> borrowList = new ArrayList<>();
        List<Map<String, Object>> fineList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch borrow details
            String borrowSql = "SELECT bd.borrow_detail_id, bd.borrow_record_id, bd.copy_id, bd.borrow_date, bd.due_date, " +
                             "bd.return_date, bd.status AS detail_status, r.full_name AS reader_name, r.email AS reader_email, " +
                             "b.title AS book_title, c.barcode " +
                             "FROM borrow_details bd " +
                             "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                             "JOIN readers r ON br.reader_id = r.reader_id " +
                             "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                             "JOIN books b ON c.book_id = b.book_id " +
                             "ORDER BY bd.created_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(borrowSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("borrow_record_id", rs.getInt("borrow_record_id"));
                    map.put("copy_id", rs.getInt("copy_id"));
                    map.put("borrow_date", rs.getDate("borrow_date"));
                    map.put("due_date", rs.getDate("due_date"));
                    map.put("return_date", rs.getDate("return_date"));
                    
                    String detailStatus = rs.getString("detail_status");
                    Date dueDate = rs.getDate("due_date");
                    if ("Borrowing".equals(detailStatus) && dueDate != null) {
                        LocalDate today = LocalDate.now();
                        LocalDate due = dueDate.toLocalDate();
                        if (today.isAfter(due)) {
                            detailStatus = "Overdue";
                        }
                    }
                    map.put("status", detailStatus);
                    
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("reader_email", rs.getString("reader_email"));
                    map.put("book_title", rs.getString("book_title"));
                    map.put("barcode", rs.getString("barcode"));
                    borrowList.add(map);
                }
            }

            // 2. Fetch fines
            String fineSql = "SELECT f.fine_id, f.borrow_detail_id, f.amount, f.original_amount, f.reason, f.status AS fine_status, " +
                           "f.paid_at, u.full_name AS receiver_name, r.full_name AS reader_name, r.email AS reader_email, b.title AS book_title, c.barcode " +
                           "FROM fines f " +
                           "JOIN borrow_details bd ON f.borrow_detail_id = bd.borrow_detail_id " +
                           "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                           "JOIN readers r ON br.reader_id = r.reader_id " +
                           "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                           "JOIN books b ON c.book_id = b.book_id " +
                           "LEFT JOIN users u ON f.received_by = u.user_id " +
                           "ORDER BY f.created_at DESC";
            try (PreparedStatement stmt = conn.prepareStatement(fineSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("fine_id", rs.getInt("fine_id"));
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("original_amount", rs.getBigDecimal("original_amount"));
                    map.put("reason", rs.getString("reason"));
                    map.put("status", rs.getString("fine_status"));
                    map.put("paid_at", rs.getTimestamp("paid_at"));
                    map.put("receiver_name", rs.getString("receiver_name"));
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("reader_email", rs.getString("reader_email"));
                    map.put("book_title", rs.getString("book_title"));
                    map.put("barcode", rs.getString("barcode"));
                    fineList.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("borrowList", borrowList);
        request.setAttribute("fineList", fineList);
        request.getRequestDispatcher("/views/borrowtereturn/index.jsp").forward(request, response);
    }

    private void handleCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        List<Map<String, Object>> readerList = new ArrayList<>();
        List<Map<String, Object>> availableCopies = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Fetch active readers for dropdown list in borrow modal
            String readerSql = "SELECT reader_id, full_name, email, phone FROM readers WHERE deleted_at IS NULL AND status = 'Active'";
            try (PreparedStatement stmt = conn.prepareStatement(readerSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("reader_id", rs.getInt("reader_id"));
                    map.put("full_name", rs.getString("full_name"));
                    map.put("email", rs.getString("email"));
                    map.put("phone", rs.getString("phone"));
                    readerList.add(map);
                }
            }

            // 2. Fetch available copies
            String copiesSql = "SELECT c.copy_id, c.barcode, b.title FROM book_copies c " +
                               "JOIN books b ON c.book_id = b.book_id " +
                               "WHERE c.status = 'Available' AND c.deleted_at IS NULL";
            try (PreparedStatement stmt = conn.prepareStatement(copiesSql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("copy_id", rs.getInt("copy_id"));
                    map.put("barcode", rs.getString("barcode"));
                    map.put("title", rs.getString("title"));
                    availableCopies.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("readerList", readerList);
        request.setAttribute("availableCopies", availableCopies);
        request.getRequestDispatcher("/views/borrowtereturn/create.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();
        if (path == null) {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        }

        // Giả sử user_id mặc định là 1 (Admin) nếu chưa tích hợp cơ chế đăng nhập.
        int currentUserId = 1;

        switch (path) {
            case "/create":
                handleBorrow(request, response, currentUserId);
                break;
            case "/edit":
                handleEditSubmit(request, response, currentUserId);
                break;
            case "/fine-edit":
                handleFineEditSubmit(request, response, currentUserId);
                break;
            case "/return":
                handleReturn(request, response, currentUserId);
                break;
            case "/lost":
                handleLost(request, response, currentUserId);
                break;
            case "/pay-fine":
                handlePayFine(request, response, currentUserId);
                break;
            case "/waive-fine":
                handleWaiveFine(request, response, currentUserId);
                break;
            case "/undo-fine":
                handleUndoFine(request, response, currentUserId);
                break;
            case "/delete":
                handleDeleteBorrow(request, response, currentUserId);
                break;
            case "/delete-fine":
                handleDeleteFine(request, response, currentUserId);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleBorrow(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int readerId = Integer.parseInt(request.getParameter("readerId"));
        int copyId = Integer.parseInt(request.getParameter("copyId"));
        int durationDays = Integer.parseInt(request.getParameter("durationDays"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra bản sao sách có sẵn không
            String checkCopySql = "SELECT status FROM book_copies WHERE copy_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(checkCopySql)) {
                stmt.setInt(1, copyId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String status = rs.getString("status");
                        if (!"Available".equals(status)) {
                            throw new SQLException("Sách không có sẵn để mượn (Trạng thái hiện tại: " + status + ")");
                        }
                    } else {
                        throw new SQLException("Không tìm thấy bản sao sách.");
                    }
                }
            }

            // 2. Tạo borrow_record mới
            String insertRecordSql = "INSERT INTO borrow_records (reader_id, user_id) VALUES (?, ?)";
            int borrowRecordId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(insertRecordSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, readerId);
                stmt.setInt(2, userId);
                stmt.executeUpdate();
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        borrowRecordId = rs.getInt(1);
                    }
                }
            }

            // 3. Tạo borrow_detail mới
            LocalDate borrowDate = LocalDate.now();
            LocalDate dueDate = borrowDate.plusDays(durationDays);
            String insertDetailSql = "INSERT INTO borrow_details (borrow_record_id, copy_id, borrow_date, due_date, status) VALUES (?, ?, ?, ?, 'Borrowing')";
            int borrowDetailId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(insertDetailSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, borrowRecordId);
                stmt.setInt(2, copyId);
                stmt.setDate(3, Date.valueOf(borrowDate));
                stmt.setDate(4, Date.valueOf(dueDate));
                stmt.executeUpdate();
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        borrowDetailId = rs.getInt(1);
                    }
                }
            }

            // 4. Cập nhật trạng thái book_copies thành 'Borrowed'
            String updateCopySql = "UPDATE book_copies SET status = 'Borrowed' WHERE copy_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                stmt.setInt(1, copyId);
                stmt.executeUpdate();
            }

            // 5. Ghi Audit Log cho việc mượn sách
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("borrow_record_id", borrowRecordId);
            newLogData.put("reader_id", readerId);
            newLogData.put("copy_id", copyId);
            newLogData.put("borrow_date", borrowDate.toString());
            newLogData.put("due_date", dueDate.toString());
            newLogData.put("status", "Borrowing");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.INSERT, "borrow_details", borrowDetailId, null, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã mượn sách thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleReturn(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int borrowDetailId = Integer.parseInt(request.getParameter("borrowDetailId"));
        String bookCondition = request.getParameter("bookCondition");
        String notes = request.getParameter("notes");
        if (bookCondition == null || bookCondition.trim().isEmpty()) {
            bookCondition = "Bình thường";
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin lượt mượn hiện tại
            int copyId = 0;
            Date dueDate = null;
            String status = null;
            String fetchSql = "SELECT copy_id, due_date, status FROM borrow_details WHERE borrow_detail_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        copyId = rs.getInt("copy_id");
                        dueDate = rs.getDate("due_date");
                        status = rs.getString("status");
                    } else {
                        throw new SQLException("Không tìm thấy thông tin lượt mượn.");
                    }
                }
            }

            if ("Returned".equals(status)) {
                throw new SQLException("Sách này đã được trả từ trước.");
            }

            // Lấy giá sách từ bảng books
            double bookPrice = 100000.00;
            String priceSql = "SELECT b.price FROM borrow_details bd " +
                              "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                              "JOIN books b ON c.book_id = b.book_id " +
                              "WHERE bd.borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(priceSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        bookPrice = rs.getDouble("price");
                    }
                }
            }

            LocalDate returnDate = LocalDate.now();
            String newStatus = "Returned";
            if ("Mất sách".equals(bookCondition)) {
                newStatus = "Lost";
            }

            // 2. Cập nhật chi tiết mượn sang 'Returned' hoặc 'Lost'
            String updateDetailSql = "UPDATE borrow_details SET return_date = ?, status = ?, book_condition = ?, notes = ? WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateDetailSql)) {
                if ("Lost".equals(newStatus)) {
                    stmt.setNull(1, java.sql.Types.DATE);
                } else {
                    stmt.setDate(1, Date.valueOf(returnDate));
                }
                stmt.setString(2, newStatus);
                stmt.setString(3, bookCondition);
                stmt.setString(4, notes);
                stmt.setInt(5, borrowDetailId);
                stmt.executeUpdate();
            }

            // 3. Cập nhật trạng thái sách thành 'Available', 'Damaged', hoặc 'Lost'
            String copyStatus = "Available";
            if ("Mất sách".equals(bookCondition) || "Lost".equals(newStatus)) {
                copyStatus = "Lost";
            } else if ("Rách nặng".equals(bookCondition)) {
                copyStatus = "Damaged";
            }
            String updateCopySql = "UPDATE book_copies SET status = ? WHERE copy_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                stmt.setString(1, copyStatus);
                stmt.setInt(2, copyId);
                stmt.executeUpdate();
            }

            // 4. Tính toán phí phạt theo quy tắc mới
            double fineAmount = 0;
            List<String> reasonsList = new ArrayList<>();

            if ("Mất sách".equals(bookCondition) || "Lost".equals(newStatus)) {
                fineAmount = bookPrice + 20000.0;
                reasonsList.add("Lost Book");
            } else {
                // Kiểm tra trễ hạn
                LocalDate localDueDate = dueDate.toLocalDate();
                long daysOverdue = ChronoUnit.DAYS.between(localDueDate, returnDate);
                double overdueFine = 0;
                if (daysOverdue > 0) {
                    overdueFine = daysOverdue * 5000.0;
                    if (overdueFine > bookPrice) {
                        overdueFine = bookPrice;
                    }
                    reasonsList.add("Overdue");
                }

                // Kiểm tra hư hỏng
                double damageFine = 0;
                if ("Rách nhẹ".equals(bookCondition)) {
                    damageFine = bookPrice * 0.20;
                    if (damageFine < 15000.0) {
                        damageFine = 15000.0;
                    }
                    reasonsList.add("Damaged Book");
                } else if ("Rách nặng".equals(bookCondition)) {
                    damageFine = bookPrice * 0.80;
                    reasonsList.add("Damaged Book");
                }

                fineAmount = overdueFine + damageFine;
                double maxFine = bookPrice + 20000.0;
                if (fineAmount > maxFine) {
                    fineAmount = maxFine;
                }
            }

            if (fineAmount > 0) {
                String combinedReason = String.join(", ", reasonsList);
                
                // Kiểm tra xem đã có bản ghi phạt nào chưa
                boolean fineExists = false;
                String checkFineSql = "SELECT fine_id FROM fines WHERE borrow_detail_id = ?";
                int existingFineId = 0;
                try (PreparedStatement stmt = conn.prepareStatement(checkFineSql)) {
                    stmt.setInt(1, borrowDetailId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            fineExists = true;
                            existingFineId = rs.getInt("fine_id");
                        }
                    }
                }

                if (fineExists) {
                    String updateFineSql = "UPDATE fines SET amount = ?, reason = ?, status = 'Unpaid' WHERE fine_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                        stmt.setDouble(1, fineAmount);
                        stmt.setString(2, combinedReason);
                        stmt.setInt(3, existingFineId);
                        stmt.executeUpdate();
                    }
                } else {
                    String insertFineSql = "INSERT INTO fines (borrow_detail_id, amount, reason, status) VALUES (?, ?, ?, 'Unpaid')";
                    try (PreparedStatement stmt = conn.prepareStatement(insertFineSql)) {
                        stmt.setInt(1, borrowDetailId);
                        stmt.setDouble(2, fineAmount);
                        stmt.setString(3, combinedReason);
                        stmt.executeUpdate();
                    }
                }
            }

            // Ghi Audit Log
            Map<String, Object> oldLogData = new HashMap<>();
            oldLogData.put("status", status);
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("status", newStatus);
            newLogData.put("return_date", returnDate.toString());
            newLogData.put("book_condition", bookCondition);

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "borrow_details", borrowDetailId, oldLogData, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã trả sách thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleLost(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int borrowDetailId = Integer.parseInt(request.getParameter("borrowDetailId"));
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int copyId = 0;
            String status = null;
            String fetchSql = "SELECT copy_id, status FROM borrow_details WHERE borrow_detail_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(fetchSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        copyId = rs.getInt("copy_id");
                        status = rs.getString("status");
                    } else {
                        throw new SQLException("Không tìm thấy thông tin lượt mượn.");
                    }
                }
            }

            if ("Returned".equals(status)) {
                throw new SQLException("Sách này đã được trả.");
            }

            // Lấy giá sách từ bảng books
            double bookPrice = 100000.00;
            String priceSql = "SELECT b.price FROM borrow_details bd " +
                              "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                              "JOIN books b ON c.book_id = b.book_id " +
                              "WHERE bd.borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(priceSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        bookPrice = rs.getDouble("price");
                    }
                }
            }

            // 1. Cập nhật chi tiết mượn sang 'Lost'
            String updateDetailSql = "UPDATE borrow_details SET status = 'Lost', book_condition = 'Mất sách' WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateDetailSql)) {
                stmt.setInt(1, borrowDetailId);
                stmt.executeUpdate();
            }

            // 2. Cập nhật trạng thái sách thành 'Lost'
            String updateCopySql = "UPDATE book_copies SET status = 'Lost' WHERE copy_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                stmt.setInt(1, copyId);
                stmt.executeUpdate();
            }

            // 3. Tạo khoản phạt mất sách (Giá sách + 20.000đ)
            double fineAmount = bookPrice + 20000.0;
            
            boolean fineExists = false;
            String checkFineSql = "SELECT fine_id FROM fines WHERE borrow_detail_id = ?";
            int existingFineId = 0;
            try (PreparedStatement stmt = conn.prepareStatement(checkFineSql)) {
                stmt.setInt(1, borrowDetailId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        fineExists = true;
                        existingFineId = rs.getInt("fine_id");
                    }
                }
            }

            if (fineExists) {
                String updateFineSql = "UPDATE fines SET amount = ?, reason = 'Lost Book', status = 'Unpaid' WHERE fine_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                    stmt.setDouble(1, fineAmount);
                    stmt.setInt(2, existingFineId);
                    stmt.executeUpdate();
                }
            } else {
                String insertFineSql = "INSERT INTO fines (borrow_detail_id, amount, reason, status) VALUES (?, ?, 'Lost Book', 'Unpaid')";
                try (PreparedStatement stmt = conn.prepareStatement(insertFineSql)) {
                    stmt.setInt(1, borrowDetailId);
                    stmt.setDouble(2, fineAmount);
                    stmt.executeUpdate();
                }
            }

            // Ghi Audit Log
            Map<String, Object> oldLogData = new HashMap<>();
            oldLogData.put("status", status);
            Map<String, Object> newLogData = new HashMap<>();
            newLogData.put("status", "Lost");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "borrow_details", borrowDetailId, oldLogData, newLogData);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã báo mất sách thành công! Đã tạo khoản phí phạt mất sách.");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handlePayFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));
        int discountRate = 0;
        try {
            discountRate = Integer.parseInt(request.getParameter("discountRate"));
        } catch (Exception e) {
            // Mặc định không giảm giá
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin số tiền phạt và trạng thái hiện tại
            double amount = 0;
            String status = "";
            String selectSql = "SELECT amount, status FROM fines WHERE fine_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
                stmt.setInt(1, fineId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        amount = rs.getDouble("amount");
                        status = rs.getString("status");
                    }
                }
            }

            if ("Paid".equals(status) || "Waived".equals(status)) {
                throw new SQLException("Khoản phạt này đã được thanh toán hoặc miễn giảm từ trước.");
            }

            double finalAmount = amount * (1.0 - discountRate / 100.0);
            String newStatus = (discountRate == 100) ? "Waived" : "Paid";

            // 2. Cập nhật fines: lưu số tiền phạt thực thu, số tiền gốc và ghi chú miễn giảm
            String updateFineSql = "UPDATE fines SET amount = ?, original_amount = ?, status = ?, paid_at = CURRENT_TIMESTAMP, received_by = ?, notes = CONCAT(IFNULL(notes, ''), ?) WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                stmt.setDouble(1, finalAmount);
                stmt.setDouble(2, amount);
                stmt.setString(3, newStatus);
                stmt.setInt(4, userId);
                String discountNote = "\n[Thu tiền] Áp dụng miễn giảm " + discountRate + "%. Số tiền gốc: " + amount + "đ.";
                stmt.setString(5, discountNote);
                stmt.setInt(6, fineId);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", status);
            oldLog.put("amount", amount);
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", newStatus);
            newLog.put("amount", finalAmount);
            newLog.put("discount_rate", discountRate);

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Thanh toán phí phạt thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }

    private void handleWaiveFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String updateFineSql = "UPDATE fines SET status = 'Waived', paid_at = CURRENT_TIMESTAMP, received_by = ? WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, fineId);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", "Unpaid");
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", "Waived");

            AuditLogger.log(conn, userId, AuditLogger.ActionType.UPDATE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã miễn giảm phí phạt thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }

    private void handleUndoFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));
        String undoReason = request.getParameter("undoReason");

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Lấy thông tin số tiền phạt, số tiền gốc và trạng thái hiện tại
            double currentAmount = 0;
            Double originalAmount = null;
            String status = "";
            String selectSql = "SELECT amount, original_amount, status FROM fines WHERE fine_id = ? FOR UPDATE";
            try (PreparedStatement stmt = conn.prepareStatement(selectSql)) {
                stmt.setInt(1, fineId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        currentAmount = rs.getDouble("amount");
                        double orig = rs.getDouble("original_amount");
                        if (!rs.wasNull()) {
                            originalAmount = orig;
                        }
                        status = rs.getString("status");
                    }
                }
            }

            if (!"Paid".equals(status) && !"Waived".equals(status)) {
                throw new SQLException("Chỉ có thể hoàn tác khoản phạt đã đóng hoặc đã miễn giảm.");
            }

            double restoredAmount = (originalAmount != null) ? originalAmount : currentAmount;

            // 2. Khôi phục trạng thái phạt về Unpaid, trả lại số tiền phạt gốc
            String updateSql = "UPDATE fines SET status = 'Unpaid', amount = ?, original_amount = NULL, paid_at = NULL, received_by = NULL, notes = CONCAT(IFNULL(notes, ''), ?) WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                stmt.setDouble(1, restoredAmount);
                String undoNote = "\n[Hoàn tác] Lý do: " + undoReason + " (Người thực hiện: User #" + userId + ")";
                stmt.setString(2, undoNote);
                stmt.setInt(3, fineId);
                stmt.executeUpdate();
            }

            // Ghi Audit Log với hành động RESTORE
            Map<String, Object> oldLog = new HashMap<>();
            oldLog.put("status", status);
            oldLog.put("amount", currentAmount);
            Map<String, Object> newLog = new HashMap<>();
            newLog.put("status", "Unpaid");
            newLog.put("amount", restoredAmount);
            newLog.put("undo_reason", undoReason);

            AuditLogger.log(conn, userId, AuditLogger.ActionType.RESTORE, "fines", fineId, oldLog, newLog);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi hoàn tác: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Đã hoàn tác trạng thái khoản phạt thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }


    private void handleDeleteBorrow(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Delete associated fines first
            String deleteFinesSql = "DELETE FROM fines WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteFinesSql)) {
                stmt.setInt(1, id);
                stmt.executeUpdate();
            }

            // 2. We should also update book copy status back to 'Available' if it was 'Borrowed' or 'Lost'
            int copyId = 0;
            String getCopySql = "SELECT copy_id FROM borrow_details WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(getCopySql)) {
                stmt.setInt(1, id);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        copyId = rs.getInt("copy_id");
                    }
                }
            }

            if (copyId > 0) {
                String updateCopySql = "UPDATE book_copies SET status = 'Available' WHERE copy_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                    stmt.setInt(1, copyId);
                    stmt.executeUpdate();
                }
            }

            // 3. Delete borrow detail
            String deleteDetailSql = "DELETE FROM borrow_details WHERE borrow_detail_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteDetailSql)) {
                stmt.setInt(1, id);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            AuditLogger.log(conn, userId, AuditLogger.ActionType.DELETE, "borrow_details", id, null, null);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi khi xóa phiếu mượn: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Xóa phiếu mượn thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleDeleteFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Delete fine
            String deleteFineSql = "DELETE FROM fines WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteFineSql)) {
                stmt.setInt(1, id);
                stmt.executeUpdate();
            }

            // Ghi Audit Log
            AuditLogger.log(conn, userId, AuditLogger.ActionType.DELETE, "fines", id, null, null);

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi khi xóa khoản phạt: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        request.getSession().setAttribute("successMsg", "Xóa khoản phạt thành công!");
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private Map<String, Object> findBorrowDetailById(int id) {
        Map<String, Object> map = null;
        String sql = "SELECT bd.borrow_detail_id, bd.borrow_record_id, bd.copy_id, bd.borrow_date, bd.due_date, " +
                     "bd.return_date, bd.status AS detail_status, bd.book_condition, bd.notes, r.full_name AS reader_name, r.email AS reader_email, " +
                     "r.phone AS reader_phone, b.title AS book_title, c.barcode " +
                     "FROM borrow_details bd " +
                     "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                     "JOIN readers r ON br.reader_id = r.reader_id " +
                     "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                     "JOIN books b ON c.book_id = b.book_id " +
                     "WHERE bd.borrow_detail_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    map = new HashMap<>();
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("borrow_record_id", rs.getInt("borrow_record_id"));
                    map.put("copy_id", rs.getInt("copy_id"));
                    map.put("borrow_date", rs.getDate("borrow_date"));
                    map.put("due_date", rs.getDate("due_date"));
                    map.put("return_date", rs.getDate("return_date"));
                    map.put("status", rs.getString("detail_status"));
                    map.put("book_condition", rs.getString("book_condition"));
                    map.put("notes", rs.getString("notes"));
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("reader_email", rs.getString("reader_email"));
                    map.put("reader_phone", rs.getString("reader_phone"));
                    map.put("book_title", rs.getString("book_title"));
                    map.put("barcode", rs.getString("barcode"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    private List<Map<String, Object>> findFinesByBorrowDetailId(int borrowDetailId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT f.fine_id, f.amount, f.reason, f.status AS fine_status, f.paid_at " +
                     "FROM fines f " +
                     "WHERE f.borrow_detail_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, borrowDetailId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("fine_id", rs.getInt("fine_id"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("reason", rs.getString("reason"));
                    map.put("status", rs.getString("fine_status"));
                    map.put("paid_at", rs.getTimestamp("paid_at"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Map<String, Object> item = findBorrowDetailById(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        }
        List<Map<String, Object>> fines = findFinesByBorrowDetailId(id);
        request.setAttribute("item", item);
        request.setAttribute("fines", fines);
        request.getRequestDispatcher("/views/borrowtereturn/detail.jsp").forward(request, response);
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Map<String, Object> item = findBorrowDetailById(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        }
        request.setAttribute("item", item);
        request.getRequestDispatcher("/views/borrowtereturn/edit.jsp").forward(request, response);
    }

    private void handleEditSubmit(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("borrowDetailId"));
        String borrowDateStr = request.getParameter("borrowDate");
        String dueDateStr = request.getParameter("dueDate");
        String returnDateStr = request.getParameter("returnDate");
        String status = request.getParameter("status");
        String bookCondition = request.getParameter("bookCondition");
        String notes = request.getParameter("notes");

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 1. Lấy giá sách từ bảng books
                double bookPrice = 100000.00;
                String priceSql = "SELECT b.price FROM borrow_details bd " +
                                  "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                                  "JOIN books b ON c.book_id = b.book_id " +
                                  "WHERE bd.borrow_detail_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(priceSql)) {
                    stmt.setInt(1, id);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            bookPrice = rs.getDouble("price");
                        }
                    }
                }

                // 2. Cập nhật chi tiết mượn
                String sql = "UPDATE borrow_details SET borrow_date = ?, due_date = ?, return_date = ?, status = ?, book_condition = ?, notes = ? WHERE borrow_detail_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setDate(1, java.sql.Date.valueOf(borrowDateStr));
                    stmt.setDate(2, java.sql.Date.valueOf(dueDateStr));
                    if (returnDateStr != null && !returnDateStr.trim().isEmpty()) {
                        stmt.setDate(3, java.sql.Date.valueOf(returnDateStr));
                    } else {
                        stmt.setNull(3, java.sql.Types.DATE);
                    }
                    stmt.setString(4, status);
                    stmt.setString(5, bookCondition);
                    stmt.setString(6, notes);
                    stmt.setInt(7, id);
                    stmt.executeUpdate();
                }

                // 3. Cập nhật trạng thái sách trong bản sao
                int copyId = 0;
                String getCopySql = "SELECT copy_id FROM borrow_details WHERE borrow_detail_id = ?";
                try (PreparedStatement stmt = conn.prepareStatement(getCopySql)) {
                    stmt.setInt(1, id);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getInt("copy_id");
                        }
                    }
                }

                if (copyId > 0) {
                    String copyStatus = "Available";
                    if ("Lost".equals(status) || "Mất sách".equals(bookCondition)) {
                        copyStatus = "Lost";
                    } else if ("Borrowing".equals(status) || "Overdue".equals(status)) {
                        copyStatus = "Borrowed";
                    } else if ("Rách nặng".equals(bookCondition)) {
                        copyStatus = "Damaged";
                    }
                    
                    String updateCopySql = "UPDATE book_copies SET status = ? WHERE copy_id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(updateCopySql)) {
                        stmt.setString(1, copyStatus);
                        stmt.setInt(2, copyId);
                        stmt.executeUpdate();
                    }
                }

                // 4. Tính toán phí phạt theo quy tắc mới
                double fineAmount = 0;
                List<String> reasonsList = new ArrayList<>();

                if ("Lost".equals(status) || "Mất sách".equals(bookCondition)) {
                    fineAmount = bookPrice + 20000.0;
                    reasonsList.add("Lost Book");
                } else {
                    // Kiểm tra quá hạn
                    if (returnDateStr != null && !returnDateStr.trim().isEmpty()) {
                        try {
                            java.time.LocalDate due = java.time.LocalDate.parse(dueDateStr);
                            java.time.LocalDate ret = java.time.LocalDate.parse(returnDateStr);
                            long daysOverdue = java.time.temporal.ChronoUnit.DAYS.between(due, ret);
                            if (daysOverdue > 0) {
                                double overdueFine = daysOverdue * 5000.0;
                                if (overdueFine > bookPrice) {
                                    overdueFine = bookPrice;
                                }
                                reasonsList.add("Overdue");
                                fineAmount += overdueFine;
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }

                    // Kiểm tra hư hỏng
                    double damageFine = 0;
                    if ("Rách nhẹ".equals(bookCondition)) {
                        damageFine = bookPrice * 0.20;
                        if (damageFine < 15000.0) {
                            damageFine = 15000.0;
                        }
                        reasonsList.add("Damaged Book");
                        fineAmount += damageFine;
                    } else if ("Rách nặng".equals(bookCondition)) {
                        damageFine = bookPrice * 0.80;
                        reasonsList.add("Damaged Book");
                        fineAmount += damageFine;
                    }

                    double maxFine = bookPrice + 20000.0;
                    if (fineAmount > maxFine) {
                        fineAmount = maxFine;
                    }
                }

                if (fineAmount > 0) {
                    String combinedReason = String.join(", ", reasonsList);

                    // Kiểm tra xem đã có bản ghi phạt nào chưa
                    boolean fineExists = false;
                    String checkFineSql = "SELECT fine_id FROM fines WHERE borrow_detail_id = ?";
                    int existingFineId = 0;
                    try (PreparedStatement stmt = conn.prepareStatement(checkFineSql)) {
                        stmt.setInt(1, id);
                        try (ResultSet rs = stmt.executeQuery()) {
                            if (rs.next()) {
                                fineExists = true;
                                existingFineId = rs.getInt("fine_id");
                            }
                        }
                    }

                    if (fineExists) {
                        String updateFineSql = "UPDATE fines SET amount = ?, reason = ?, notes = ? WHERE fine_id = ?";
                        try (PreparedStatement stmt = conn.prepareStatement(updateFineSql)) {
                            stmt.setDouble(1, fineAmount);
                            stmt.setString(2, combinedReason);
                            stmt.setString(3, notes);
                            stmt.setInt(4, existingFineId);
                            stmt.executeUpdate();
                        }
                    } else {
                        String insertFineSql = "INSERT INTO fines (borrow_detail_id, amount, reason, status, notes) VALUES (?, ?, ?, 'Unpaid', ?)";
                        try (PreparedStatement stmt = conn.prepareStatement(insertFineSql)) {
                            stmt.setInt(1, id);
                            stmt.setDouble(2, fineAmount);
                            stmt.setString(3, combinedReason);
                            stmt.setString(4, notes);
                            stmt.executeUpdate();
                        }
                    }
                }

                conn.commit();
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private boolean hasFine(Connection conn, int borrowDetailId, String reason) throws SQLException {
        String sql = "SELECT 1 FROM fines WHERE borrow_detail_id = ? AND reason = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, borrowDetailId);
            stmt.setString(2, reason);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void createFine(Connection conn, int borrowDetailId, double amount, String reason) throws SQLException {
        String sql = "INSERT INTO fines (borrow_detail_id, amount, reason, status) VALUES (?, ?, ?, 'Unpaid')";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, borrowDetailId);
            stmt.setDouble(2, amount);
            stmt.setString(3, reason);
            stmt.executeUpdate();
        }
    }

    private Map<String, Object> findFineById(int fineId) {
        Map<String, Object> map = null;
        String sql = "SELECT f.fine_id, f.borrow_detail_id, f.amount, f.reason, f.status AS fine_status, " +
                     "f.paid_at, f.notes, r.full_name AS reader_name, r.email AS reader_email, b.title AS book_title, c.barcode, " +
                     "bd.borrow_date, bd.due_date, bd.return_date " +
                     "FROM fines f " +
                     "JOIN borrow_details bd ON f.borrow_detail_id = bd.borrow_detail_id " +
                     "JOIN borrow_records br ON bd.borrow_record_id = br.borrow_record_id " +
                     "JOIN readers r ON br.reader_id = r.reader_id " +
                     "JOIN book_copies c ON bd.copy_id = c.copy_id " +
                     "JOIN books b ON c.book_id = b.book_id " +
                     "WHERE f.fine_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, fineId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    map = new HashMap<>();
                    map.put("fine_id", rs.getInt("fine_id"));
                    map.put("borrow_detail_id", rs.getInt("borrow_detail_id"));
                    map.put("amount", rs.getBigDecimal("amount"));
                    map.put("reason", rs.getString("reason"));
                    map.put("status", rs.getString("fine_status"));
                    map.put("paid_at", rs.getTimestamp("paid_at"));
                    map.put("notes", rs.getString("notes"));
                    map.put("reader_name", rs.getString("reader_name"));
                    map.put("reader_email", rs.getString("reader_email"));
                    map.put("book_title", rs.getString("book_title"));
                    map.put("barcode", rs.getString("barcode"));
                    map.put("borrow_date", rs.getDate("borrow_date"));
                    map.put("due_date", rs.getDate("due_date"));
                    map.put("return_date", rs.getDate("return_date"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    private void handleFineDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Map<String, Object> item = findFineById(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        }
        request.setAttribute("item", item);
        request.getRequestDispatcher("/views/borrowtereturn/fine-detail.jsp").forward(request, response);
    }

    private void handleFineEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Map<String, Object> item = findFineById(id);
        if (item == null) {
            response.sendRedirect(request.getContextPath() + "/borrow-return");
            return;
        }
        request.setAttribute("item", item);
        request.getRequestDispatcher("/views/borrowtereturn/fine-edit.jsp").forward(request, response);
    }

    private void handleFineEditSubmit(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("fineId"));
        double amount = Double.parseDouble(request.getParameter("amount"));
        String[] reasons = request.getParameterValues("reason");
        String reason = (reasons != null) ? String.join(", ", reasons) : "";
        String status = request.getParameter("status");
        String paidAtStr = request.getParameter("paidAt");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE fines SET amount = ?, reason = ?, status = ?, paid_at = ?, received_by = ? WHERE fine_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setDouble(1, amount);
                stmt.setString(2, reason);
                stmt.setString(3, status);
                if ("Paid".equals(status)) {
                    stmt.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
                    stmt.setInt(5, userId);
                } else if (paidAtStr != null && !paidAtStr.trim().isEmpty()) {
                    try {
                        // Handle standard datetime formats
                        stmt.setTimestamp(4, java.sql.Timestamp.valueOf(paidAtStr.replace("T", " ") + ":00"));
                    } catch (Exception e) {
                        stmt.setTimestamp(4, new java.sql.Timestamp(System.currentTimeMillis()));
                    }
                    stmt.setInt(5, userId);
                } else {
                    stmt.setNull(4, java.sql.Types.TIMESTAMP);
                    stmt.setNull(5, java.sql.Types.INTEGER);
                }
                stmt.setInt(6, id);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }

    private void updateFineAmount(Connection conn, int borrowDetailId, String reason, double amount) throws SQLException {
        String sql = "UPDATE fines SET amount = ? WHERE borrow_detail_id = ? AND reason = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDouble(1, amount);
            stmt.setInt(2, borrowDetailId);
            stmt.setString(3, reason);
            stmt.executeUpdate();
        }
    }
}

