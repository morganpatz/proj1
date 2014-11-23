/***
 *  A sample program to demonstrate how to use servlet to 
 *  load an image file from the client disk via a web browser
 *  and insert the image into a table in Oracle DB.
 *  
 *  Copyright 2005 COMPUT 391 Team, CS, UofA                             
 *  Author:  Fan Deng
 *                                                                  
 *  Licensed under the Apache License, Version 2.0 (the "License");         
 *  you may not use this file except in compliance with the License.        
 *  You may obtain a copy of the License at                                 
 *      http://www.apache.org/licenses/LICENSE-2.0                          
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 *
 *  the table shall be created using the following
      CREATE TABLE images (
           photo_id    int,
	   owner_name  varchar(24),
	   permitted   int,
	   subject     varchar(128),
	   place       varchar(128),
	   timing      date,
	   description varchar(2048),
	   thumbnail   blob,
	   photo       blob,
	   PRIMARY KEY(photo_id),
	   FOREIGN KEY(owner_name) REFERENCES users,
	   FOREIGN KEY(permitted) REFERENCES groups
      );
 *
 *  One may also need to create a sequence using the following 
 *  SQL statement to automatically generate a unique pic_id:
 *
 *   CREATE SEQUENCE pic_id_sequence;
 *
 ***/

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.util.Date;
import java.util.*;
import oracle.sql.*;
import oracle.jdbc.*;
import java.util.Date.*;

/**
 *  The package commons-fileupload-1.0.jar is downloaded from 
 *         http://jakarta.apache.org/commons/fileupload/ 
 *  and it has to be put under WEB-INF/lib/ directory in your servlet context.
 *  One shall also modify the CLASSPATH to include this jar file.
 */
import org.apache.commons.fileupload.DiskFileUpload;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.io.FilenameUtils;

public class EditImage extends HttpServlet {
	public String response_message = "Nothing Happened";

	private Connection conn = null;

	// initial values
	String username = "patzelt";
	String password = "Chocolate1";
	String drivername = "oracle.jdbc.driver.OracleDriver";
	String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// change the following parameters to connect to the oracle database
		String photo_id = request.getQueryString();
		String command = "";
		InputStream instream = null;
		Statement stmt = null;
		PreparedStatement stmt1 = null;
		PreparedStatement update = null;

		String subject = null;
		String place = null;
		String timing = null;
		String description = null;

		try {
			// Parse the HTTP request to get the image stream
			DiskFileUpload fu = new DiskFileUpload();
			List FileItems = fu.parseRequest(request);

			subject = request.getParameter("subject");
			place = request.getParameter("place");
			timing = request.getParameter("timing");
			description = request.getParameter("description");

			// Connect to the database and create a statement
			Connection conn;
			conn = getConnected(drivername, dbstring, username, password);
			stmt = conn.createStatement();

			if (!subject.isEmpty()) {
				update = conn.prepareStatement("UPDATE images SET subject = "
						+ subject + " WHERE photo_id = " + photo_id);
				update.executeUpdate();
			}
			if (!place.isEmpty()) {
				update = conn.prepareStatement("UPDATE images SET place = "
						+ place + " WHERE photo_id = " + photo_id);
				update.executeUpdate();
			}
			if (!timing.isEmpty()) {
				update = conn.prepareStatement("UPDATE images SET timing = "
						+ timing + " WHERE photo_id = " + photo_id);
				update.executeUpdate();
			}
			if (!description.isEmpty()) {
				update = conn
						.prepareStatement("UPDATE images SET description = "
								+ description + " WHERE photo_id = " + photo_id);
				update.executeUpdate();
			}

			response_message = "Image Updated!";
		} catch (Exception e) {
			response_message = response_message + "uh oh";
		}
		try {
			// Output response to the client
			response.setContentType("text/html");
			PrintWriter out = response.getWriter();
			out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 "
					+ "Transitional//EN\">\n" + "<HTML>\n"
					+ "<HEAD><TITLE>Upload Message</TITLE></HEAD>\n"
					+ "<BODY>\n" + "<H1>" + response_message + "</H1>\n"
					+ "</BODY></HTML>");
			out.println("<P><a href=\"GetBigPic?big" + photo_id
					+ "\"> Back To Image </a>");
			out.println("</body>");
			out.println("</html>");
		} catch (Exception e) {
			response_message = response_message + "4";
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

	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}

}
