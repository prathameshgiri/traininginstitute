<%-- Admin Exams Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Exams | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h1 class="page-title">Certification Exams</h1>
                <p class="page-subtitle">Manage online examinations</p>
            </div>
            <button class="btn btn-primary" onclick="document.getElementById('addModal').style.display='flex'">
                <i class="fas fa-plus"></i> Add Exam
            </button>
        </div>
        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>Exam Name</th><th>Company/Role</th><th>Duration</th><th>Marks (Pass/Total)</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="e" items="${exams}">
                    <tr>
                        <td><strong>${e.examName}</strong></td>
                        <td>${e.companyName}<br><small style="color:var(--text-muted)">${e.internshipRole}</small></td>
                        <td>${e.duration} mins</td>
                        <td>${e.passingMarks} / ${e.totalMarks}</td>
                        <td><span class="status-badge status-${e.status.toLowerCase()}">${e.status}</span></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty exams}"><tr><td colspan="5" class="empty-state">No exams found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Add Exam Modal -->
    <div class="modal-overlay" id="addModal" style="display:none">
        <div class="modal-box" style="text-align:left; max-width:500px;">
            <h3 style="margin-bottom:20px; font-weight:600;"><i class="fas fa-laptop-code" style="color:var(--primary)"></i> Create New Exam</h3>
            <form action="${pageContext.request.contextPath}/admin/exams/add" method="post">
                <div class="form-group" style="margin-bottom:15px">
                    <label class="form-label">Linked Internship</label>
                    <select name="internship_id" class="form-control" required>
                        <option value="">Select Internship Program</option>
                        <c:forEach var="i" items="${internships}">
                            <option value="${i.internshipId}">${i.companyName} - ${i.role}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group" style="margin-bottom:15px"><label class="form-label">Exam Name</label><input type="text" name="exam_name" class="form-control" required></div>
                <div class="form-group" style="margin-bottom:15px"><label class="form-label">Description</label><textarea name="description" class="form-control" rows="2" required></textarea></div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:20px;">
                    <div class="form-group"><label class="form-label">Duration (Mins)</label><input type="number" name="duration" class="form-control" value="60" required></div>
                    <div class="form-group"><label class="form-label">Passing Marks</label><input type="number" step="0.1" name="passing_marks" class="form-control" value="40" required></div>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:10px;">
                    <button type="button" class="btn-modal-cancel" onclick="document.getElementById('addModal').style.display='none'">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Exam</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
