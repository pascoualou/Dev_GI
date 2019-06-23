<%@ page language="java" contentType="text/html;charset=UTF-8"
	pageEncoding="UTF-8" session="true"
	errorPage="/WEB-INF/jsp/errorPage.jsp"%>
<html>
<head>
<title>Pacific Application Server logout</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/static/magi/css/commonStyle.css" media="screen" />
<link rel="stylesheet" href="/static/magi/css/Site.css" />
</head>
<body>
    <%@ include file="/static/html/magiPageHeader.html"%>
    <p>
<%
    String lmodel = application.getInitParameter("contextConfigLocation"); 
    if ( lmodel.matches(".*oeablSecurity-form.*") ) {
%>
	<p>
	<br> Souhaitez vous vraiment vous déconnecter ?
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
    <%@ include file="/static/html/magiPageFooter.html"%>
</body>
</html>

