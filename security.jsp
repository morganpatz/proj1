<HTML>
  <HEAD>
    <TITLE></TITLE>
  </HEAD>
  <BODY>
    <!--
	This module will handle the requirements for the security module.
      -->

    <%!
       <!--
	   A helper function that executes a query for a given value, and
	   and returns that value as a string. Does not close the passed
	   connection.
	   Usage:
	   --query: A string containing an SQL query.
	   --conn: A connection to an SQL database.
	 -->
       public String query_value(String query, Connection conn){
       //Establish the given statement and execute the query.
       Statement stmt = null;
       ResultSet rset = null;
       String result_string = "";
       try{ 
       stmt = conn.createStatement();
       rset = check.executeQuery(query);
       }
       //If something went wrong with the query, return an empty string.
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       return "";
       }

       //Convert the result set from the query into a string.
       while(rset != null && rset.next())
       result_string = (rset.getString(1)).trim();

       //Return the resulting string.
       return result_string;
       }
       %>
    
    <%!
       <!--
	   A helper function for safely executing a single SQL insert query.
	   Closes the passed query.
	   Usage:
	   --update: A string containing a proper SQL update statement.
	   --conn: A connection to an SQL database.
	 -->
       public int insert_value (String insert, connection conn){
       //Attempt to execute the insert statement.
       Statement stmt = null;
       try{
         stmt = conn.createStatement();
         stmt.executeUpdate(insert);
         conn.commit();
       }
       //If something went wrong during the insert, attempt to rollback the
       //changes.
       catch (SQLException sqle) {
         try {
           conn.rollback();
           return -1;
         } 

       //If the rollback fails, report that.
         catch(SQLException sqle1) {
           out.println("<hr>" + sqle1.getMessage() + "<hr>");
           return -1;
         }
       } 
       
       //Lastly, attempt to close the connection.
       finally {
         try{
           conn.close();
         }
         //If closing the connection somehow fails, report the failure.
         catch(Exception ex){
           out.println("<hr>" + ex.getMessage() + "<hr>");
           return -1;
         }
       }
       //If we got here, the insert was a success!
       return 1;
       }
       %>

    <!-- The pseudo-code of the related queries
	 Creating a Group:
	 Since one needs to be logged in to make a group, making one is easy.
	 Well, almost. We need to generate a group id for the group first.
	 Assume that:
	 --userid is the user name of the user requesting the action
	 --groupname is the name of the group submitted by the user, it DOES
	   NOT have to be unique on its own, though the combination of user
	   and group name as a tuple must be unique.
	 if ((userid, groupname) is unique) {
	   id += 1;
	   INSERT INTO groups VALUES(id, userid, groupname, sysdate);
	 }
	 else { tell the user to pick a new group name }

	 Updating a group's list of members:
	 When adding a person into the group, the user needs to supply the
	 user name of the friend being added, and the name of group which the
	 user plans on adding this friend to. As group names alone are not
	 unique, we need to figure out the group id from the supplied group
	 name and the user id of the user performing the action.
	 Assume that:
	 --userid is the user name of the user requesting the action
	 --groupname is the name of the group submitted by the user.
	 --friendid is the user name of the friend the user has submitted.
	 The query to find the correct id should be as follows:
	 declare int gid = null;
	 SELECT g.group_id INTO gid
	 FROM groups g, users u
	 WHERE g.user_name == u.user_name AND
	       u.user_name == userid
	       g.group_name == groupname
	 
	 From here, we can insert the friend into the correct group, if such
	 a group exists and the provided friend's id is valid.
	 if (gid exists && friendid is valid) {
	   INSERT INTO group_lists (group_id, friend_id, date_added)
	   VALUES(gid, friendid, sysdate);
	 else {tell the user to try again}
	 
	 The process for removing friends from a group list follows the same
	 logic above, but concludes with an appropriate DELETE statement.

	 As a side note, how are we going to deal with the notice value...?

	 Viewing Images:
	 A user may view an image if:
	 --The value of PERMITTED is set to 1; that is, it's set to public
	 --The user_id  of the user is admin
	 --The user_id of the user is the same as the one that uploaded the
	   image
	 --If the value of PERMITTED is set to a value greater than 2, and the
	   user_id of the user belongs in the group that matches the value
	   of PERMITTED

	 Updating Image Information / Deleting Images:
	 A user that can update a given image can also delete said image. In
	 order to perform either on a given image, the user_id of the one
	 requesting this action must be any of the following:
	 --admin
	 --the same user_id as the one that uploaded the image
	 -->

    <!-- Creating a Group:
	 Since one needs to be logged in to make a group, making one is easy.
	 Well, almost. We need to generate a group id for the group first.
	 Assume that:
	 --userid is the user name of the user requesting the action
	 --groupname is the name of the group submitted by the user, it DOES
	   NOT have to be unique on its own, though the combination of user
	   and group name as a tuple must be unique.
	 if ((userid, groupname) is unique) {
	   id += 1;
	   INSERT INTO groups VALUES(id, userid, groupname, sysdate);
	 }
	 else { tell the user to pick a new group name }

	 For now, create_group returns an int. 1 if the operation succeeded, 0
	 if the insert was rejected.
	 -->
    
    <%!
       public int create_group(String userid, String groupname,
       Connection conn) {
       //First, we need to check if the user can use this group_name. We start
       //by finding out what name the user has used for a currently existing
       //group.
       String namecheck = "select GROUP_NAME from GROUPS "
       + "where USER_NAME = '"+userid+"' and GROUP_NAME = '"+groupname+"'";
       String nameused = query_value(namecheck, conn);
       
       //If the name is already in use by this user, then reject the
       //registration and tell the user to choose a new group name.
       if(groupname.equals(nameused)) {
       //Oh, and close the connection.
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       out.println("You have already used this name for one of your existing"
       +"groups. Please choose a different name.<br>");
       return 0;
       }

       //Else, we can generate a new id for the group and create it.
       //First, we find out the highest ID of all currently existing groups.
       String find_max_id = "select MAX(GROUP_ID) from GROUPS";
       String max_id = query_value(find_max_id, conn);
       
       //Then, we convert the result to a integer, increment it by 1 for a new
       //group id, then convert it back into a string so that we can put it
       //into an sql statement.
       int new_id = Integer.parseInt(maxid);
       new_id = new_id + 1;
       String group_id = Integer.toString(new_id);

       //Now, we have the neccessary information to create a new group.
       String create_group = "INSERT INTO GROUPS VALUES("+group_id+", '"
       +userid+"', '"+groupname+"', '"+sysdate+"')";
      
       int attempt_insert = insert_value(create_group, conn);
       if(attempt_insert == 1)
         out.println("New group created!<br>");
       else
         out.println("Error with creating a new group.<br>");
       return attempt_insert;
       }

       %>

    <!--
	Updating a group's list of members:
	 When adding a person into the group, the user needs to supply the
	 user name of the friend being added, and the name of group which the
	 user plans on adding this friend to. As group names alone are not
	 unique, we need to figure out the group id from the supplied group
	 name and the user id of the user performing the action.
	 Assume that:
	 --userid is the user name of the user requesting the action
	 --groupname is the name of the group submitted by the user.
	 --friendid is the user name of the friend the user has submitted.
	 The query to find the correct id should be as follows:
	 declare int gid = null;
	 SELECT g.group_id INTO gid
	 FROM groups g, users u
	 WHERE g.user_name == u.user_name AND
	       u.user_name == userid
	       g.group_name == groupname
	 
	 From here, we can insert the friend into the correct group, if such
	 a group exists and the provided friend's id is valid.
	 if (gid exists && friendid is valid) {
	   INSERT INTO group_lists (group_id, friend_id, date_added)
	   VALUES(gid, friendid, sysdate);
	 else {tell the user to try again}
	 
	 The process for removing friends from a group list follows the same
	 logic above, but concludes with an appropriate DELETE statement.

	 As a side note, how are we going to deal with the notice value...?
	 -->
    <%!
       public String validate_group_update(String userid, String groupname,
       String friendid, Connection conn) {
       //Before anything else, let's make sure that the user isn't submitting
       //his or her own id to be updated in a group.
       if(userid.equals(friendid)){
       out.println("You can't add or remove yourself from your own group!<br>");
       return "";
       }

       //Next, let's make sure the user has submitted a valid friend ID.
       String friend_check = "select USER_ID from USERS where "
       +"USERID = '"+friendid+"'";
       String valid_friend = query_value(friend_check, conn);

       //If the supplied friend ID is invalid, reject the update.
       if(friendid != valid_friend || valid_friend == "") {
       out.println("Invalid friend ID supplied, please try again.<br>");
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       return "";
       }

       //Else, we continue on. Next, we must figure out which group we are
       //updating.
       String find_group = "select g.GROUP_ID from GROUPS g, USERS u "
       +"where g.USER_NAME == u.USER_NAME and u.USER_NAME == '"+userid+"' "
       +"and g.GROUP_NAME == '"+groupname+"'";
       String gid = query_value(find_group, conn);
       
       //Now, if we do not find a matching group ID, we tell the user that
       //there does not exist a group with the given name that is made by the
       //user.
       if(gid == "") {
       out.println("You have not created a group with that name.<br>");
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       return "";
       }
       
       //If we got to here, we know that the group is valid, and that the
       //supplied friend ID is not the user's own ID and exists in the
       //database.
       return gid;
       }
       %>
    
    <%!
       public int add_friend(String userid, String groupname, String friendid,
       Connection conn) {
       //We need to check to see if the user has supplied a a valid group name
       //and an existing friend ID.
       String groupid = "";
       groupid = validate_group_update(userid, groupname, friendid,
       conn);
       if(groupid == "") {
       return 0;
       }

       //However, we still need to check if the friend is already a member of
       //the selected group.
       String redundancy_check = "select FRIEND_ID from group_lists where "
       +"FRIEND_ID = '"+friendid+"' and GROUP_ID = '"+gid+"'";
       redundant_friend = query_value(redundancy_check, conn);
       
       //If the friend is not in the group, we can add the friend.
       if(friendid != redundant_friend) {
       String insert_friend = "insert into group_lists (GROUP_ID, FRIEND_ID, "
       +"DATE_ADDED) values ('"+gid+"', '"+friendid+"', sysdate)";
       int attempt_insert = insert_value(insert_friend, conn);
       if(attempt_insert == 1);
         out.println(friendid+"has been added to "+groupname+".<br>");
       else
         out.println("An error occured during the insertion.<br>");
       return attempt_insert;
       }
      
       //Otherwise, we just tell the user that the friend is already in the
       //selected group.
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       out.println(friendid+"is already a member of "+groupname+".<br>");
       return 0;
       }
       %>
    
    <%!
       public int remove_friend(String userid, String groupname,
       String friendid, Connection conn){
       //We need to check to see if the user has supplied a a valid group name
       //and an existing friend ID.
        String groupid = "";
       groupid = validate_group_update(userid, groupname, friendid,
       conn);
       if(groupid == "") {
       return 0;
       }

       //However, we still need to check if the friend is in the selected group.
       String presence_check = "select FRIEND_ID from group_lists where "
       +"FRIEND_ID = '"+friendid+"' and GROUP_ID = '"+gid+"'";
       String is_present = query_value(presence_check, conn);
       
       //If the friend is in the group, we can remove the friend.
       if(friendid.equals(is_present)) {
       String remove_friend = "delete from group_lists where FRIEND_ID = '"
       +friendid+"'";
       int attempt_delete = insert_value(insert_friend, conn);
       if(attempt_delete == 1);
         out.println(friendid+"has been removed from "+groupname+".<br>");
       else
         out.println("An error occured during the deletion.<br>");
       return attempt_insert;
       }
      
       //Otherwise, we just tell the user that the friend is not in the
       //selected group.
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       out.println(friendid+"is not a member of "+groupname+".<br>");
       return 0;
       }
       %>
    
  </BODY>
</HTML>
