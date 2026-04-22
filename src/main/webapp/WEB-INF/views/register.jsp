<%-- Registration Page --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Student Registration | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <style>
        .register-page { min-height:100vh; background:var(--bg-dark); display:flex; flex-direction:column; align-items:center; padding:48px 16px; }
        .reg-header { text-align:center; margin-bottom:40px; }
        .reg-header h1 { font-size:30px; font-weight:800; }
        .reg-header p  { color:var(--text-muted); margin-top:8px; }
        .reg-card { background:var(--bg-card); border:1px solid var(--border-light); border-radius:var(--radius); padding:40px; width:100%; max-width:680px; box-shadow:var(--shadow); }
    </style>
</head>
<body class="register-page">
    <div class="reg-header">
        <a href="${pageContext.request.contextPath}/login" style="font-size:13px;color:var(--text-muted);display:block;margin-bottom:16px">
            ← Back to Login
        </a>
        <div style="font-size:40px;margin-bottom:12px">🎓</div>
        <h1>Student Registration</h1>
        <p>Create your Training Institute Portal account</p>
    </div>

    <div class="reg-card">
        <c:if test="${not empty error}">
            <div class="alert-message alert-error" style="margin-bottom:24px"><i class="fas fa-exclamation-circle"></i> ${error}</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validateForm()">
            <!-- Personal Info -->
            <h4 style="font-size:14px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:16px;padding-bottom:10px;border-bottom:1px solid var(--border-light)">
                <i class="fas fa-user" style="color:var(--primary)"></i> Personal Information
            </h4>
            <div class="form-row" style="margin-bottom:16px">
                <div class="form-group">
                    <label class="form-label">Full Name *</label>
                    <input type="text" name="name" class="form-control" placeholder="Aarvi Kulkarni" required value="${param.name}">
                </div>
                <div class="form-group">
                    <label class="form-label">Email *</label>
                    <input type="email" name="email" class="form-control" placeholder="aarvi@student.com" required value="${param.email}">
                </div>
            </div>
            <div class="form-row" style="margin-bottom:24px">
                <div class="form-group">
                    <label class="form-label">Password *</label>
                    <input type="password" name="password" class="form-control" placeholder="Min. 8 characters" required id="pwd">
                </div>
                <div class="form-group">
                    <label class="form-label">Confirm Password *</label>
                    <input type="password" name="confirm_password" class="form-control" placeholder="Repeat password" required id="cpwd">
                </div>
            </div>

            <!-- Academic Info -->
            <h4 style="font-size:14px;font-weight:700;color:var(--text-muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:16px;padding-bottom:10px;border-bottom:1px solid var(--border-light)">
                <i class="fas fa-graduation-cap" style="color:var(--primary)"></i> Academic Information
            </h4>
            <div class="form-row" style="margin-bottom:16px">
                <div class="form-group">
                    <label class="form-label">Course *</label>
                    <select name="course" class="form-control" required>
                        <option value="">Select Course</option>
                        <option value="B.Tech Computer Science" ${param.course eq 'B.Tech Computer Science' ? 'selected' : ''}>B.Tech Computer Science</option>
                        <option value="B.Tech Information Technology">B.Tech Information Technology</option>
                        <option value="B.Tech Electronics">B.Tech Electronics</option>
                        <option value="MCA">MCA</option>
                        <option value="B.Sc Computer Science">B.Sc Computer Science</option>
                        <option value="M.Tech">M.Tech</option>
                        <option value="MBA">MBA</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">CGPA (0.00 - 10.00) *</label>
                    <input type="number" name="cgpa" class="form-control" placeholder="8.50"
                           step="0.01" min="0.00" max="10.00" required value="${param.cgpa}">
                </div>
            </div>
            <div class="form-row" style="margin-bottom:32px">
                <div class="form-group">
                    <label class="form-label">Phone Number</label>
                    <input type="tel" name="phone" class="form-control" placeholder="9876543210" value="${param.phone}">
                </div>
                <div class="form-group">
                    <label class="form-label">Enrollment Number</label>
                    <input type="text" name="enrollment_number" class="form-control" placeholder="EN2024001" value="${param.enrollment_number}">
                </div>
            </div>

            <button type="submit" class="btn btn-primary" style="width:100%;padding:14px;font-size:16px" id="regBtn">
                <i class="fas fa-user-plus"></i> Create Account
            </button>
        </form>

        <div style="text-align:center;margin-top:24px;font-size:14px;color:var(--text-muted)">
            Already have an account? <a href="${pageContext.request.contextPath}/login" style="color:var(--primary);font-weight:500">Sign In</a>
        </div>
    </div>

    <div style="margin-top:24px;font-size:12px;color:var(--text-dim);text-align:center">
        Designed & compiled by Dr. Geeta Mete
    </div>

    <script>
    function validateForm() {
        const pwd  = document.getElementById('pwd').value;
        const cpwd = document.getElementById('cpwd').value;
        if (pwd.length < 8) {
            alert('Password must be at least 8 characters.');
            return false;
        }
        if (pwd !== cpwd) {
            alert('Passwords do not match.');
            return false;
        }
        document.getElementById('regBtn').innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating Account...';
        document.getElementById('regBtn').disabled = true;
        return true;
    }
    </script>
</body>
</html>
