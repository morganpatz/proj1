<HTML>
  <HEAD>
    <TITLE>Test Main Page</TITLE>
  </HEAD>

  <BODY>
  <!--
      Just a file to test if the security measures work.
    -->
  <%@ page import="security.jsp.*" %>
  <%
     String userid = "";
     Cookie login_cookie = null;
     Cookie cookie = null;
     Cookie[] cookies = null;
     //Get an array of cookies associated with this domain
     cookies = request.getCookies();
     //If any cookies were found, see if any of them contain a valid login.
     if( cookies != null ){
     for(int i = 0; i < cookies.length; i++){
	cookie = cookies[i];
	//out.println(cookie.getName()+"<br>");
	//However, we only want one cookie, the one whose name matches the
	//userid that has logged in on this browser.
	if(i != 0 && userid == ""){
	  userid = cookie.getName();
        }
     }
     }
     //If no login was detected, redirect the user to the login page.
     if(userid == "") {
     out.println("<a href=login.jsp>Please login to access this site.</a>");
     }
     //Else, we have a valid session.
     else {
     out.println("Hello, "+userid+"<br>");
     }		 
     %>
  </BODY>
</HTML>
