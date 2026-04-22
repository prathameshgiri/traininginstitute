import org.mindrot.jbcrypt.BCrypt;

public class BCryptVerify {
    public static void main(String[] args) {
        // Hashes from schema.sql
        String adminHash   = "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lh9i";
        String studentHash = "$2a$10$rI5s.t8sU.3eDx4sLHQdouX6sSlpjzMrPt0TZTUhGCGWp3zRwQWum";

        System.out.println("=== BCrypt Hash Verification ===");
        System.out.println("Admin Hash vs 'Admin@123':    " + BCrypt.checkpw("Admin@123", adminHash));
        System.out.println("Admin Hash vs 'admin@123':    " + BCrypt.checkpw("admin@123", adminHash));
        System.out.println("Student Hash vs 'Student@123':" + BCrypt.checkpw("Student@123", studentHash));
        System.out.println("Student Hash vs 'student@123':" + BCrypt.checkpw("student@123", studentHash));

        // Generate correct hashes for the passwords we want
        System.out.println("\n=== Generating Fresh Correct Hashes ===");
        String newAdminHash   = BCrypt.hashpw("Admin@123",   BCrypt.gensalt(10));
        String newStudentHash = BCrypt.hashpw("Student@123", BCrypt.gensalt(10));
        System.out.println("Admin@123   => " + newAdminHash);
        System.out.println("Student@123 => " + newStudentHash);

        // Verify the new ones
        System.out.println("\n=== Verifying New Hashes ===");
        System.out.println("New admin hash check:   " + BCrypt.checkpw("Admin@123",   newAdminHash));
        System.out.println("New student hash check: " + BCrypt.checkpw("Student@123", newStudentHash));
    }
}
