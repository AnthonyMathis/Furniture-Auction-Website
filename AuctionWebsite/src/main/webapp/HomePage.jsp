<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
		<title>Home Page</title>
	</head>
	
	<body>
<% if(session.getAttribute("username") != null){
	%>
	<a href="http://localhost:8080/AuctionWebsite/CreateListing.jsp">Create listing</a>
	<a href="http://localhost:8080/AuctionWebsite/Alerts.jsp">Alerts</a>
	<a href="http://localhost:8080/AuctionWebsite/AuctionsPage.jsp">All Listings</a>
	<a href="http://localhost:8080/AuctionWebsite/CreateListing.jsp">Help</a>
	
	<%
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();
	Statement stmt = con.createStatement();
	
	
	String str = "SELECT username FROM users where isCustRep = true";
	 ResultSet result = stmt.executeQuery(str);
	while(result.next()){
	String username = result.getString("username");
	if(username.equals((session.getAttribute("username")))){

		%>
		<a href="http://localhost:8080/AuctionWebsite/CustRepPortal.jsp">Customer Rep Portal</a>
		<% 
		
	}
	}
	
	%>
	
		<br>
	<% 
    out.println("Currently logged in as: "+session.getAttribute("username")+"!");
   %>
   <form method="post" action="logout.jsp">
            <input type="submit" value="Logout">
        </form>
        <% 
    
}else {
	%>
	Login:
	<br>
		<form method="post" action="login.jsp">
			<table>
				<tr>    
					<td>Username:</td><td><input type="text" name="username"></td>
				</tr>
				<tr>
					<td>Password:</td><td><input type="text" name="password"></td>
				</tr>
			</table>
			<input type="submit" value="Login">
		</form>
		
		
		<form method="post" action="RegisterAccount.jsp">
		
			<input type="submit" value="Create an account!">
		</form>
		
	 <% 
}%>


	
	

</body>
</html>