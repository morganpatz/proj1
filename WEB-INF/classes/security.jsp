<HTML>
  <HEAD>
    <TITLE></TITLE>
  </HEAD>
  <BODY>
    <!--
	This module will handle the requirements for the security module.
	Note that NONE of these functions will close any connections passed
	to them.
      -->

    <%!
       <!--
	   A helper function that executes a query for a given value, and
	   and returns that value as a string. Returns the resulting value in
	   a string if a value is found. Otherwise, an empty string is returned.
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
	   A helper function for safely executing a single SQL update query.
	   Returns 1 if the update is successful, -1 if an SQL error occured.
	   Usage:
	   --update: A string containing a proper SQL update statement.
	   --conn: A connection to an SQL database.
	 -->
       public int update_value (String update, connection conn){
       //Attempt to execute the update statement.
       Statement stmt = null;
       try{
         stmt = conn.createStatement();
         stmt.executeUpdate(update);
         conn.commit();
       }
       //If something went wrong during the update, attempt to rollback the
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
       //If we got here, the update was a success!
       return 1;
       }
       %>

    <%!
       <!--
	   A function that contains the logic that applies to both adding and
	   removing members from a group. It's called by add_friend and
	   remove_friend. It returns the group_id of the group the user
	   specified, encapsulated in a string, only if the user has permission
	   to edit the group. Otherwise, an empty string is returned.
	   Usage:
	 --userid: the user_id of the user who requested this action
	 --groupname: the name of the group specified by the user
	 --friendid: the user_id of the one the user wishes to add or remove
	   from the selected group.
	 --conn: a connection to an sql database
	 -->
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
       return "";
       }
       
       //If we got to here, we know that the group is valid, and that the
       //supplied friend ID is not the user's own ID and exists in the
       //database.
       return gid;
       }
       %>

    <%!
       <!--
	   A simple function that checks if the user has permission to edit
	   a given image. Note that a user that can edit an image is also able
	   to view it. Returns 1 if the user has permission, 0 if not.
	   Usage:
	   --username: the user_id of the user calling this function
	   --photoid: the photo_id of the photo selected by the user
	   --conn: a connection to an sql database
	   -->
       
       public int edit_allowed(String username, String photoid,
       Connection conn){
       //First, let's see if it's the admin requesting to edit the image.
       //If so, grant permission to view.
       if(userid.equals("admin")){
         return 1;
       }
       
       //If not, check if the user trying to view one of the user's own images.
       String is_image_users = "select OWNER_NAME from IMAGES "
       +"where PHOTO_ID = "+photoid;
       String image_owner = "";
       image_owner = query_value(is_image_users, conn);
       
       //If so, grant permission to view.
       if(userid.equals(image_owner)){
         return 1;
       }
       //If the user does not meet either qualification above, then the user
       //does not have permission to edit the image.
       return 0;
       }
       %>
    

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

	 Usage:
	 --userid: the user_id of the user who requested this action
	 --groupname: the name of the group specified by the user
	 --conn: a connection to an sql database
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
	 
	 Both add_friend and remove_friend return 1 if the add/remove is
	 successful, and return 0 if the edit is rejected.

	 Usage:
	 --userid: the user_id of the user who requested this action
	 --groupname: the name of the group specified by the user
	 --friendid: the user_id of the one the user wishes to add or remove
	   from the selected group.
	 --conn: a connection to an sql database
	 -->
    
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
       int attempt_insert = update_value(insert_friend, conn);
       if(attempt_insert == 1);
         out.println(friendid+"has been added to "+groupname+".<br>");
       else
         out.println("An error occured during the insertion.<br>");
       return attempt_insert;
       }
      
       //Otherwise, we just tell the user that the friend is already in the
       //selected group.
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
       int attempt_delete = update_value(remove_friend, conn);
       if(attempt_delete == 1);
         out.println(friendid+"has been removed from "+groupname+".<br>");
       else
         out.println("An error occured during the deletion.<br>");
       return attempt_delete;
       }
      
       //Otherwise, we just tell the user that the friend is not in the
       //selected group.
       out.println(friendid+"is not a member of "+groupname+".<br>");
       return 0;
       }
       %>

    <!-- Viewing Images:
	 A user may view an image if:
      --The value of PERMITTED is set to 1; that is, it's set to public
      --The user_id  of the user is admin
      --The user_id of the user is the same as the one that uploaded the
	image
      --If the value of PERMITTED is set to a value greater than 2, and the
	user_id of the user belongs in the group that matches the value
	of PERMITTED
	
	If permission to view the image is granted, view_allowed returns 1.
	Else, it returns a 0.
      -->
    <%!
       public int view_allowed(String userid, String photoid, Connection conn){
       //First, let's check if the user has permission to edit the image. A
       //user that can edit a given image can also view it.
       int edit_permission = edit_allowed(userid, photoid, conn);
       if(edit_permission == 1){
         return 1;
       }

       //If not, we next check the permission setting of the image.
       String permission_check = "select PERMITTED from IMAGES "
       +"where PHOTO_ID = '"+photoid;
       String image_permission = query_value(permission_check, conn);
       
       //If the image permission is set to 1 (public), grant access to view.
       if(image_permission.equals("1")){
        return 1;
       }
       
       //If not, check if the permission is set to a group ID that the user
       //is a friend in.
       String group_check = "select FRIEND_ID from GROUP_LISTS where "
       +"GROUP_ID = "+image_permission+" and FRIEND_ID = '"+userid+"'";
       String in_group = query_value(group_check, conn);
       if(userid.equals(in_group) {
         return 1;
       }
       //If the user met none of the above conditions, then deny permission to
       //view the image.
       return 0;
       }
       %>

    <!-- Updating Image Information / Deleting Images:
	 A user that can update a given image can also delete said image. In
	 order to perform either on a given image, the user_id of the one
	 requesting this action must be any of the following:
	 --admin
	 --the same user_id as the one that uploaded the image
	 -->
    <%!
       <!--
	   The function that edits an image if the user requesting to edit has
	   permission to do so. It
	 -->
       
       public int edit_image(String username, String photoid,
       Connection conn){
       //First, let's check if the user has permission to edit the image.
       int edit_permission = edit_allowed(userid, photoid, conn);
       if(edit_permission == 0){
         return 0;
       }
       }
       %>
    
  </BODY>
</HTML>
