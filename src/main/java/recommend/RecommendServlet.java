package recommend;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller trung tâm xử lý toàn bộ request liên quan đến Quản lý Đề xuất sách.
 * URL pattern: /recommend/*
 * Phân nhánh theo pathInfo:
 *   GET  /recommend              → Danh sách đề xuất sách (hỗ trợ thùng rác)
 *   GET  /recommend/add          → Form thêm đề xuất mới
 *   POST /recommend/add          → Xử lý lưu đề xuất mới
 *   GET  /recommend/edit         → Form chỉnh sửa đề xuất
 *   POST /recommend/edit         → Xử lý lưu chỉnh sửa
 *   GET  /recommend/detail       → Chi tiết đề xuất sách
 *   POST /recommend/delete       → Xóa mềm đề xuất (POST)
 *   POST /recommend/restore      → Khôi phục đề xuất đã xóa (POST)
 *   POST /recommend/approve      → Duyệt đề xuất trực tiếp (POST)
 *   POST /recommend/reject       → Từ chối đề xuất trực tiếp (POST)
 */
@WebServlet(name = "RecommendServlet", urlPatterns = {"/recommend/*"})
public class RecommendServlet extends HttpServlet {
    private final BookRecommendationDAO recommendationDAO = new BookRecommendationDAO();

    @Override
    public void init() throws ServletException {
        super.init();
        // Tự động kiểm tra và nâng cấp CSDL nếu thiếu cột xóa mềm (deleted_at, deleted_by)
        try (java.sql.Connection conn = common.DBConnection.getConnection();
             java.sql.Statement stmt = conn.createStatement()) {
            
            boolean columnExists = false;
            try (java.sql.ResultSet rs = conn.getMetaData().getColumns(null, null, "book_recommendations", "deleted_at")) {
                if (rs.next()) {
                    columnExists = true;
                }
            }
            
            if (!columnExists) {
                stmt.execute("ALTER TABLE book_recommendations ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL;");
                stmt.execute("ALTER TABLE book_recommendations ADD COLUMN deleted_by INT NULL;");
                stmt.execute("ALTER TABLE book_recommendations ADD CONSTRAINT fk_book_rec_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(user_id);");
                System.out.println("DATABASE MIGRATION: Added deleted_at and deleted_by columns to book_recommendations table successfully.");
            }
        } catch (Exception e) {
            System.err.println("DATABASE MIGRATION WARNING: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        handleRoleSimulation(request);
        
        String path = request.getPathInfo(); // null, "/add", "/edit", "/detail"
        
        if (path == null || path.equals("/")) {
            handleList(request, response);
        } else {
            switch (path) {
                case "/add":
                    handleAddForm(request, response);
                    break;
                case "/edit":
                    handleEditForm(request, response);
                    break;
                case "/detail":
                    handleDetail(request, response);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/recommend");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        handleRoleSimulation(request);
        
        String path = request.getPathInfo();
        
        if (path == null) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        switch (path) {
            case "/add":
                handleAddSubmit(request, response);
                break;
            case "/edit":
                handleEditSubmit(request, response);
                break;
            case "/delete":
                handleDeleteSubmit(request, response);
                break;
            case "/restore":
                handleRestoreSubmit(request, response);
                break;
            case "/approve":
                handleApproveSubmit(request, response);
                break;
            case "/reject":
                handleRejectSubmit(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/recommend");
        }
    }

    // =============================================
    // GET /recommend : Danh sách đề xuất sách
    // =============================================
    private void handleList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String keyword = request.getParameter("keyword");
        String statusFilter = request.getParameter("status");

        try {
            List<BookRecommendation> list = recommendationDAO.listAll(keyword, statusFilter);
            List<BookRecommendation> deletedList = recommendationDAO.findDeleted();
            
            request.setAttribute("recommendationsList", list);
            request.setAttribute("deletedRecommendations", deletedList);
            request.setAttribute("keyword", keyword);
            request.setAttribute("statusFilter", statusFilter);
            
            transferFlashMessage(request);
            request.getRequestDispatcher("/views/recommend/list.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("flashMessage", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            request.setAttribute("flashType", "danger");
            request.getRequestDispatcher("/views/recommend/list.jsp").forward(request, response);
        }
    }

    // =============================================
    // GET /recommend/add : Form thêm mới đề xuất
    // =============================================
    private void handleAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/recommend/add.jsp").forward(request, response);
    }

    // =============================================
    // POST /recommend/add : Xử lý lưu đề xuất
    // =============================================
    private void handleAddSubmit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String readerName = request.getParameter("readerName");
        String readerPhone = request.getParameter("readerPhone");
        String readerCode = request.getParameter("readerCode");
        String bookTitle = request.getParameter("bookTitle");
        String author = request.getParameter("author");
        String category = request.getParameter("category");
        String publisher = request.getParameter("publisher");
        String publishYearStr = request.getParameter("publishYear");
        String reason = request.getParameter("reason");
        String note = request.getParameter("note");

        // Validate bắt buộc
        if (readerName == null || readerName.trim().isEmpty() ||
            bookTitle == null || bookTitle.trim().isEmpty() ||
            author == null || author.trim().isEmpty()) {
            
            request.setAttribute("error", "Vui lòng nhập đầy đủ các trường bắt buộc (*).");
            request.setAttribute("readerName", readerName);
            request.setAttribute("readerPhone", readerPhone);
            request.setAttribute("readerCode", readerCode);
            request.setAttribute("bookTitle", bookTitle);
            request.setAttribute("author", author);
            request.setAttribute("category", category);
            request.setAttribute("publisher", publisher);
            request.setAttribute("publishYear", publishYearStr);
            request.setAttribute("reason", reason);
            request.setAttribute("note", note);
            request.getRequestDispatcher("/views/recommend/add.jsp").forward(request, response);
            return;
        }

        int publishYear = 0;
        if (publishYearStr != null && !publishYearStr.trim().isEmpty()) {
            try {
                publishYear = Integer.parseInt(publishYearStr.trim());
            } catch (NumberFormatException e) {
                // Bỏ qua lỗi định dạng năm
            }
        }

        int creatorId = getCurrentUserId(request);

        BookRecommendation rec = new BookRecommendation();
        rec.setReaderName(readerName.trim());
        rec.setReaderPhone(trimOrNull(readerPhone));
        rec.setReaderCode(trimOrNull(readerCode));
        rec.setBookTitle(bookTitle.trim());
        rec.setAuthor(author.trim());
        rec.setCategory(trimOrNull(category));
        rec.setPublisher(trimOrNull(publisher));
        rec.setPublishYear(publishYear);
        rec.setReason(trimOrNull(reason));
        rec.setNote(trimOrNull(note));
        rec.setCreatedBy(creatorId);

        try {
            boolean success = recommendationDAO.create(rec);
            if (success) {
                setFlashMessage(request, "success", "Ghi nhận đề xuất sách mới thành công!");
                response.sendRedirect(request.getContextPath() + "/recommend");
            } else {
                request.setAttribute("error", "Lưu thất bại. Vui lòng kiểm tra lại kết nối.");
                request.getRequestDispatcher("/views/recommend/add.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi CSDL: " + e.getMessage());
            request.getRequestDispatcher("/views/recommend/add.jsp").forward(request, response);
        }
    }

    // =============================================
    // GET /recommend/edit : Form chỉnh sửa đề xuất
    // =============================================
    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        try {
            BookRecommendation rec = recommendationDAO.getById(id);
            if (rec == null) {
                setFlashMessage(request, "danger", "Đề xuất không tồn tại hoặc đã bị xóa.");
                response.sendRedirect(request.getContextPath() + "/recommend");
                return;
            }

            if (!"Pending".equalsIgnoreCase(rec.getStatus())) {
                setFlashMessage(request, "warning", "Đề xuất này đã được xét duyệt, không thể sửa đổi.");
                response.sendRedirect(request.getContextPath() + "/recommend/detail?id=" + id);
                return;
            }

            request.setAttribute("recommendation", rec);
            request.getRequestDispatcher("/views/recommend/edit.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            setFlashMessage(request, "danger", "Lỗi tải thông tin đề xuất: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/recommend");
        }
    }

    // =============================================
    // POST /recommend/edit : Xử lý sửa đề xuất
    // =============================================
    private void handleEditSubmit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        String readerName = request.getParameter("readerName");
        String readerPhone = request.getParameter("readerPhone");
        String readerCode = request.getParameter("readerCode");
        String bookTitle = request.getParameter("bookTitle");
        String author = request.getParameter("author");
        String category = request.getParameter("category");
        String publisher = request.getParameter("publisher");
        String publishYearStr = request.getParameter("publishYear");
        String reason = request.getParameter("reason");
        String note = request.getParameter("note");

        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        // Validate
        if (readerName == null || readerName.trim().isEmpty() ||
            bookTitle == null || bookTitle.trim().isEmpty() ||
            author == null || author.trim().isEmpty()) {
            
            request.setAttribute("error", "Vui lòng nhập đầy đủ các trường bắt buộc (*).");
            try {
                request.setAttribute("recommendation", recommendationDAO.getById(id));
            } catch (SQLException e) {
                e.printStackTrace();
            }
            request.getRequestDispatcher("/views/recommend/edit.jsp").forward(request, response);
            return;
        }

        int publishYear = 0;
        if (publishYearStr != null && !publishYearStr.trim().isEmpty()) {
            try {
                publishYear = Integer.parseInt(publishYearStr.trim());
            } catch (NumberFormatException e) {
                // Bỏ qua
            }
        }

        BookRecommendation rec = new BookRecommendation();
        rec.setRecommendationId(id);
        rec.setReaderName(readerName.trim());
        rec.setReaderPhone(trimOrNull(readerPhone));
        rec.setReaderCode(trimOrNull(readerCode));
        rec.setBookTitle(bookTitle.trim());
        rec.setAuthor(author.trim());
        rec.setCategory(trimOrNull(category));
        rec.setPublisher(trimOrNull(publisher));
        rec.setPublishYear(publishYear);
        rec.setReason(trimOrNull(reason));
        rec.setNote(trimOrNull(note));

        try {
            boolean success = recommendationDAO.update(rec);
            if (success) {
                setFlashMessage(request, "success", "Cập nhật đề xuất sách thành công!");
                response.sendRedirect(request.getContextPath() + "/recommend/detail?id=" + id);
            } else {
                setFlashMessage(request, "danger", "Cập nhật thất bại. Đề xuất đã được duyệt hoặc đã bị xóa.");
                response.sendRedirect(request.getContextPath() + "/recommend");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi CSDL: " + e.getMessage());
            try {
                request.setAttribute("recommendation", recommendationDAO.getById(id));
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            request.getRequestDispatcher("/views/recommend/edit.jsp").forward(request, response);
        }
    }

    // =============================================
    // GET /recommend/detail : Xem chi tiết đề xuất
    // =============================================
    private void handleDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        try {
            BookRecommendation rec = recommendationDAO.getById(id);
            if (rec == null) {
                setFlashMessage(request, "danger", "Đề xuất không tồn tại hoặc đã bị xóa.");
                response.sendRedirect(request.getContextPath() + "/recommend");
                return;
            }

            request.setAttribute("recommendation", rec);
            
            transferFlashMessage(request);
            request.getRequestDispatcher("/views/recommend/detail.jsp").forward(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            setFlashMessage(request, "danger", "Lỗi kết nối cơ sở dữ liệu: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/recommend");
        }
    }

    // =============================================
    // POST /recommend/delete : Xóa mềm đề xuất (Thùng rác)
    // =============================================
    private void handleDeleteSubmit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        int deletedBy = getCurrentUserId(request);

        try {
            boolean success = recommendationDAO.delete(id, deletedBy);
            if (success) {
                setFlashMessage(request, "success", "Đã di chuyển đề xuất vào Thùng rác.");
            } else {
                setFlashMessage(request, "danger", "Xóa thất bại. Đề xuất không ở trạng thái Chờ xử lý hoặc không tồn tại.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            setFlashMessage(request, "danger", "Lỗi CSDL: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/recommend");
    }

    // =============================================
    // POST /recommend/restore : Khôi phục từ Thùng rác
    // =============================================
    private void handleRestoreSubmit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        try {
            boolean success = recommendationDAO.restore(id);
            if (success) {
                setFlashMessage(request, "success", "Khôi phục đề xuất sách thành công!");
            } else {
                setFlashMessage(request, "danger", "Khôi phục thất bại. Bản ghi không ở trong Thùng rác.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            setFlashMessage(request, "danger", "Lỗi: " + e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/recommend");
    }

    // =============================================
    // POST /recommend/approve : Duyệt đề xuất trực tiếp
    // =============================================
    private void handleApproveSubmit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        try {
            boolean success = recommendationDAO.updateStatus(id, "Approved");
            if (success) {
                setFlashMessage(request, "success", "Phê duyệt đề xuất sách thành công!");
            } else {
                setFlashMessage(request, "danger", "Duyệt đề xuất thất bại. Bản ghi không tồn tại.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            setFlashMessage(request, "danger", "Lỗi CSDL: " + e.getMessage());
        }

        String redirectUrl = request.getParameter("redirectUrl");
        if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/recommend/detail?id=" + id);
        }
    }

    // =============================================
    // POST /recommend/reject : Từ chối đề xuất trực tiếp
    // =============================================
    private void handleRejectSubmit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = parseId(request.getParameter("id"));
        if (id <= 0) {
            response.sendRedirect(request.getContextPath() + "/recommend");
            return;
        }

        try {
            boolean success = recommendationDAO.updateStatus(id, "Rejected");
            if (success) {
                setFlashMessage(request, "success", "Đã từ chối đề xuất sách.");
            } else {
                setFlashMessage(request, "danger", "Từ chối thất bại. Bản ghi không tồn tại.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            setFlashMessage(request, "danger", "Lỗi CSDL: " + e.getMessage());
        }

        String redirectUrl = request.getParameter("redirectUrl");
        if (redirectUrl != null && !redirectUrl.trim().isEmpty()) {
            response.sendRedirect(redirectUrl);
        } else {
            response.sendRedirect(request.getContextPath() + "/recommend/detail?id=" + id);
        }
    }

    // =============================================
    // HELPER METHODS
    // =============================================
    private int getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            return (int) session.getAttribute("userId");
        }
        return 1;
    }

    private void setFlashMessage(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("flashType", type);
        session.setAttribute("flashMessage", message);
    }

    private void transferFlashMessage(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String type = (String) session.getAttribute("flashType");
            String message = (String) session.getAttribute("flashMessage");
            if (message != null) {
                request.setAttribute("flashType", type);
                request.setAttribute("flashMessage", message);
                session.removeAttribute("flashType");
                session.removeAttribute("flashMessage");
            }
        }
    }

    private int parseId(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) return -1;
        try {
            return Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    private String trimOrNull(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        return value.trim();
    }

    private void handleRoleSimulation(HttpServletRequest request) {
        HttpSession session = request.getSession();
        String mockRole = request.getParameter("mockRole");
        
        if (mockRole != null) {
            if ("librarian".equalsIgnoreCase(mockRole)) {
                session.setAttribute("role", "Librarian");
                session.setAttribute("userId", 2);
                session.setAttribute("userName", "Lê Thị Đào");
            } else if ("admin".equalsIgnoreCase(mockRole)) {
                session.setAttribute("role", "Admin");
                session.setAttribute("userId", 1);
                session.setAttribute("userName", "Nguyễn Văn A");
            }
        }
        
        if (session.getAttribute("role") == null) {
            session.setAttribute("role", "Admin");
            session.setAttribute("userId", 1);
            session.setAttribute("userName", "Nguyễn Văn A");
        }
    }
}
