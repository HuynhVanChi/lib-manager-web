package borrowtereturn;

import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/borrow-return/*")
public class BorrowReturnServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final BorrowReturnDAO dao = new BorrowReturnDAO();
    private final BorrowReturnService service = new BorrowReturnService();

    @Override
    public void init() throws ServletException {
        dao.initDb();
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

        try {
            borrowList = dao.getBorrowList();
            fineList = dao.getFineList();

            // Process overdue logic for borrowing items on the fly
            for (Map<String, Object> map : borrowList) {
                String detailStatus = (String) map.get("status");
                Date dueDate = (Date) map.get("due_date");
                if ("Borrowing".equals(detailStatus) && dueDate != null) {
                    LocalDate today = LocalDate.now();
                    LocalDate due = dueDate.toLocalDate();
                    if (today.isAfter(due)) {
                        detailStatus = "Overdue";
                    }
                }
                map.put("status", detailStatus);
            }
        } catch (Exception e) {
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

        try {
            readerList = dao.getActiveReaders();
            availableCopies = dao.getAvailableCopies();
        } catch (Exception e) {
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

        try {
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
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleBorrow(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int readerId = Integer.parseInt(request.getParameter("readerId"));
        int copyId = Integer.parseInt(request.getParameter("copyId"));
        int durationDays = Integer.parseInt(request.getParameter("durationDays"));

        try {
            service.borrowBook(readerId, copyId, durationDays, userId);
            request.getSession().setAttribute("successMsg", "Đã mượn sách thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleReturn(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int borrowDetailId = Integer.parseInt(request.getParameter("borrowDetailId"));
        String bookCondition = request.getParameter("bookCondition");
        String notes = request.getParameter("notes");

        try {
            service.returnBook(borrowDetailId, bookCondition, notes, userId);
            request.getSession().setAttribute("successMsg", "Đã trả sách thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleLost(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int borrowDetailId = Integer.parseInt(request.getParameter("borrowDetailId"));
        try {
            service.reportLostBook(borrowDetailId, userId);
            request.getSession().setAttribute("successMsg", "Đã báo mất sách thành công! Đã tạo khoản phí phạt mất sách.");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }
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

        try {
            service.payFine(fineId, discountRate, userId);
            request.getSession().setAttribute("successMsg", "Thanh toán phí phạt thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }

    private void handleWaiveFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));
        try {
            service.waiveFine(fineId, userId);
            request.getSession().setAttribute("successMsg", "Đã miễn giảm phí phạt thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }

    private void handleUndoFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int fineId = Integer.parseInt(request.getParameter("fineId"));
        String undoReason = request.getParameter("undoReason");

        try {
            service.undoFine(fineId, undoReason, userId);
            request.getSession().setAttribute("successMsg", "Đã hoàn tác trạng thái khoản phạt thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi hoàn tác: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }

    private void handleDeleteBorrow(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            service.deleteBorrow(id, userId);
            request.getSession().setAttribute("successMsg", "Xóa phiếu mượn thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi khi xóa phiếu mượn: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleDeleteFine(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            service.deleteFine(id, userId);
            request.getSession().setAttribute("successMsg", "Xóa khoản phạt thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Lỗi khi xóa khoản phạt: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            Map<String, Object> item = dao.findBorrowDetailById(id);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/borrow-return");
                return;
            }
            List<Map<String, Object>> fines = dao.findFinesByBorrowDetailId(id);
            request.setAttribute("item", item);
            request.setAttribute("fines", fines);
            request.getRequestDispatcher("/views/borrowtereturn/detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            Map<String, Object> item = dao.findBorrowDetailById(id);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/borrow-return");
                return;
            }
            request.setAttribute("item", item);
            request.getRequestDispatcher("/views/borrowtereturn/edit.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
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

        try {
            service.updateBorrowDetail(id, borrowDateStr, dueDateStr, returnDateStr, status, bookCondition, notes, userId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return");
    }

    private void handleFineDetail(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            Map<String, Object> item = dao.findFineById(id);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/borrow-return");
                return;
            }
            request.setAttribute("item", item);
            request.getRequestDispatcher("/views/borrowtereturn/fine-detail.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleFineEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        try {
            Map<String, Object> item = dao.findFineById(id);
            if (item == null) {
                response.sendRedirect(request.getContextPath() + "/borrow-return");
                return;
            }
            request.setAttribute("item", item);
            request.getRequestDispatcher("/views/borrowtereturn/fine-edit.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/borrow-return");
        }
    }

    private void handleFineEditSubmit(HttpServletRequest request, HttpServletResponse response, int userId) 
            throws IOException {
        int id = Integer.parseInt(request.getParameter("fineId"));
        double amount = Double.parseDouble(request.getParameter("amount"));
        String[] reasons = request.getParameterValues("reason");
        String status = request.getParameter("status");
        String paidAtStr = request.getParameter("paidAt");

        try {
            service.updateFineDetails(id, amount, reasons, status, paidAtStr, userId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.sendRedirect(request.getContextPath() + "/borrow-return?tab=fines");
    }
}
