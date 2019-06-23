<%@ page language="java" 
         contentType="text/html;charset=UTF-8" 
         pageEncoding="UTF-8" 
         session="true" 
         errorPage="/WEB-INF/jsp/errorPage.jsp" %>
<html>
<head>
    <link rel="stylesheet" href="../bootstrap/css/bootstrap.min.css"/>
    <link rel="stylesheet" href="../magi/css/Site.css"/>     
</head>
<body> 
<%
    String lmodel = application.getInitParameter("contextConfigLocation"); 
    if ( lmodel.matches(".*oeablSecurity-form.*") ) { 
%>
    <div class="login">
        <div><a href="#"><img src="/static/images/Logo.png" alt="LGI" title="Retour accueil" /></a></div>
        <form class="form-horizontal"  action="j_spring_security_check" method="POST">  
            <div class="input-group inpt">
                <span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
                <input class="form-control" type='text' name='j_username' placeholder="utilisateur@reference" />                 
            </div>
            <div class="input-group inpt">
                <span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
                <input class="form-control" type='text' name='j_password' placeholder="mot de passe" />
            </div>
            <div class="input-group inpt">
               <button class="btn btn-info" name="btn_login" type="submit" >Se connecter</button>                
            </div>           
        </form>
    </div>
<%
    } else {
%>
    <br>
    <b>Form login is not compatible with the security policy configuration</b>
<%
    }
%>
    <%@ include file="/static/html/magiPageFooter.html" %>
</body>
</html>