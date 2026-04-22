package com.traininginstitute.dao;

import com.traininginstitute.model.*;
import com.traininginstitute.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;

/**
 * ExamDAO - Online Examination System
 * Implements Case 2 transaction: Save answers + Calculate marks + Update result
 * @author Dr. Geeta Mete
 */
public class ExamDAO {

    private static final Logger LOGGER = Logger.getLogger(ExamDAO.class.getName());

    // ================================================================
    // EXAM CRUD
    // ================================================================

    public List<Exam> getAllExams() throws SQLException {
        String sql = "SELECT e.*, i.role AS internship_role, c.company_name, " +
                     "(SELECT COUNT(*) FROM questions q WHERE q.exam_id = e.exam_id) AS total_questions " +
                     "FROM exams e LEFT JOIN internships i ON e.internship_id = i.internship_id " +
                     "LEFT JOIN companies c ON i.company_id = c.company_id ORDER BY e.start_time DESC";
        List<Exam> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapExam(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    public Exam getExamById(int examId) throws SQLException {
        String sql = "SELECT e.*, i.role AS internship_role, c.company_name, " +
                     "(SELECT COUNT(*) FROM questions q WHERE q.exam_id = e.exam_id) AS total_questions " +
                     "FROM exams e LEFT JOIN internships i ON e.internship_id = i.internship_id " +
                     "LEFT JOIN companies c ON i.company_id = c.company_id WHERE e.exam_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            if (rs.next()) return mapExam(rs);
        } finally { DBConnection.close(rs, ps, conn); }
        return null;
    }

    public int createExam(Exam exam) throws SQLException {
        String sql = "INSERT INTO exams (exam_name, description, duration, start_time, end_time, " +
                     "total_marks, passing_marks, internship_id, status, created_by) VALUES (?,?,?,?,?,?,?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, exam.getExamName());
            ps.setString(2, exam.getDescription());
            ps.setInt(3, exam.getDuration());
            ps.setTimestamp(4, exam.getStartTime());
            ps.setTimestamp(5, exam.getEndTime());
            ps.setInt(6, exam.getTotalMarks());
            ps.setInt(7, exam.getPassingMarks());
            if (exam.getInternshipId() > 0) ps.setInt(8, exam.getInternshipId()); else ps.setNull(8, Types.INTEGER);
            ps.setString(9, exam.getStatus() != null ? exam.getStatus() : "SCHEDULED");
            ps.setInt(10, exam.getCreatedBy());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return -1;
    }

    public void updateExamStatus(int examId, String status) throws SQLException {
        String sql = "UPDATE exams SET status = ? WHERE exam_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status); ps.setInt(2, examId);
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    // ================================================================
    // QUESTIONS
    // ================================================================

    public int addQuestion(Question q) throws SQLException {
        String sql = "INSERT INTO questions (exam_id, question_text, type, marks, difficulty, sequence_no) " +
                     "VALUES (?,?,?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, q.getExamId()); ps.setString(2, q.getQuestionText());
            ps.setString(3, q.getType()); ps.setInt(4, q.getMarks());
            ps.setString(5, q.getDifficulty()); ps.setInt(6, q.getSequenceNo());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } finally { DBConnection.close(rs, ps, conn); }
        return -1;
    }

    public void addOption(Option opt) throws SQLException {
        String sql = "INSERT INTO options (question_id, option_text, is_correct, option_label) VALUES (?,?,?,?)";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, opt.getQuestionId()); ps.setString(2, opt.getOptionText());
            ps.setBoolean(3, opt.isCorrect()); ps.setString(4, opt.getOptionLabel());
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    /**
     * Load all questions WITH options for an exam (exam session).
     */
    public List<Question> getQuestionsWithOptions(int examId) throws SQLException {
        String sql = "SELECT q.*, o.option_id, o.option_text, o.is_correct, o.option_label " +
                     "FROM questions q LEFT JOIN options o ON q.question_id = o.question_id " +
                     "WHERE q.exam_id = ? ORDER BY q.sequence_no, o.option_label";
        List<Question> questions = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            Question current = null;
            while (rs.next()) {
                int qId = rs.getInt("question_id");
                if (current == null || current.getQuestionId() != qId) {
                    current = mapQuestion(rs);
                    current.setOptions(new ArrayList<>());
                    questions.add(current);
                }
                if (rs.getObject("option_id") != null) {
                    current.getOptions().add(mapOption(rs));
                }
            }
        } finally { DBConnection.close(rs, ps, conn); }
        return questions;
    }

    // ================================================================
    // EXAM ATTEMPT MANAGEMENT
    // ================================================================

    /**
     * Start or Resume exam attempt.
     */
    public ExamAttempt startOrResumeAttempt(int userId, int examId, String ipAddress) throws SQLException {
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();

            // Check for existing attempt
            ps = conn.prepareStatement(
                "SELECT ea.*, e.duration AS exam_duration, e.total_marks, e.passing_marks, e.exam_name " +
                "FROM exam_attempts ea JOIN exams e ON ea.exam_id = e.exam_id " +
                "WHERE ea.user_id = ? AND ea.exam_id = ?");
            ps.setInt(1, userId); ps.setInt(2, examId);
            rs = ps.executeQuery();

            if (rs.next()) {
                ExamAttempt existing = mapAttempt(rs);
                if (existing.isInProgress()) return existing; // Resume
                return null; // Already submitted
            }

            DBConnection.close(rs, ps);

            // Create new attempt
            String resumeToken = UUID.randomUUID().toString();
            ps = conn.prepareStatement(
                "INSERT INTO exam_attempts (user_id, exam_id, ip_address, resume_token) VALUES (?,?,?,?)",
                Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, userId); ps.setInt(2, examId);
            ps.setString(3, ipAddress); ps.setString(4, resumeToken);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            int attemptId = rs.next() ? rs.getInt(1) : -1;
            DBConnection.close(rs, ps);

            // Initialize blank answers for all questions
            ps = conn.prepareStatement(
                "INSERT INTO answers (attempt_id, question_id) " +
                "SELECT ?, question_id FROM questions WHERE exam_id = ?");
            ps.setInt(1, attemptId); ps.setInt(2, examId);
            ps.executeUpdate();

            return getAttemptById(attemptId);
        } finally { DBConnection.close(rs, ps, conn); }
    }

    /**
     * Auto-save answer (AJAX call during exam).
     * Uses INSERT ... ON DUPLICATE KEY UPDATE for idempotency.
     */
    public boolean saveAnswer(int attemptId, int questionId, Integer selectedOption,
                               String descriptiveAnswer, boolean isMarkedReview) throws SQLException {
        String sql = "INSERT INTO answers (attempt_id, question_id, selected_option, descriptive_answer, is_marked_review) " +
                     "VALUES (?, ?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE selected_option = VALUES(selected_option), " +
                     "descriptive_answer = VALUES(descriptive_answer), " +
                     "is_marked_review = VALUES(is_marked_review), " +
                     "answer_time = CURRENT_TIMESTAMP";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId); ps.setInt(2, questionId);
            if (selectedOption != null) ps.setInt(3, selectedOption); else ps.setNull(3, Types.INTEGER);
            ps.setString(4, descriptiveAnswer);
            ps.setBoolean(5, isMarkedReview);
            ps.executeUpdate();
            return true;
        } finally { DBConnection.close(ps, conn); }
    }

    /**
     * TRANSACTION - Case 2: Full exam submission.
     * Auto-evaluate MCQ + Update attempt + Calculate total score.
     */
    public boolean submitExam(int attemptId, String submitType) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Step 1: Auto-evaluate MCQ answers
            PreparedStatement psEval = conn.prepareStatement(
                "UPDATE answers a " +
                "JOIN options o ON a.selected_option = o.option_id " +
                "JOIN questions q ON a.question_id = q.question_id " +
                "SET a.marks_awarded = CASE WHEN o.is_correct = TRUE THEN q.marks ELSE 0 END " +
                "WHERE a.attempt_id = ? AND q.type = 'MCQ'");
            psEval.setInt(1, attemptId);
            psEval.executeUpdate();
            DBConnection.close(psEval);

            // Step 2: Calculate MCQ total
            PreparedStatement psScore = conn.prepareStatement(
                "SELECT COALESCE(SUM(a.marks_awarded), 0) AS mcq_score " +
                "FROM answers a JOIN questions q ON a.question_id = q.question_id " +
                "WHERE a.attempt_id = ? AND q.type = 'MCQ'");
            psScore.setInt(1, attemptId);
            ResultSet rs = psScore.executeQuery();
            double mcqScore = rs.next() ? rs.getDouble("mcq_score") : 0;
            DBConnection.close(rs, psScore);

            // Step 3: Get passing marks
            PreparedStatement psPass = conn.prepareStatement(
                "SELECT e.passing_marks FROM exam_attempts ea " +
                "JOIN exams e ON ea.exam_id = e.exam_id WHERE ea.attempt_id = ?");
            psPass.setInt(1, attemptId);
            rs = psPass.executeQuery();
            int passingMarks = rs.next() ? rs.getInt("passing_marks") : 0;
            boolean isPassed = mcqScore >= passingMarks;
            DBConnection.close(rs, psPass);

            // Step 4: Update exam attempt
            PreparedStatement psUpdate = conn.prepareStatement(
                "UPDATE exam_attempts SET status = ?, end_time = NOW(), submit_time = NOW(), " +
                "total_score = ?, mcq_score = ?, is_passed = ? WHERE attempt_id = ?");
            psUpdate.setString(1, submitType);
            psUpdate.setDouble(2, mcqScore);
            psUpdate.setDouble(3, mcqScore);
            psUpdate.setBoolean(4, isPassed);
            psUpdate.setInt(5, attemptId);
            psUpdate.executeUpdate();
            DBConnection.close(psUpdate);

            conn.commit();
            LOGGER.info("Exam submitted successfully. AttemptId=" + attemptId + ", Score=" + mcqScore);
            return true;

        } catch (SQLException e) {
            LOGGER.severe("Submit exam transaction failed: " + e.getMessage());
            DBConnection.rollback(conn);
            return false;
        } finally {
            DBConnection.close(conn);
        }
    }

    /**
     * Increment tab-switch count and log suspicious activity.
     */
    public void recordTabSwitch(int attemptId) throws SQLException {
        String sql = "UPDATE exam_attempts SET tab_switch_count = tab_switch_count + 1 WHERE attempt_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public ExamAttempt getAttemptById(int attemptId) throws SQLException {
        String sql = "SELECT ea.*, e.duration AS exam_duration, e.total_marks, e.passing_marks, e.exam_name, " +
                     "u.name AS student_name FROM exam_attempts ea " +
                     "JOIN exams e ON ea.exam_id = e.exam_id " +
                     "JOIN users u ON ea.user_id = u.user_id WHERE ea.attempt_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            if (rs.next()) return mapAttempt(rs);
        } finally { DBConnection.close(rs, ps, conn); }
        return null;
    }

    public ExamAttempt getAttemptByUserAndExam(int userId, int examId) throws SQLException {
        String sql = "SELECT ea.*, e.duration AS exam_duration, e.total_marks, e.passing_marks, e.exam_name " +
                     "FROM exam_attempts ea JOIN exams e ON ea.exam_id = e.exam_id " +
                     "WHERE ea.user_id = ? AND ea.exam_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId); ps.setInt(2, examId);
            rs = ps.executeQuery();
            if (rs.next()) return mapAttempt(rs);
        } finally { DBConnection.close(rs, ps, conn); }
        return null;
    }

    /**
     * Get all answers for an attempt (with question text and correct option info).
     */
    public List<Question> getAttemptAnswers(int attemptId) throws SQLException {
        String sql = "SELECT q.*, a.selected_option, a.descriptive_answer, a.marks_awarded, " +
                     "a.is_marked_review, a.answer_id " +
                     "FROM answers a JOIN questions q ON a.question_id = q.question_id " +
                     "WHERE a.attempt_id = ? ORDER BY q.sequence_no";
        List<Question> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, attemptId);
            rs = ps.executeQuery();
            while (rs.next()) {
                Question q = mapQuestion(rs);
                q.setSelectedOption(rs.getObject("selected_option") != null ? rs.getInt("selected_option") : null);
                q.setDescriptiveAnswer(rs.getString("descriptive_answer"));
                q.setMarksAwarded(rs.getDouble("marks_awarded"));
                q.setMarkedReview(rs.getBoolean("is_marked_review"));
                q.setAnswerId(rs.getInt("answer_id"));
                list.add(q);
            }
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    /**
     * Admin: Evaluate subjective answers.
     */
    public boolean evaluateSubjective(int answerId, double marksAwarded, int evaluatorId) throws SQLException {
        String sql = "UPDATE answers SET marks_awarded = ?, evaluated_by = ?, evaluated_at = NOW() WHERE answer_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDouble(1, marksAwarded); ps.setInt(2, evaluatorId); ps.setInt(3, answerId);
            return ps.executeUpdate() > 0;
        } finally { DBConnection.close(ps, conn); }
    }

    /**
     * Recalculate total score after subjective evaluation.
     */
    public void recalculateTotalScore(int attemptId) throws SQLException {
        String sql = "UPDATE exam_attempts SET " +
                     "total_score = (SELECT COALESCE(SUM(marks_awarded), 0) FROM answers WHERE attempt_id = ?), " +
                     "mcq_score = (SELECT COALESCE(SUM(a.marks_awarded), 0) FROM answers a " +
                     "  JOIN questions q ON a.question_id = q.question_id WHERE a.attempt_id = ? AND q.type = 'MCQ'), " +
                     "subjective_score = (SELECT COALESCE(SUM(a.marks_awarded), 0) FROM answers a " +
                     "  JOIN questions q ON a.question_id = q.question_id WHERE a.attempt_id = ? AND q.type = 'SUBJECTIVE'), " +
                     "evaluated = TRUE, " +
                     "is_passed = (total_score >= (SELECT passing_marks FROM exams e JOIN exam_attempts ea ON e.exam_id = ea.exam_id WHERE ea.attempt_id = ?)) " +
                     "WHERE attempt_id = ?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 1; i <= 5; i++) ps.setInt(i, attemptId);
            ps.executeUpdate();
        } finally { DBConnection.close(ps, conn); }
    }

    public List<ExamAttempt> getAllAttemptsByExam(int examId) throws SQLException {
        String sql = "SELECT ea.*, e.duration AS exam_duration, e.total_marks, e.passing_marks, e.exam_name, " +
                     "u.name AS student_name FROM exam_attempts ea " +
                     "JOIN exams e ON ea.exam_id = e.exam_id " +
                     "JOIN users u ON ea.user_id = u.user_id " +
                     "WHERE ea.exam_id = ? ORDER BY ea.total_score DESC";
        List<ExamAttempt> list = new ArrayList<>();
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, examId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapAttempt(rs));
        } finally { DBConnection.close(rs, ps, conn); }
        return list;
    }

    // ================================================================
    // MAPPERS
    // ================================================================

    private Exam mapExam(ResultSet rs) throws SQLException {
        Exam e = new Exam();
        e.setExamId(rs.getInt("exam_id"));
        e.setExamName(rs.getString("exam_name"));
        e.setDescription(rs.getString("description"));
        e.setDuration(rs.getInt("duration"));
        e.setStartTime(rs.getTimestamp("start_time"));
        e.setEndTime(rs.getTimestamp("end_time"));
        e.setTotalMarks(rs.getInt("total_marks"));
        e.setPassingMarks(rs.getInt("passing_marks"));
        e.setStatus(rs.getString("status"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        try { e.setInternshipId(rs.getInt("internship_id")); } catch (SQLException ignored) {}
        try { e.setInternshipRole(rs.getString("internship_role")); } catch (SQLException ignored) {}
        try { e.setCompanyName(rs.getString("company_name")); } catch (SQLException ignored) {}
        try { e.setTotalQuestions(rs.getInt("total_questions")); } catch (SQLException ignored) {}
        return e;
    }

    private Question mapQuestion(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setQuestionId(rs.getInt("question_id"));
        q.setExamId(rs.getInt("exam_id"));
        q.setQuestionText(rs.getString("question_text"));
        q.setType(rs.getString("type"));
        q.setMarks(rs.getInt("marks"));
        q.setDifficulty(rs.getString("difficulty"));
        q.setSequenceNo(rs.getInt("sequence_no"));
        return q;
    }

    private Option mapOption(ResultSet rs) throws SQLException {
        Option o = new Option();
        o.setOptionId(rs.getInt("option_id"));
        o.setQuestionId(rs.getInt("question_id"));
        o.setOptionText(rs.getString("option_text"));
        o.setCorrect(rs.getBoolean("is_correct"));
        o.setOptionLabel(rs.getString("option_label"));
        return o;
    }

    private ExamAttempt mapAttempt(ResultSet rs) throws SQLException {
        ExamAttempt ea = new ExamAttempt();
        ea.setAttemptId(rs.getInt("attempt_id"));
        ea.setUserId(rs.getInt("user_id"));
        ea.setExamId(rs.getInt("exam_id"));
        ea.setStartTime(rs.getTimestamp("start_time"));
        ea.setEndTime(rs.getTimestamp("end_time"));
        ea.setSubmitTime(rs.getTimestamp("submit_time"));
        ea.setStatus(rs.getString("status"));
        ea.setTotalScore(rs.getDouble("total_score"));
        ea.setMcqScore(rs.getDouble("mcq_score"));
        ea.setSubjectiveScore(rs.getDouble("subjective_score"));
        ea.setPassed(rs.getBoolean("is_passed"));
        ea.setIpAddress(rs.getString("ip_address"));
        ea.setTabSwitchCount(rs.getInt("tab_switch_count"));
        ea.setResumeToken(rs.getString("resume_token"));
        ea.setEvaluated(rs.getBoolean("evaluated"));
        try { ea.setExamDuration(rs.getInt("exam_duration")); } catch (SQLException ignored) {}
        try { ea.setTotalMarks(rs.getInt("total_marks")); } catch (SQLException ignored) {}
        try { ea.setPassingMarks(rs.getInt("passing_marks")); } catch (SQLException ignored) {}
        try { ea.setExamName(rs.getString("exam_name")); } catch (SQLException ignored) {}
        try { ea.setStudentName(rs.getString("student_name")); } catch (SQLException ignored) {}
        return ea;
    }
}
