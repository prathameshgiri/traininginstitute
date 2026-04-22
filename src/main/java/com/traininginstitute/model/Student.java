package com.traininginstitute.model;

/**
 * Student Model - Student Profile & Academic Information
 * @author Dr. Geeta Mete
 */
public class Student {
    private int studentId;
    private int userId;
    private String course;
    private double cgpa;
    private String phone;
    private String address;
    private String profilePic;
    private String skills;
    private String resumePath;
    private String enrollmentNumber;
    private int batchYear;

    // Joined user info (populated via JOIN queries)
    private String name;
    private String email;

    public Student() {}

    // Getters & Setters
    public int getStudentId() { return studentId; }
    public void setStudentId(int studentId) { this.studentId = studentId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getCourse() { return course; }
    public void setCourse(String course) { this.course = course; }

    public double getCgpa() { return cgpa; }
    public void setCgpa(double cgpa) { this.cgpa = cgpa; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getProfilePic() { return profilePic; }
    public void setProfilePic(String profilePic) { this.profilePic = profilePic; }

    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }

    public String getResumePath() { return resumePath; }
    public void setResumePath(String resumePath) { this.resumePath = resumePath; }

    public String getEnrollmentNumber() { return enrollmentNumber; }
    public void setEnrollmentNumber(String enrollmentNumber) { this.enrollmentNumber = enrollmentNumber; }

    public int getBatchYear() { return batchYear; }
    public void setBatchYear(int batchYear) { this.batchYear = batchYear; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFormattedCgpa() {
        return String.format("%.2f", cgpa);
    }
}
