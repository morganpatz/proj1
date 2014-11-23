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

import java.awt.image.BufferedImage;
import java.io.*;

import javax.imageio.ImageIO;
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

public class UploadImageThumb extends HttpServlet {
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
		int photo_id = 0;
		String subject = null;
		String location = null;
		String date = null;
		String description = null;
		File photo = null;
		Date sqlDate = null;
		String command = "";
		InputStream instream = null;
		Statement stmt = null;
		PreparedStatement stmt1 = null;

		try {
			// Parse the HTTP request to get the image stream
			DiskFileUpload fu = new DiskFileUpload();
			List FileItems = fu.parseRequest(request);

			// Process the uploaded items, assuming only 1 image file
			// uploaded
			Iterator i = FileItems.iterator();
			FileItem item = (FileItem) i.next();
			String fieldname = "";
			String fieldvalue;
			while (i.hasNext() && item.isFormField()) {
				// Process regular form field (input
				// type="text|radio|checkbox|etc", select, etc).
				fieldname = item.getFieldName();
				fieldvalue = item.getString();

				if (fieldname.equals("subject")) {
					subject = fieldvalue;
				} else if (fieldname.equals("location")) {
					location = fieldvalue;
				} else if (fieldname.equals("SnapHost_Calendar")) {
					date = fieldvalue;
				} else if (fieldname.equals("description")) {
					description = fieldvalue;
				}
				item = (FileItem) i.next();
				response_message = response_message + fieldname;

			}
			// Process form file field (input type="file").
			fieldname = item.getFieldName();
			String filename = FilenameUtils.getName(item.getName());
			instream = item.getInputStream();
			response_message = response_message + fieldname;

			BufferedImage img = ImageIO.read(instream);
			BufferedImage thumbnail = shrink(img, 10);

			// Connect to the database and create a statement
			Connection conn;
			conn = getConnected(drivername, dbstring, username, password);
			stmt = conn.createStatement();

			/*
			 * First, to generate a unique pic_id using an SQL sequence
			 */
			ResultSet rset1 = stmt
					.executeQuery("SELECT pic_id_sequence.nextval from dual"); // good
			rset1.next();
			photo_id = rset1.getInt(1);

			response_message = response_message + "photoid";

			command = "INSERT INTO images VALUES (" + photo_id
					+ ", 'user', 0, '" + subject + "', '" + location
					+ "', to_date('" + date + "', 'YYYY-MM-DD'), '"
					+ description + "', empty_blob(), empty_blob())";
			response_message = response_message + "query";

			stmt.execute(command);
			response_message = response_message + "executed";

			// to retrieve the lob_locator
			// Note that you must use "FOR UPDATE" in the select statement
			String cmd = "SELECT * FROM images WHERE photo_id = " + photo_id
					+ " FOR UPDATE";
			ResultSet rset = stmt.executeQuery(cmd);
			rset.next();
			BLOB myblob = ((OracleResultSet) rset).getBLOB(3);

			// Write the image to the blob object
			OutputStream outstream = myblob.getBinaryOutputStream();
			ImageIO.write(thumbnail, "jpg", outstream);

			/*
			 * int size = myblob.getBufferSize(); byte[] buffer = new
			 * byte[size]; int length = -1; while ((length =
			 * instream.read(buffer)) != -1) outstream.write(buffer, 0, length);
			 */
			instream.close();
			outstream.close();

			stmt.executeUpdate("commit");
			response_message = " Upload OK!  ";
			conn.close();

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
			out.println("<P><a href=\"PictureBrowse\"> See Pictures </a>");
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

	// shrink image by a factor of n, and return the shrinked image
	public static BufferedImage shrink(BufferedImage image, int n) {

		int w = image.getWidth() / n;
		int h = image.getHeight() / n;

		BufferedImage shrunkImage = new BufferedImage(w, h, image.getType());

		for (int y = 0; y < h; ++y)
			for (int x = 0; x < w; ++x)
				shrunkImage.setRGB(x, y, image.getRGB(x * n, y * n));

		return shrunkImage;
	}

}
