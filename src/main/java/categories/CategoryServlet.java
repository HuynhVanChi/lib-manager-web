package categories;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import common.AuditLogger;

@WebServlet("/categories")
public class CategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        String showTrash = request.getParameter("trash");
        if ("true".equals(showTrash)) {
            List<Category> deletedList = categoryDAO.findAllDeleted();
            request.setAttribute("deletedCategories", deletedList);
            request.setAttribute("isTrashView", true);
        } else {
            List<Category> activeList = categoryDAO.findAllActive();
            request.setAttribute("activeCategories", activeList);
            request.setAttribute("isTrashView", false);
        }
        
        request.getRequestDispatcher("/views/categories/categories.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            userId = 1; // Fallback mặc định về nhân viên Admin (dữ liệu mẫu) nếu chưa đăng nhập
        }

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        try {
            switch (action) {
                case "insert":
                    handleInsert(request, response, userId);
                    break;
                case "update":
                    handleUpdate(request, response, userId);
                    break;
                case "delete":
                    handleDelete(request, response, userId);
                    break;
                case "restore":
                    handleRestore(request, response, userId);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/categories");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            request.getSession().setAttribute("messageType", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
        }
    }

    private void handleInsert(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String name = request.getParameter("name");
        String description = request.getParameter("description");

        if (name == null || name.trim().isEmpty()) {
            setFlashMessage(request, "Tên danh mục không được để trống!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        name = name.trim();

        // Kiểm tra trùng tên đang hoạt động
        if (categoryDAO.existsByName(name, null)) {
            setFlashMessage(request, "Tên danh mục '" + name + "' đã tồn tại và đang hoạt động!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        Category c = new Category();
        c.setName(name);
        c.setDescription(description);

        int newId = categoryDAO.insert(c);
        if (newId > 0) {
            // Ghi Audit Log
            Map<String, Object> newValues = new HashMap<>();
            newValues.put("name", name);
            newValues.put("description", description);

            AuditLogger.log(userId, AuditLogger.ActionType.INSERT, "categories", newId, null, newValues);
            
            setFlashMessage(request, "Thêm mới danh mục thành công!", "success");
        } else {
            setFlashMessage(request, "Thêm mới danh mục thất bại!", "danger");
        }
        
        response.sendRedirect(request.getContextPath() + "/categories");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String idStr = request.getParameter("categoryId");
        String name = request.getParameter("name");
        String description = request.getParameter("description");

        if (idStr == null || name == null || name.trim().isEmpty()) {
            setFlashMessage(request, "Thông tin cập nhật không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        int id = Integer.parseInt(idStr);
        name = name.trim();

        // Lấy dữ liệu cũ để ghi Audit Log
        Category oldCat = categoryDAO.findById(id);
        if (oldCat == null) {
            setFlashMessage(request, "Danh mục không tồn tại hoặc đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        // Kiểm tra trùng tên với danh mục khác
        if (categoryDAO.existsByName(name, id)) {
            setFlashMessage(request, "Tên danh mục '" + name + "' đã được sử dụng bởi danh mục khác!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        Category c = new Category();
        c.setCategoryId(id);
        c.setName(name);
        c.setDescription(description);

        if (categoryDAO.update(c)) {
            // Ghi Audit Log
            Map<String, Object> oldValues = new HashMap<>();
            oldValues.put("name", oldCat.getName());
            oldValues.put("description", oldCat.getDescription());

            Map<String, Object> newValues = new HashMap<>();
            newValues.put("name", name);
            newValues.put("description", description);

            AuditLogger.log(userId, AuditLogger.ActionType.UPDATE, "categories", id, oldValues, newValues);

            setFlashMessage(request, "Cập nhật danh mục thành công!", "success");
        } else {
            setFlashMessage(request, "Cập nhật danh mục thất bại!", "danger");
        }
        
        response.sendRedirect(request.getContextPath() + "/categories");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String idStr = request.getParameter("categoryId");
        if (idStr == null) {
            setFlashMessage(request, "Mã danh mục không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        int id = Integer.parseInt(idStr);

        // 1. Kiểm tra xem danh mục có sách đang hoạt động không (Ràng buộc nghiệp vụ)
        if (categoryDAO.hasActiveBooks(id)) {
            setFlashMessage(request, "Không thể xóa danh mục này vì đang chứa các đầu sách đang hoạt động!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        // Lấy dữ liệu cũ để ghi Audit Log
        Category oldCat = categoryDAO.findById(id);
        if (oldCat == null) {
            setFlashMessage(request, "Danh mục không tồn tại hoặc đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories");
            return;
        }

        if (categoryDAO.softDelete(id, userId)) {
            // Ghi Audit Log
            Map<String, Object> oldValues = new HashMap<>();
            oldValues.put("name", oldCat.getName());
            oldValues.put("description", oldCat.getDescription());

            AuditLogger.log(userId, AuditLogger.ActionType.DELETE, "categories", id, oldValues, null);

            setFlashMessage(request, "Xóa danh mục thành công!", "success");
        } else {
            setFlashMessage(request, "Xóa danh mục thất bại!", "danger");
        }
        
        response.sendRedirect(request.getContextPath() + "/categories");
    }

    private void handleRestore(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String idStr = request.getParameter("categoryId");
        if (idStr == null) {
            setFlashMessage(request, "Mã danh mục không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories?trash=true");
            return;
        }

        int id = Integer.parseInt(idStr);

        // Lấy danh mục cũ đã bị xóa mềm
        Category deletedCat = categoryDAO.findDeletedById(id);
        if (deletedCat == null) {
            setFlashMessage(request, "Không tìm thấy danh mục đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories?trash=true");
            return;
        }

        // Kiểm tra xem đã có danh mục nào đang hoạt động trùng tên chưa (Chặn trùng lặp khi khôi phục)
        if (categoryDAO.existsByName(deletedCat.getName(), null)) {
            setFlashMessage(request, "Không thể khôi phục vì đã có danh mục '" + deletedCat.getName() + "' khác đang hoạt động!", "danger");
            response.sendRedirect(request.getContextPath() + "/categories?trash=true");
            return;
        }

        if (categoryDAO.restore(id)) {
            // Ghi Audit Log
            Map<String, Object> newValues = new HashMap<>();
            newValues.put("name", deletedCat.getName());
            newValues.put("description", deletedCat.getDescription());

            AuditLogger.log(userId, AuditLogger.ActionType.RESTORE, "categories", id, null, newValues);

            setFlashMessage(request, "Khôi phục danh mục thành công!", "success");
        } else {
            setFlashMessage(request, "Khôi phục danh mục thất bại!", "danger");
        }
        
        response.sendRedirect(request.getContextPath() + "/categories");
    }

    private void setFlashMessage(HttpServletRequest request, String msg, String type) {
        request.getSession().setAttribute("message", msg);
        request.getSession().setAttribute("messageType", type);
    }
}