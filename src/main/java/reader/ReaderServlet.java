package reader;

import common.AuditLogger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller trung tâm xử lý toàn bộ request liên quan đến Quản lý Độc giả.
 * URL pattern: /readers/*
 * Phân nhánh theo pathInfo:
 *   GET  /readers          → Danh sách
 *   GET  /readers/add      → Form thêm mới
 *   POST /readers/add      → Xử lý thêm mới
 *   GET  /readers/edit     → Form chỉnh sửa
 *   POST /readers/edit     → Xử lý chỉnh sửa
 *   GET  /readers/detail   → Trang chi tiết
 *   POST /readers/delete   → Xóa mềm
 *   POST /readers/restore  → Khôi phục
 */
@WebServlet("/readers/*")
public class ReaderServlet extends HttpServlet {

    private final ReaderDAO dao = new ReaderDAO();
    private final ReaderService service = new ReaderService();

    // =============================================
    // GET — Phân nhánh theo pathInfo
    // =============================================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
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
                    response.sendRedirect(request.getContextPath() + "/readers");
            }
        }
    }

    // =============================================
    // POST — Phân nhánh theo pathInfo
    // =============================================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String path = request.getPathInfo();

        if (path == null) {
            response.sendRedirect(request.getContextPath() + "/readers");
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
                handleDelete(request, response);
                break;
            case "/restore":
                handleRestore(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/readers");
        }
    }


    // =============================================
    // 4.2 — GET /readers: Danh sách độc giả
    // =============================================

    private void handleList(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String search = request.getParameter("search");
        String statusFilter = request.getParameter("status");

        List<Reader> readers = dao.findAll(search, statusFilter);

        request.setAttribute("readers", readers);
        request.setAttribute("search", search);
        request.setAttribute("statusFilter", statusFilter);

        // Đọc flash message từ session (nếu có sau redirect)
        transferFlashMessage(request);

        request.getRequestDispatcher("/views/reader/list.jsp").forward(request, response);
    }


    // =============================================
    // 4.3 — GET /readers/add: Form thêm mới
    // =============================================

    private void handleAddForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // Nếu form bị lỗi và servlet forward lại, giữ nguyên reader object cũ
        if (request.getAttribute("reader") == null) {
            request.setAttribute("reader", new Reader());
        }

        request.getRequestDispatcher("/views/reader/add.jsp").forward(request, response);
    }


    // =============================================
    // 4.4 — POST /readers/add: Xử lý thêm mới
    // =============================================

    private void handleAddSubmit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // 1. Parse dữ liệu từ form vào đối tượng Reader
        Reader reader = parseFormData(request, 0);

        // 2. Validate nghiệp vụ
        ReaderService.ValidationResult result = service.validateForInsert(reader);

        if (!result.isValid()) {
            // Trả form về với lỗi inline — không redirect
            request.setAttribute("reader", reader);
            request.setAttribute("fieldErrors", result.toMap());
            request.getRequestDispatcher("/views/reader/add.jsp").forward(request, response);
            return;
        }

        // 3. Lưu vào DB
        int newReaderId = dao.insert(reader);

        if (newReaderId > 0) {
            // 4. Ghi Audit Log (INSERT — độc lập, không cần Transaction)
            Map<String, Object> newData = new HashMap<>();
            newData.put("full_name", reader.getFullName());
            newData.put("email", reader.getEmail());
            newData.put("phone", reader.getPhone());
            newData.put("status", reader.getStatus());
            newData.put("membership_expired_at",
                reader.getMembershipExpiredAt() != null ? reader.getMembershipExpiredAt().toString() : null);

            AuditLogger.log(
                getCurrentUserId(request),
                AuditLogger.ActionType.INSERT,
                "readers",
                newReaderId,
                null,
                newData
            );

            // 5. PRG Pattern: redirect về danh sách với flash message
            setFlashMessage(request, "success", "Đã thêm độc giả \"" + reader.getFullName() + "\" thành công.");
            response.sendRedirect(request.getContextPath() + "/readers");

        } else {
            // DB lỗi không xác định
            request.setAttribute("reader", reader);
            request.setAttribute("globalError", "Đã xảy ra lỗi khi lưu dữ liệu. Vui lòng thử lại.");
            request.getRequestDispatcher("/views/reader/add.jsp").forward(request, response);
        }
    }


    // =============================================
    // 4.5 — GET /readers/edit: Form chỉnh sửa
    // =============================================

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        int readerId = parseId(request.getParameter("id"));
        if (readerId <= 0) {
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        // Ưu tiên dùng reader đã có trong request (khi form bị lỗi và forward lại)
        if (request.getAttribute("reader") == null) {
            Reader reader = dao.findById(readerId);
            if (reader == null || reader.isDeleted()) {
                setFlashMessage(request, "error", "Không tìm thấy độc giả cần chỉnh sửa.");
                response.sendRedirect(request.getContextPath() + "/readers");
                return;
            }
            request.setAttribute("reader", reader);
        }

        request.getRequestDispatcher("/views/reader/edit.jsp").forward(request, response);
    }


    // =============================================
    // 4.6 — POST /readers/edit: Xử lý chỉnh sửa
    // =============================================

    private void handleEditSubmit(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        int readerId = parseId(request.getParameter("readerId"));
        if (readerId <= 0) {
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        // 1. Lấy dữ liệu cũ để ghi vào audit log
        Reader oldReader = dao.findById(readerId);
        if (oldReader == null || oldReader.isDeleted()) {
            setFlashMessage(request, "error", "Không tìm thấy độc giả cần chỉnh sửa.");
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        // 2. Parse dữ liệu mới từ form
        Reader updatedReader = parseFormData(request, readerId);

        // 3. Validate nghiệp vụ (loại trừ chính nó)
        ReaderService.ValidationResult result = service.validateForUpdate(updatedReader);

        if (!result.isValid()) {
            // Trả form về với lỗi inline
            request.setAttribute("reader", updatedReader);
            request.setAttribute("fieldErrors", result.toMap());
            // Giữ id trên URL để form action đúng
            request.getRequestDispatcher("/views/reader/edit.jsp").forward(request, response);
            return;
        }

        // 4. Cập nhật DB
        boolean updated = dao.update(updatedReader);

        if (updated) {
            // 5. Ghi Audit Log UPDATE
            Map<String, Object> oldData = new HashMap<>();
            oldData.put("full_name", oldReader.getFullName());
            oldData.put("email", oldReader.getEmail());
            oldData.put("phone", oldReader.getPhone());
            oldData.put("status", oldReader.getStatus());
            oldData.put("membership_expired_at",
                oldReader.getMembershipExpiredAt() != null ? oldReader.getMembershipExpiredAt().toString() : null);

            Map<String, Object> newData = new HashMap<>();
            newData.put("full_name", updatedReader.getFullName());
            newData.put("email", updatedReader.getEmail());
            newData.put("phone", updatedReader.getPhone());
            newData.put("status", updatedReader.getStatus());
            newData.put("membership_expired_at",
                updatedReader.getMembershipExpiredAt() != null ? updatedReader.getMembershipExpiredAt().toString() : null);

            AuditLogger.log(
                getCurrentUserId(request),
                AuditLogger.ActionType.UPDATE,
                "readers",
                readerId,
                oldData,
                newData
            );

            setFlashMessage(request, "success", "Đã cập nhật thông tin độc giả \"" + updatedReader.getFullName() + "\" thành công.");
            response.sendRedirect(request.getContextPath() + "/readers");

        } else {
            request.setAttribute("reader", updatedReader);
            request.setAttribute("globalError", "Đã xảy ra lỗi khi cập nhật. Vui lòng thử lại.");
            request.getRequestDispatcher("/views/reader/edit.jsp").forward(request, response);
        }
    }


    // =============================================
    // 4.7 — GET /readers/detail: Trang chi tiết
    // =============================================

    private void handleDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        int readerId = parseId(request.getParameter("id"));
        if (readerId <= 0) {
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        Reader reader = dao.findById(readerId);
        if (reader == null) {
            setFlashMessage(request, "error", "Không tìm thấy độc giả.");
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        Map<String, Object> stats = dao.getReaderStats(readerId);
        List<Map<String, Object>> borrowHistory = dao.getBorrowHistory(readerId);

        request.setAttribute("reader", reader);
        request.setAttribute("stats", stats);
        request.setAttribute("borrowHistory", borrowHistory);

        request.getRequestDispatcher("/views/reader/detail.jsp").forward(request, response);
    }


    // =============================================
    // 4.8 — POST /readers/delete: Xóa mềm
    // =============================================

    private void handleDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        int readerId = parseId(request.getParameter("readerId"));
        if (readerId <= 0) {
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        Reader reader = dao.findById(readerId);
        if (reader == null || reader.isDeleted()) {
            setFlashMessage(request, "error", "Không tìm thấy độc giả hoặc đã bị xóa.");
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        // Kiểm tra nghiệp vụ: không xóa nếu còn đang mượn sách
        if (!service.canDelete(readerId)) {
            setFlashMessage(request, "error",
                "Không thể xóa độc giả \"" + reader.getFullName() + "\" vì hiện đang có sách chưa trả.");
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        // Thực hiện xóa mềm
        boolean deleted = dao.softDelete(readerId, getCurrentUserId(request));

        if (deleted) {
            // Ghi Audit Log DELETE
            Map<String, Object> oldData = new HashMap<>();
            oldData.put("full_name", reader.getFullName());
            oldData.put("email", reader.getEmail());
            oldData.put("phone", reader.getPhone());
            oldData.put("status", reader.getStatus());

            AuditLogger.log(
                getCurrentUserId(request),
                AuditLogger.ActionType.DELETE,
                "readers",
                readerId,
                oldData,
                null
            );

            setFlashMessage(request, "success", "Đã xóa độc giả \"" + reader.getFullName() + "\" thành công.");
        } else {
            setFlashMessage(request, "error", "Đã xảy ra lỗi khi xóa. Vui lòng thử lại.");
        }

        response.sendRedirect(request.getContextPath() + "/readers");
    }


    // =============================================
    // 4.9 — POST /readers/restore: Khôi phục
    // =============================================

    private void handleRestore(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        int readerId = parseId(request.getParameter("readerId"));
        if (readerId <= 0) {
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        Reader reader = dao.findById(readerId);
        if (reader == null) {
            setFlashMessage(request, "error", "Không tìm thấy độc giả cần khôi phục.");
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        // Kiểm tra nghiệp vụ: email/phone không bị xung đột với active reader
        if (!service.canRestore(readerId)) {
            setFlashMessage(request, "error",
                "Không thể khôi phục độc giả \"" + reader.getFullName()
                + "\" vì email hoặc số điện thoại đã được sử dụng bởi độc giả khác.");
            response.sendRedirect(request.getContextPath() + "/readers");
            return;
        }

        boolean restored = dao.restore(readerId);

        if (restored) {
            // Ghi Audit Log RESTORE
            Map<String, Object> newData = new HashMap<>();
            newData.put("full_name", reader.getFullName());
            newData.put("email", reader.getEmail());
            newData.put("phone", reader.getPhone());
            newData.put("status", reader.getStatus());

            AuditLogger.log(
                getCurrentUserId(request),
                AuditLogger.ActionType.RESTORE,
                "readers",
                readerId,
                null,
                newData
            );

            setFlashMessage(request, "success", "Đã khôi phục độc giả \"" + reader.getFullName() + "\" thành công.");
        } else {
            setFlashMessage(request, "error", "Đã xảy ra lỗi khi khôi phục. Vui lòng thử lại.");
        }

        response.sendRedirect(request.getContextPath() + "/readers");
    }


    // =============================================
    // PRIVATE HELPERS — Tiện ích dùng chung trong Servlet
    // =============================================

    /**
     * Parse dữ liệu từ form HTTP request sang đối tượng Reader.
     * Tập trung tại một chỗ, tránh lặp code giữa handleAddSubmit và handleEditSubmit.
     *
     * @param request  HTTP request chứa form data
     * @param readerId 0 khi thêm mới, >0 khi chỉnh sửa
     * @return Reader đã được điền dữ liệu từ form
     */
    private Reader parseFormData(HttpServletRequest request, int readerId) {
        Reader reader = new Reader();
        reader.setReaderId(readerId);

        reader.setFullName(trimOrNull(request.getParameter("fullName")));
        reader.setEmail(trimOrNull(request.getParameter("email")));
        reader.setPhone(trimOrNull(request.getParameter("phone")));
        reader.setStatus(trimOrNull(request.getParameter("status")));

        // Parse hạn thẻ từ chuỗi "yyyy-MM-dd" của input type="date"
        String expiredAtStr = request.getParameter("membershipExpiredAt");
        if (expiredAtStr != null && !expiredAtStr.trim().isEmpty()) {
            try {
                // Thêm thời gian cuối ngày 23:59:59 cho trực quan
                reader.setMembershipExpiredAt(Timestamp.valueOf(expiredAtStr.trim() + " 23:59:59"));
            } catch (IllegalArgumentException e) {
                reader.setMembershipExpiredAt(null);
            }
        } else {
            reader.setMembershipExpiredAt(null);
        }

        return reader;
    }

    /**
     * Lấy user_id của thủ thư đang đăng nhập từ Session.
     * Nếu chưa có session (chưa implement login), trả về 1 (admin mặc định).
     *
     * @param request HTTP request
     * @return user_id của người đang đăng nhập
     */
    private int getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("userId") != null) {
            return (int) session.getAttribute("userId");
        }
        return 1; // Fallback: admin mặc định khi chưa implement session login
    }

    /**
     * Đặt flash message vào Session để đọc sau khi redirect (PRG Pattern).
     *
     * @param request HTTP request
     * @param type    "success" hoặc "error"
     * @param message Nội dung thông báo
     */
    private void setFlashMessage(HttpServletRequest request, String type, String message) {
        HttpSession session = request.getSession();
        session.setAttribute("flashType", type);
        session.setAttribute("flashMessage", message);
    }

    /**
     * Chuyển flash message từ Session sang Request attribute rồi xóa khỏi Session.
     * Gọi trước khi forward sang JSP để JSP đọc được.
     *
     * @param request HTTP request
     */
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

    /**
     * Parse an toàn chuỗi sang int, trả về -1 nếu lỗi.
     */
    private int parseId(String idStr) {
        if (idStr == null || idStr.trim().isEmpty()) return -1;
        try {
            return Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /**
     * Trim chuỗi, trả về null nếu rỗng sau trim.
     * Giúp lưu NULL vào DB thay vì chuỗi rỗng "" cho các trường không bắt buộc.
     */
    private String trimOrNull(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        return value.trim();
    }
}
