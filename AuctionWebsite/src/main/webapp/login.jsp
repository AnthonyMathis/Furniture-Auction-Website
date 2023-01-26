<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<!--Import some libraries that have classes that we need -->
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Login Page</title>
</head>
<body>
	<%
	try {
		//Get the database connection
		ApplicationDB db = new ApplicationDB();	
		Connection con = db.getConnection();

		//Create a SQL statement
		Statement stmt = con.createStatement();

		//Get parameters from the HTML form at the index.jsp
		String username = request.getParameter("username");
		String password = request.getParameter("password");
		
		
		//Make a SELECT query from the table specified by the 'command' parameter at the index.jsp
		String str = "SELECT * FROM users WHERE username = '"+username +"' and password = '"+password+"'";
		//Run the query against the database.
		
		ResultSet result = stmt.executeQuery(str);
		//No columns
		if(result.next()){
		session.setAttribute("username", username);
		out.println(session.getAttribute("username"));
		response.sendRedirect("WelcomePage.jsp");
		}else{
			out.println("Invalid login! Click the button to login again.");
			
		}
		con.close();

		
	} catch (Exception ex) {
	
		out.print("login failed");
	}
%>
<br>

<form method="post" action="HomePage.jsp">
			
			<input type="submit" value="Login">
		</form>

</body>
</html>