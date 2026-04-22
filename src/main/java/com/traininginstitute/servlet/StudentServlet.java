package com.traininginstitute.servlet;

import com.traininginstitute.dao.*;
import com.traininginstitute.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;

/**
 * StudentServlet - Student Module Controller.
 * Handles dashboard, profile, internship browsing, and applications.
 * @author Dr. Geeta Mete
 */
@WebServlet("/student/*")
public class StudentServlet extends HttpServlet {

    private StudentDAO    studentDAO;
    private CompanyDAO    companyDAO;
    private ApplicationDAO appDAO;
    private ExamDAO        examDAO;
    private AuditLogDAO    auditDAO;

    @Override
    public void init() {
        studentDAO = new StudentDAO();
        companyDAO = new CompanyDAO();
        appDAO     = new ApplicationDAO();
        examDAO    = new ExamDAO();
        auditDAO   = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null) info = "/dashboard";

        switch (info) {
            case "/dashboard":    showDashboard(req, resp);    break;
            case "/profile":      showProfile(req, resp);      break;
            case "/internships":  showInternships(req, resp);  break;
            case "/applications": showApplications(req, resp); break;
            case "/results":      showResults(req, resp);      break;
            default:
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null) info = "";

        switch (info) {
            case "/profile/update":    updateProfile(req, resp);    break;
            case "/internships/apply": applyInternship(req, resp);  break;
            default:
                resp.sendRedirect(req.getContextPath() + "/student/dashboard");
        }
    }

    // ================================================================
    // DASHBOARD
    // ================================================================
    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        try {
            Student student = studentDAO.findByUserId(user.getUserId());
            req.setAttribute("student", student);
            req.setAttribute("myApplications", appDAO.getByStudentId(student.getStudentId()));
            req.setAttribute("openInternships", companyDAO.getOpenInternships());
            req.getRequestDispatcher("/WEB-INF/views/student/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // PROFILE
    // ================================================================
    private void showProfile(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        try {
            Student student = studentDAO.findByUserId(user.getUserId());
            req.setAttribute("student", student);
            req.getRequestDispatcher("/WEB-INF/views/student/profile.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        User user = getUser(req);
        try {
            Student student = studentDAO.findByUserId(user.getUserId());
            student.setCourse(req.getParameter("course"));
            student.setPhone(req.getParameter("phone"));
            student.setAddress(req.getParameter("address"));
            student.setSkills(req.getParameter("skills"));
            studentDAO.updateProfile(student);
            auditDAO.logAction(user.getUserId(), "Profile updated",
                "PROFILE_UPDATE", getClientIP(req), req.getHeader("User-Agent"),
                req.getSession().getId(), "INFO");
            resp.sendRedirect(req.getContextPath() + "/student/profile?success=updated");
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // INTERNSHIPS
    // ================================================================
    private void showInternships(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        try {
            Student student = studentDAO.findByUserId(user.getUserId());
            req.setAttribute("student", student);
            req.setAttribute("internships",
                companyDAO.getEligibleInternships(student.getCgpa(), student.getStudentId()));
            req.getRequestDispatcher("/WEB-INF/views/student/internships.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void applyInternship(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        User user = getUser(req);
        try {
            Student student = studentDAO.findByUserId(user.getUserId());
            int internshipId = Integer.parseInt(req.getParameter("internship_id"));
            String coverLetter = req.getParameter("cover_letter");

            String result = appDAO.applyForInternship(student.getStudentId(), internshipId, coverLetter);

            if (result.startsWith("SUCCESS")) {
                auditDAO.logAction(user.getUserId(), "Applied for internship #" + internshipId,
                    "APPLICATION", getClientIP(req), req.getHeader("User-Agent"),
                    req.getSession().getId(), "INFO");
                resp.sendRedirect(req.getContextPath() + "/student/applications?success=applied");
            } else if ("DUPLICATE".equals(result)) {
                resp.sendRedirect(req.getContextPath() + "/student/internships?error=already_applied");
            } else if ("EXPIRED".equals(result)) {
                resp.sendRedirect(req.getContextPath() + "/student/internships?error=deadline_passed");
            } else if (result.startsWith("INELIGIBLE")) {
                resp.sendRedirect(req.getContextPath() + "/student/internships?error=cgpa_low");
            } else {
                resp.sendRedirect(req.getContextPath() + "/student/internships?error=apply_failed");
            }
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/student/internships?error=" + e.getMessage());
        }
    }

    // ================================================================
    // APPLICATIONS
    // ================================================================
    private void showApplications(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        try {
            Student student = studentDAO.findByUserId(user.getUserId());
            req.setAttribute("applications", appDAO.getByStudentId(student.getStudentId()));
            req.getRequestDispatcher("/WEB-INF/views/student/applications.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // RESULTS
    // ================================================================
    private void showResults(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            // Show exam results for the logged-in student
            req.setAttribute("exams", examDAO.getAllExams());
            req.getRequestDispatcher("/WEB-INF/views/student/results.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private User getUser(HttpServletRequest req) {
        return (User) req.getSession().getAttribute("user");
    }

    private void forwardError(HttpServletRequest req, HttpServletResponse resp, Exception e)
            throws ServletException, IOException {
        req.setAttribute("error", e.getMessage());
        req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
    }

    private String getClientIP(HttpServletRequest req) {
        String ip = req.getHeader("X-Forwarded-For");
        if (ip == null) ip = req.getRemoteAddr();
        return ip;
    }
}
