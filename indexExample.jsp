<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
  <meta http-equiv="content-type" content="text/html; charset=windows-1250">
  <title>Inverted Index example</title>
  </head>
  <body>
    <p> Suppose we have the following table <br> 
    <table border=1>
      <tr>
        <th>Column Name</th>
        <th>Column Type</th>
      </tr>
      <tr>
        <td>ItemId</td>
        <td>Integer</td>
      </tr>
      <tr>
        <td>ItemName</td>
        <td>Varchar</td>
      </tr>
      <tr>
        <td>Description</td>
        <td>Varchar</td>
      </tr>
    </table>
    
    <p>The <a href=setup_2014f.sql>sql</a> for the above table</p>
    <br>
    
    <%
      String m_url = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";
      String m_driverName = "oracle.jdbc.driver.OracleDriver";
      
      String m_userName = "patzelt"; //supply username
      String m_password = "Chocolate1"; //supply password
      
      String addItemError = "";
      
      Connection m_con;
      String createString;
      String selectString = "select subject, place, description from images";
      Statement stmt;
      
      try
      {
      
        Class drvClass = Class.forName(m_driverName);
        DriverManager.registerDriver((Driver)
        drvClass.newInstance());
        m_con = DriverManager.getConnection(m_url, m_userName, m_password);
        
      } 
      catch(Exception e)
      {      
        out.print("Error displaying data: ");
        out.println(e.getMessage());
        return;
      }

      try
      {

        
        stmt = m_con.createStatement();
        ResultSet rset = stmt.executeQuery(selectString);
        out.println("<table border=1>");
        out.println("<tr>");
        out.println("<th>Subject</th>");
        out.println("<th>Place</th>");
	out.println("<th>Description</th>");
        out.println("</tr>"); 
        while(rset.next()) { 
          out.println("<tr>");
          out.println("<td>"); 
          out.println(rset.getString(1));
          out.println("</td>");
          out.println("<td>"); 
          out.println(rset.getString(2)); 
          out.println("</td>");
	  out.println("<td>"); 
          out.println(rset.getString(3)); 
          out.println("</td>");
          out.println("</tr>"); 
        } 
        out.println("</table>");
        stmt.close();     
       
      
    %>
    
    <br><br>
    We can create an inverted index on the column description using the following sql:
    
    <table border=1>
      <tr>
        <td face=Courier>
          CREATE INDEX index_name ON item(column_name) INDEXTYPE IS CTXSYS.CONTEXT;
          <br>
        </td>
      </tr>
    </table>
    <p>The <a href=myIndex.sql>sql</a> for creating the index</p>
        Once the index is created we need to tell oracle to keep updating the index as new data is entered (this is turned off by default). To do this run the this <a href=drjobdml.sql>sql file</a>. This sql command takes two parameters: index name and rate of update (in seconds). 
    
    <br><br><br>
    We can now query the table to find all documents and their relvance for a certain list of words
    through the following query:
    <table border=1>
      <tr>
        <td face=Courier>
          SELECT score(1), subject FROM images WHERE contains(description, 'database', 1) > 0 order by score(1) desc;
          <br>
        </td>
      </tr>
    </table>
    This query returns all the item names along with their relevance score sorted descendingly by the relevance score
    <br>
    <br>
    <br>
    You can add data to the table and then try querying it <br>
    <b><%=addItemError%></b><br>
    <form name=insertData method=post action=indexExample.jsp> 
      <table>
        <tr>
          <td>Item Name</td>
          <td><input type=text name=itemName maxlengh=100> </td>
        </tr>
        <tr>
          <td>Item description</td>
          <td><textarea name=description cols=40 rows=6></textarea>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td><input type=submit name="addRecord" value="Add record">
        </tr>
      </table>
    <br>
    <br>
    <br>
      <!--Every time you add or update data you need to update the index. <br>
      <input type=submit name="updateIndex" value="Update Index">
    	<br>
    	<br>
    	<br>
    -->
    
      Query the database to see relevant items
      <table>
        <tr>
          <td>
            <input type=text name=query>
          </td>
          <td>
            <input type=submit value="Search" name="search">
          </td>
        </tr>
      </table>
      <%
        
          if (request.getParameter("search") != null)
          {
          
          	out.println("<br>");
          	out.println("Query is " + request.getParameter("query"));
          	out.println("<br>");
          
            if(!(request.getParameter("query").equals("")))
            {
              PreparedStatement doSearch = m_con.prepareStatement("SELECT score(1), subject, description FROM images WHERE CONTAINS (description, '" + request.getParameter("query") + "', 1) > 0");
              //doSearch.setString(1, request.getParameter("query"));
              ResultSet rset2 = doSearch.executeQuery();
              out.println("<table border=1>");
              out.println("<tr>");
              out.println("<th>Subject</th>");
              out.println("<th>Description</th>");
              out.println("<th>Score</th>");
              out.println("</tr>");
              while(rset2.next())
              {
                out.println("<tr>");
                out.println("<td>"); 
                out.println(rset2.getString(2));
                out.println("</td>");
                out.println("<td>"); 
                out.println(rset2.getString(3)); 
                out.println("</td>");
                out.println("<td>");
                out.println(rset2.getObject(1));
                out.println("</td>");
                out.println("</tr>");
              } 
              out.println("</table>");
            }
            else
            {
              out.println("<br><b>Please enter text for quering</b>");
            }            
          }
          m_con.close();
        }
        catch(SQLException e)
        {
          out.println("SQLException: " +
          e.getMessage());
			m_con.rollback();
        }
      %>
    </form>
  </body>
</html>
