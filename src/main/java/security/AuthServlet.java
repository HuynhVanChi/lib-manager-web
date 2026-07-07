package security;

import java.io.IOException;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller xử lý Đăng nhập, Đăng xuất, Dashboard và CRUD Quản lý Tài khoản.
 * Tích hợp cả Servlet và Filter vào một lớp public duy nhất để tránh lỗi
 * NoSuchMethodException khi Tomcat khởi tạo Filter qua reflection.
 */
@WebServlet(urlPatterns = {"/login", "/logout", "/accounts", "/dashboard"})
@WebFilter(urlPatterns = "/*")
public class AuthServlet extends HttpServlet implements Filter {

    private final TaiKhoanDAO dao = new TaiKhoanDAO();

    /** Constructor public mặc định bắt buộc cho Servlet/Filter. */
    public AuthServlet() {
        super();
    }

    // =========================================================================
    // FILTER: Phân quyền và chặn truy cập trái phép
    // =========================================================================
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse res  = (HttpServletResponse) response;
        HttpSession session      = req.getSession(false);

        String contextPath = req.getContextPath();
        String path        = req.getRequestURI().substring(contextPath.length());

        // Cho phép tài nguyên tĩnh và trang đăng nhập đi thẳng
        if (path.startsWith("/assets/") || path.equals("/login")) {
            chain.doFilter(request, response);
            return;
        }

        TaiKhoan currentUser = (session != null)
                ? (TaiKhoan) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            // Chưa đăng nhập → về trang login
            res.sendRedirect(contextPath + "/login");
            return;
        }

        // Đã đăng nhập mà vào lại /login → vào accounts
        if (path.equals("/login")) {
            res.sendRedirect(contextPath + "/accounts");
            return;
        }

        // Nếu là Admin truy cập trang chủ / hoặc /index.jsp trực tiếp -> chuyển hướng về /accounts để lấy DB
        if ("Admin".equalsIgnoreCase(currentUser.getRole())) {
            if (path.equals("/index.jsp") || path.equals("/")) {
                res.sendRedirect(contextPath + "/accounts");
                return;
            }
        }

        // Chặn Staff truy cập trang quản lý nhân sự, trang chủ / hoặc /index.jsp và audit log
        if ((path.equals("/accounts") || path.equals("/index.jsp") || path.equals("/") || path.startsWith("/AuditLogs"))
                && !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            req.setAttribute("errorCode", "403");
            req.setAttribute("errorMessage", "Tài khoản Thủ thư không có quyền truy cập trang này.");
            req.getRequestDispatcher("/views/security/error.jsp").forward(req, res);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}

    // =========================================================================
    // SERVLET: Điều phối GET và POST
    // =========================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        switch (req.getServletPath()) {
            case "/login":    showLogin(req, res);    break;
            case "/logout":   handleLogout(req, res); break;
            case "/dashboard":
                res.sendRedirect(req.getContextPath() + "/accounts");
                break;
            case "/accounts": showAccounts(req, res); break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        switch (req.getServletPath()) {
            case "/login":    handleLogin(req, res);    break;
            case "/accounts": handleAccountPost(req, res); break;
        }
    }

    // =========================================================================
    // GET /login  – hiển thị form đăng nhập
    // =========================================================================
    private void showLogin(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        // Nếu đã đăng nhập, bỏ qua trang login
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            res.sendRedirect(req.getContextPath() + "/accounts");
            return;
        }
        req.getRequestDispatcher("/views/security/login.jsp").forward(req, res);
    }

    // =========================================================================
    // POST /login – xử lý đăng nhập
    // =========================================================================
    private void handleLogin(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            req.setAttribute("loginError", "Vui lòng nhập đầy đủ tên tài khoản và mật khẩu.");
            req.getRequestDispatcher("/views/security/login.jsp").forward(req, res);
            return;
        }

        TaiKhoan user = dao.checkLogin(username.trim(), password);
        if (user != null) {
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", user);
            res.sendRedirect(req.getContextPath() + "/accounts");
        } else {
            req.setAttribute("loginError", "Tên tài khoản hoặc mật khẩu không chính xác.");
            req.getRequestDispatcher("/views/security/login.jsp").forward(req, res);
        }
    }

    // =========================================================================
    // GET /logout – hủy phiên đăng nhập
    // =========================================================================
    private void handleLogout(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) session.invalidate();
        res.sendRedirect(req.getContextPath() + "/login");
    }

    // =========================================================================
    // GET /accounts – hiển thị danh sách tài khoản
    // =========================================================================
    private void showAccounts(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        String search     = req.getParameter("search");
        String roleFilter = req.getParameter("role");

        List<TaiKhoan> accounts = dao.getAll(search, roleFilter);
        req.setAttribute("accounts",   accounts);
        req.setAttribute("search",     search);
        req.setAttribute("roleFilter", roleFilter);

        // Chuyển thông báo toast từ session sang request rồi xóa đi
        HttpSession session = req.getSession(false);
        if (session != null) {
            req.setAttribute("toastMessage", session.getAttribute("toastMessage"));
            req.setAttribute("toastType",    session.getAttribute("toastType"));
            session.removeAttribute("toastMessage");
            session.removeAttribute("toastType");
        }

        req.getRequestDispatcher("/views/security/index.jsp").forward(req, res);
    }

    // =========================================================================
    // POST /accounts – xử lý CRUD (create / update / delete)
    // =========================================================================
    private void handleAccountPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session   = req.getSession(false);
        TaiKhoan currentUser  = (session != null)
                ? (TaiKhoan) session.getAttribute("currentUser") : null;
        int actorId = (currentUser != null) ? currentUser.getUserId() : 1;

        String action = req.getParameter("action");

        if ("create".equals(action)) {
            doCreate(req, res, session, actorId);
        } else if ("update".equals(action)) {
            doUpdate(req, res, session, actorId);
        } else if ("delete".equals(action)) {
            doDelete(req, res, session, actorId);
        } else {
            res.sendRedirect(req.getContextPath() + "/accounts");
        }
    }

    private void doCreate(HttpServletRequest req, HttpServletResponse res,
                          HttpSession session, int actorId) throws IOException {
        String username = trim(req.getParameter("username"));
        String password = req.getParameter("password");
        String fullName = trim(req.getParameter("fullName"));
        String role     = trim(req.getParameter("role"));

        if (username.isEmpty() || password == null || password.trim().isEmpty()
                || fullName.isEmpty() || role.isEmpty()) {
            setToast(session, "Vui lòng điền đầy đủ thông tin bắt buộc.", "danger");
            res.sendRedirect(req.getContextPath() + "/accounts");
            return;
        }
        if (dao.isUsernameExists(username, null)) {
            setToast(session, "Tên đăng nhập '" + username + "' đã được sử dụng.", "danger");
            res.sendRedirect(req.getContextPath() + "/accounts");
            return;
        }

        TaiKhoan tk = new TaiKhoan();
        tk.setUsername(username);
        tk.setPassword(password);
        tk.setFullName(fullName);
        tk.setRole(role);

        if (dao.insert(tk, actorId)) {
            setToast(session, "Thêm tài khoản thành công!", "success");
        } else {
            setToast(session, "Thêm tài khoản thất bại do lỗi hệ thống.", "danger");
        }
        res.sendRedirect(req.getContextPath() + "/accounts");
    }

    private void doUpdate(HttpServletRequest req, HttpServletResponse res,
                          HttpSession session, int actorId) throws IOException {
        String idStr    = req.getParameter("userId");
        String username = trim(req.getParameter("username"));
        String password = req.getParameter("password");
        String fullName = trim(req.getParameter("fullName"));
        String role     = trim(req.getParameter("role"));

        if (idStr == null || username.isEmpty() || fullName.isEmpty() || role.isEmpty()) {
            setToast(session, "Dữ liệu cập nhật không hợp lệ.", "danger");
            res.sendRedirect(req.getContextPath() + "/accounts");
            return;
        }

        int userId = Integer.parseInt(idStr);
        if (dao.isUsernameExists(username, userId)) {
            setToast(session, "Tên đăng nhập '" + username + "' đã được người khác sử dụng.", "danger");
            res.sendRedirect(req.getContextPath() + "/accounts");
            return;
        }

        TaiKhoan tk = new TaiKhoan();
        tk.setUserId(userId);
        tk.setUsername(username);
        tk.setPassword(password);
        tk.setFullName(fullName);
        tk.setRole(role);

        if (dao.update(tk, actorId)) {
            setToast(session, "Cập nhật tài khoản thành công!", "success");
        } else {
            setToast(session, "Cập nhật tài khoản thất bại.", "danger");
        }
        res.sendRedirect(req.getContextPath() + "/accounts");
    }

    private void doDelete(HttpServletRequest req, HttpServletResponse res,
                          HttpSession session, int actorId) throws IOException {
        String idStr = req.getParameter("userId");
        if (idStr != null) {
            int userId = Integer.parseInt(idStr);
            if (userId == actorId) {
                setToast(session, "Bạn không thể tự xóa tài khoản của chính mình!", "danger");
            } else if (dao.delete(userId, actorId)) {
                setToast(session, "Xóa tài khoản thành công!", "success");
            } else {
                setToast(session, "Xóa tài khoản thất bại.", "danger");
            }
        }
        res.sendRedirect(req.getContextPath() + "/accounts");
    }

    // =========================================================================
    // Helpers
    // =========================================================================
    private void setToast(HttpSession session, String message, String type) {
        if (session != null) {
            session.setAttribute("toastMessage", message);
            session.setAttribute("toastType",    type);
        }
    }

    private String trim(String s) {
        return (s != null) ? s.trim() : "";
    }
}
