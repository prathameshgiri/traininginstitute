package com.traininginstitute.model;

import java.sql.Timestamp;

/**
 * Application Model - Internship Applications
 * @author Dr. Geeta Mete
 */
public class Application {
    private int applicationId;
    private int studentId;
    private int internshipId;
    private String status;  // APPLIED, SHORTLISTED, REJECTED, SELECTED, CONFIRMED
    private String coverLetter;
    private Timestamp appliedDate;
    private Timestamp reviewedDate;
    private int reviewedBy;
    private String remarks;

    // Joined fields
    private String studentName;
    private String studentEmail;
    private String course;
    private double cgpa;
    private String enrollmentNumber;
    private String companyName;
    private String internshipRole;
    private String internshipLocation;
    private String reviewedByName;

    public Application() {}

    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }

    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getInternshipId() { return internshipId; }
    public void setInternshipId(int internshipId) { this.internshipId = internshipId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCoverLetter() { return coverLetter; }
    public void setCoverLetter(String coverLetter) { this.coverLetter = coverLetter; }

    public Timestamp getAppliedDate() { return appliedDate; }
    public void setAppliedDate(Timestamp appliedDate) { this.appliedDate = appliedDate; }

    public Timestamp getReviewedDate() { return reviewedDate; }
    public void setReviewedDate(Timestamp reviewedDate) { this.reviewedDate = reviewedDate; }

    public int getReviewedBy() { return reviewedBy; }
    public void setReviewedBy(int reviewedBy) { this.reviewedBy = reviewedBy; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStudentEmail() { return studentEmail; }
    public void setStudentEmail(String studentEmail) { this.studentEmail = studentEmail; }

    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }

    public double getCgpa() { return cgpa; }
    public void setCgpa(double cgpa) { this.cgpa = cgpa; }

    public String getEnrollmentNumber() { return enrollmentNumber; }
    public void setEnrollmentNumber(String enrollmentNumber) { this.enrollmentNumber = enrollmentNumber; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getInternshipRole() { return internshipRole; }
    public void setInternshipRole(String internshipRole) { this.internshipRole = internshipRole; }

    public String getInternshipLocation() { return internshipLocation; }
    public void setInternshipLocation(String internshipLocation) { this.internshipLocation = internshipLocation; }

    public String getReviewedByName() { return reviewedByName; }
    public void setReviewedByName(String reviewedByName) { this.reviewedByName = reviewedByName; }

    public String getStatusBadgeClass() {
        switch (status) {
            case "APPLIED": return "badge-primary";
            case "SHORTLISTED": return "badge-warning";
            case "SELECTED": return "badge-success";
            case "REJECTED": return "badge-danger";
            case "CONFIRMED": return "badge-info";
            default: return "badge-secondary";
        }
    }
}
