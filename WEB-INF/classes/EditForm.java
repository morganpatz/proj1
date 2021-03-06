/***
 *  A program that allows the user to edit fields of an image that they are the owner of
 *  
 *  Taken From:
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
 *  Date: November 26, 2014
 *  Author: Morgan Patzelt
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

public class EditForm extends HttpServlet {
	public String response_message = "Nothing Happened";

	private Connection conn = null;

	// initial connection values
	String username = "amlee1";
	String password = "splplus719";
	String drivername = "oracle.jdbc.driver.OracleDriver";
	String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// change the following parameters to connect to the oracle database
		String photo_id = request.getQueryString();

		PrintWriter out = response.getWriter();
		
		// Check to makes sure the user is logged in
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

		out.println("<html><body><head><title>Edit Image</title></head><body ><P>");
		out.println("<form name=\"EditForm\" method=\"POST\" action=\"EditImage?" + photo_id + "\"><table>");
		out.println("<tr><td> Subject: <td> <input type=text size=20 name=subject>");
		out.println("<tr><td alian = right>  Location: </td><td alian = left> <input type=text size=20 name=place></td></tr>");
		out.println("<tr><td alian = right>  Date: </td><td alian = left> <script type=\"text/javascript\""
			+" src=\"http://www.snaphost.com/jquery/Calendar.aspx?dateFormat=yy-mm-dd\"></script></script> &nbsp;</td></tr>");
		out.println("<tr><td alian = right>  Description: </td><td alian = left> <textarea name=description rows=10 cols=30></textarea></td></tr>");

		out.println("<tr><td alain = right>     Who Can See This Photo:");
		out.println("<td>Everyone <input class=\"everyone\" name = \"permission\" type=\"radio\" id=\"everyone\" value=\"everyone\">");
		out.println("Only Me <input class=\"useronly\" name = \"permission\" type=\"radio\" id=\"useronly\" value=\"useronly\">");
		out.println("Specific Group <input class=\"conditional_form_part_activator\" name = \"permission\" type=\"radio\" id=\"group\" value=\"group\">");

		out.println("<div class=\"conditional_form_part\">Group Name: <input class=\"groupname\" type=text size=20 name=\"groupName\"></td></select> </div></tr></td>");

		out.println("<tr><td alian = center colspan=\"2\"><input type = submit value = \"Update Image\"></td></tr></form></table></body></html>");
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










