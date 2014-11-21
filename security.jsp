<HTML>
  <HEAD>
    <TITLE></TITLE>
  </HEAD>
  <BODY>
    <!--
	This module will handle the requirements for the security module.
      -->

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
       Statement check = null;
       ResultSet nset = null;
       String namecheck = "select GROUP_NAME from GROUPS "
       + "where USER_NAME = '"+userid+"' and GROUP_NAME = '"+groupname+"'";
       try{ 
       check = conn.createStatement();
       nset = check.executeQuery(name_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       String nameused = "";
       while(nset != null && nset.next())
       nameused = (nset.getString(1)).trim();
       
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
       +"groups. Please choose a different name.");
       return 0;
       }
       //Else, we can generate a new id for the group and create it.
       //First, we find out the highest ID of all currently existing groups.
       int id = 0;
       String new_id = "select MAX(GROUP_ID) from GROUPS";
       try{
       generate_id = conn.createStatement();
       id = generate_id.executeQuery(name_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       //Then, we increment the result by 1 for a new group id, then convert
       //it into a string so that we can put it into an sql statement.
       id = id + 1;
       String group_id = Integer.toString(id);
       //Now, we have the neccessary information to create a new group.
       String create_group = "INSERT INTO GROUPS VALUES("+group_id+", '"
       +userid+"', '"+groupname+"', '"+sysdate+"')";
       try{
       stmt = conn.createStatement();
       stmt.executeUpdate(create_group);
       conn.commit();
       } catch (SQLException sqle) {
       try {
       conn.rollback();
       } catch(SQLException sqle1) {
       out.println("<hr>" + sqle1.getMessage() + "<hr>");
       }
       } finally {
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       out.println("New group created!");
       return 1;
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
       public int add_friend(String userid, String groupname, String friendid,
       Connection conn) {
       //Before anything else, let's make sure that the user isn't submitting
       //his or her own id to be added to a group.
       if(userid.equals(friendid)){
       out.println("You can't add yourself to your own group as a friend!");
       return 0;
       }

       //Next, let's make sure the user has submitted a valid id to be added.
       String friend_check = "select USER_ID from USERS where "
       +"USERID = '"+friendid+"'";
       try{ 
       check = conn.createStatement();
       fset = check.executeQuery(friend_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       String valid_friend = "";
       while(fset != null && fset.next())
       valid_friend = (fset.getString(1)).trim();
       //If the supplied friend id is invalid, reject the insertion.
       if(friendid != valid_friend || valid_friend == "") {
       out.println("Invalid friend ID supplied, please try again.");
       return 0;
       }

       //Else, we continue on. Next, we must figure out which group we are
       //updating.
       string gid = "";
       String find_group = "select g.GROUP_ID from GROUPS g, USERS u "
       +"where g.USER_NAME == u.USER_NAME and u.USER_NAME == '"+userid+"' "
       +"and g.GROUP_NAME == '"+groupname+"'";
       try{ 
       check = conn.createStatement();
       gset = check.executeQuery(find_group);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       while(gset != null && gset.next())
       gid = (gset.getString(1)).trim();
       //Now, if we do not find a matching group ID, we tell the user that
       //there does not exist a group with the given name that is made by the
       //user.
       if(gid == "") {
       out.println("You have not created a group with that name.");
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       return 0;
       }

       //Finally, we need to check if the friend is already a member of the
       //selected group.
       String redundancy_check = "select FRIEND_ID from group_lists where "
       +"FRIEND_ID = '"+friendid+"' and GROUP_ID = '"+gid+"'";
       try{ 
       check = conn.createStatement();
       redundancy_set = check.executeQuery(redundancy_check);
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       String redundant_friend = "";
       while(redundancy_set != null && redundancy_set.next())
       redundant_friend = (redundancy_set.getString(1)).trim();
       //If the friend is not in the group, we can add the friend.
       if(friendid != redundant_friend) {
       String insert_friend = "insert into group_lists (GROUP_ID, FRIEND_ID, "
       +"DATE_ADDED) values ('"+gid+"', '"+friendid+"', sysdate)";
       try{
       stmt = conn.createStatement();
       stmt.executeUpdate(insert_friend);
       conn.commit();
       } catch (SQLException sqle) {
       try {
       conn.rollback();
       } catch(SQLException sqle1) {
       out.println("<hr>" + sqle1.getMessage() + "<hr>");
       }
       } finally {
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       out.println(friendid+"has been added to "+groupname+".");
       return 1;
       }
       }
      
       //Otherwise, we just tell the user that the friend is already in the
       //selected group.
       try{
       conn.close();
       }
       catch(Exception ex){
       out.println("<hr>" + ex.getMessage() + "<hr>");
       }
       out.println(friendid+"is already a member of "+groupname+".");
       return 0;
       }
       %>
    
    <%!
       public int remove_friend(String userid, String groupname,
       String friendid, Connection conn){

       }
       %>
    
  </BODY>
</HTML>
