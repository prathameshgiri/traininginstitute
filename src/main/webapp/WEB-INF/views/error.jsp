<%-- Error Page --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Error | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: #0D0D1A; color: #E8E8F5;
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
            padding: 24px;
        }
        .error-box {
            text-align: center; max-width: 480px;
            background: #161629;
            border: 1px solid rgba(255,255,255,.06);
            border-radius: 20px; padding: 48px;
            box-shadow: 0 20px 60px rgba(0,0,0,.5);
        }
        .error-icon { font-size: 64px; margin-bottom: 24px; }
        .error-code { font-size: 72px; font-weight: 800; color: #6C63FF; line-height: 1; margin-bottom: 8px; }
        .error-title { font-size: 22px; font-weight: 700; margin-bottom: 12px; }
        .error-desc  { color: #8888AA; font-size: 15px; line-height: 1.6; margin-bottom: 32px; }
        .error-detail { background: rgba(255,70,70,.08); border: 1px solid rgba(255,70,70,.2); border-radius: 10px; padding: 12px 16px; font-size: 13px; color: #FF7070; margin-bottom: 24px; text-align: left; word-break: break-word; }
        .btn-back {
            display: inline-flex; align-items: center; gap: 8px;
            padding: 12px 24px;
            background: linear-gradient(135deg, #6C63FF, #4B44CC);
            color: #fff; border: none; border-radius: 12px;
            font-size: 15px; font-weight: 600; cursor: pointer;
            text-decoration: none; font-family: inherit;
        }
    </style>
</head>
<body>
    <div class="error-box">
        <div class="error-icon">⚠️</div>
        <div class="error-code">500</div>
        <h1 class="error-title">Something went wrong</h1>
        <p class="error-desc">An unexpected error occurred on the server. Please try again or contact your administrator.</p>

        <%
            String errMsg = (String) request.getAttribute("error");
            if (errMsg == null && exception != null) errMsg = exception.getMessage();
        %>
        <% if (errMsg != null && !errMsg.isEmpty()) { %>
        <div class="error-detail"><i class="fas fa-exclamation-circle"></i> <%= errMsg %></div>
        <% } %>

        <a href="javascript:history.back()" class="btn-back">
            <i class="fas fa-arrow-left"></i> Go Back
        </a>
        &nbsp;&nbsp;
        <a href="${pageContext.request.contextPath}/login" class="btn-back" style="background:rgba(255,255,255,.08);color:#E8E8F5">
            <i class="fas fa-home"></i> Home
        </a>
    </div>
</body>
</html>
