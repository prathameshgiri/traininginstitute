package com.traininginstitute.model;

import java.sql.Timestamp;

/**
 * Company Model
 * @author Dr. Geeta Mete
 */
public class Company {
    private int companyId;
    private String companyName;
    private String location;
    private String industry;
    private String website;
    private String contactEmail;
    private String contactPerson;
    private String description;
    private double eligibilityCgpa;
    private String logoPath;
    private Timestamp createdAt;
    private boolean isActive;

    // Stats (populated via joins)
    private int totalInternships;

    public Company() {}

    // Getters & Setters
    public int getCompanyId() { return companyId; }
    public void setCompanyId(int companyId) { this.companyId = companyId; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getIndustry() { return industry; }
    public void setIndustry(String industry) { this.industry = industry; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }

    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }

    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public double getEligibilityCgpa() { return eligibilityCgpa; }
    public void setEligibilityCgpa(double eligibilityCgpa) { this.eligibilityCgpa = eligibilityCgpa; }

    public String getLogoPath() { return logoPath; }
    public void setLogoPath(String logoPath) { this.logoPath = logoPath; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public int getTotalInternships() { return totalInternships; }
    public void setTotalInternships(int totalInternships) { this.totalInternships = totalInternships; }
}
