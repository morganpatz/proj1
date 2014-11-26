import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import oracle.jdbc.driver.*;
import java.text.*;
import java.net.*;

/*
 * 
 */
public class Groups extends HttpServlet {
    
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
	String userid = "";
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
		// However, we only want one cookie, the one
		// whose name matches the userid that has
		// logged in on this browser.
		if (i != 0 && userid == "") {
		    userid = cookie.getName();
		}
	    }
	}
	// If no login was detected, redirect the user to the login page
	if (userid == "") {
	    out.println("<a href=login.jsp>Please login to access "
			+"this site.</a>");
	}
	// Else, we have a valid session.
	else {
	     
	    if(request.getParameter("aSubmit") != null) {
		try {
		    String groupname = request.getParameter("groupName");
		    out.println(userid+"<br>");
		    out.println(groupname+"<br>");
		    
		    Connection conn;
		    conn = getConnected(drivername, dbstring, username,
					password);
		    int make_group = 0;
		    make_group = sec.create_group(userid, groupname,
						  conn);
		    if(make_group == 1)
			response_message = "Group Created";
		    else
			response_message = "Error Occured";
		    conn.close();
		    
		}
		catch (Exception e) {
		    
		}
	    }
	    
	    if(request.getParameter("bSubmit") != null) {
		try {
		    String friendid = request.getParameter("friendID");
		    String groupname = request.getParameter("groupName");
		    out.println(userid+"<br>");
		    out.println(groupname+"<br>");
		    out.println(friendid+"<br>");

		    Connection conn;
		    conn = getConnected(drivername, dbstring, username,
					password);
		    int add_friend_to_group = 0;
		    add_friend_to_group = sec.add_friend(userid, groupname,
							 friendid, conn);
		    if(add_friend_to_group == 1)
			response_message = "Friend Added";
		    else
			response_message = "Error Occured";
		    conn.close();
		    
		}
		catch (Exception e) {
		    
		}
	    }
	    
	    if(request.getParameter("cSubmit") != null) {
		try {
		    String friendid = request.getParameter("friendID");
		    String groupname = request.getParameter("groupName");
		    out.println(userid+"<br>");
		    out.println(groupname+"<br>");
		    out.println(friendid+"<br>");

		    Connection conn;
		    conn = getConnected(drivername, dbstring, username,
					password);
		    int remove_from_group = 0;
		    remove_from_group = sec.remove_friend(userid, groupname,
							 friendid, conn);
		    if(remove_from_group == 1)
			response_message = "Friend Removed";
		    else
			response_message = "Error Occured";
		    conn.close();
		    
		}
		catch (Exception e) {
		    
		}
	    }

	    try {
		// Output response to the client
		response.setContentType("text/html");
		out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD "
			    +"HTML 4.0 "
			    +"Transitional//EN\">\n" + "<HTML>\n"
			    +"<HEAD><TITLE>Upload Message</TITLE>"
			    +"</HEAD>\n"
			    +"<BODY>\n" + "<H1>" 
			    +response_message + "</H1>\n"
			    + "</BODY></HTML>");
		out.println("<P><a href=\"groups.html\">"
			    +"Back to Groups</a>");
		out.println("</body>");
		out.println("</html>");
	    }
	    catch (Exception e) {
		
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