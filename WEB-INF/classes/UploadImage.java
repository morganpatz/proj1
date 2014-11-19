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

public class UploadImage extends HttpServlet {
	public String response_message;

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// change the following parameters to connect to the oracle database
		String username = "patzelt";
		String password = "Chocolate1";
		String drivername = "oracle.jdbc.driver.OracleDriver";
		String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
		int photo_id;
		String command = "oops";

		try {

			// Get information from html
			String subject = "";
			String location = "";
			String date = "";
			String description = "";
			File photo = null;
			Date sqlDate = null;

			subject = request.getParameter("subject");
			location = request.getParameter("location");
			date = request.getParameter("date");
			description = request.getParameter("description");
			//photo = request.getParameter("file-path");
	

			// Convert date string to Date type
			if (!date.equals("")) {
				sqlDate = java.sql.Date.valueOf(date);
			} 

			/**
			// Parse the HTTP request to get the image stream
			DiskFileUpload fu = new DiskFileUpload();
			List FileItems = fu.parseRequest(request);

			// Process the uploaded items, assuming only 1 image file uploaded
			Iterator i = FileItems.iterator();
			FileItem item = (FileItem) i.next();
			while (i.hasNext() && item.isFormField()) {
				item = (FileItem) i.next();
			}
			long size = item.getSize();

			// Get the image stream
			InputStream instream = item.getInputStream();
			**/

			// Connect to the database and create a statement
			Connection conn = getConnected(drivername, dbstring, username,
					password);
			Statement stmt = conn.createStatement();

			/*
			 * First, to generate a unique pic_id using an SQL sequence
			 */
			ResultSet rset1 = stmt.executeQuery("SELECT pic_id_sequence.nextval from dual"); // good
			rset1.next();
			photo_id = rset1.getInt(1);

			command = "INSERT INTO images VALUES (" + photo_id
				+ ", 'user', 0, " + subject + ", " + location + ", " + sqlDate
				+ ", " + description + ", empty_blob(), empty_blob())";
			

			stmt.execute(command);
			
			//PreparedStatement stmt1 = conn.prepareStatement("UPDATE images SET photo = ? WHERE photo_id = + " + photo_id);
			//stmt1.setBinaryStream(1, instream);
			//stmt1.executeUpdate();

			response_message = "YAHHOOOOOO";
			conn.close();

		} catch (Exception ex) {
			response_message = ex.getMessage();
			command = "yikes";
		}

		// Output response to the client
		response.setContentType("text/html");
		PrintWriter out = response.getWriter();
		out.println("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 "
				+ "Transitional//EN\">\n" + "<HTML>\n"
				+ "<HEAD><TITLE>Upload Message</TITLE></HEAD>\n" + "<BODY>\n"
				+ "<H1>" + response_message + "</H1>\n" + "</BODY></HTML>");
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
