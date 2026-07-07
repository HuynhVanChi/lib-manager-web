package book;

import categories.Category;
import categories.CategoryDAO;
import common.AuditLogger;
import common.DBConnection;
import com.google.gson.Gson;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/books")
public class BookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final BookDAO bookDAO = new BookDAO();
    private final BookCopyDAO bookCopyDAO = new BookCopyDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        // AJAX API: Lấy danh sách cuốn sách của một đầu sách dạng JSON (Giữ nguyên)
        if ("getCopies".equals(action)) {
            String bookIdStr = request.getParameter("bookId");
            if (bookIdStr != null) {
                try {
                    int bookId = Integer.parseInt(bookIdStr);
                    List<BookCopy> copies = bookCopyDAO.findCopiesByBookId(bookId);
                    response.setContentType("application/json");
                    response.getWriter().write(gson.toJson(copies));
                    return;
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
        }

        // 1. Chuyển hướng sang trang thêm đầu sách
        if ("add".equals(action)) {
            request.setAttribute("categoriesList", categoryDAO.findAllActive());
            request.getRequestDispatcher("/views/book/add.jsp").forward(request, response);
            return;
        }

        // 2. Chuyển hướng sang trang sửa đầu sách
        if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int bookId = Integer.parseInt(idStr);
                    Book book = bookDAO.findById(bookId);
                    if (book != null) {
                        request.setAttribute("book", book);
                        request.setAttribute("categoriesList", categoryDAO.findAllActive());
                        request.getRequestDispatcher("/views/book/edit.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
            setFlashMessage(request, "Không tìm thấy đầu sách cần sửa!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        // 3. Chuyển hướng sang trang chi tiết đầu sách
        if ("detail".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int bookId = Integer.parseInt(idStr);
                    Book book = bookDAO.findById(bookId);
                    if (book != null) {
                        List<BookCopy> copies = bookCopyDAO.findCopiesByBookId(bookId);

                        request.setAttribute("book", book);
                        request.setAttribute("copiesList", copies);

                        request.getRequestDispatcher("/views/book/detail.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
            setFlashMessage(request, "Không tìm thấy đầu sách!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        // 4. Chuyển hướng sang trang quản lý cuốn sách (bản sao)
        if ("copies".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int bookId = Integer.parseInt(idStr);
                    Book book = bookDAO.findById(bookId);
                    if (book != null) {
                        List<BookCopy> copies = bookCopyDAO.findCopiesByBookId(bookId);
                        request.setAttribute("book", book);
                        request.setAttribute("copiesList", copies);
                        request.getRequestDispatcher("/views/book/copies.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }
            setFlashMessage(request, "Không tìm thấy đầu sách!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        // 5. Hiển thị danh sách đầu sách (Mặc định)
        // Xử lý xóa bộ lọc
        if ("true".equals(request.getParameter("clearFilters"))) {
            request.getSession().removeAttribute("bookSearchQuery");
            request.getSession().removeAttribute("bookCategoryId");
        }

        // Lọc theo Request Parameter hoặc đọc từ Session (nếu request parameter là null)
        String query = request.getParameter("query");
        if (query != null) {
            request.getSession().setAttribute("bookSearchQuery", query.trim());
        } else {
            query = (String) request.getSession().getAttribute("bookSearchQuery");
        }

        String categoryIdStr = request.getParameter("categoryId");
        Integer categoryId = null;
        if (categoryIdStr != null) {
            if (!categoryIdStr.trim().isEmpty()) {
                try {
                    categoryId = Integer.parseInt(categoryIdStr);
                    request.getSession().setAttribute("bookCategoryId", categoryId);
                } catch (NumberFormatException e) {
                    request.getSession().removeAttribute("bookCategoryId");
                }
            } else {
                request.getSession().removeAttribute("bookCategoryId");
            }
        } else {
            categoryId = (Integer) request.getSession().getAttribute("bookCategoryId");
        }

        // Nạp dữ liệu thống kê đầu trang
        request.setAttribute("totalBooks", bookDAO.countTotalActiveBooks());
        request.setAttribute("totalCopies", bookDAO.countTotalBookCopies());
        request.setAttribute("availableCopies", bookDAO.countAvailableCopies());
        request.setAttribute("damagedOrLostCopies", bookDAO.countDamagedOrLostCopies());

        // Nạp danh sách đầu sách và danh mục
        request.setAttribute("booksList", bookDAO.findAllActive(query, categoryId));
        request.setAttribute("categoriesList", categoryDAO.findAllActive());
        
        // Giữ lại các bộ lọc đã chọn lên UI
        request.setAttribute("selectedQuery", query);
        request.setAttribute("selectedCategoryId", categoryId);

        request.getRequestDispatcher("/views/book/books.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            userId = 1; // Mặc định về thủ thư đầu tiên nếu chưa đăng nhập
        }

        if (action == null) {
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        try {
            switch (action) {
                case "insert":
                    handleInsertBook(request, response, userId);
                    break;
                case "update":
                    handleUpdateBook(request, response, userId);
                    break;
                case "delete":
                    handleDeleteBook(request, response, userId);
                    break;
                case "insertCopy":
                    handleInsertCopy(request, response, userId);
                    break;
                case "updateCopy":
                    handleUpdateCopy(request, response, userId);
                    break;
                case "deleteCopy":
                    handleDeleteCopy(request, response, userId);
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/books");
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("message", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            request.getSession().setAttribute("messageType", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
        }
    }

    // ==========================================
    // CÁC HÀM XỬ LÝ ĐẦU SÁCH (BOOKS CRUD)
    // ==========================================

    private void handleInsertBook(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String categoryIdStr = request.getParameter("categoryId");
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String publisher = request.getParameter("publisher");
        String publishYearStr = request.getParameter("publishYear");

        if (title == null || title.trim().isEmpty() || categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Tên sách và danh mục là bắt buộc!");
            request.setAttribute("categoriesList", categoryDAO.findAllActive());
            Book book = new Book();
            book.setTitle(title);
            book.setAuthor(author);
            book.setPublisher(publisher);
            request.setAttribute("book", book);
            try {
                request.getRequestDispatcher("/views/book/add.jsp").forward(request, response);
            } catch (ServletException e) {
                e.printStackTrace();
            }
            return;
        }

        Integer publishYear = null;
        if (publishYearStr != null && !publishYearStr.trim().isEmpty()) {
            try {
                publishYear = Integer.parseInt(publishYearStr.trim());
                if (publishYear <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Năm xuất bản phải là số nguyên dương!");
                request.setAttribute("categoriesList", categoryDAO.findAllActive());
                Book book = new Book();
                book.setCategoryId(Integer.parseInt(categoryIdStr));
                book.setTitle(title);
                book.setAuthor(author);
                book.setPublisher(publisher);
                request.setAttribute("book", book);
                try {
                    request.getRequestDispatcher("/views/book/add.jsp").forward(request, response);
                } catch (ServletException se) {
                    se.printStackTrace();
                }
                return;
            }
        }

        Book book = new Book();
        book.setCategoryId(Integer.parseInt(categoryIdStr));
        book.setTitle(title.trim());
        book.setAuthor(author != null ? author.trim() : "");
        book.setPublisher(publisher != null ? publisher.trim() : "");
        book.setPublishYear(publishYear);

        int newBookId = bookDAO.insert(book);
        if (newBookId > 0) {
            // Ghi log
            Map<String, Object> newValues = new HashMap<>();
            newValues.put("category_id", book.getCategoryId());
            newValues.put("title", book.getTitle());
            newValues.put("author", book.getAuthor());
            newValues.put("publisher", book.getPublisher());
            newValues.put("publish_year", book.getPublishYear());

            AuditLogger.log(userId, AuditLogger.ActionType.INSERT, "books", newBookId, null, newValues);

            setFlashMessage(request, "Thêm mới đầu sách thành công! Vui lòng nhập bản sao vật lý.", "success");
            // Redirect thẳng đến trang Quản lý cuốn sách con để thêm bản sao vật lý
            response.sendRedirect(request.getContextPath() + "/books?action=copies&id=" + newBookId);
        } else {
            setFlashMessage(request, "Thêm mới đầu sách thất bại!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
        }
    }

    private void handleUpdateBook(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String bookIdStr = request.getParameter("bookId");
        String categoryIdStr = request.getParameter("categoryId");
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String publisher = request.getParameter("publisher");
        String publishYearStr = request.getParameter("publishYear");

        if (bookIdStr == null || title == null || title.trim().isEmpty() || categoryIdStr == null || categoryIdStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Tên sách và danh mục là bắt buộc!");
            request.setAttribute("categoriesList", categoryDAO.findAllActive());
            Book book = new Book();
            if (bookIdStr != null) book.setBookId(Integer.parseInt(bookIdStr));
            book.setTitle(title);
            book.setAuthor(author);
            book.setPublisher(publisher);
            request.setAttribute("book", book);
            try {
                request.getRequestDispatcher("/views/book/edit.jsp").forward(request, response);
            } catch (ServletException e) {
                e.printStackTrace();
            }
            return;
        }

        int bookId = Integer.parseInt(bookIdStr);
        Book oldBook = bookDAO.findById(bookId);
        if (oldBook == null) {
            setFlashMessage(request, "Đầu sách không tồn tại hoặc đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        Integer publishYear = null;
        if (publishYearStr != null && !publishYearStr.trim().isEmpty()) {
            try {
                publishYear = Integer.parseInt(publishYearStr.trim());
                if (publishYear <= 0) {
                    throw new NumberFormatException();
                }
            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Năm xuất bản phải là số nguyên dương!");
                request.setAttribute("categoriesList", categoryDAO.findAllActive());
                Book book = new Book();
                book.setBookId(bookId);
                book.setCategoryId(Integer.parseInt(categoryIdStr));
                book.setTitle(title);
                book.setAuthor(author);
                book.setPublisher(publisher);
                request.setAttribute("book", book);
                try {
                    request.getRequestDispatcher("/views/book/edit.jsp").forward(request, response);
                } catch (ServletException se) {
                    se.printStackTrace();
                }
                return;
            }
        }

        Book book = new Book();
        book.setBookId(bookId);
        book.setCategoryId(Integer.parseInt(categoryIdStr));
        book.setTitle(title.trim());
        book.setAuthor(author != null ? author.trim() : "");
        book.setPublisher(publisher != null ? publisher.trim() : "");
        book.setPublishYear(publishYear);

        if (bookDAO.update(book)) {
            // Ghi log
            Map<String, Object> oldValues = new HashMap<>();
            oldValues.put("category_id", oldBook.getCategoryId());
            oldValues.put("title", oldBook.getTitle());
            oldValues.put("author", oldBook.getAuthor());
            oldValues.put("publisher", oldBook.getPublisher());
            oldValues.put("publish_year", oldBook.getPublishYear());

            Map<String, Object> newValues = new HashMap<>();
            newValues.put("category_id", book.getCategoryId());
            newValues.put("title", book.getTitle());
            newValues.put("author", book.getAuthor());
            newValues.put("publisher", book.getPublisher());
            newValues.put("publish_year", book.getPublishYear());

            AuditLogger.log(userId, AuditLogger.ActionType.UPDATE, "books", bookId, oldValues, newValues);

            setFlashMessage(request, "Cập nhật đầu sách thành công!", "success");
            // Redirect về trang xem chi tiết đầu sách vừa sửa
            response.sendRedirect(request.getContextPath() + "/books?action=detail&id=" + bookId);
        } else {
            setFlashMessage(request, "Cập nhật đầu sách thất bại!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
        }
    }

    private void handleDeleteBook(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String bookIdStr = request.getParameter("bookId");
        if (bookIdStr == null) {
            setFlashMessage(request, "Mã đầu sách không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        int bookId = Integer.parseInt(bookIdStr);
        Book oldBook = bookDAO.findById(bookId);
        if (oldBook == null) {
            setFlashMessage(request, "Đầu sách không tồn tại hoặc đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        try {
            // Thực hiện xóa mềm bắc cầu trong Transaction ở lớp DAO
            if (bookDAO.softDelete(bookId, userId)) {
                // Ghi log
                Map<String, Object> oldValues = new HashMap<>();
                oldValues.put("title", oldBook.getTitle());
                oldValues.put("author", oldBook.getAuthor());

                AuditLogger.log(userId, AuditLogger.ActionType.DELETE, "books", bookId, oldValues, null);

                setFlashMessage(request, "Xóa đầu sách và toàn bộ cuốn sách liên quan thành công!", "success");
            } else {
                setFlashMessage(request, "Xóa đầu sách thất bại!", "danger");
            }
        } catch (SQLException e) {
            // Bắt lỗi ràng buộc nghiệp vụ (ví dụ: có sách đang mượn)
            setFlashMessage(request, e.getMessage(), "danger");
        }
        response.sendRedirect(request.getContextPath() + "/books");
    }

    // ==========================================
    // CÁC HÀM XỬ LÝ CUỐN SÁCH CON (BOOK COPIES CRUD)
    // ==========================================

    private void handleInsertCopy(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String bookIdStr = request.getParameter("bookId");
        String locationShelf = request.getParameter("locationShelf");
        String quantityStr = request.getParameter("quantity");

        if (bookIdStr == null || locationShelf == null || locationShelf.trim().isEmpty() || quantityStr == null) {
            setFlashMessage(request, "Thông tin thêm cuốn sách không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        int bookId = Integer.parseInt(bookIdStr);
        int quantity = Integer.parseInt(quantityStr);

        Book book = bookDAO.findById(bookId);
        if (book == null) {
            setFlashMessage(request, "Đầu sách không tồn tại!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        // Tạo mã viết tắt 3 ký tự hoa từ tên sách (JWD, DSA, SDO...)
        String prefix = generateBookPrefix(book.getTitle());

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Sử dụng transaction để thêm hàng loạt an toàn

            // Truy vấn lấy mã vạch kế tiếp dạng chuỗi duy nhất một lần để tránh truy vấn lặp trong vòng for
            String startBarcode = bookCopyDAO.getNextBarcodeForBook(bookId, prefix);
            String[] parts = startBarcode.split("-");
            int seqNum = 1;
            if (parts.length >= 2) {
                try {
                    seqNum = Integer.parseInt(parts[parts.length - 1]);
                } catch (NumberFormatException e) {
                    // Ignore
                }
            }

            for (int i = 0; i < quantity; i++) {
                String barcode = String.format("%s-%03d", prefix, seqNum + i);
                
                BookCopy copy = new BookCopy();
                copy.setBookId(bookId);
                copy.setBarcode(barcode);
                copy.setStatus("Available");
                copy.setLocationShelf(locationShelf.trim());

                bookCopyDAO.insert(conn, copy);

                // Ghi audit log cho từng cuốn sách được tạo
                Map<String, Object> newValues = new HashMap<>();
                newValues.put("book_id", bookId);
                newValues.put("barcode", barcode);
                newValues.put("status", "Available");
                newValues.put("location_shelf", copy.getLocationShelf());

                // Sử dụng connection dùng chung cho log để roll back nếu lỗi
                AuditLogger.log(conn, userId, AuditLogger.ActionType.INSERT, "book_copies", 0, null, newValues);
            }

            conn.commit();
            setFlashMessage(request, "Đã thêm thành công " + quantity + " cuốn sách mới!", "success");
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            e.printStackTrace();
            setFlashMessage(request, "Thêm cuốn sách thất bại: " + e.getMessage(), "danger");
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }

        response.sendRedirect(request.getContextPath() + "/books?action=copies&id=" + bookId);
    }

    private void handleUpdateCopy(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String copyIdStr = request.getParameter("copyId");
        String locationShelf = request.getParameter("locationShelf");
        String status = request.getParameter("status");

        if (copyIdStr == null || locationShelf == null || locationShelf.trim().isEmpty() || status == null) {
            setFlashMessage(request, "Dữ liệu sửa cuốn sách không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        int copyId = Integer.parseInt(copyIdStr);
        BookCopy oldCopy = bookCopyDAO.findById(copyId);
        if (oldCopy == null) {
            setFlashMessage(request, "Cuốn sách không tồn tại hoặc đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        // TƯ DUY PHẢN BIỆN: Nếu trạng thái hiện tại là 'Borrowed' (đang mượn),
        // KHÔNG cho phép thủ thư đổi trạng thái thủ công thành cái khác để tránh lỗi đối soát.
        if ("Borrowed".equalsIgnoreCase(oldCopy.getStatus()) && !status.equalsIgnoreCase(oldCopy.getStatus())) {
            setFlashMessage(request, "Không thể chỉnh sửa trạng thái cuốn sách đang được độc giả mượn (để đảm bảo tính toàn vẹn của phiếu mượn)!", "danger");
            response.sendRedirect(request.getContextPath() + "/books?action=copies&id=" + oldCopy.getBookId());
            return;
        }

        // KHÔNG cho phép thủ thư tự ý đặt trạng thái thành 'Borrowed' thủ công từ màn hình này
        if (!"Borrowed".equalsIgnoreCase(oldCopy.getStatus()) && "Borrowed".equalsIgnoreCase(status)) {
            setFlashMessage(request, "Không thể chuyển trạng thái cuốn sách sang 'Borrowed' theo cách thủ công. Hành động này chỉ được thực hiện bởi chức năng Mượn sách!", "danger");
            response.sendRedirect(request.getContextPath() + "/books?action=copies&id=" + oldCopy.getBookId());
            return;
        }

        BookCopy copy = new BookCopy();
        copy.setCopyId(copyId);
        copy.setLocationShelf(locationShelf.trim());
        copy.setStatus(status);

        if (bookCopyDAO.update(copy)) {
            // Ghi log
            Map<String, Object> oldValues = new HashMap<>();
            oldValues.put("barcode", oldCopy.getBarcode());
            oldValues.put("status", oldCopy.getStatus());
            oldValues.put("location_shelf", oldCopy.getLocationShelf());

            Map<String, Object> newValues = new HashMap<>();
            newValues.put("barcode", oldCopy.getBarcode());
            newValues.put("status", status);
            newValues.put("location_shelf", locationShelf.trim());

            AuditLogger.log(userId, AuditLogger.ActionType.UPDATE, "book_copies", copyId, oldValues, newValues);

            setFlashMessage(request, "Cập nhật thông tin cuốn sách thành công!", "success");
        } else {
            setFlashMessage(request, "Cập nhật thông tin cuốn sách thất bại!", "danger");
        }

        response.sendRedirect(request.getContextPath() + "/books?action=copies&id=" + oldCopy.getBookId());
    }

    private void handleDeleteCopy(HttpServletRequest request, HttpServletResponse response, int userId)
            throws SQLException, IOException {
        String copyIdStr = request.getParameter("copyId");
        if (copyIdStr == null) {
            setFlashMessage(request, "Mã cuốn sách không hợp lệ!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        int copyId = Integer.parseInt(copyIdStr);
        BookCopy oldCopy = bookCopyDAO.findById(copyId);
        if (oldCopy == null) {
            setFlashMessage(request, "Cuốn sách không tồn tại hoặc đã bị xóa!", "danger");
            response.sendRedirect(request.getContextPath() + "/books");
            return;
        }

        try {
            if (bookCopyDAO.softDelete(copyId, userId)) {
                // Ghi log
                Map<String, Object> oldValues = new HashMap<>();
                oldValues.put("barcode", oldCopy.getBarcode());
                oldValues.put("status", oldCopy.getStatus());

                AuditLogger.log(userId, AuditLogger.ActionType.DELETE, "book_copies", copyId, oldValues, null);

                setFlashMessage(request, "Xóa cuốn sách thành công!", "success");
            } else {
                setFlashMessage(request, "Xóa cuốn sách thất bại!", "danger");
            }
        } catch (SQLException e) {
            // Bắt lỗi khi xóa sách đang mượn
            setFlashMessage(request, e.getMessage(), "danger");
        }

        response.sendRedirect(request.getContextPath() + "/books?action=copies&id=" + oldCopy.getBookId());
    }

    // ==========================================
    // CÁC PHƯƠNG THỨC TIỆN ÍCH
    // ==========================================

    private void setFlashMessage(HttpServletRequest request, String msg, String type) {
        request.getSession().setAttribute("message", msg);
        request.getSession().setAttribute("messageType", type);
    }

    /**
     * Thuật toán tự sinh mã viết tắt 3 ký tự chữ hoa từ tiêu đề đầu sách bất kỳ.
     */
    public static String generateBookPrefix(String title) {
        if (title == null || title.trim().isEmpty()) {
            return "BK";
        }
        
        // 1. Loại bỏ dấu tiếng Việt và chuyển sang chữ in hoa
        String normalized = removeAccents(title).toUpperCase();
        
        // 2. Chỉ giữ lại chữ cái, số và khoảng trắng
        normalized = normalized.replaceAll("[^A-Z0-9\\s]", "");
        
        // 3. Tách từ
        String[] words = normalized.trim().split("\\s+");
        StringBuilder prefix = new StringBuilder();
        
        // Nếu có từ 3 từ trở lên, lấy chữ cái đầu của 3 từ đầu
        if (words.length >= 3) {
            for (int i = 0; i < 3; i++) {
                if (!words[i].isEmpty()) {
                    prefix.append(words[i].charAt(0));
                }
            }
        } 
        // Nếu có 2 từ, lấy chữ cái đầu từ thứ nhất và 2 chữ cái đầu từ thứ hai
        else if (words.length == 2) {
            if (!words[0].isEmpty()) {
                prefix.append(words[0].charAt(0));
            }
            if (words[1].length() >= 2) {
                prefix.append(words[1].substring(0, 2));
            } else if (!words[1].isEmpty()) {
                prefix.append(words[1].charAt(0)).append("X");
            }
        } 
        // Nếu chỉ có 1 từ, lấy 3 ký tự đầu
        else if (words.length == 1) {
            String word = words[0];
            if (word.length() >= 3) {
                prefix.append(word.substring(0, 3));
            } else {
                prefix.append(word);
                while (prefix.length() < 3) {
                    prefix.append("X");
                }
            }
        }
        
        return prefix.toString();
    }

    private static String removeAccents(String text) {
        if (text == null) return "";
        String temp = java.text.Normalizer.normalize(text, java.text.Normalizer.Form.NFD);
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        return pattern.matcher(temp).replaceAll("")
                      .replace('Đ', 'D')
                      .replace('đ', 'd');
    }
}
