package com.traininginstitute.filter;

import com.traininginstitute.dao.AuditLogDAO;
import com.traininginstitute.model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * AuthenticationFilter - Role-Based Access Control Filter.
 * Intercepts all requests, validates session, enforces role boundaries.
 * @author Dr. Geeta Mete
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    /** URLs that are publicly accessible without login */
    private static final Set<String> PUBLIC_URLS = new HashSet<>(Arrays.asList(
        "/login", "/register", "/index.jsp", "/login.jsp", "/register.jsp",
        "/error.jsp", "/about.jsp"
    ));

    /** URLs restricted to ADMIN role only */
    private static final Set<String> ADMIN_URLS = new HashSet<>(Arrays.asList(
        "/admin", "/admin/dashboard", "/admin/students", "/admin/companies",
        "/admin/internships", "/admin/applications", "/admin/exams",
        "/admin/questions", "/admin/reports", "/admin/audit-logs",
        "/admin/evaluate"
    ));

    /** URLs restricted to STUDENT role only */
    private static final Set<String> STUDENT_URLS = new HashSet<>(Arrays.asList(
        "/student/dashboard", "/student/profile", "/student/internships",
        "/student/applications", "/student/exam"
    ));

    private AuditLogDAO auditLogDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        auditLogDAO = new AuditLogDAO();
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();
        String path = uri.substring(contextPath.length());

        // Allow static resources (CSS, JS, images, fonts)
        if (path.startsWith("/assets/") || path.startsWith("/css/") ||
            path.startsWith("/js/") || path.startsWith("/images/") ||
            path.endsWith(".css") || path.endsWith(".js") ||
            path.endsWith(".png") || path.endsWith(".jpg") ||
            path.endsWith(".ico") || path.endsWith(".woff") ||
            path.endsWith(".woff2")) {
            chain.doFilter(request, response);
            return;
        }

        // Allow public URLs
        if (isPublicUrl(path)) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is logged in
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(contextPath + "/login?error=session_expired");
            return;
        }

        // Update session activity
        auditLogDAO.updateSessionActivity(session.getId());

        // Admin-only URL check
        if (isAdminUrl(path) && !user.isAdmin()) {
            resp.sendRedirect(contextPath + "/student/dashboard?error=access_denied");
            return;
        }

        // Student-only URL check
        if (isStudentUrl(path) && !user.isStudent()) {
            resp.sendRedirect(contextPath + "/admin/dashboard?error=access_denied");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}

    private boolean isPublicUrl(String path) {
        if (path.equals("/") || path.isEmpty()) return true;
        for (String pub : PUBLIC_URLS) {
            if (path.startsWith(pub)) return true;
        }
        return false;
    }

    private boolean isAdminUrl(String path) {
        for (String adminUrl : ADMIN_URLS) {
            if (path.startsWith(adminUrl)) return true;
        }
        return false;
    }

    private boolean isStudentUrl(String path) {
        for (String studentUrl : STUDENT_URLS) {
            if (path.startsWith(studentUrl)) return true;
        }
        return false;
    }
}
