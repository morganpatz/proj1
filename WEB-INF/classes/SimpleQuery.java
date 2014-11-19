import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;

/**
 *  A simple example to demonstrate how to use servlet with JDBC to 
 *  connect and query a database. 
 *
 * @author  Li-Yan Yuan, University of Alberta
 *
 */
public class SimpleQuery extends HttpServlet {

    private Connection conn = null;

    // initial values 
    private String username = "patzelt";
    private String password = "Chocolate1";
    private String drivername = "oracle.jdbc.driver.OracleDriver";
    private String dbstring="jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
    private String query = "";

    /*
     *  The interface uses two different forms, one for connection and one    
     *  for query. The following are used to identify which is which.
     */
    private final int CONNECTION_FORM = 1;
    private final int QUERY_FORM = 2;
    private int formStatus = CONNECTION_FORM;

    /**
     *  To allow the servlet to handle a GET request.
     *
     *  This method posts a connection form such that the user can type in
     *  the following parameters:
     *      User Name, Password, JDBC Driver Name, Database Connection String
     *  to connect to a specified database.
     */
    public void doGet(HttpServletRequest request, HttpServletResponse res)
	throws IOException, ServletException {
        res.setContentType("text/html");
        PrintWriter out = res.getWriter();
	formStatus = CONNECTION_FORM;
	postConnectionForm( out );
    }

    /**
     *  This method will process POST method submitted by the client.
     *
     *  The method can be submitted from two difference forms, one is
     *  CONNECTION_FORM, and the other QUERY_FORM.
     *  
     *  For CONNECTION_FORM, the method will get the connection parameters 
     *       and then connect to the database
     *
     *  For QUERY_FORM, the method will execute the sql command obtained from
     *       the user and display the result/error message
     *
     */
    public void doPost(HttpServletRequest request, HttpServletResponse res)
	throws IOException, ServletException  {

        PrintWriter out = res.getWriter();
	Statement stmt = null;
	String response = null;
	ResultSet rset = null;
	
	/*
	 *  to sepecify the type of the response
	 */
        res.setContentType("text/html");

	/*
	 *  Specify the actions for the request from a CONNECTION_FORM
	 */

	if ( formStatus == CONNECTION_FORM ) {
	    username = request.getParameter("username");
	    password = request.getParameter("password");
	    dbstring = request.getParameter("dbstring");
	    drivername = request.getParameter("drivername");

	    try {
		conn = getConnected();
	    } catch( Exception ex ) {
		out.println("<hr>" + ex.getMessage() + "<hr>");
		postConnectionForm(out);
		return;
	    }
	}

	//  specify actions for the request from a QUERY_FORM
	else {
	    query = request.getParameter("query");
	    boolean ret;

	    /*
	     *   to execute the given query
	     */
	    try {
		stmt = conn.createStatement();
		if ( query.trim().startsWith("select") ) {
		    rset = stmt.executeQuery(query);
		}
		else {
		    if (! ( ret = stmt.execute(query)) ) 
			response = "the execution succeeds";
		}
	    } 
	    catch( Exception ex) { 
		response = ex.getMessage();
	    }
	}

	postQueryForm( out, rset, response );

	try {
	    stmt.close(); 
	} catch(Exception ex){ response = ex.getMessage();}
       
    }


    /**
     *   Post a connection form, including text inputs for the following:
     *    user name, password, JDBC driver, database connection string
     * 
     */
    private void postConnectionForm( PrintWriter out ) {
        out.println("<html>");
	out.println("<body>");
	out.println("<head>");
	out.println("<title>JDBC Interface</title>");
	out.println("</head>");
	out.println("<body >");
	out.println("<h3>Please Connect to the Database</h3>");
	out.println("(change the parameters to connect to other database)");
	out.println("<P>");
 
	out.println("To connect to the Oracle in the undergraduate lab, use the following parameters:");
	out.println("<br>");
	out.println("DriverName: oracle.jdbc.driver.OracleDriver");
	out.println("<br>");
	out.println("DB String: jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS");

	out.println("<form action=\"SimpleQuery\" method=POST>");
	out.println("<table>");
	out.println("<tr>");
	out.println("<td> User Name ");
	out.println("<td> <input type=text size=20 name=username value = " + username + "> ");

	out.println("<tr><td alian = right>  Password </td>");
	out.println("<td alian = left> <input type=password size=20 name=password value = " + password + "></td></tr>");

	out.println("<td alian = right>  Driver Name </td>");
	out.println("<td alian = left> <input type=text size=20 name=drivername value = " + drivername + "></td></tr>");

	out.println("<td alian = right>  DB String </td>");
	out.println("<td alian = left> <input type=text size=50 name=dbstring value = " + dbstring + "></td></tr>");
	out.println("</table>");

	out.println("<input type = submit value = \"connect\">");
	out.println("<input type = reset >");
	out.println("</form>");

	out.println("</body>");
	out.println("</html>");
    }


    /**
     *   to post a query form, including the text area for 
     *   inputing an SQL command, and display the result 
     */
    private void postQueryForm( PrintWriter out, 
				ResultSet rset, 
				String warning ) {

	out.println("<html>");
	out.println("<head>");
	out.println("<title> Simple Query </title>");
	out.println("</head>");
	out.println("<body>");
	out.println("<center>");
	out.println("<h3>A Simple JDBC Interface </h3>");
 	out.println("<form action=\"SimpleQuery\" method=POST>");
	out.println("<textarea rows = 5 cols = 40 name=query>");

	out.println( query );
	out.println("</textarea>");
	out.println("<table>");
	out.println("<tr><td><input type = submit value = \"execute\">");
      out.println("<td><table border = 1><tr><td> <a href=\"/patzelt/catalina/webapps/proj1/WEB-INF/classes/SimpleQuery\">connect</a> </table>");

	out.println("</table>");
	out.println("</form>");

	out.println("</body>");
	out.println("</html>");
 
	if ( warning != null )
	    out.println("<hr>" + warning + "<hr>" );

       	if ( rset != null )
	    displayResultSet( out, rset);


	out.println("</body>");
	out.println("</html>");

	formStatus = QUERY_FORM;
    }


    /*
     *   Display the result set in a generated HTML file
     */
    private void displayResultSet( PrintWriter out, ResultSet rset ) {

	out.println("<table border = 1 alian>");
	String value = null;
	Object o = null;
	int type;
	Blob image;

	/* 
	 *  to generate the column labels
	 */
	try {

	    ResultSetMetaData rsetMetaData = rset.getMetaData();
	    int columnCount = rsetMetaData.getColumnCount();

	    out.println("<tr valign = \"top\">");

	    for ( int column = 1; column <= columnCount; column++) {
		value = rsetMetaData.getColumnLabel(column);
		out.print("<td>" + value + "</td>");
	    }
	    out.println("</tr>");

	    /*
	     *   generate answers, one tuple at a time
	     */
	    while (rset.next() ) {
		out.println("<tr valign = \"top\">");
		for ( int index = 1; index <= columnCount; index++) {
		    type= rsetMetaData.getColumnType(index);

		    if (type==Types.LONGVARBINARY||
			type==Types.BLOB||type==Types.CLOB) {

			out.println("<img src=\"/patzelt/catalina/webapps/proj1/WEB-INF/classes/GetOnePic\"></a>");
			/*
			image= rset.getBlob(index);
			rese.setContentType("image/gif");
			InputStream input = rset.getBinaryStream(index);
			int imageByte;
			while((imageByte = input.read()) != -1) {
			    out.write(imageByte);
			}
			input.close();
			*/

		    }
		    else {
			o = rset.getObject(index);
			if (o != null )
			    value = o.toString();
			else 
			    value = "null";
			out.print("<td>" + value + "</td>");
		    }
		}
		out.println("</tr>");
	    }
	} catch ( Exception io ){ out.println(io.getMessage()); }

	out.println("</table>");
    }

    /*
     *  to connect to the database
     */
    private Connection getConnected() throws Exception {
	Connection conn;
	Class drvClass = Class.forName(drivername); 
	DriverManager.registerDriver((Driver) drvClass.newInstance());
	conn = DriverManager.getConnection(dbstring,username,password);
	conn.setAutoCommit(false);
	return conn;
    }
}
