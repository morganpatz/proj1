import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.sql.Date.*;
import oracle.jdbc.*;
import javax.servlet.RequestDispatcher;



/**
 * This servlet sends one picture stored in the table below to the client who
 * requested the servlet.
 * 
 * picture( photo_id: integer, title: varchar, place: varchar, sm_image: blob,
 * image: blob )
 * 
 * The request must come with a query string as follows: GetOnePic?12: sends the
 * picture in sm_image with photo_id = 12 GetOnePicture?big12: sends the picture
 * in image with photo_id = 12
 * 
 * @author Li-Yan Yuan
 * 
 */
public class GetBigPic extends HttpServlet implements SingleThreadModel {

	/**
	 * This method first gets the query string indicating PHOTO_ID, and then
	 * executes the query select image from yuan.photos where photo_id =
	 * PHOTO_ID Finally, it sends the picture to the client
	 */
	

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		Security sec = new Security();
		

		

		// construct the query from the client's QueryString
		String query;
		String response_message = "ERROR: ";

		String photo_id = request.getQueryString().substring(3);

		query = "SELECT owner_name, subject, place, timing, description FROM images WHERE photo_id = " + photo_id;

		// ServletOutputStream out = response.getOutputStream();
		PrintWriter out = response.getWriter();

		/*
		 * to execute the given query
		 */
		Connection conn = null;
		try {
			conn = getConnected();
			Statement stmt = conn.createStatement();
			ResultSet rset = stmt.executeQuery(query);
			response.setContentType("text/html");
			
			String owner_name = "owner_name";
			String subject = "subject";
			String place = "place";
			Date timing = null;
			String description = "Desc";

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

			response_message = response_message + "cookies";


			PreparedStatement stmtUpdate = conn.prepareStatement("UPDATE imageCount SET imgCount = imgCount + 1 WHERE photo_id = " + photo_id);

			String test = "UPDATE imageCount SET imgCount = imgCount + 1 WHERE photo_id = " + photo_id;

			out.print(test);
			//stmtUpdate.executeUpdate();

			response_message = response_message + "imgCount";


			while (rset.next()) {
				owner_name = rset.getString("owner_name");
				subject = rset.getString("subject");
				place = rset.getString("place");
				timing = rset.getDate("timing");
				description = rset.getString("description");
				out.println("<html><head><title>\"" + subject + "\"</title></head>");				
				out.println("<body bgcolor=\"#000000\" text=\"#cccccc\">"
						+ "<center><img src = \"GetOnePic?big" + photo_id + "\">"
						+ "<h3>Owner: " + owner_name + "</h3>"
						+ "<h3>Subject: " + subject + "</h3>"
						+ "<h3>Location: " + place + "</h3>"
						+ "<h3>Date: " + timing + "</h3>"
						+ "<h3>Description: " + description + "</h3>"
						+ "</body></html>");
				if (sec.edit_allowed(userid, photo_id, conn) == 1) {
					out.println("<P><a href=\"EditForm?" + photo_id + "\"> Edit Image </a>");
				}

			response_message = response_message + "imgInfo";
			}
			//} else
			//	out.println("<html> Pictures are not available</html>");
		} catch (Exception ex) {
			response_message = response_message + "uhoh";
			out.println(response_message);
		}
		// to close the connection
		finally {
			try {
				conn.close();
			} catch (SQLException ex) {
				out.println(ex.getMessage());
			}
		}
	}

	/*
	 * /* To connect to the specified database
	 */
	private static Connection getConnected() throws Exception {

		String username = "patzelt";
		String password = "Chocolate1";
		String drivername = "oracle.jdbc.driver.OracleDriver";
		String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

		Class drvClass = Class.forName(drivername);
		DriverManager.registerDriver((Driver) drvClass.newInstance());
		return (DriverManager.getConnection(dbstring, username, password));
	}


}
