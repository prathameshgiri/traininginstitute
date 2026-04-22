package com.traininginstitute.servlet;

import com.traininginstitute.dao.AuditLogDAO;
import com.traininginstitute.dao.StudentDAO;
import com.traininginstitute.dao.UserDAO;
import com.traininginstitute.model.Student;
import com.traininginstitute.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import com.traininginstitute.util.DBConnection;

/**
 * LoginServlet - Handles authentication with HttpSession + single-session enforcement.
 * @author Dr. Geeta Mete
 */
@WebServlet(urlPatterns = {"/login", "/logout", "/register"})
public class LoginServlet extends HttpServlet {

    private UserDAO    userDAO;
    private StudentDAO studentDAO;
    private AuditLogDAO auditDAO;

    @Override
    public void init() {
        userDAO    = new UserDAO();
        studentDAO = new StudentDAO();
        auditDAO   = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();

        if ("/logout".equals(path)) {
            handleLogout(req, resp);
        } else if ("/register".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        } else {
            // Check if already logged in → redirect
            HttpSession session = req.getSession(false);
            if (session != null && session.getAttribute("user") != null) {
                User u = (User) session.getAttribute("user");
                redirectToDashboard(u, req, resp);
                return;
            }
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getServletPath();
        if ("/register".equals(path)) {
            handleRegister(req, resp);
        } else {
            handleLogin(req, resp);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String ip       = getClientIP(req);
        String ua       = req.getHeader("User-Agent");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Email and password are required.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userDAO.authenticate(email.trim(), password);

            if (user == null) {
                auditDAO.logAction(0, "Failed login attempt for: " + email,
                    "SECURITY_ALERT", ip, ua, null, "WARNING");
                req.setAttribute("error", "Invalid email or password.");
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                return;
            }


            // Invalidate old session and create new one
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) oldSession.invalidate();

            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setMaxInactiveInterval(30 * 60); // 30 min

            // Mark logged in + track session
            userDAO.setLoginStatus(user.getUserId(), true);
            auditDAO.createSession(session.getId(), user.getUserId(), ip, ua);
            auditDAO.logAction(user.getUserId(), "User logged in successfully",
                "LOGIN", ip, ua, session.getId(), "INFO");

            // Load student profile if student
            if (user.isStudent()) {
                Student student = studentDAO.findByUserId(user.getUserId());
                session.setAttribute("student", student);
            }

            redirectToDashboard(user, req, resp);

        } catch (SQLException e) {
            String msg = e.getMessage() != null ? e.getMessage() : "";
            String userMsg;
            if (msg.contains("Communications link failure") || msg.contains("Connection refused")
                    || msg.contains("10061") || msg.contains("Can't connect")) {
                userMsg = "Cannot reach database. Please ensure MySQL (XAMPP) is running and try again.";
            } else {
                userMsg = "Database error: " + msg;
            }
            getServletContext().log("[LoginServlet] SQLException: " + msg, e);
            req.setAttribute("error", userMsg);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String name     = req.getParameter("name");
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        String confirm  = req.getParameter("confirm_password");
        String course   = req.getParameter("course");
        String cgpaStr  = req.getParameter("cgpa");
        String phone    = req.getParameter("phone");
        String enrollment = req.getParameter("enrollment_number");

        // Validation
        if (name == null || email == null || password == null || course == null || cgpaStr == null) {
            req.setAttribute("error", "All fields are required.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        if (password.length() < 8) {
            req.setAttribute("error", "Password must be at least 8 characters.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            return;
        }

        Connection conn = null;
        try {
            // Check duplicate email
            if (userDAO.emailExists(email.trim())) {
                req.setAttribute("error", "Email already registered.");
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                return;
            }

            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Create user
            User user = new User();
            user.setName(name.trim());
            user.setEmail(email.trim().toLowerCase());
            user.setPassword(password);
            user.setRole("STUDENT");

            int userId = userDAO.register(user);
            if (userId < 0) throw new SQLException("User creation failed.");

            // Create student profile
            Student student = new Student();
            student.setUserId(userId);
            student.setCourse(course.trim());
            student.setCgpa(Double.parseDouble(cgpaStr));
            student.setPhone(phone);
            student.setEnrollmentNumber(enrollment);
            student.setBatchYear(java.time.Year.now().getValue());

            studentDAO.createStudentProfile(conn, student);
            conn.commit();

            auditDAO.logAction(userId, "New student registered: " + email,
                "OTHER", getClientIP(req), req.getHeader("User-Agent"), null, "INFO");

            // Auto-login the new user
            user.setUserId(userId);
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", userId);
            session.setMaxInactiveInterval(30 * 60);

            userDAO.setLoginStatus(userId, true);
            auditDAO.createSession(session.getId(), userId, getClientIP(req), req.getHeader("User-Agent"));
            auditDAO.logAction(userId, "User auto-logged in post-registration", "LOGIN", getClientIP(req), req.getHeader("User-Agent"), session.getId(), "INFO");

            resp.sendRedirect(req.getContextPath() + "/student/dashboard");

        } catch (NumberFormatException e) {
            DBConnection.rollback(conn);
            req.setAttribute("error", "Invalid CGPA value.");
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        } catch (SQLException e) {
            DBConnection.rollback(conn);
            req.setAttribute("error", "Registration failed: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
        } finally {
            DBConnection.close(conn);
        }
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                try {
                    userDAO.setLoginStatus(user.getUserId(), false);
                    auditDAO.invalidateSession(session.getId());
                    auditDAO.logAction(user.getUserId(), "User logged out",
                        "LOGOUT", getClientIP(req), req.getHeader("User-Agent"), session.getId(), "INFO");
                } catch (SQLException e) { /* log but continue */ }
            }
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login?success=logged_out");
    }

    private void redirectToDashboard(User user, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String ctx = req.getContextPath();
        if (user.isAdmin())   resp.sendRedirect(ctx + "/admin/dashboard");
        else                  resp.sendRedirect(ctx + "/student/dashboard");
    }

    private String getClientIP(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty()) ip = req.getHeader("X-Real-IP");
        if (ip == null || ip.isEmpty()) ip = req.getRemoteAddr();
        return ip != null && ip.contains(",") ? ip.split(",")[0].trim() : ip;
    }
}
