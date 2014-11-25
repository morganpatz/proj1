import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import oracle.jdbc.driver.*;
import java.text.*;
import java.net.*;

/**
 * A simple example to demonstrate how to use servlet to query and display a
 * list of pictures
 * 
 * @author Li-Yan Yuan
 * 
 */
public class SearchBrowse extends HttpServlet implements SingleThreadModel {

	/**
	 * Generate and then send an HTML file that displays all the thermonail
	 * images of the photos.
	 * 
	 * Both the thermonail and images will be generated using another servlet,
	 * called GetOnePic, with the photo_id as its query string
	 * 
	 */
	public void doGet(HttpServletRequest request, HttpServletResponse res)
			throws ServletException, IOException {

		Security sec = new Security();
		
		PrintWriter out = res.getWriter();
		String userid = "";
		Cookie login_cookie = null;
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
				// the
				// userid that has logged in on this browser.
				if (i != 0 && userid == "") {
					userid = cookie.getName();
				}
			}
		}
		// If no login was detected, redirect the user to the login page.
		if (userid == "") {
			out.println("<a href=login.jsp>Please login to access this site.</a>");
		}
		// Else, we have a valid session.
		else {

			// send out the HTML file
			res.setContentType("text/html");
			

			out.println("<html>");
			out.println("<head>");
			out.println("<title> Search Results </title>");
			out.println("</head>");
			out.println("<body bgcolor=\"#000000\" text=\"#cccccc\" >");
			out.println("<left>");
			out.println("<a href=\"indexExample.jsp\">Back to Search</a>");
			out.println("<P ALIGN=\"right\">");
			out.println("<a href=\"PictureBrowse\">Back to Home</a>");
			out.println("</P>");
			out.println("<center>");
			out.println("<P><a href=\"upload_image.html\"> Upload Image </a>");
			out.println("<h3>The List of Images </h3>");

			/*
			 * to execute the given query
			 */
			try {
				String query = "SELECT photo_id FROM rankImage ORDER BY rank DESC";

				Connection conn = getConnected();
				Statement stmt = conn.createStatement();
				ResultSet rset = stmt.executeQuery(query);
				String p_id = "";

				while (rset.next()) {
					p_id = (rset.getObject(1)).toString();
					
					//if (sec.view_allowed(userid, p_id, conn) == 1) {

						// specify the servlet for the image
						out.println("<a href=\"GetBigPic?big" + p_id + "\">");
						// specify the servlet for the thumbnail
						out.println("<img src=\"GetOnePic?" + p_id + "\"></a>");
					//}

				}
				stmt.close();
				conn.close();
			} catch (Exception ex) {
				out.println(ex.toString());
			}

			out.println("</body>");
			out.println("</html>");
		}
	}

	/*
	 * Connect to the specified database
	 */
	private Connection getConnected() throws Exception {

		String username = "patzelt";
		String password = "Chocolate1";
		String drivername = "oracle.jdbc.driver.OracleDriver";
		String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

		/*
		 * to connect to the database
		 */
		Class drvClass = Class.forName(drivername);
		DriverManager.registerDriver((Driver) drvClass.newInstance());
		return (DriverManager.getConnection(dbstring, username, password));
	}
}

