<%-- Root redirect to login --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    Object user = session.getAttribute("user");
    if (user != null) {
        response.sendRedirect(ctx + "/admin/dashboard");
    } else {
        response.sendRedirect(ctx + "/login");
    }
%>
