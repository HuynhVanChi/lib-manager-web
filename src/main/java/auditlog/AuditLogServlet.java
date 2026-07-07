package auditlog;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.Set;
import java.util.LinkedHashSet;
import java.lang.reflect.Type;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

/**
 * Controller xử lý luồng xem Nhật ký hệ thống.
 * URL Pattern: /AuditLogs (Dùng query parameter ?action=detail để chuyển hướng xem chi tiết)
 * Quyền truy cập: Chỉ Admin. (Cơ chế fallback tự động cấp Admin khi chưa đăng nhập).
 */
@WebServlet("/AuditLogs")
public class AuditLogServlet extends HttpServlet {

    private final AuditLogDAO dao = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1. Phân quyền truy cập (RBAC)
        HttpSession session = request.getSession(false);
        String role = (session != null) ? (String) session.getAttribute("role") : null;

        // Cơ chế FALLBACK: Nếu chưa đăng nhập (role == null), coi như là Admin để dễ test local
        if (role == null) {
            role = "Admin"; // TODO: Bỏ dòng này khi thành viên khác đã ráp xong module Login
        }

        // Chặn quyền nếu vai trò không phải Admin
        if (!"Admin".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập nhật ký hệ thống.");
            return;
        }

        // Phân nhánh dựa trên tham số action
        String action = request.getParameter("action");
        if ("detail".equals(action)) {
            handleDetail(request, response);
        } else {
            handleList(request, response);
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 2. Đọc bộ lọc tìm kiếm
        String search = request.getParameter("search");
        String actionFilter = request.getParameter("action"); // Tham số dropdown select name="action"
        String tableFilter = request.getParameter("table");

        // 3. Gọi DAO lấy danh sách (Giới hạn tối đa hiển thị 150 log mới nhất)
        List<AuditLog> logs = dao.findAll(search, actionFilter, tableFilter, 150);

        // 4. Đẩy dữ liệu ra giao diện JSP
        request.setAttribute("logs", logs);
        request.setAttribute("search", search);
        request.setAttribute("actionFilter", actionFilter);
        request.setAttribute("tableFilter", tableFilter);

        request.getRequestDispatcher("/views/auditlog/list.jsp").forward(request, response);
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/AuditLogs");
            return;
        }

        try {
            int id = Integer.parseInt(idStr);
            AuditLog log = dao.findById(id);
            if (log == null) {
                response.sendRedirect(request.getContextPath() + "/AuditLogs");
                return;
            }

            // Phân tích và đối sánh dữ liệu thay đổi ở phía Server (Java)
            List<LogFieldDiff> diffs = buildDiffList(log.getTableName(), log.getOldValues(), log.getNewValues());

            request.setAttribute("log", log);
            request.setAttribute("diffs", diffs);
            request.getRequestDispatcher("/views/auditlog/detail.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/AuditLogs");
        }
    }

    /**
     * Giải mã 2 chuỗi JSON cũ/mới và so sánh sự khác biệt theo từng trường thông tin.
     */
    private List<LogFieldDiff> buildDiffList(String tableName, String oldJson, String newJson) {
        List<LogFieldDiff> diffs = new ArrayList<>();
        Gson gson = new Gson();
        Type mapType = new TypeToken<Map<String, Object>>(){}.getType();

        Map<String, Object> oldMap = null;
        Map<String, Object> newMap = null;

        try {
            if (oldJson != null && !oldJson.trim().isEmpty() && !oldJson.equals("null")) {
                oldMap = gson.fromJson(oldJson, mapType);
            }
        } catch (Exception e) {
            System.err.println("[AuditLogServlet] Lỗi parse oldJson: " + e.getMessage());
        }

        try {
            if (newJson != null && !newJson.trim().isEmpty() && !newJson.equals("null")) {
                newMap = gson.fromJson(newJson, mapType);
            }
        } catch (Exception e) {
            System.err.println("[AuditLogServlet] Lỗi parse newJson: " + e.getMessage());
        }

        if (oldMap == null) oldMap = new HashMap<>();
        if (newMap == null) newMap = new HashMap<>();

        // Gom tất cả các keys độc nhất của 2 map
        Set<String> allKeys = new LinkedHashSet<>();
        allKeys.addAll(oldMap.keySet());
        allKeys.addAll(newMap.keySet());

        for (String key : allKeys) {
            // Loại bỏ các trường thông tin nội bộ của hệ thống
            if ("active_username".equals(key) || "active_email".equals(key) || "active_phone".equals(key)) {
                continue;
            }

            Object oldValObj = oldMap.get(key);
            Object newValObj = newMap.get(key);

            String oldValStr = formatValue(oldValObj);
            String newValStr = formatValue(newValObj);

            boolean isChanged = !oldValStr.equals(newValStr);
            String friendlyName = translateFieldKey(tableName, key);

            diffs.add(new LogFieldDiff(key, friendlyName, oldValStr, newValStr, isChanged));
        }

        return diffs;
    }

    /**
     * Định dạng dữ liệu thô từ JSON sang chuỗi thân thiện người dùng
     */
    private String formatValue(Object val) {
        if (val == null) return "—";
        
        // Chuẩn hóa kiểu Double trả về bởi Gson của số nguyên
        if (val instanceof Double) {
            Double d = (Double) val;
            if (d == d.longValue()) {
                return String.valueOf(d.longValue());
            }
            return String.valueOf(d);
        }
        
        String valStr = val.toString().trim();
        if (valStr.isEmpty() || "null".equals(valStr)) return "—";

        // Dịch các trạng thái chuẩn tiếng Anh sang Tiếng Việt
        switch (valStr) {
            case "Active": return "Hoạt động";
            case "Suspended": return "Bị tạm đình chỉ";
            case "Expired": return "Hết hạn";
            case "Available": return "Có sẵn";
            case "Borrowed": return "Đang mượn";
            case "Damaged": return "Hỏng";
            case "Lost": return "Mất";
            default: return valStr;
        }
    }

    /**
     * Dịch tên thuộc tính DB thô sang Tiếng Việt
     */
    private String translateFieldKey(String table, String key) {
        Map<String, String> general = new HashMap<>();
        general.put("created_at", "Ngày tạo");
        general.put("updated_at", "Ngày cập nhật");
        general.put("deleted_at", "Ngày xóa");
        general.put("deleted_by", "Người xóa");

        if (general.containsKey(key)) return general.get(key);

        if ("readers".equals(table)) {
            Map<String, String> m = new HashMap<>();
            m.put("reader_id", "Mã độc giả");
            m.put("full_name", "Họ và tên");
            m.put("phone", "Số điện thoại");
            m.put("email", "Email");
            m.put("membership_expired_at", "Ngày hết hạn thẻ");
            m.put("status", "Trạng thái");
            if (m.containsKey(key)) return m.get(key);
        } else if ("books".equals(table)) {
            Map<String, String> m = new HashMap<>();
            m.put("book_id", "Mã sách");
            m.put("category_id", "Mã danh mục");
            m.put("title", "Tiêu đề sách");
            m.put("author", "Tác giả");
            m.put("publisher", "Nhà xuất bản");
            m.put("publish_year", "Năm xuất bản");
            if (m.containsKey(key)) return m.get(key);
        } else if ("book_copies".equals(table)) {
            Map<String, String> m = new HashMap<>();
            m.put("copy_id", "Mã bản sao");
            m.put("book_id", "Mã đầu sách");
            m.put("barcode", "Mã vạch (Barcode)");
            m.put("status", "Trạng thái bản sao");
            m.put("location_shelf", "Vị trí kệ");
            if (m.containsKey(key)) return m.get(key);
        } else if ("fines".equals(table)) {
            Map<String, String> m = new HashMap<>();
            m.put("fine_id", "Mã phí phạt");
            m.put("borrow_detail_id", "Mã chi tiết mượn");
            m.put("amount", "Số tiền phạt");
            m.put("reason", "Lý do phạt");
            m.put("status", "Trạng thái thanh toán");
            m.put("paid_at", "Ngày đóng phạt");
            m.put("received_by", "Người thu tiền");
            if (m.containsKey(key)) return m.get(key);
        } else if ("borrow_records".equals(table)) {
            Map<String, String> m = new HashMap<>();
            m.put("borrow_record_id", "Mã phiếu mượn");
            m.put("reader_id", "Mã độc giả");
            m.put("user_id", "Mã nhân viên");
            if (m.containsKey(key)) return m.get(key);
        } else if ("borrow_details".equals(table)) {
            Map<String, String> m = new HashMap<>();
            m.put("borrow_detail_id", "Mã chi tiết");
            m.put("borrow_record_id", "Mã phiếu mượn");
            m.put("copy_id", "Mã bản sao");
            m.put("borrow_date", "Ngày mượn");
            m.put("due_date", "Hạn trả");
            m.put("return_date", "Ngày thực trả");
            m.put("status", "Trạng thái mượn");
            if (m.containsKey(key)) return m.get(key);
        }

        return key;
    }
}
