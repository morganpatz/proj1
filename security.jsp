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
  </BODY>
</HTML>
