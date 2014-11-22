import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

public class display extends HttpServlet {

	public void doGet(HttpServletRequest req, HttpServletResponse res)
			throws IOException, ServletException {

		// initial values
		String username = "patzelt";
		String password = "Chocolate1";
		String drivername = "oracle.jdbc.driver.OracleDriver";
		String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

		String response_message = "Errors: ";
		Connection con = null;
		Statement stmt = null;
		ResultSet rs= null;
		PrintWriter out = res.getWriter();
		res.setContentType("text/html");
		out.println("<html><body>");
		try {
			con = getConnected(drivername, dbstring, username, password);
			stmt = con.createStatement();
			response_message = response_message + "Connected / ";
		
			rs = stmt.executeQuery("select photo_id, subject, place from images");
			out.println("<table border=1 width=50% height=50%>");
			out.println("<tr><th>photo_id</th><th>subject</th><th>place</th><tr>");
			response_message = response_message + "Printed table / ";

			while (rs.next()) {
				int photo_id = rs.getInt("photo_id");
				String subject = rs.getString("subject");
				String place = rs.getString("place");
				out.println("<tr><td>" + photo_id + "</td><td>" + subject + "</td><td>" + 						place + "</td></tr>");
			}
		} catch (Exception e) {
			response_message = response_message
					+ "Did not execute while loop / ";
			out.println(response_message);
		}
		try {
			out.println("</table>");
			out.println("</html></body>");
			con.close();
			response_message = response_message + "Got to end / ";
			out.println(response_message);
		} catch (Exception e) {
			out.println("error");
		}
	}

	/*
	 * /* To connect to the specified database
	 */
	private static Connection getConnected(String drivername, String dbstring,
			String username, String password) throws Exception {
		Class drvClass = Class.forName(drivername);
		DriverManager.registerDriver((Driver) drvClass.newInstance());
		return (DriverManager.getConnection(dbstring, username, password));
	}
}
