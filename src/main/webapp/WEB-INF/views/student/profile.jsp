<%-- Student Profile --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>My Profile | Training Institute Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="My Profile"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">My Profile</h1>
                <p class="page-subtitle">Manage your personal and academic details</p>
            </div>
        </div>

        <c:if test="${param.success eq 'updated'}">
            <div class="alert-message alert-success"><i class="fas fa-check-circle"></i> Profile updated successfully!</div>
        </c:if>

        <div class="card" style="max-width: 800px; margin: 0 auto; padding: 40px;">
            <div style="display:flex; gap: 30px; align-items:flex-start; margin-bottom: 40px;">
                <div class="avatar" style="width:100px; height:100px; font-size:48px; border-radius: 50%; background: var(--primary); color: white; display: flex; align-items: center; justify-content: center;">
                    ${student.name.charAt(0)}
                </div>
                <div>
                    <h2>${student.name}</h2>
                    <p style="color:var(--text-muted); margin-bottom:10px;"><i class="fas fa-envelope"></i> ${student.email}</p>
                    <span class="cgpa-badge">CGPA: ${student.cgpa}</span>
                    <span class="status-badge status-open" style="margin-left:10px;">${student.course} - Batch ${student.batchYear}</span>
                </div>
            </div>

            <form action="${pageContext.request.contextPath}/student/profile/update" method="post">
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 20px; border-top: 1px solid rgba(255,255,255,0.1); padding-top:20px;">
                    <div class="form-group">
                        <label class="form-label">Phone Number</label>
                        <input type="text" name="phone" value="${student.phone}" class="form-control" placeholder="+91">
                    </div>
                    <div class="form-group">
                        <label class="form-label">Course Specialization</label>
                        <input type="text" name="course" value="${student.course}" class="form-control" required>
                    </div>
                </div>
                <div class="form-group" style="margin-top:20px;">
                    <label class="form-label">Permanent Address</label>
                    <textarea name="address" class="form-control" rows="2">${student.address}</textarea>
                </div>
                <div class="form-group" style="margin-top:20px;">
                    <label class="form-label">Skills (Comma separated)</label>
                    <textarea name="skills" class="form-control" rows="2" placeholder="Java, Python, React...">${student.skills}</textarea>
                </div>
                
                <div style="margin-top: 30px; text-align: right;">
                    <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Save Changes</button>
                </div>
            </form>
        </div>
    </main>
</body>
</html>
