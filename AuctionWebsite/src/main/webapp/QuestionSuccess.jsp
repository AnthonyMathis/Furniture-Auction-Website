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
String question = request.getParameter("question");


int lastQuestionIndex = 0;
try{
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();

	//Create a SQL statement
	Statement stmt = con.createStatement();

	//Make a SELECT query from the table specified by the 'command' parameter at the index.jsp
	String str = "SELECT * FROM ItemQuestions";
	String insert = "";
	ResultSet result = stmt.executeQuery(str);
	while(result.next()){
		lastQuestionIndex = result.getInt("question_id");
	}
	lastQuestionIndex = lastQuestionIndex + 1;
	
	insert = "insert into ItemQuestions values("+lastQuestionIndex+","+listing_id+",\""+question+"\",null)";
	stmt.executeUpdate(insert);
	out.println("Successfully asked question!");
	%>
	 <form method="post" action="ListingPage.jsp">
          <input type="hidden" id="listing_id" name="listing_id" value=${param.listing_id}>
            <input type="submit" value="Go back to item.">
        </form> 
	<% 
}catch(Exception e){
	
}

} catch (Exception ex) {

}

%>
  </form>
</body>