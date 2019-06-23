<%@ page language="java" contentType="text/html;charset=UTF-8"
	pageEncoding="UTF-8" session="true"
	errorPage="/WEB-INF/jsp/errorPage.jsp"%>
<html>
<head>
<title>Pacific Application Server logout</title>
<link rel="stylesheet" type="text/css"
    href="<%=request.getContextPath()%>/static/commonStyle.css" media="screen" />
</head>
<body>
    <%@ include file="/static/commonPageHeader.html"%>
    <p>
    <table>
        <tr><td><b>RemoteUser:</b></td> <td> <%=request.getRemoteUser()%></td></tr>
        <tr><td><b>Session:</b></td> <td> <%=session.getId()%></td></tr>
        <tr><td><b>RemoteAddr:</b></td> <td> <%=request.getRemoteAddr()%></td></tr>
        <tr><td><b>ServerName:</b></td> <td> <%=request.getServerName()%></td></tr>
    </table>
<%
    String lmodel = application.getInitParameter("contextConfigLocation"); 
    if ( lmodel.matches(".*oeablSecurity-form.*") ) {
%>
	<p>
	<br> Do you want to logout this user?
	<form action="j_spring_security_logout" method="POST">
		<input name="logout" type="submit" value="Logout" />
	</form>
<%
    } else {
%>
    <p>
    <b>Form login is not compatible with the security policy configuration</b>
<%
    }
%>
	<p>
    <%@ include file="/static/commonPageFooter.html"%>
</body>
</html>

