import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

import oracle.jdbc.*;
import oracle.sql.*;

/**
 * This servlet sends one picture stored in the table below to the client who
 * requested the servlet.
 * 
 * CREATE TABLE images (
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
 * The request must come with a query string as follows: GetOnePic?12: sends the
 * picture in sm_image with photo_id = 12 GetOnePicture?big12: sends the picture
 * in image with photo_id = 12
 * 
 * Taken From: Li-Yan Yuan - November 26, 2014
 * Author: Morgan Patzelt
 * 
 */
public class GetOnePic extends HttpServlet 
    implements SingleThreadModel {



    /**
     *    This method first gets the query string indicating PHOTO_ID,
     *    and then executes the query 
     *          select image from images where photo_id = PHOTO_ID   
     *    Finally, it sends the picture to the client
     */

    public void doGet(HttpServletRequest request,
		      HttpServletResponse response)
	throws ServletException, IOException {
	
	//  construct the query  from the client's QueryString
	String photo_id  = request.getQueryString();
	String query;

	// Checks which class to call based on query string
	if ( photo_id.startsWith("big") )  
	    query = "SELECT photo FROM images WHERE photo_id = " + photo_id.substring(3);
	else
	    query = "SELECT thumbnail FROM images WHERE photo_id = " + photo_id;

	ServletOutputStream out = response.getOutputStream();

	/*
	 *   to execute the given query
	 */
	Connection conn = null;
	try {
	    // Connection
	    conn = getConnected();
	    Statement stmt = conn.createStatement();
	    ResultSet rset = stmt.executeQuery(query);
		
            // Prints out the picture
	    if ( rset.next() ) {
		response.setContentType("image/jpeg");
		InputStream input = rset.getBinaryStream(1);	    
		int imageByte;
		while((imageByte = input.read()) != -1) {
		    out.write(imageByte);
		}
		input.close();
	    } 
	    else 
		out.println("no picture available");
	} catch( Exception ex ) {
	    out.println(ex.getMessage() );
	}
	// to close the connection
	finally {
	    try {
		conn.close();
	    } catch ( SQLException ex) {
		out.println( ex.getMessage() );
	    }
	}
    }

           

    /*
     *   Connect to the specified database
     */
    private Connection getConnected() throws Exception {

	String username = "amlee1";
    String password = "splplus719";
    String drivername = "oracle.jdbc.driver.OracleDriver";
    String dbstring="jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

	/*
	 *  to connect to the database
	 */
	Class drvClass = Class.forName(drivername); 
	DriverManager.registerDriver((Driver) drvClass.newInstance());
	return( DriverManager.getConnection(dbstring,username,password) );
    }
}
