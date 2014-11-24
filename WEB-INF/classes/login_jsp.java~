package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import java.sql.*;

public final class login_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.List _jspx_dependants;

  private javax.el.ExpressionFactory _el_expressionfactory;
  private org.apache.AnnotationProcessor _jsp_annotationprocessor;

  public Object getDependants() {
    return _jspx_dependants;
  }

  public void _jspInit() {
    _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
    _jsp_annotationprocessor = (org.apache.AnnotationProcessor) getServletConfig().getServletContext().getAttribute(org.apache.AnnotationProcessor.class.getName());
  }

  public void _jspDestroy() {
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write("<HTML>\r\n");
      out.write("  <HEAD>\r\n");
      out.write("    \r\n");
      out.write("    \r\n");
      out.write("    <TITLE>Your Login Result</TITLE>\r\n");
      out.write("  </HEAD>\r\n");
      out.write("  \r\n");
      out.write("  <BODY>\r\n");
      out.write("    <!--A simple example to demonstrate how to use JSP to \r\n");
      out.write("\tconnect and query a database. \r\n");
      out.write("\t@author  Hong-Yu Zhang, University of Alberta\r\n");
      out.write("      -->\r\n");
      out.write("    \r\n");
      out.write("    ");

    
       if(request.getParameter("bSubmit") != null)
    {
       
       //get the user input from the login page
       String userid = (request.getParameter("USERID")).trim();
       String pass = (request.getParameter("PASSWD")).trim();
       out.println("<p>Your input User Name is "+userid+"</p>");
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
       
       
       //select the user table from the underlying db and validate the user name and password
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
       String valid_id = "";
       while(nset != null && nset.next())
       valid_id = (nset.getString(1)).trim();
       
       //Display the result.
       if(pass.equals(truepwd) && userid.equals(valid_id) && userid != "") {
       //Create a cookie to allow the server to recognize the login.
       Cookie login_cookie = new Cookie(userid, userid+"'s_cookie");
       response.addCookie(login_cookie);
       //out.println(login_cookie.getName()+"<br>");
       out.println("<p><b>Your Login is Successful!</b></p>");
       out.println("<a href=testmain.jsp>Click here to continue.</a>");
       
       //Link to a user's home page should go here.
       }
       else
       { out.println("<p><b>Either your userName or Your password is inValid!</b></p>");
       //Prompt the user to try again, or register.
       out.println("<form method=post action=login.jsp>");
       out.println("UserName: <input type=text name=USERID maxlength=20><br>");
       out.println("Password: <input type=password name=PASSWD maxlength=20><br>");
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

       else
       {
       out.println("<form method=post action=login.jsp>");
       out.println("UserName: <input type=text name=USERID maxlength=20><br>");
       out.println("Password: <input type=password name=PASSWD maxlength=20><br>");
       out.println("<input type=submit name=bSubmit value=Submit>");
       out.println("</form>");
       //Ask the user to register
       out.println("New to this site? ");
       out.println("<a href=register.jsp>Please register here!</a>");
       }      
       
      out.write("\r\n");
      out.write("    \r\n");
      out.write("    \r\n");
      out.write("    \r\n");
      out.write("  </BODY>\r\n");
      out.write("</HTML>\r\n");
      out.write("\r\n");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try { out.clearBuffer(); } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
