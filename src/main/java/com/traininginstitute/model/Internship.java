package com.traininginstitute.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Internship Model
 * @author Dr. Geeta Mete
 */
public class Internship {
    private int internshipId;
    private int companyId;
    private String role;
    private String description;
    private double stipend;
    private int durationMonths;
    private Date deadline;
    private int seats;
    private String location;
    private String skillsRequired;
    private double eligibilityCgpa;
    private String status;  // OPEN, CLOSED, ARCHIVED
    private Timestamp createdAt;

    // Company info (populated via JOIN)
    private String companyName;
    private String companyLocation;
    private String companyLogo;

    // Application stats
    private int totalApplications;
    private boolean hasApplied;     // for logged-in student
    private String applicationStatus;

    public Internship() {}

    // Getters & Setters
    public int getInternshipId() { return internshipId; }
    public void setInternshipId(int internshipId) { this.internshipId = internshipId; }

    public int getCompanyId() { return companyId; }
    public void setCompanyId(int companyId) { this.companyId = companyId; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getStipend() { return stipend; }
    public void setStipend(double stipend) { this.stipend = stipend; }

    public int getDurationMonths() { return durationMonths; }
    public void setDurationMonths(int durationMonths) { this.durationMonths = durationMonths; }

    public Date getDeadline() { return deadline; }
    public void setDeadline(Date deadline) { this.deadline = deadline; }

    public int getSeats() { return seats; }
    public void setSeats(int seats) { this.seats = seats; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getSkillsRequired() { return skillsRequired; }
    public void setSkillsRequired(String skillsRequired) { this.skillsRequired = skillsRequired; }

    public double getEligibilityCgpa() { return eligibilityCgpa; }
    public void setEligibilityCgpa(double eligibilityCgpa) { this.eligibilityCgpa = eligibilityCgpa; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getCompanyLocation() { return companyLocation; }
    public void setCompanyLocation(String companyLocation) { this.companyLocation = companyLocation; }

    public String getCompanyLogo() { return companyLogo; }
    public void setCompanyLogo(String companyLogo) { this.companyLogo = companyLogo; }

    public int getTotalApplications() { return totalApplications; }
    public void setTotalApplications(int totalApplications) { this.totalApplications = totalApplications; }

    public boolean isHasApplied() { return hasApplied; }
    public void setHasApplied(boolean hasApplied) { this.hasApplied = hasApplied; }

    public String getApplicationStatus() { return applicationStatus; }
    public void setApplicationStatus(String applicationStatus) { this.applicationStatus = applicationStatus; }

    public boolean isDeadlinePassed() {
        return deadline != null && deadline.before(new java.util.Date());
    }

    public String getFormattedStipend() {
        return String.format("₹%.0f/month", stipend);
    }
}
