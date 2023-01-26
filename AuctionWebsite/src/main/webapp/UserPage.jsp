<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
  <%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>All Listings</title>
</head>
<body>
<a href="http://localhost:8080/FurnitureAuctionWebsite/HomePage.jsp">Home</a>
<br>
<% 
try {
	String username = request.getParameter("username");
	
	out.print("<h1>Showing activity for user: " + username + "</h1>");
	
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();
	//Create a SQL statement
	Statement stmt = con.createStatement();
	Statement stmt2 = con.createStatement();
	String listingsQuery = "SELECT * FROM ebay.LISTINGS WHERE username=\""+username+"\"";
	String bidsQuery = "SELECT * FROM ebay.BID WHERE username=\""+username+"\" ORDER BY bid_id DESC;";
	//Run the query against the database.
	
	ResultSet listings = stmt.executeQuery(listingsQuery);
	ResultSet bids = stmt2.executeQuery(bidsQuery);
	out.print("<h2>Listings:</h2>");
	%>
	
   <% 
   out.print("<ul>");
	while (listings.next()) {
		String id = listings.getString("listing_id");
		String price = listings.getString("price");
		String increment = listings.getString("increment");
		String expires = listings.getString("expires_time");
		String itemId = listings.getString("item_id");
		String q2 = "SELECT category FROM ebay.ITEMS WHERE item_id = " + itemId + ";";
		Statement stmtF = con.createStatement();
		ResultSet res2 = stmtF.executeQuery(q2);
		res2.next();
		String category = res2.getString("category");
       out.print("<li>");
       // Listing 1: Bed ($50, increment $10, minimum bid $10, expires 10/10/2022) listed by
       out.print("Listing " + id + ": <b>" + category + " $" + price + "</b> (increment $" + increment + ", expires " + expires + ") listed by " + username + ".");
       out.print(" <small><a href=\"http://localhost:8080/FurnitureAuctionWebsite/ListingPage.jsp?listing_id="+id+"&item_type="+category+"\">Click here to view listing.</a></small>");
       
        out.print("</li>");
   }
	out.print("</ul>");
	
	out.print("<h2>Bids:</h2>");
	 out.print("<ul>");
		while (bids.next()) {
			String listing_id = bids.getString("listing_id");
			String price = bids.getString("bid_value");
			String q3 = "SELECT category FROM ebay.ITEMS i JOIN ebay.LISTINGS l JOIN ebay.BID b ON i.item_id = l.item_id AND l.listing_id = b.listing_id WHERE l.listing_id = " + listing_id;
			Statement stmtG = con.createStatement();
			ResultSet res3 = stmtG.executeQuery(q3);
			res3.next();
			String category = res3.getString("category");
	       out.print("<li>");
	       // Admin bid $10 on bed
	       out.print(username + " bid $" + price + " on " + category + ".");
	       out.print(" <small><a href=\"http://localhost:8080/FurnitureAuctionWebsite/ListingPage.jsp?listing_id="+listing_id+"&item_type="+category+"\">Click here to view listing.</a></small>");
	       
	        out.print("</li>");
	   }
		out.print("</ul>");
	
   
   %>
<% 
	
}
catch (Exception ex) {
	out.println(ex.toString());
}
%>


</body>
</html>