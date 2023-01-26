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

java.util.Date date = Calendar.getInstance().getTime();  
java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");  
String the_date = dateFormat.format(date);
String expire_date = request.getParameter("expire_date").replace("T", " ");

java.util.Date now = dateFormat.parse(the_date);
java.util.Date expire = dateFormat.parse(expire_date);

if(now.before(expire)){


String category = request.getParameter("category");
%>
<b>Select item specifics:</b>
<br>

<form action = "ListingSuccess.jsp">
<%


if(session.getAttribute("username") == null){
	String redirectURL = "http://localhost:8080/AuctionWebsite/CreateListing.jsp";
    response.sendRedirect(redirectURL);
}else if(category == null){
	
	String redirectURL = "http://localhost:8080/AuctionWebsite/CreateListing.jsp";
    response.sendRedirect(redirectURL);
}else if(category.equals("bed")){
%>
 <label for="size">Bed Length:</label>
 <input type="text" id="size" name="size" value="" >
 <br>
 <label for="color">Bed color:</label>
 <input type="text" id="color" name="color" value="" >

<%
}else if(category.equals("couch")){
	%>
 <label for="capacity">Couch capacity:</label>
 <input type="text" id="capacity" name="capacity" value="" >
 <br>
 <label for="recliner">Recliner?</label>
  <select name="recliner" id="recliner">
    <option value="true">True</option>
    <option value="false">False</option>
    <% 
}else if(category.equals("desk")){
	%>
 <label for="length">Desk Length:</label>
 <input type="text" id="length" name="length" value="" >
 <br>
 <label for="material">Desk material:</label>
 <input type="text" id="material" name="material" value="" >
	<% 
}

%>
<br>
 <input type="hidden" id="category" name="category" value=${param.category}>
 <input type="hidden" id="increment" name="increment" value=${param.increment}>
 <input type="hidden" id="price" name="price" value=${param.price}>
 <input type="hidden" id="expire_date" name="expire_date" value=${param.expire_date}>
  <input type="hidden" id="min_bid" name="min_bid" value=${param.min_bid}>
<input type ="submit" value= "Submit">
  </form>
  <% 
  }else{
	out.println("Invalid date, please start over");
	 %> 
	 <form action="http://localhost:8080/AuctionWebsite/CreateListing.jsp">
    <input type="submit" value="Go back" />
	</form>
	 <% 
}%>
</body>



