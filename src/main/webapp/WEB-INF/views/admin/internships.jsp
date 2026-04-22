<%-- Admin Internships Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Internships | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h1 class="page-title">Internship Drives</h1>
                <p class="page-subtitle">Manage open internship opportunities</p>
            </div>
            <button class="btn btn-primary" onclick="document.getElementById('addModal').style.display='flex'">
                <i class="fas fa-plus"></i> Add Internship
            </button>
        </div>
        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>Role</th><th>Company</th><th>Stipend</th><th>Eligibility CGPA</th><th>Deadline</th><th>Status</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="i" items="${internships}">
                    <tr>
                        <td><strong>${i.role}</strong></td>
                        <td>${i.companyName}</td>
                        <td>${i.stipend} / month</td>
                        <td><span class="cgpa-badge">${i.eligibilityCgpa}</span></td>
                        <td>${i.deadline}</td>
                        <td><span class="status-badge status-${i.status.toLowerCase()}">${i.status}</span></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty internships}"><tr><td colspan="6" class="empty-state">No internships found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Add Internship Modal -->
    <div class="modal-overlay" id="addModal" style="display:none">
        <div class="modal-box" style="text-align:left; max-width:600px;">
            <h3 style="margin-bottom:20px; font-weight:600;"><i class="fas fa-briefcase" style="color:var(--primary)"></i> Add New Internship</h3>
            <form action="${pageContext.request.contextPath}/admin/internships/add" method="post">
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:15px;">
                    <div class="form-group">
                        <label class="form-label">Company</label>
                        <select name="company_id" class="form-control" required>
                            <option value="">Select Company</option>
                            <c:forEach var="c" items="${companies}">
                                <option value="${c.companyId}">${c.companyName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-group"><label class="form-label">Role / Job Title</label><input type="text" name="role" class="form-control" required></div>
                </div>
                <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:15px; margin-bottom:15px;">
                    <div class="form-group"><label class="form-label">Stipend (Min)</label><input type="number" name="stipend" class="form-control" value="0.0" required></div>
                    <div class="form-group"><label class="form-label">Duration (Mos)</label><input type="number" name="duration_months" class="form-control" value="3" required></div>
                    <div class="form-group"><label class="form-label">Total Seats</label><input type="number" name="seats" class="form-control" value="10" required></div>
                </div>
                <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:15px; margin-bottom:15px;">
                    <div class="form-group"><label class="form-label">Deadline</label><input type="date" name="deadline" class="form-control" required></div>
                    <div class="form-group"><label class="form-label">Min CGPA</label><input type="number" step="0.1" name="eligibility_cgpa" class="form-control" value="6.0" required></div>
                    <div class="form-group"><label class="form-label">Location</label><input type="text" name="location" class="form-control" placeholder="Remote / City" required></div>
                </div>
                <div class="form-group" style="margin-bottom:15px">
                    <label class="form-label">Skills Required</label>
                    <input type="text" name="skills_required" class="form-control" placeholder="Java, SQL, Communication..." required>
                </div>
                <div class="form-group" style="margin-bottom:20px">
                    <label class="form-label">Description</label>
                    <textarea name="description" class="form-control" rows="3" required></textarea>
                </div>
                <div style="display:flex; justify-content:flex-end; gap:10px;">
                    <button type="button" class="btn-modal-cancel" onclick="document.getElementById('addModal').style.display='none'">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Internship</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
