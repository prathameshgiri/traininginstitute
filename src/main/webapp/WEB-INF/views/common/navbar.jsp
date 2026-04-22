<%-- Reusable: Navigation Header Fragment --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<nav class="navbar" id="mainNav">
    <div class="nav-brand">
        <span class="nav-icon"><i class="fas fa-graduation-cap"></i></span>
        <span class="nav-title">TI Portal</span>
    </div>
    <div class="nav-links" id="navLinks">
        <c:choose>
            <c:when test="${sessionScope.user.role eq 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/dashboard" class="${pageTitle eq 'Dashboard' ? 'active' : ''}">
                    <i class="fas fa-tachometer-alt"></i> Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/admin/students" class="${pageTitle eq 'Students' ? 'active' : ''}">
                    <i class="fas fa-user-graduate"></i> Students
                </a>
                <a href="${pageContext.request.contextPath}/admin/companies" class="${pageTitle eq 'Companies' ? 'active' : ''}">
                    <i class="fas fa-building"></i> Companies
                </a>
                <a href="${pageContext.request.contextPath}/admin/internships" class="${pageTitle eq 'Internships' ? 'active' : ''}">
                    <i class="fas fa-briefcase"></i> Internships
                </a>
                <a href="${pageContext.request.contextPath}/admin/applications" class="${pageTitle eq 'Applications' ? 'active' : ''}">
                    <i class="fas fa-file-alt"></i> Applications
                </a>
                <a href="${pageContext.request.contextPath}/admin/exams" class="${pageTitle eq 'Exams' ? 'active' : ''}">
                    <i class="fas fa-clipboard-list"></i> Exams
                </a>
                <a href="${pageContext.request.contextPath}/admin/reports" class="${pageTitle eq 'Reports' ? 'active' : ''}">
                    <i class="fas fa-chart-bar"></i> Reports
                </a>
                <a href="${pageContext.request.contextPath}/admin/audit-logs" class="${pageTitle eq 'Audit Logs' ? 'active' : ''}">
                    <i class="fas fa-shield-alt"></i> Audit
                </a>
            </c:when>
            <c:when test="${sessionScope.user.role eq 'STUDENT'}">
                <a href="${pageContext.request.contextPath}/student/dashboard" class="${pageTitle eq 'Dashboard' ? 'active' : ''}">
                    <i class="fas fa-home"></i> Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/student/profile" class="${pageTitle eq 'Profile' ? 'active' : ''}">
                    <i class="fas fa-user-circle"></i> Profile
                </a>
                <a href="${pageContext.request.contextPath}/student/internships" class="${pageTitle eq 'Internships' ? 'active' : ''}">
                    <i class="fas fa-briefcase"></i> Internships
                </a>
                <a href="${pageContext.request.contextPath}/student/applications" class="${pageTitle eq 'Applications' ? 'active' : ''}">
                    <i class="fas fa-file-alt"></i> My Applications
                </a>
                <a href="${pageContext.request.contextPath}/student/exam/list" class="${pageTitle eq 'Exams' ? 'active' : ''}">
                    <i class="fas fa-laptop-code"></i> Exams
                </a>
            </c:when>
        </c:choose>
    </div>
    <div class="nav-user">
        <div class="user-pill" onclick="toggleUserMenu()">
            <div class="user-avatar">${sessionScope.user.name.charAt(0)}</div>
            <div class="user-info">
                <span class="user-name">${sessionScope.user.name}</span>
                <span class="user-role">${sessionScope.user.role}</span>
            </div>
            <i class="fas fa-chevron-down" id="chevron"></i>
        </div>
        <div class="user-menu" id="userMenu">
            <c:if test="${sessionScope.user.role eq 'STUDENT'}">
                <a href="${pageContext.request.contextPath}/student/profile"><i class="fas fa-cog"></i> Profile Settings</a>
            </c:if>
            <c:if test="${sessionScope.user.role eq 'ADMIN'}">
                <a href="${pageContext.request.contextPath}/admin/audit-logs"><i class="fas fa-history"></i> Activity Log</a>
            </c:if>
            <div class="menu-divider"></div>
            <a href="${pageContext.request.contextPath}/logout" class="logout-link"><i class="fas fa-sign-out-alt"></i> Logout</a>
        </div>
    </div>
    <button class="nav-toggle" onclick="toggleNav()" id="navToggle">
        <i class="fas fa-bars"></i>
    </button>
</nav>
<script>
    function toggleUserMenu() {
        document.getElementById('userMenu').classList.toggle('show');
        document.getElementById('chevron').classList.toggle('rotated');
    }
    function toggleNav() {
        document.getElementById('navLinks').classList.toggle('mobile-show');
    }
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.nav-user')) {
            document.getElementById('userMenu').classList.remove('show');
            document.getElementById('chevron').classList.remove('rotated');
        }
    });
</script>
