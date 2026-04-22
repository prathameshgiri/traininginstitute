<%-- Admin Applications Management --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Applications | Admin Panel</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <c:set var="pageTitle" value="Applications"/>
</head>
<body class="dashboard-body">
    <%@ include file="../common/navbar.jsp" %>
    <main class="main-content">
        <div class="page-header">
            <div>
                <h1 class="page-title">Internship Applications</h1>
                <p class="page-subtitle">Review, shortlist, and select candidates</p>
            </div>
            <!-- Filter by internship -->
            <form method="get" style="display:flex;gap:10px;align-items:center">
                <select name="internship_id" class="form-control" style="width:280px" onchange="this.form.submit()">
                    <option value="">All Internships</option>
                    <c:forEach var="intern" items="${internships}">
                    <option value="${intern.internshipId}" ${param.internship_id == intern.internshipId ? 'selected' : ''}>
                        ${intern.companyName} - ${intern.role}
                    </option>
                    </c:forEach>
                </select>
            </form>
        </div>

        <c:if test="${param.success eq 'updated'}">
            <div class="alert-message alert-success"><i class="fas fa-check-circle"></i> Application status updated successfully.</div>
        </c:if>

        <!-- Filter Chips -->
        <div class="filter-row">
            <c:forEach var="statusOpt" items="${['ALL','APPLIED','SHORTLISTED','SELECTED','REJECTED']}">
            <button class="filter-chip ${empty param.status or param.status eq statusOpt ? 'active' : ''}"
                    onclick="filterTable('${statusOpt}')">
                ${statusOpt} (${statusOpt eq 'ALL' ? applications.size() : ''})
            </button>
            </c:forEach>
        </div>

        <div class="card">
            <div class="table-controls">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchInput" placeholder="Search students..." oninput="searchTable()">
                </div>
                <span style="color:var(--text-muted);font-size:14px">${applications.size()} applications</span>
            </div>
            <table class="data-table" id="appTable">
                <thead>
                <tr>
                    <th>#</th><th>Student</th><th>Company / Role</th>
                    <th>CGPA</th><th>Applied</th><th>Status</th><th>Action</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="app" items="${applications}" varStatus="s">
                <tr data-status="${app.status}">
                    <td>${s.count}</td>
                    <td>
                        <div class="user-cell">
                            <div class="avatar-sm">${app.studentName.charAt(0)}</div>
                            <div>
                                <div class="cell-name">${app.studentName}</div>
                                <div class="cell-sub">${app.studentEmail}</div>
                                <div class="cell-sub">${app.enrollmentNumber}</div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div class="cell-name">${app.companyName}</div>
                        <div class="cell-sub">${app.internshipRole}</div>
                    </td>
                    <td><span class="cgpa-badge">${app.cgpa}</span></td>
                    <td><fmt:formatDate value="${app.appliedDate}" pattern="dd MMM yyyy"/></td>
                    <td><span class="status-badge status-${app.status.toLowerCase()}" id="statusBadge${app.applicationId}">${app.status}</span></td>
                    <td>
                        <div style="display:flex;gap:6px">
                            <button class="btn btn-sm btn-secondary" onclick="viewDetails(${app.applicationId},'${app.studentName}','${app.companyName}','${app.internshipRole}','${app.status}','${app.cgpa}','${app.course}')" title="View">
                                <i class="fas fa-eye"></i>
                            </button>
                            <c:if test="${app.status ne 'SELECTED' and app.status ne 'REJECTED'}">
                            <button class="btn btn-sm btn-success" onclick="updateStatus(${app.applicationId},'SHORTLISTED')" title="Shortlist">
                                <i class="fas fa-star"></i>
                            </button>
                            <button class="btn btn-sm btn-primary" onclick="updateStatus(${app.applicationId},'SELECTED')" title="Select">
                                <i class="fas fa-check"></i>
                            </button>
                            <button class="btn btn-sm btn-danger" onclick="updateStatus(${app.applicationId},'REJECTED')" title="Reject">
                                <i class="fas fa-times"></i>
                            </button>
                            </c:if>
                        </div>
                    </td>
                </tr>
                </c:forEach>
                <c:if test="${empty applications}">
                    <tr><td colspan="7" class="empty-state">No applications found.</td></tr>
                </c:if>
                </tbody>
            </table>
        </div>
    </main>

    <!-- View Details Modal -->
    <div class="modal-overlay" id="detailsModal" style="display:none">
        <div class="modal-box" style="text-align:left;max-width:520px">
            <h3 style="margin-bottom:20px"><i class="fas fa-user-graduate" style="color:var(--primary)"></i> Application Details</h3>
            <div id="detailsContent"></div>
            <button class="btn-modal-cancel" style="margin-top:20px" onclick="document.getElementById('detailsModal').style.display='none'">
                Close
            </button>
        </div>
    </div>

    <!-- Update Status Form (hidden) -->
    <form id="statusForm" action="${pageContext.request.contextPath}/admin/applications/update" method="post" style="display:none">
        <input type="hidden" name="application_id" id="statusAppId">
        <input type="hidden" name="status" id="statusValue">
        <input type="hidden" name="remarks" id="statusRemarks">
    </form>

    <script>
    function filterTable(status) {
        document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
        event.target.classList.add('active');
        document.querySelectorAll('#appTable tbody tr').forEach(row => {
            row.style.display = status === 'ALL' || row.dataset.status === status ? '' : 'none';
        });
    }
    function searchTable() {
        const q = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('#appTable tbody tr').forEach(row => {
            row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    }
    function updateStatus(appId, status) {
        const remarks = status === 'REJECTED'
            ? (prompt('Enter reason for rejection (optional):') || '')
            : '';
        if (status === 'REJECTED' && remarks === null) return; // user cancelled

        const confirmMsg = {
            'SHORTLISTED': 'Shortlist this candidate?',
            'SELECTED': 'Select this candidate? They will be eligible for the certification exam.',
            'REJECTED': 'Reject this application?'
        };
        if (!confirm(confirmMsg[status] || 'Update status?')) return;

        document.getElementById('statusAppId').value = appId;
        document.getElementById('statusValue').value = status;
        document.getElementById('statusRemarks').value = remarks;
        document.getElementById('statusForm').submit();
    }
    function viewDetails(appId, name, company, role, status, cgpa, course) {
        document.getElementById('detailsContent').innerHTML = `
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px">
                <div><div style="font-size:12px;color:var(--text-muted);text-transform:uppercase;margin-bottom:4px">Student</div><div style="font-weight:600">${name}</div></div>
                <div><div style="font-size:12px;color:var(--text-muted);text-transform:uppercase;margin-bottom:4px">Course</div><div>${course}</div></div>
                <div><div style="font-size:12px;color:var(--text-muted);text-transform:uppercase;margin-bottom:4px">Company</div><div style="font-weight:600">${company}</div></div>
                <div><div style="font-size:12px;color:var(--text-muted);text-transform:uppercase;margin-bottom:4px">Role</div><div>${role}</div></div>
                <div><div style="font-size:12px;color:var(--text-muted);text-transform:uppercase;margin-bottom:4px">CGPA</div><div class="cgpa-badge">${cgpa}</div></div>
                <div><div style="font-size:12px;color:var(--text-muted);text-transform:uppercase;margin-bottom:4px">Status</div><div class="status-badge status-${status.toLowerCase()}">${status}</div></div>
            </div>`;
        document.getElementById('detailsModal').style.display = 'flex';
    }
    </script>
</body>
</html>
