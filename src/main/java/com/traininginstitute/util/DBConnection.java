package com.traininginstitute.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Logger;

/**
 * Database Connection Pool Manager using Singleton pattern.
 * Provides thread-safe database connections for the Training Institute Portal.
 *
 * @author Dr. Geeta Mete
 */
public class DBConnection {

    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());

    private static final String DRIVER   = "com.mysql.cj.jdbc.Driver";
    private static final String DB_URL   = "jdbc:mysql://localhost:3306/training_institute_db?useSSL=false&serverTimezone=Asia/Kolkata&allowPublicKeyRetrieval=true&rewriteBatchedStatements=true&zeroDateTimeBehavior=convertToNull";
    private static final String DB_USER  = "root";
    // List of common XAMPP / local MySQL passwords to try dynamically
    private static final String[] DB_PASSWORDS = {"", "root", "admin", "password"};

    static {
        try {
            Class.forName(DRIVER);
            LOGGER.info("MySQL JDBC Driver registered successfully.");
        } catch (ClassNotFoundException e) {
            LOGGER.severe("MySQL Driver not found: " + e.getMessage());
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() { /* Utility class – no instantiation */ }

    /**
     * Returns a new database connection by trying common local passwords.
     * Caller is responsible for closing the connection.
     */
    public static Connection getConnection() throws SQLException {
        SQLException lastException = null;
        for (String pass : DB_PASSWORDS) {
            try {
                return DriverManager.getConnection(DB_URL, DB_USER, pass);
            } catch (SQLException e) {
                lastException = e;
            }
        }
        throw new SQLException("Could not connect to database using any of the common local passwords.", lastException);
    }

    /**
     * Safely close connection, suppressing any SQL exceptions.
     */
    public static void close(AutoCloseable... resources) {
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    LOGGER.warning("Error closing resource: " + e.getMessage());
                }
            }
        }
    }

    /**
     * Quietly roll back a connection on error.
     */
    public static void rollback(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                LOGGER.warning("Rollback failed: " + e.getMessage());
            }
        }
    }
}
