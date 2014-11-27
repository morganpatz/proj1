<HTML>
  <HEAD>
    
    
    <TITLE>Your Login Result</TITLE>
  </HEAD>
  
  <BODY>
    <!--
	Login file for CMPUT391 project, based off of login.jsp made by Hong-Yu
	Zhang:
	  "A simple example to demonstrate how to use JSP to 
	  connect and query a database. 
	  @author  Hong-Yu Zhang, University of Alberta"
      
	Method for checking associated cookies with this domain based off of:
	http://www.tutorialspoint.com/jsp/jsp_cookies_handling.htm

	Author: Austin Lee
      -->
    <%@ page import="java.sql.*" %>
    <%
       // Check to see if a user is already logged in through this browser by
       // checking the cookies associated with this domain.
       String userid2 = "";
       Cookie cookie = null;
       Cookie[] cookies = null;
       // Get an array of cookies associated with this domain
       cookies = request.getCookies();
       // If any cookies were found, see if any of them contain a valid login.
       if (cookies != null) {
       for (int i = 0; i < cookies.length; i++) {
		cookie = cookies[i];
		// out.println(cookie.getName()+"<br>");
		// However, we only want one cookie, the one whose name matches
		// the userid that has logged in on this browser, if it exists.
		if (i != 0 && userid2 == "") {
		    userid2 = cookie.getName();
		}
	}
       }
			   
       // If a login was detected, redirect the user to the main page.
       if (userid2 != "") {
       out.println("<a href=PictureBrowse>Click here to resume browsing.</a>");
       }
       // Else, show the login page.
       else {
       
       if(request.getParameter("bSubmit") != null)
       {
       
       //get the user input from the login page
       String userid = (request.getParameter("USERID")).trim();
       String pass = (request.getParameter("PASSWD")).trim();
       //out.println("<p>Your input User Name is "+userid+"</p>");
       //out.println("<p>Your input password is "+pass+"</p>");
       
       
       //establish the connection to the underlying database
       Connection conn = null;
       
       String driverName = "oracle.jdbc.driver.OracleDriver";
       String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
       
       try{
       //load and register the driver
       Class drvClass = Class.forName(driverName); 
       DriverManager.registerDriver((Driver) drvClass.newInstance());
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       
       }
       
       try{
       //establish the connection 
       conn = DriverManager.getConnection(dbstring,"amlee1","splplus719");
       conn.setAutoCommit(false);
       }
       catch(Exception ex){
       
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       
       
       //select the user table from the underlying db and validate the user
       //name and password
       Statement stmt = null;
       ResultSet rset = null;
       String sql = "select password from users where user_name = '"+userid+"'";
       //out.println(sql);
       try{
       stmt = conn.createStatement();
       rset = stmt.executeQuery(sql);
       }
       
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       
       String truepwd = "";
       
       while(rset != null && rset.next())
       truepwd = (rset.getString(1)).trim();

       // check if the username is a a registerd user
       ResultSet nset = null;
       String name_check = "select USER_NAME from USERS "
       +"where USER_NAME = '"+userid+"'";

       try{ 
       stmt = conn.createStatement();
       nset = stmt.executeQuery(name_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }

       // convert the result set into a string
       String valid_id = "";
       while(nset != null && nset.next())
       valid_id = (nset.getString(1)).trim();
       
       //Display the result.
       if(pass.equals(truepwd) && userid.equals(valid_id) && userid != "") {
       //Create a cookie to allow the server to recognize the login.
       Cookie login_cookie = new Cookie(userid, userid+"'s_cookie");
       response.addCookie(login_cookie);

       //Link to a user's home page should go here.
       out.println("<p><b>Your Login is Successful!</b></p>");
       //out.println("<a href=testmain.jsp>Click here to continue.</a>");
       out.println("<a href=PictureBrowse>Click here to continue.</a>");
       }

       else
       { out.println("<p><b>Either your username or Your password is invalid!</b></p>");
       //Prompt the user to try again, or register.
       out.println("<form method=post action=login.jsp>");
       out.println("UserName: <input type=text name=USERID maxlength=24><br>");
       out.println("Password: <input type=password name=PASSWD maxlength=24><br>");
       out.println("<input type=submit name=bSubmit value=Submit>");
       out.println("</form>");
       out.println("New to this site? ");
       out.println("<a href=register.jsp>Please register here!</a>");
       }
       
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       }

       // Else, if nothing has been submitted, display the login page.
       else
       {
       out.println("<form method=post action=login.jsp>");
       out.println("UserName: <input type=text name=USERID maxlength=24><br>");
       out.println("Password: <input type=password name=PASSWD maxlength=24><br>");
       out.println("<input type=submit name=bSubmit value=Submit>");
       out.println("</form>");

       //Ask the user to register
       out.println("New to this site? ");
       out.println("<a href=register.jsp>Please register here!</a>");
       }
       }
       %>
    
    
    
  </BODY>
</HTML>

