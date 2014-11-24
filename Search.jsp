<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
  <meta http-equiv="content-type" content="text/html; charset=windows-1250">
  <title>Search For Images</title>
  </head>
  <body>
    
    
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
    
    
      Query the database to see relevant items
      <table>
        <tr>
          <td>
            <input type=text name=query>
          </td>
          <td>
            <input type=submit value="Search" name="Search">
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
              PreparedStatement doSearch = m_con.prepareStatement("SELECT score(1), score(2), score(3), subject, description, place, photo_id FROM images WHERE CONTAINS (description, '" + request.getParameter("query") + "', 1) > 0 OR CONTAINS (subject, '" + request.getParameter("query") + "', 2) > 0 OR CONTAINS (place, '" + request.getParameter("query") + "', 3) > 0");

	      ResultSet rset2 = doSearch.executeQuery();

              out.println("<table border=1>");
              out.println("<tr>");
              out.println("<th>Rank</th>");

              while(rset2.next())
              {

		int descRank = Integer.parseInt(rset2.getObject(1).toString());
		int subRank = Integer.parseInt(rset2.getObject(2).toString());
		int locRank = Integer.parseInt(rset2.getObject(3).toString());

		String photo_id = rset2.getString(7);

		subRank = subRank * 6;
		locRank = locRank * 3;

		int rank = descRank + subRank + locRank;
		
		out.println("<td>");
                out.println(rank);
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
