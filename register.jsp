<HTML>
  <HEAD>


    <TITLE>Registration</TITLE>
  </HEAD>

  <BODY>
    <!--A simple example to demonstrate how to use JSP to 
	connect and query a database. 
	@author  Hong-Yu Zhang, University of Alberta
      -->
    <%@ page import="java.sql.*" %>
    <%

       if(request.getParameter("bSubmit") != null)
       {
       //get the user input from the registration page
       String userid = (request.getParameter("USERID")).trim();
       String pass = (request.getParameter("PASSWD")).trim();
       String fname = (request.getParameter("FNAME")).trim();
       String lname = (request.getParameter("LNAME")).trim();
       String address = (request.getParameter("ADDRESS")).trim();
       String email = (request.getParameter("EMAIL")).trim();
       String phone = (request.getParameter("PHONE")).trim();
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
       //--------------make sure to have the right credentials!-------------
       conn = DriverManager.getConnection(dbstring,"amlee1","splplus719");
       conn.setAutoCommit(false);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       //Check if the selected username or email is already in the database
       Statement check = null;
       ResultSet nset = null;
       ResultSet eset = null;
       String name_check = "select USER_NAME from USERS "
       +"where USER_NAME = '"+userid+"'";
       String email_check = "select EMAIL from PERSONS "
       +"where EMAIL = '"+email+"'";
       try{ 
       check = conn.createStatement();
       nset = check.executeQuery(name_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       String idtaken = "";
       while(nset != null && nset.next())
       idtaken = (nset.getString(1)).trim();

       try{ 
       check = conn.createStatement();
       eset = check.executeQuery(email_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }

       String mailtaken = "";
       while(eset != null && eset.next())
       mailtaken = (eset.getString(1)).trim();

       //out.println(idtaken);
       //out.println(phone.length());
       //out.println(mailtaken);

       if(userid.equals(idtaken) || phone.length() != 10 
       || email.equals(mailtaken)) {
       if(userid.equals(idtaken))
       out.println("The selected username, "+userid+", is already taken.<br>");
       if(phone.length() != 10)
       out.println("The given phone number is not 10 digits long.<br>");
       if(email.equals(mailtaken))
       out.println("The selected email, "+email+", is already taken.<br>");

       out.println("<form method=post action=register.jsp>");
       out.println("UserName: <input type=text name=USERID maxlength=24><br>");
       out.println("Password: <input type=password "
       + "name=PASSWD maxlength=24><br>");
       out.println("First Name: <input type=text name=FNAME "
       + "maxlength=24><br>");
       out.println("Last Name: <input type=text name=LNAME maxlength=24><br>");
       out.println("Address: <input type=text name=ADDRESS "
       + "maxlength=128><br>");
       out.println("E-mail: <input type=text name=EMAIL maxlength=128><br>");
       out.println("Phone #: <input type=text name=PHONE maxlength=10><br>");
       out.println("<input type=submit name=bSubmit value=Submit>");
       out.println("</form>");
       }
       
       //Else, insert the registration form into the database.
       else{
       Statement stmt = null;
       int update_users = -1;
       int update_persons = -1;
       String sql_users = "Insert into users (USER_NAME, PASSWORD, "
       + "DATE_REGISTERED) VALUES('"+userid+"', '"+pass+"', sysdate)";
       String sql_persons = "Insert into persons (USER_NAME, FIRST_NAME, "
       + "LAST_NAME, ADDRESS, EMAIL, PHONE) VALUES( '"+userid+"', '"
       +fname+"', '"+lname+"', '"+address+"', '"+email+"', '"+phone+"')";
       //out.println(sql_users);
       //out.println(sql_persons);

       try{
       stmt = conn.createStatement();
       update_users = stmt.executeUpdate(sql_users);
       update_persons = stmt.executeUpdate(sql_persons);
       conn.commit();
       } catch (SQLException sqle) {
       try {
       conn.rollback();
       } catch(SQLException sqle1) {
       out.println("<hr>" + sqle1.getMessage() + "<hr>");
       }
       } finally {
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       }
       //Then, we need to tell the user that registration was successful
       //out.println(update_users);
       //out.println(update_persons);
       //Direct the user to the login page
       out.println("Registration was successful.<br>");
       out.println("<a href=login.jsp>Click here to Log in.</a>");
       }  

       //Then, we need to tell the user that registration was successful
       //out.println(update_users);
       //out.println(update_persons);
       //Direct the user to the login page
       //out.println("Registration was successful.<br>");
       //out.println("<a href=login.jsp>Click here to Log in.</a>");
       }
       //Display the registration form
       else
       {
       out.println("<form method=post action=register.jsp>");
       out.println("UserName: <input type=text name=USERID maxlength=24><br>");
       out.println("Password: <input type=password "
       + "name=PASSWD maxlength=24><br>");
       out.println("First Name: <input type=text name=FNAME "
       + "maxlength=24><br>");
       out.println("Last Name: <input type=text name=LNAME maxlength=24><br>");
       out.println("Address: <input type=text name=ADDRESS "
       + "maxlength=128><br>");
       out.println("E-mail: <input type=text name=EMAIL maxlength=128><br>");
       out.println("Phone #: <input type=text name=PHONE maxlength=10><br>");
       out.println("<input type=submit name=bSubmit value=Submit>");
       out.println("</form>");
       }      
       %>
    
    
    
  </BODY>
</HTML>

