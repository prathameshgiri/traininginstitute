<%-- Admin Students Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Students | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Registered Students</h1>
                <p class="page-subtitle">Manage student profiles</p>
            </div>
        </div>
        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>ID</th><th>Name</th><th>Email</th><th>Course</th><th>CGPA</th><th>Phone</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${students}">
                    <tr>
                        <td>${s.studentId}</td>
                        <td><strong>${s.name}</strong></td>
                        <td>${s.email}</td>
                        <td>${s.course}</td>
                        <td><span class="cgpa-badge">${s.cgpa}</span></td>
                        <td>${s.phone}</td>
                        <td>
                            <button class="btn btn-sm btn-outline" 
                                    onclick="openAssignModal('${s.userId}', '${s.name}')">
                                <i class="fas fa-plus"></i> Assign Exam
                            </button>
                        </td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty students}"><tr><td colspan="6" class="empty-state">No students found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Assign Exam Modal -->
    <div class="modal-overlay" id="assignModal" style="display:none">
        <div class="modal-box" style="text-align:left; max-width:450px;">
            <h3 style="margin-bottom:20px; font-weight:600;"><i class="fas fa-clipboard-check" style="color:var(--primary)"></i> Assign Exam</h3>
            <form action="${pageContext.request.contextPath}/admin/exams/assign" method="post">
                <input type="hidden" name="user_id" id="assignUserId">
                <div class="form-group" style="margin-bottom:15px">
                    <label class="form-label">Student Name</label>
                    <input type="text" id="assignStudentName" class="form-control" readonly>
                </div>
                <div class="form-group" style="margin-bottom:20px">
                    <label class="form-label">Select Exam</label>
                    <select name="exam_id" class="form-control" required>
                        <option value="">Choose Exam to Assign</option>
                        <c:forEach var="e" items="${exams}">
                            <option value="${e.examId}">${e.examName} (${e.companyName})</option>
                        </c:forEach>
                    </select>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:10px;">
                    <button type="button" class="btn-modal-cancel" onclick="document.getElementById('assignModal').style.display='none'">Cancel</button>
                    <button type="submit" class="btn btn-primary">Assign Now</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openAssignModal(userId, name) {
            document.getElementById('assignUserId').value = userId;
            document.getElementById('assignStudentName').value = name;
            document.getElementById('assignModal').style.display = 'flex';
        }
    </script>
</body>
</html>
