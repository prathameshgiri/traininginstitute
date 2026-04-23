package com.traininginstitute.servlet;

import com.traininginstitute.dao.*;
import com.traininginstitute.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * AdminDashboardServlet - Central Admin Controller.
 * Handles all admin sub-module routing using path-based dispatch.
 * @author Dr. Geeta Mete
 */
@WebServlet("/admin/*")
public class AdminDashboardServlet extends HttpServlet {


    private StudentDAO    studentDAO;
    private CompanyDAO    companyDAO;
    private ApplicationDAO appDAO;
    private ExamDAO       examDAO;
    private AuditLogDAO   auditDAO;

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
            case "/dashboard":  showDashboard(req, resp);      break;
            case "/students":   showStudents(req, resp);       break;
            case "/companies":  showCompanies(req, resp);      break;
            case "/internships": showInternships(req, resp);   break;
            case "/applications": showApplications(req, resp); break;
            case "/exams":      showExams(req, resp);          break;
            case "/exams/questions": showExamQuestions(req, resp); break;
            case "/reports":    showReports(req, resp);        break;
            case "/audit-logs": showAuditLogs(req, resp);      break;
            case "/evaluate":   showEvaluation(req, resp);     break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null) info = "";

        switch (info) {
            case "/companies/add":    addCompany(req, resp);        break;
            case "/companies/update": updateCompany(req, resp);     break;
            case "/companies/delete": deleteCompany(req, resp);     break;
            case "/internships/add":  addInternship(req, resp);     break;
            case "/internships/update": updateInternship(req, resp);break;
            case "/internships/delete": deleteInternship(req, resp);break;
            case "/applications/update": updateApplication(req, resp); break;
            case "/exams/add":        addExam(req, resp);           break;
            case "/exams/update":     updateExam(req, resp);        break;
            case "/exams/assign":     assignExam(req, resp);        break;
            case "/exams/questions/add":    addQuestion(req, resp);       break;
            case "/exams/questions/delete": deleteQuestion(req, resp);    break;
            case "/evaluate/save":    saveEvaluation(req, resp);    break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    // ================================================================
    // DASHBOARD
    // ================================================================
    private void showDashboard(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("totalStudents",   studentDAO.getTotalStudents());
            req.setAttribute("totalCompanies",  companyDAO.getTotalCompanies());
            req.setAttribute("totalInternships",companyDAO.getTotalOpenInternships());
            req.setAttribute("totalApplications", appDAO.getTotalApplications());
            req.setAttribute("recentLogs",      auditDAO.getSuspiciousLogs(10));
            req.setAttribute("recentApplications", appDAO.getAllApplications().stream().limit(5).collect(java.util.stream.Collectors.toList()));
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error loading dashboard: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    // ================================================================
    // STUDENTS
    // ================================================================
    private void showStudents(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("students", studentDAO.getAllStudents());
            req.setAttribute("exams", examDAO.getAllExams());
            req.getRequestDispatcher("/WEB-INF/views/admin/students.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // COMPANIES
    // ================================================================
    private void showCompanies(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("companies", companyDAO.getAllCompanies());
            req.getRequestDispatcher("/WEB-INF/views/admin/companies.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void addCompany(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Company c = buildCompanyFromRequest(req);
        try { companyDAO.addCompany(c); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/companies?success=added");
    }

    private void updateCompany(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Company c = buildCompanyFromRequest(req);
        c.setCompanyId(Integer.parseInt(req.getParameter("company_id")));
        try { companyDAO.updateCompany(c); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/companies?success=updated");
    }

    private void deleteCompany(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("company_id"));
        try { companyDAO.deleteCompany(id); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/companies?success=deleted");
    }

    private Company buildCompanyFromRequest(HttpServletRequest req) {
        Company c = new Company();
        c.setCompanyName(req.getParameter("company_name"));
        c.setLocation(req.getParameter("location"));
        c.setIndustry(req.getParameter("industry"));
        c.setWebsite(req.getParameter("website"));
        c.setContactEmail(req.getParameter("contact_email"));
        c.setContactPerson(req.getParameter("contact_person"));
        c.setDescription(req.getParameter("description"));
        c.setEligibilityCgpa(Double.parseDouble(req.getParameter("eligibility_cgpa")));
        return c;
    }

    // ================================================================
    // INTERNSHIPS
    // ================================================================
    private void showInternships(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("internships", companyDAO.getAllInternships());
            req.setAttribute("companies",   companyDAO.getAllCompanies());
            req.getRequestDispatcher("/WEB-INF/views/admin/internships.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void addInternship(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Internship i = buildInternshipFromRequest(req);
        try { companyDAO.addInternship(i); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/internships?success=added");
    }

    private void updateInternship(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Internship i = buildInternshipFromRequest(req);
        i.setInternshipId(Integer.parseInt(req.getParameter("internship_id")));
        try { companyDAO.updateInternship(i); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/internships?success=updated");
    }

    private void deleteInternship(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int id = Integer.parseInt(req.getParameter("internship_id"));
        try { companyDAO.deleteInternship(id); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/internships?success=deleted");
    }

    private Internship buildInternshipFromRequest(HttpServletRequest req) {
        Internship i = new Internship();
        i.setCompanyId(Integer.parseInt(req.getParameter("company_id")));
        i.setRole(req.getParameter("role"));
        i.setDescription(req.getParameter("description"));
        i.setStipend(Double.parseDouble(req.getParameter("stipend")));
        i.setDurationMonths(Integer.parseInt(req.getParameter("duration_months")));
        i.setDeadline(java.sql.Date.valueOf(req.getParameter("deadline")));
        i.setSeats(Integer.parseInt(req.getParameter("seats")));
        i.setLocation(req.getParameter("location"));
        i.setSkillsRequired(req.getParameter("skills_required"));
        i.setEligibilityCgpa(Double.parseDouble(req.getParameter("eligibility_cgpa")));
        i.setStatus("OPEN");
        return i;
    }

    // ================================================================
    // APPLICATIONS
    // ================================================================
    private void showApplications(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String internshipParam = req.getParameter("internship_id");
            List<Application> apps;
            if (internshipParam != null) {
                apps = appDAO.getByInternshipId(Integer.parseInt(internshipParam));
            } else {
                apps = appDAO.getAllApplications();
            }
            req.setAttribute("applications", apps);
            req.setAttribute("internships", companyDAO.getAllInternships());
            req.getRequestDispatcher("/WEB-INF/views/admin/applications.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void updateApplication(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int appId    = Integer.parseInt(req.getParameter("application_id"));
        String status = req.getParameter("status");
        String remarks = req.getParameter("remarks");
        User admin = (User) req.getSession().getAttribute("user");
        appDAO.updateStatus(appId, status, admin.getUserId(), remarks);
        auditDAO.logAction(admin.getUserId(),
            "Application #" + appId + " status updated to " + status,
            "ADMIN_ACTION", getClientIP(req), req.getHeader("User-Agent"),
            req.getSession().getId(), "INFO");
        resp.sendRedirect(req.getContextPath() + "/admin/applications?success=updated");
    }

    // ================================================================
    // EXAMS
    // ================================================================
    private void showExams(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("exams", examDAO.getAllExams());
            req.setAttribute("internships", companyDAO.getAllInternships());
            // If an exam_id param is passed, load its questions too
            String examIdParam = req.getParameter("exam_id");
            if (examIdParam != null && !examIdParam.isEmpty()) {
                int eid = Integer.parseInt(examIdParam);
                req.setAttribute("selectedExamId", eid);
                req.setAttribute("selectedExam", examDAO.getExamById(eid));
                req.setAttribute("examQuestions", examDAO.getQuestionsWithOptions(eid));
            }
            req.getRequestDispatcher("/WEB-INF/views/admin/exams.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void showExamQuestions(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String examIdParam = req.getParameter("exam_id");
            if (examIdParam == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/exams");
                return;
            }
            int eid = Integer.parseInt(examIdParam);
            req.setAttribute("exams", examDAO.getAllExams());
            req.setAttribute("internships", companyDAO.getAllInternships());
            req.setAttribute("selectedExamId", eid);
            req.setAttribute("selectedExam", examDAO.getExamById(eid));
            req.setAttribute("examQuestions", examDAO.getQuestionsWithOptions(eid));
            req.getRequestDispatcher("/WEB-INF/views/admin/exams.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void addExam(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Exam exam = new Exam();
        exam.setExamName(req.getParameter("exam_name"));
        exam.setDescription(req.getParameter("description"));
        exam.setDuration(Integer.parseInt(req.getParameter("duration")));
        exam.setStartTime(java.sql.Timestamp.valueOf(req.getParameter("start_time").replace("T", " ") + ":00"));
        exam.setEndTime(java.sql.Timestamp.valueOf(req.getParameter("end_time").replace("T", " ") + ":00"));
        exam.setTotalMarks(Integer.parseInt(req.getParameter("total_marks")));
        exam.setPassingMarks(Integer.parseInt(req.getParameter("passing_marks")));
        String intId = req.getParameter("internship_id");
        if (intId != null && !intId.isEmpty()) exam.setInternshipId(Integer.parseInt(intId));
        User admin = (User) req.getSession().getAttribute("user");
        exam.setCreatedBy(admin.getUserId());
        try { examDAO.createExam(exam); } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/exams?success=created");
    }

    private void addQuestion(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        try {
            int examId = Integer.parseInt(req.getParameter("exam_id"));
            Question q = new Question();
            q.setExamId(examId);
            q.setQuestionText(req.getParameter("question_text"));
            q.setType(req.getParameter("type"));
            q.setMarks(Integer.parseInt(req.getParameter("marks")));
            q.setDifficulty(req.getParameter("difficulty"));
            q.setSequenceNo(Integer.parseInt(req.getParameter("sequence_no")));
            int qId = examDAO.addQuestion(q);

            // Add MCQ options
            if ("MCQ".equals(q.getType())) {
                String[] optTexts = req.getParameterValues("option_text");
                String correctOpt = req.getParameter("correct_option");
                String[] labels = {"A","B","C","D"};
                for (int i = 0; optTexts != null && i < optTexts.length; i++) {
                    Option opt = new Option();
                    opt.setQuestionId(qId);
                    opt.setOptionText(optTexts[i]);
                    opt.setOptionLabel(labels[i]);
                    opt.setCorrect(String.valueOf(i).equals(correctOpt));
                    examDAO.addOption(opt);
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/exams?success=question_added&exam_id=" + examId);
        } catch (SQLException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/exams?error=question_failed");
        }
    }

    private void updateExam(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            int examId = Integer.parseInt(req.getParameter("exam_id"));
            String name = req.getParameter("exam_name");
            String desc = req.getParameter("description");
            int duration = Integer.parseInt(req.getParameter("duration"));
            int totalMarks = Integer.parseInt(req.getParameter("total_marks"));
            int passingMarks = Integer.parseInt(req.getParameter("passing_marks"));
            String status = req.getParameter("status");
            examDAO.updateExam(examId, name, desc, duration, totalMarks, passingMarks, status);
            resp.sendRedirect(req.getContextPath() + "/admin/exams?exam_id=" + examId + "&success=exam_updated");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/exams?error=update_failed");
        }
    }

    private void deleteQuestion(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            int questionId = Integer.parseInt(req.getParameter("question_id"));
            int examId = Integer.parseInt(req.getParameter("exam_id"));
            examDAO.deleteQuestion(questionId);
            resp.sendRedirect(req.getContextPath() + "/admin/exams?exam_id=" + examId + "&success=question_deleted");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/exams?error=delete_failed");
        }
    }

    private void assignExam(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            int userId = Integer.parseInt(req.getParameter("user_id"));
            int examId = Integer.parseInt(req.getParameter("exam_id"));
            boolean success = examDAO.assignExamToUser(userId, examId);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/students?success=exam_assigned");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/students?error=already_assigned");
            }
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/students?error=assign_failed");
        }
    }

    // ================================================================
    // REPORTS
    // ================================================================
    private void showReports(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("exams", examDAO.getAllExams());
            req.setAttribute("internships", companyDAO.getAllInternships());
            req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // AUDIT LOGS
    // ================================================================
    private void showAuditLogs(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int page = 1;
            String pageParam = req.getParameter("page");
            if (pageParam != null) page = Integer.parseInt(pageParam);
            int limit = 50;
            int offset = (page - 1) * limit;
            req.setAttribute("logs", auditDAO.getAllLogs(limit, offset));
            req.setAttribute("suspiciousLogs", auditDAO.getSuspiciousLogs(20));
            req.setAttribute("page", page);
            req.getRequestDispatcher("/WEB-INF/views/admin/audit_logs.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // SUBJECTIVE EVALUATION
    // ================================================================
    private void showEvaluation(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String examParam = req.getParameter("exam_id");
            if (examParam != null) {
                int examId = Integer.parseInt(examParam);
                req.setAttribute("attempts", examDAO.getAllAttemptsByExam(examId));
                req.setAttribute("selectedExam", examDAO.getExamById(examId));
            }
            req.setAttribute("exams", examDAO.getAllExams());
            req.getRequestDispatcher("/WEB-INF/views/admin/evaluate.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    private void saveEvaluation(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int answerId = Integer.parseInt(req.getParameter("answer_id"));
        double marks = Double.parseDouble(req.getParameter("marks_awarded"));
        int attemptId = Integer.parseInt(req.getParameter("attempt_id"));
        User admin = (User) req.getSession().getAttribute("user");
        try {
            examDAO.evaluateSubjective(answerId, marks, admin.getUserId());
            examDAO.recalculateTotalScore(attemptId);
        } catch (SQLException e) { /* log */ }
        resp.sendRedirect(req.getContextPath() + "/admin/evaluate?success=evaluated&attempt_id=" + attemptId);
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
