package com.traininginstitute.servlet;

import com.google.gson.Gson;
import com.traininginstitute.dao.AuditLogDAO;
import com.traininginstitute.dao.ExamDAO;

import com.traininginstitute.model.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * ExamServlet - Online Examination System Controller.
 * Handles exam start, navigation, AJAX auto-save, anti-cheat, and submission.
 * @author Dr. Geeta Mete
 */
@WebServlet("/student/exam/*")
public class ExamServlet extends HttpServlet {

    private ExamDAO     examDAO;

    private AuditLogDAO auditDAO;
    private final Gson  gson = new Gson();

    @Override
    public void init() {
        examDAO    = new ExamDAO();

        auditDAO   = new AuditLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null) info = "/list";

        switch (info) {
            case "/list":      showExamList(req, resp);    break;
            case "/start":     startExam(req, resp);       break;
            case "/take":      showExamPage(req, resp);    break;
            case "/result":    showResult(req, resp);      break;
            case "/time":      getRemainingTime(req, resp);break; // AJAX
            default:
                resp.sendRedirect(req.getContextPath() + "/student/exam/list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String info = req.getPathInfo();
        if (info == null) info = "";

        switch (info) {
            case "/save-answer":  saveAnswer(req, resp);   break; // AJAX
            case "/tab-switch":   recordTabSwitch(req, resp); break; // AJAX
            case "/submit":       submitExam(req, resp);   break;
            default:
                resp.sendRedirect(req.getContextPath() + "/student/exam/list");
        }
    }

    // ================================================================
    // EXAM LIST
    // ================================================================
    private void showExamList(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        try {
            req.setAttribute("exams", examDAO.getAllExams());
            // Pass student's own attempts so JSP can show inline result per exam
            if (user != null) {
                req.setAttribute("myAttempts", examDAO.getAttemptsByUser(user.getUserId()));
            }
            req.getRequestDispatcher("/WEB-INF/views/student/exam_list.jsp").forward(req, resp);
        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // START / RESUME EXAM
    // ================================================================
    private void startExam(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        User user = getUser(req);
        String examIdParam = req.getParameter("exam_id");
        if (examIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/student/exam/list?error=no_exam");
            return;
        }
        int examId = Integer.parseInt(examIdParam);

        try {
            Exam exam = examDAO.getExamById(examId);
            if (exam == null) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/list?error=not_found");
                return;
            }

            // Check if already submitted
            ExamAttempt existing = examDAO.getAttemptByUserAndExam(user.getUserId(), examId);
            if (existing != null && !existing.isInProgress()) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/result?attempt_id=" + existing.getAttemptId());
                return;
            }

            // Start or resume
            ExamAttempt attempt = examDAO.startOrResumeAttempt(user.getUserId(), examId, getClientIP(req));
            if (attempt == null) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/list?error=attempt_failed");
                return;
            }

            auditDAO.logAction(user.getUserId(), "Exam started: " + exam.getExamName(),
                "EXAM_START", getClientIP(req), req.getHeader("User-Agent"),
                req.getSession().getId(), "INFO");

            resp.sendRedirect(req.getContextPath() + "/student/exam/take?attempt_id=" + attempt.getAttemptId());

        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // EXAM TAKING PAGE
    // ================================================================
    private void showExamPage(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        String attemptParam = req.getParameter("attempt_id");

        if (attemptParam == null) {
            resp.sendRedirect(req.getContextPath() + "/student/exam/list");
            return;
        }

        try {
            int attemptId = Integer.parseInt(attemptParam);
            ExamAttempt attempt = examDAO.getAttemptById(attemptId);

            if (attempt == null || attempt.getUserId() != user.getUserId()) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/list?error=unauthorized");
                return;
            }

            if (!attempt.isInProgress()) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/result?attempt_id=" + attemptId);
                return;
            }

            // Auto-submit if time expired
            long remaining = attempt.getRemainingSeconds();
            if (remaining <= 0) {
                examDAO.submitExam(attemptId, "AUTO_SUBMITTED");
                auditDAO.logAction(user.getUserId(), "Exam auto-submitted (time expired)",
                    "EXAM_SUBMIT", getClientIP(req), req.getHeader("User-Agent"),
                    req.getSession().getId(), "WARNING");
                resp.sendRedirect(req.getContextPath() + "/student/exam/result?attempt_id=" + attemptId + "&auto=true");
                return;
            }

            // Load questions with current answers
            List<Question> questions = examDAO.getQuestionsWithOptions(attempt.getExamId());
            List<Question> answers   = examDAO.getAttemptAnswers(attemptId);

            // Merge saved answers into questions for display
            Map<Integer, Question> answerMap = new HashMap<>();
            for (Question a : answers) answerMap.put(a.getQuestionId(), a);
            for (Question q : questions) {
                Question saved = answerMap.get(q.getQuestionId());
                if (saved != null) {
                    q.setSelectedOption(saved.getSelectedOption());
                    q.setDescriptiveAnswer(saved.getDescriptiveAnswer());
                    q.setMarkedReview(saved.isMarkedReview());
                    q.setAnswerId(saved.getAnswerId());
                }
            }

            int currentQ = 0;
            String qParam = req.getParameter("q");
            if (qParam != null) currentQ = Integer.parseInt(qParam);

            req.setAttribute("attempt",  attempt);
            req.setAttribute("questions", questions);
            req.setAttribute("currentQ", currentQ);
            req.setAttribute("totalQ",   questions.size());
            req.setAttribute("remainingSeconds", remaining);
            req.getRequestDispatcher("/WEB-INF/views/student/exam_take.jsp").forward(req, resp);

        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // AJAX: AUTO-SAVE ANSWER
    // ================================================================
    private void saveAnswer(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            int attemptId = Integer.parseInt(req.getParameter("attempt_id"));
            int questionId = Integer.parseInt(req.getParameter("question_id"));
            String selectedOptStr = req.getParameter("selected_option");
            String descriptive   = req.getParameter("descriptive_answer");
            boolean isMarked     = "true".equals(req.getParameter("is_marked_review"));

            Integer selectedOpt = (selectedOptStr != null && !selectedOptStr.isEmpty())
                    ? Integer.parseInt(selectedOptStr) : null;

            // Verify attempt belongs to user
            User user = getUser(req);
            ExamAttempt attempt = examDAO.getAttemptById(attemptId);
            if (attempt == null || attempt.getUserId() != user.getUserId() || !attempt.isInProgress()) {
                result.put("success", false);
                result.put("message", "Invalid attempt");
                out.print(gson.toJson(result));
                return;
            }

            boolean saved = examDAO.saveAnswer(attemptId, questionId, selectedOpt, descriptive, isMarked);
            result.put("success", saved);
            result.put("remainingSeconds", attempt.getRemainingSeconds());

        } catch (SQLException | NumberFormatException e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }

        out.print(gson.toJson(result));
    }

    // ================================================================
    // AJAX: TAB SWITCH DETECTION (Anti-Cheat)
    // ================================================================
    private void recordTabSwitch(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();

        try {
            int attemptId = Integer.parseInt(req.getParameter("attempt_id"));
            User user = getUser(req);

            examDAO.recordTabSwitch(attemptId);

            // Get updated tab switch count
            ExamAttempt attempt = examDAO.getAttemptById(attemptId);
            int switchCount = attempt.getTabSwitchCount();

            auditDAO.logAction(user.getUserId(),
                "TAB SWITCH DETECTED during exam. Attempt: " + attemptId + ", Count: " + switchCount,
                "TAB_SWITCH", getClientIP(req), req.getHeader("User-Agent"),
                req.getSession().getId(),
                switchCount >= 3 ? "CRITICAL" : "WARNING");

            result.put("success", true);
            result.put("tabSwitchCount", switchCount);
            // Auto-submit if too many violations
            if (switchCount >= 5) {
                examDAO.submitExam(attemptId, "AUTO_SUBMITTED");
                result.put("autoSubmitted", true);
                result.put("message", "Exam auto-submitted due to repeated violations.");
            }

        } catch (SQLException | NumberFormatException e) {
            result.put("success", false);
        }

        out.print(gson.toJson(result));
    }

    // ================================================================
    // AJAX: GET REMAINING TIME
    // ================================================================
    private void getRemainingTime(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();
        Map<String, Object> result = new HashMap<>();
        try {
            int attemptId = Integer.parseInt(req.getParameter("attempt_id"));
            ExamAttempt attempt = examDAO.getAttemptById(attemptId);
            if (attempt != null && attempt.isInProgress()) {
                long remaining = attempt.getRemainingSeconds();
                result.put("remaining", remaining);
                result.put("isExpired", remaining <= 0);
                if (remaining <= 0) {
                    examDAO.submitExam(attemptId, "AUTO_SUBMITTED");
                    result.put("autoSubmitted", true);
                }
            } else {
                result.put("remaining", 0);
                result.put("isExpired", true);
            }
        } catch (SQLException | NumberFormatException e) {
            result.put("remaining", 0);
        }
        out.print(gson.toJson(result));
    }

    // ================================================================
    // EXAM SUBMISSION
    // ================================================================
    private void submitExam(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        User user = getUser(req);
        int attemptId = Integer.parseInt(req.getParameter("attempt_id"));

        try {
            ExamAttempt attempt = examDAO.getAttemptById(attemptId);
            if (attempt == null || attempt.getUserId() != user.getUserId()) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/list?error=unauthorized");
                return;
            }

            if (attempt.isInProgress()) {
                examDAO.submitExam(attemptId, "SUBMITTED");
                auditDAO.logAction(user.getUserId(), "Exam submitted manually",
                    "EXAM_SUBMIT", getClientIP(req), req.getHeader("User-Agent"),
                    req.getSession().getId(), "INFO");
            }

            resp.sendRedirect(req.getContextPath() + "/student/exam/result?attempt_id=" + attemptId);

        } catch (SQLException e) {
            forwardError(req, resp, e);
        }
    }

    // ================================================================
    // RESULT PAGE
    // ================================================================
    private void showResult(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = getUser(req);
        String attemptParam = req.getParameter("attempt_id");
        if (attemptParam == null) {
            resp.sendRedirect(req.getContextPath() + "/student/exam/list");
            return;
        }
        try {
            int attemptId = Integer.parseInt(attemptParam);
            ExamAttempt attempt = examDAO.getAttemptById(attemptId);
            if (attempt == null || attempt.getUserId() != user.getUserId()) {
                resp.sendRedirect(req.getContextPath() + "/student/exam/list?error=unauthorized");
                return;
            }
            Exam exam = examDAO.getExamById(attempt.getExamId());
            List<Question> answeredQ = examDAO.getAttemptAnswers(attemptId);
            req.setAttribute("attempt", attempt);
            req.setAttribute("exam",    exam);
            req.setAttribute("answers", answeredQ);
            req.getRequestDispatcher("/WEB-INF/views/student/exam_result.jsp").forward(req, resp);
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
