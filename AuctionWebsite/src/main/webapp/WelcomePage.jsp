<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
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
<% if(session.getAttribute("username") != null){
    out.println("Welcome "+session.getAttribute("username")+"!");
}else {
    out.println("Unable to validate login details.");
}
%>

<br>

        
        <form method="post" action="logout.jsp">
            <input type="submit" value="Logout">
        </form>
         
    
</body>