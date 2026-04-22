<%-- Login Page - Training Institute Portal --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Training Institute Portal</title>
    <meta name="description" content="Login to the Training Institute Management Portal - Manage students, internships, and certifications.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <style>
        :root {
            --primary:    #6C63FF;
            --primary-dark: #4B44CC;
            --secondary:  #FF6584;
            --accent:     #43E97B;
            --bg-dark:    #0D0D1A;
            --bg-card:    #161629;
            --bg-input:   #1E1E36;
            --text-light: #E8E8F5;
            --text-muted: #8888AA;
            --border:     rgba(108,99,255,.25);
            --glow:       0 0 40px rgba(108,99,255,.3);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-dark);
            color: var(--text-light);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        /* Animated background */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background: radial-gradient(ellipse at 20% 50%, rgba(108,99,255,.12) 0%, transparent 60%),
                        radial-gradient(ellipse at 80% 20%, rgba(255,101,132,.08) 0%, transparent 50%),
                        radial-gradient(ellipse at 60% 80%, rgba(67,233,123,.06) 0%, transparent 50%);
            pointer-events: none;
            animation: bgPulse 8s ease-in-out infinite alternate;
        }
        @keyframes bgPulse {
            0%  { opacity: .8; }
            100%{ opacity: 1; }
        }
        /* Floating particles */
        .particles span {
            position: fixed;
            width: 3px; height: 3px;
            border-radius: 50%;
            background: var(--primary);
            opacity: .4;
            animation: float linear infinite;
        }
        @keyframes float {
            0%   { transform: translateY(100vh) scale(0); opacity: 0; }
            10%  { opacity: .4; }
            90%  { opacity: .4; }
            100% { transform: translateY(-10vh) scale(1); opacity: 0; }
        }

        .login-container {
            display: flex;
            gap: 0;
            width: 90vw;
            max-width: 960px;
            border-radius: 24px;
            overflow: hidden;
            box-shadow: 0 30px 80px rgba(0,0,0,.6), var(--glow);
            animation: slideUp .6s ease;
            position: relative;
            z-index: 10;
        }
        @keyframes slideUp {
            from { opacity:0; transform: translateY(40px); }
            to   { opacity:1; transform: translateY(0); }
        }

        /* Left Panel - Branding */
        .login-brand {
            flex: 1;
            background: linear-gradient(135deg, #6C63FF 0%, #4B44CC 40%, #2D1B8B 100%);
            padding: 60px 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        .login-brand::before {
            content: '';
            position: absolute;
            top: -50%; right: -30%;
            width: 200%; height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,.08) 0%, transparent 60%);
        }
        .brand-logo {
            width: 72px; height: 72px;
            background: rgba(255,255,255,.15);
            border-radius: 20px;
            display: flex; align-items: center; justify-content: center;
            font-size: 32px;
            margin-bottom: 32px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,.2);
        }
        .brand-title {
            font-size: 32px;
            font-weight: 800;
            color: #fff;
            line-height: 1.2;
            margin-bottom: 16px;
        }
        .brand-subtitle {
            font-size: 15px;
            color: rgba(255,255,255,.75);
            line-height: 1.6;
            margin-bottom: 40px;
        }
        .brand-features { list-style: none; }
        .brand-features li {
            display: flex; align-items: center; gap: 12px;
            color: rgba(255,255,255,.85);
            font-size: 14px;
            padding: 8px 0;
        }
        .brand-features li i {
            width: 28px; height: 28px;
            background: rgba(255,255,255,.15);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 12px;
            flex-shrink: 0;
        }
        .brand-author {
            margin-top: 48px;
            padding-top: 24px;
            border-top: 1px solid rgba(255,255,255,.15);
            font-size: 12px;
            color: rgba(255,255,255,.6);
        }

        /* Right Panel - Form */
        .login-form-panel {
            flex: 1;
            background: var(--bg-card);
            padding: 60px 48px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .form-header { margin-bottom: 36px; }
        .form-header h2 {
            font-size: 26px;
            font-weight: 700;
            color: var(--text-light);
            margin-bottom: 8px;
        }
        .form-header p { font-size: 14px; color: var(--text-muted); }

        .alert {
            padding: 14px 18px;
            border-radius: 12px;
            font-size: 14px;
            margin-bottom: 24px;
            display: flex; align-items: center; gap: 10px;
        }
        .alert-danger { background: rgba(255,70,70,.12); border: 1px solid rgba(255,70,70,.3); color: #FF7070; }
        .alert-success{ background: rgba(67,233,123,.12); border: 1px solid rgba(67,233,123,.3); color: #43E97B; }

        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: .5px;
            margin-bottom: 8px;
        }
        .input-wrapper {
            position: relative;
        }
        .input-wrapper i {
            position: absolute;
            left: 16px; top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 15px;
            pointer-events: none;
        }
        .form-control {
            width: 100%;
            padding: 14px 16px 14px 44px;
            background: var(--bg-input);
            border: 1px solid var(--border);
            border-radius: 12px;
            color: var(--text-light);
            font-size: 15px;
            font-family: 'Inter', sans-serif;
            transition: all .2s;
            outline: none;
        }
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 4px rgba(108,99,255,.15);
            background: #1a1a30;
        }
        .form-control::placeholder { color: var(--text-muted); }

        .btn-primary {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            transition: all .2s;
            display: flex; align-items: center; justify-content: center; gap: 10px;
            margin-top: 8px;
            position: relative;
            overflow: hidden;
        }
        .btn-primary::before {
            content: '';
            position: absolute; inset: 0;
            background: linear-gradient(135deg, rgba(255,255,255,.1), transparent);
            opacity: 0;
            transition: opacity .2s;
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(108,99,255,.5); }
        .btn-primary:hover::before { opacity: 1; }
        .btn-primary:active { transform: translateY(0); }

        .form-footer {
            text-align: center;
            margin-top: 28px;
            font-size: 14px;
            color: var(--text-muted);
        }
        .form-footer a { color: var(--primary); text-decoration: none; font-weight: 500; }
        .form-footer a:hover { text-decoration: underline; }

        .divider {
            display: flex; align-items: center; gap: 16px;
            margin: 24px 0;
            color: var(--text-muted);
            font-size: 12px;
        }
        .divider::before, .divider::after {
            content: ''; flex: 1; height: 1px; background: var(--border);
        }

        /* Demo credentials */
        .demo-creds {
            background: rgba(108,99,255,.08);
            border: 1px solid rgba(108,99,255,.2);
            border-radius: 12px;
            padding: 16px;
            font-size: 13px;
        }
        .demo-creds h4 { color: var(--primary); margin-bottom: 10px; font-size: 12px; text-transform: uppercase; letter-spacing:.5px; }
        .demo-row { display: flex; justify-content: space-between; gap: 16px; }
        .demo-item {
            flex: 1;
            background: var(--bg-input);
            border-radius: 8px;
            padding: 10px 12px;
            cursor: pointer;
            transition: all .2s;
            border: 1px solid transparent;
        }
        .demo-item:hover { border-color: var(--primary); }
        .demo-item .role { font-weight: 600; color: var(--text-light); font-size: 12px; }
        .demo-item .cred { color: var(--text-muted); font-size: 11px; }

        @media (max-width: 768px) {
            .login-container { flex-direction: column; width: 95vw; }
            .login-brand { padding: 40px 32px; }
            .login-form-panel { padding: 40px 32px; }
            .brand-title { font-size: 24px; }
        }
    </style>
</head>
<body>
    <div class="particles">
        <span style="left:10%;animation-duration:8s;animation-delay:0s;"></span>
        <span style="left:25%;animation-duration:12s;animation-delay:2s;background:#FF6584;"></span>
        <span style="left:50%;animation-duration:9s;animation-delay:1s;"></span>
        <span style="left:75%;animation-duration:11s;animation-delay:3s;background:#43E97B;"></span>
        <span style="left:90%;animation-duration:7s;animation-delay:0.5s;"></span>
    </div>

    <div class="login-container">
        <!-- Left: Branding -->
        <div class="login-brand">
            <div class="brand-logo">🎓</div>
            <h1 class="brand-title">Training<br>Institute Portal</h1>
            <p class="brand-subtitle">An enterprise-grade platform for managing the complete student journey from registration through certification.</p>
            <ul class="brand-features">
                <li><i class="fas fa-user-graduate"></i> Student lifecycle management</li>
                <li><i class="fas fa-briefcase"></i> Internship application & selection</li>
                <li><i class="fas fa-laptop-code"></i> Online proctored examination</li>
                <li><i class="fas fa-chart-bar"></i> Real-time analytics & reports</li>
                <li><i class="fas fa-shield-alt"></i> Anti-cheat & security monitoring</li>
            </ul>
            <div class="brand-author">
                Designed & compiled by <strong>Dr. Geeta Mete</strong>
            </div>
        </div>

        <!-- Right: Form -->
        <div class="login-form-panel">
            <div class="form-header">
                <h2>Welcome Back</h2>
                <p>Sign in to access your portal</p>
            </div>

            <!-- Messages -->
            <c:if test="${not empty error}">
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> ${error}
                </div>
            </c:if>
            <c:if test="${param.success eq 'registered'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> Registration successful! Please login.
                </div>
            </c:if>
            <c:if test="${param.success eq 'logged_out'}">
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i> You have been logged out successfully.
                </div>
            </c:if>
            <c:if test="${param.error eq 'session_expired'}">
                <div class="alert alert-danger">
                    <i class="fas fa-clock"></i> Session expired. Please login again.
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post" id="loginForm">
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrapper">
                        <i class="fas fa-envelope"></i>
                        <input type="email" class="form-control" id="email" name="email"
                               placeholder="your@email.com" required autofocus
                               value="${param.email}">
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <i class="fas fa-lock"></i>
                        <input type="password" class="form-control" id="password" name="password"
                               placeholder="••••••••" required>
                    </div>
                </div>

                <button type="submit" class="btn-primary" id="loginBtn">
                    <i class="fas fa-sign-in-alt"></i>
                    Sign In
                </button>
            </form>

            <div class="divider">Demo Credentials</div>

            <div class="demo-creds">
                <h4>Quick Fill</h4>
                <div class="demo-row">
                    <div class="demo-item" onclick="fillCreds('admin@traininginstitute.com','Admin@123')">
                        <div class="role">👑 Admin</div>
                        <div class="cred">admin@traininginstitute.com</div>
                        <div class="cred">Admin@123</div>
                    </div>
                    <div class="demo-item" onclick="fillCreds('aarvi.kulkarni@student.com','Student@123')">
                        <div class="role">🎓 Student</div>
                        <div class="cred">aarvi.kulkarni@student.com</div>
                        <div class="cred">Student@123</div>
                    </div>
                </div>
            </div>

            <div class="form-footer">
                New student? <a href="${pageContext.request.contextPath}/register">Register here</a>
            </div>
        </div>
    </div>

    <script>
        function fillCreds(email, pass) {
            document.getElementById('email').value = email;
            document.getElementById('password').value = pass;
        }
        document.getElementById('loginForm').addEventListener('submit', function() {
            const btn = document.getElementById('loginBtn');
            btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing In...';
            btn.disabled = true;
        });
    </script>
</body>
</html>
