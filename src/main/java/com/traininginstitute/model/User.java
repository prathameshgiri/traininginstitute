package com.traininginstitute.model;

import java.sql.Timestamp;

/**
 * User Model - Authentication & Role Management
 * @author Dr. Geeta Mete
 */
public class User {
    private int userId;
    private String name;
    private String email;
    private String password;
    private String role;          // ADMIN / STUDENT
    private boolean isLoggedIn;
    private Timestamp lastLogin;
    private Timestamp createdAt;

    public User() {}

    public User(int userId, String name, String email, String role) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.role = role;
    }

    // Getters & Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isLoggedIn() { return isLoggedIn; }
    public void setLoggedIn(boolean loggedIn) { isLoggedIn = loggedIn; }

    public Timestamp getLastLogin() { return lastLogin; }
    public void setLastLogin(Timestamp lastLogin) { this.lastLogin = lastLogin; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isAdmin()   { return "ADMIN".equals(this.role); }
    public boolean isStudent() { return "STUDENT".equals(this.role); }

    @Override
    public String toString() {
        return "User{userId=" + userId + ", name='" + name + "', email='" + email + "', role='" + role + "'}";
    }
}
