<%-- Admin Companies Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Companies | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header" style="display:flex; justify-content:space-between; align-items:center;">
            <div>
                <h1 class="page-title">Partner Companies</h1>
                <p class="page-subtitle">Manage hiring partners</p>
            </div>
            <button class="btn btn-primary" onclick="document.getElementById('addModal').style.display='flex'">
                <i class="fas fa-plus"></i> Add Company
            </button>
        </div>
        <div class="card">
            <table class="data-table">
                <thead>
                    <tr><th>Name</th><th>Industry</th><th>Location</th><th>Website</th><th>Contact</th></tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${companies}">
                    <tr>
                        <td><strong>${c.companyName}</strong></td>
                        <td>${c.industry}</td>
                        <td>${c.location}</td>
                        <td><a href="${c.website}" target="_blank" style="color:var(--primary)">${c.website}</a></td>
                        <td>${c.contactEmail}</td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty companies}"><tr><td colspan="5" class="empty-state">No companies found.</td></tr></c:if>
                </tbody>
            </table>
        </div>
    </main>

    <!-- Add Company Modal -->
    <div class="modal-overlay" id="addModal" style="display:none">
        <div class="modal-box" style="text-align:left; max-width:500px;">
            <h3 style="margin-bottom:20px; font-weight:600;"><i class="fas fa-building" style="color:var(--primary)"></i> Add New Company</h3>
            <form action="${pageContext.request.contextPath}/admin/companies/add" method="post">
                <div class="form-group" style="margin-bottom:15px"><label class="form-label">Company Name</label><input type="text" name="company_name" class="form-control" required></div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:15px;">
                    <div class="form-group"><label class="form-label">Industry</label><input type="text" name="industry" class="form-control" required></div>
                    <div class="form-group"><label class="form-label">City/Location</label><input type="text" name="location" class="form-control" required></div>
                </div>
                <div class="form-group" style="margin-bottom:15px"><label class="form-label">Website URL</label><input type="url" name="website" class="form-control" required></div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:15px; margin-bottom:15px;">
                    <div class="form-group"><label class="form-label">Contact Email</label><input type="email" name="contact_email" class="form-control" required></div>
                    <div class="form-group"><label class="form-label">Contact Person</label><input type="text" name="contact_person" class="form-control" required></div>
                </div>
                <div class="form-group" style="margin-bottom:15px"><label class="form-label">Min CGPA Required</label><input type="number" step="0.1" name="eligibility_cgpa" class="form-control" value="0.0" required></div>
                <div class="form-group" style="margin-bottom:20px"><label class="form-label">Description</label><textarea name="description" class="form-control" rows="3"></textarea></div>
                <div style="display:flex; justify-content:flex-end; gap:10px;">
                    <button type="button" class="btn-modal-cancel" onclick="document.getElementById('addModal').style.display='none'">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Company</button>
                </div>
            </form>
        </div>
    </div>
</body>
</html>
