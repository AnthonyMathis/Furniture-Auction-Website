<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<!--Import some libraries that have classes that we need -->
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Welcome <% if(session.getAttribute("username") != null){
    out.println(session.getAttribute("username"));
}else {
    out.println("Page");
}
%></title>
</head>
<body>
<a href="http://localhost:8080/AuctionWebsite/HomePage.jsp">Home</a>
<br>
<%
try{
	if(session.getAttribute("username") == null){
		String redirectURL = "http://localhost:8080/AuctionWebsite/HomePage.jsp";
	    response.sendRedirect(redirectURL);
	}
String listing_id = request.getParameter("listing_id");
String answer = request.getParameter("answer");
String question = request.getParameter("question");

int questionIndex = 0;
try{
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();

	//Create a SQL statement
	Statement stmt = con.createStatement();

	//Make a SELECT query from the table specified by the 'command' parameter at the index.jsp
	String str = "SELECT * FROM ItemQuestions";
	
	ResultSet result = stmt.executeQuery(str);
	
	while(result.next()){
	questionIndex = result.getInt("question_id");
	question = result.getString("question");
	if(question.equals(question)){
		break;
	}
	}
	
	str = "UPDATE ItemQuestions SET answer =\""+(answer)+"\" WHERE question = \""+question+"\";";
	stmt.executeUpdate(str);
	out.println("Successfully answered question!");

	%>
	 <form method="post" action="ListingPage.jsp">
          <input type="hidden" id="listing_id" name="listing_id" value=${param.listing_id}>
            <input type="submit" value="Go back to item.">
        </form> 
	<% 
}catch(Exception e){
	out.println(e.toString());
}

} catch (Exception ex) {
	
}

%>
  </form>
</body>