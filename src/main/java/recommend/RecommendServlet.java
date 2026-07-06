package recommend;

import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Controller chính xử lý hệ thống gợi ý sách (Book Recommendation).
 * Ánh xạ tới hai đường dẫn /recommends và /recommend để tương thích tối đa.
 * Hỗ trợ:
 * 1. GET /recommends: Trả về trang JSP và tải trước toàn bộ sách phục vụ chức năng tìm kiếm.
 * 2. GET /recommends?action=api&type=[loại_gợi_ý]&bookId=[id_sách_đang_xem]: Trả về kết quả gợi ý dạng JSON.
 */
@WebServlet(name = "RecommendServlet", urlPatterns = {"/recommends", "/recommend"})
public class RecommendServlet extends HttpServlet {
    private final RecommendDAO recommendDAO = new RecommendDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if ("api".equalsIgnoreCase(action)) {
            handleAPIRequest(request, response);
        } else {
            handleHTMLRequest(request, response);
        }
    }

    /**
     * Tải trước toàn bộ danh mục sách và forward tới trang JSP giao diện.
     */
    private void handleHTMLRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            List<BookDTO> allBooks = recommendDAO.getAllBooks();
            request.setAttribute("allBooks", allBooks);
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Không thể nạp danh sách sách: " + e.getMessage());
        }
        request.getRequestDispatcher("/views/recommend/index.jsp").forward(request, response);
    }

    /**
     * API xử lý yêu cầu AJAX trả về danh sách sách gợi ý tương ứng dưới dạng JSON.
     */
    private void handleAPIRequest(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String type = request.getParameter("type");
        String bookIdParam = request.getParameter("bookId");
        String limitParam = request.getParameter("limit");
        
        int bookId = 0;
        int limit = 6; // Giới hạn mặc định hiển thị 6 cuốn sách trên một hàng/lưới
        
        if (bookIdParam != null && !bookIdParam.trim().isEmpty()) {
            try {
                bookId = Integer.parseInt(bookIdParam);
            } catch (NumberFormatException e) {
                // Bỏ qua lỗi định dạng và giữ mặc định
            }
        }
        
        if (limitParam != null && !limitParam.trim().isEmpty()) {
            try {
                limit = Integer.parseInt(limitParam);
            } catch (NumberFormatException e) {
                // Bỏ qua lỗi định dạng và giữ mặc định
            }
        }

        try (PrintWriter out = response.getWriter()) {
            List<BookDTO> recommendations = new ArrayList<>();
            
            if (type == null || type.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"success\": false, \"message\": \"Thiếu tham số 'type' xác định cơ chế gợi ý.\"}");
                return;
            }
            
            switch (type.toLowerCase()) {
                case "popular":
                    recommendations = recommendDAO.getPopularBooks(limit);
                    break;
                case "newest":
                    recommendations = recommendDAO.getNewestBooks(limit);
                    break;
                case "recent":
                    recommendations = recommendDAO.getRecentlyBorrowedBooks(limit);
                    break;
                case "random":
                    recommendations = recommendDAO.getRandomBooks(limit);
                    break;
                case "same-category":
                    if (bookId > 0) {
                        recommendations = recommendDAO.getBooksBySameCategory(bookId, limit);
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"success\": false, \"message\": \"Thiếu tham số 'bookId' cho cơ chế gợi ý cùng thể loại.\"}");
                        return;
                    }
                    break;
                case "same-author":
                    if (bookId > 0) {
                        recommendations = recommendDAO.getBooksBySameAuthor(bookId, limit);
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"success\": false, \"message\": \"Thiếu tham số 'bookId' cho cơ chế gợi ý cùng tác giả.\"}");
                        return;
                    }
                    break;
                case "content-based":
                    if (bookId > 0) {
                        recommendations = recommendDAO.getContentBasedRecommendations(bookId, limit);
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"success\": false, \"message\": \"Thiếu tham số 'bookId' cho cơ chế gợi ý Content-based.\"}");
                        return;
                    }
                    break;
                case "hybrid":
                    if (bookId > 0) {
                        recommendations = recommendDAO.getHybridRecommendations(bookId, limit);
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        out.print("{\"success\": false, \"message\": \"Thiếu tham số 'bookId' cho cơ chế gợi ý Hybrid.\"}");
                        return;
                    }
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"success\": false, \"message\": \"Cơ chế gợi ý '" + type + "' không được hỗ trợ.\"}");
                    return;
            }
            
            // Trả về kết quả JSON thành công
            out.print(gson.toJson(recommendations));
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\": false, \"message\": \"Lỗi truy vấn database: " + e.getMessage() + "\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"success\": false, \"message\": \"Lỗi hệ thống: " + e.getMessage() + "\"}");
            }
        }
    }
}
