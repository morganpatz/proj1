<HTML>
  <HEAD>
    <TITLE>Log Out</TITLE>
  </HEAD>
  <BODY>
    <!--Logout file for CMPUT391 project.
      
	Method for checking associated cookies with this domain, as well as
	deleting cookies, based off of:
	http://www.tutorialspoint.com/jsp/jsp_cookies_handling.htm

	Author: Austin Lee
      -->

    <%			   
       // Check to see if a user is already logged in through this browser by
       // checking the cookies associated with this domain.
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
		// the userid that has logged in on this browser, if it exists.
		if (i != 0) {
		    cookie.setMaxAge(0);
		    response.addCookie(cookie);
		}
	}
	}
	//Tell the user that he or she has been logged out.   
	out.println("You have been logged out. ");
	out.println("<a href=login.jsp>Click here</a>");
	out.println(" to return to the login page.");
       %>
  </BODY>
</HTML>
