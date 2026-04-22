package com.traininginstitute.model;

import java.sql.Timestamp;

/**
 * ExamAttempt Model - Tracks student exam sessions
 * @author Dr. Geeta Mete
 */
public class ExamAttempt {
    private int attemptId;
    private int userId;
    private int examId;
    private int applicationId;
    private Timestamp startTime;
    private Timestamp endTime;
    private Timestamp submitTime;
    private String status;  // IN_PROGRESS, SUBMITTED, AUTO_SUBMITTED, ABANDONED
    private double totalScore;
    private double mcqScore;
    private double subjectiveScore;
    private boolean isPassed;
    private String ipAddress;
    private int tabSwitchCount;
    private String resumeToken;
    private boolean evaluated;

    // Joined fields
    private String studentName;
    private String examName;
    private int examDuration;
    private int totalMarks;
    private int passingMarks;

    public ExamAttempt() {}

    public int getAttemptId() { return attemptId; }
    public void setAttemptId(int attemptId) { this.attemptId = attemptId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }

    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }

    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }

    public Timestamp getSubmitTime() { return submitTime; }
    public void setSubmitTime(Timestamp submitTime) { this.submitTime = submitTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public double getTotalScore() { return totalScore; }
    public void setTotalScore(double totalScore) { this.totalScore = totalScore; }

    public double getMcqScore() { return mcqScore; }
    public void setMcqScore(double mcqScore) { this.mcqScore = mcqScore; }

    public double getSubjectiveScore() { return subjectiveScore; }
    public void setSubjectiveScore(double subjectiveScore) { this.subjectiveScore = subjectiveScore; }

    public boolean isPassed() { return isPassed; }
    public void setPassed(boolean passed) { isPassed = passed; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public int getTabSwitchCount() { return tabSwitchCount; }
    public void setTabSwitchCount(int tabSwitchCount) { this.tabSwitchCount = tabSwitchCount; }

    public String getResumeToken() { return resumeToken; }
    public void setResumeToken(String resumeToken) { this.resumeToken = resumeToken; }

    public boolean isEvaluated() { return evaluated; }
    public void setEvaluated(boolean evaluated) { this.evaluated = evaluated; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getExamName() { return examName; }
    public void setExamName(String examName) { this.examName = examName; }

    public int getExamDuration() { return examDuration; }
    public void setExamDuration(int examDuration) { this.examDuration = examDuration; }

    public int getTotalMarks() { return totalMarks; }
    public void setTotalMarks(int totalMarks) { this.totalMarks = totalMarks; }

    public int getPassingMarks() { return passingMarks; }
    public void setPassingMarks(int passingMarks) { this.passingMarks = passingMarks; }

    /** Returns remaining time in seconds based on exam duration and start time */
    public long getRemainingSeconds() {
        if (startTime == null) return 0;
        long elapsed = (System.currentTimeMillis() - startTime.getTime()) / 1000;
        long total = (long) examDuration * 60;
        return Math.max(0, total - elapsed);
    }

    public boolean isInProgress() { return "IN_PROGRESS".equals(status); }
}
