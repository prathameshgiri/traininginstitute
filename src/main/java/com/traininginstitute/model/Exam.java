package com.traininginstitute.model;

import java.sql.Timestamp;


/**
 * Exam Model - Online Examination System
 * @author Dr. Geeta Mete
 */
public class Exam {
    private int examId;
    private String examName;
    private String description;
    private int duration;           // in minutes
    private Timestamp startTime;
    private Timestamp endTime;
    private int totalMarks;
    private int passingMarks;
    private int internshipId;
    private String status;          // SCHEDULED, ACTIVE, COMPLETED, CANCELLED
    private Timestamp createdAt;
    private int createdBy;

    // Joined fields
    private String internshipRole;
    private String companyName;
    private int totalQuestions;

    public Exam() {}

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public String getExamName() { return examName; }
    public void setExamName(String examName) { this.examName = examName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getDuration() { return duration; }
    public void setDuration(int duration) { this.duration = duration; }

    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }

    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }

    public int getTotalMarks() { return totalMarks; }
    public void setTotalMarks(int totalMarks) { this.totalMarks = totalMarks; }

    public int getPassingMarks() { return passingMarks; }
    public void setPassingMarks(int passingMarks) { this.passingMarks = passingMarks; }

    public int getInternshipId() { return internshipId; }
    public void setInternshipId(int internshipId) { this.internshipId = internshipId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public String getInternshipRole() { return internshipRole; }
    public void setInternshipRole(String internshipRole) { this.internshipRole = internshipRole; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public int getTotalQuestions() { return totalQuestions; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }

    public boolean isActive() { return "ACTIVE".equals(status); }
    public boolean isScheduled() { return "SCHEDULED".equals(status); }
}
