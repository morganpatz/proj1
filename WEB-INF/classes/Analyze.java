import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import oracle.jdbc.driver.*;
import java.text.*;
import java.net.*;

public class Analyze extends HttpServlet {
    
    private Connection conn = null;

    // initial values
    String username = "amlee1";
    String password = "splplus719";
    String drivername = "oracle.jdbc.driver.OracleDriver";
    String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
    
    public void doPost(HttpServletRequest request,
		       HttpServletResponse response)
	throws ServletException, IOException {
	Security sec = new Security();
		
	String response_message = "Nothing Happened";
	
	PrintWriter out = response.getWriter();
	String adminid = "";
	Cookie login_cookie = null;
	Cookie cookie = null;
	Cookie[] cookies = null;
	// Get an array of cookies associated with this domain
	cookies = request.getCookies();
	// If any cookies were found, see if any of them contain a
	// valid login.
	if (cookies != null) {
	    for (int i = 0; i < cookies.length; i++) {
		cookie = cookies[i];
		// out.println(cookie.getName()+"<br>");
		// However, we only want one cookie, the admin's cookie.
		if (i != 0 && adminid == "") {
		    adminid = cookie.getName();
		}
	    }
	}
	// If the admins is not logged in, redirect the user to the login page
	if (!adminid.equals("admin")) {
	    out.println("<a href=login.jsp>You don't have permission to view "
			+"this page.</a>");
	}
	// Else, we have a valid session.
	else {

	    // Grab the values the use submitted.
	    String user_set = "";
	    String userid = "";
	    String start_date = "";
	    String end_date = "";
	    String time_frame = "";
	    try {
		user_set = request.getParameter("user");
		userid = request.getParameter("USERID");
		start_date = request.getParameter("SnapHost_Calendar");
		end_date = request.getParameter("SnapHost_Calendar2");
		time_frame = request.getParameter("tframe");
		System.out.println(user_set);
		System.out.println(userid);
		System.out.println(start_date);
		System.out.println(end_date);
		System.out.println(time_frame);
	    }
	    catch (Exception e) {
	    }
	    
	    // If the user didn't supply enough information, prompt the user
	    // to try again.
	    if(user_set == null || (user_set.equals("user") && userid == "") ||
	       start_date == null || end_date == null || time_frame == null){
		out.println("<a href=analyze.html>Insufficient data "
			    +"provided.</a>");
	    }

	    // Else, begin to generate the result set.
	    else {
		out.println("<a href=analyze.html>Sufficient data "
			    +"provided.</a>");
	    }
	}
    }
    
    /*
     * To connect to the specified database
     */
    private static Connection getConnected(String drivername, String dbstring,
					   String username, String password)
	throws Exception {
	Class drvClass = Class.forName(drivername);
	DriverManager.registerDriver((Driver) drvClass.newInstance());
	return (DriverManager.getConnection(dbstring, username, password));
    }
    
    public void doGet(HttpServletRequest request, HttpServletResponse response)
	throws ServletException, IOException {
	doPost(request, response);
    }
}