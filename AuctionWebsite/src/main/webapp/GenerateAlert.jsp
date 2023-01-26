<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<!--Import some libraries that have classes that we need -->
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>
<% if(session.getAttribute("username") != null){
    out.println("Alerts for " + session.getAttribute("username"));
}else {
    out.println("");
}
%></title>
</head>
<body>
<form method="post" action="HomePage.jsp">
	<input type="submit" value="Home Page">
</form>

<%
String listing_id = request.getParameter("listing_id");
String alert_type = request.getParameter("alertType");
String username = (String)session.getAttribute("username");

try {
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();

	//Create a SQL statement
	Statement stmt = con.createStatement();
	
	// Get alert ID 
	String maxQuery = "SELECT MAX(alert_id) as maxID FROM ebay.ALERTS;";
	
	ResultSet maxIDs = stmt.executeQuery(maxQuery);
	int maxID = 0;
	if (maxIDs.next() != false) {
		maxID = Integer.parseInt(maxIDs.getString("maxID"));
	} else {
		throw new SQLException();
	}
	
	// Get item ID from listing ID
	String itemIDQuery = "SELECT L.item_id FROM EBAY.LISTINGS L WHERE L.listing_id=" + listing_id + ";";
	
	ResultSet itemIDs = stmt.executeQuery(itemIDQuery);
	int itemID = 0;
	if (itemIDs.next() != false) {
		itemID = Integer.parseInt(itemIDs.getString("item_id"));
	} else {
		throw new SQLException();
	}
	
	// Generate alert based on type selected
	if (alert_type.equals("INTEREST ALERT")) {
		String checkQuery = "SELECT * FROM ebay.ALERTS A WHERE A.alert_type = 'INTEREST ALERT' AND A.item_id = " + itemID + " AND A.username = '" + username + "';";
        ResultSet check = stmt.executeQuery(checkQuery);
        if (check.next() != false) {
            out.println("<h2>Alert already exists</h2>");
        } else {
        	String newInterestAlert = "INSERT INTO ebay.ALERTS values (" + (maxID + 1) + ", 'INTEREST ALERT'," + itemID + ",'" + username + "');";
        	stmt.executeUpdate(newInterestAlert);
            out.println("<b>SUCCESS</b> - Interest alert created");
        }
		
	} else if (alert_type.equals("OUTBID ALERT")) {
		String checkQuery = "SELECT * FROM ebay.ALERTS A WHERE A.alert_type = 'OUTBID ALERT' AND A.item_id = " + itemID + " AND A.username = '" + username + "';";
		ResultSet check = stmt.executeQuery(checkQuery);
        if (check.next() != false) {
        	out.println("<h2>Alert already exists</h2>");
        } else {
        	// Check if the user made a bid on the listing
            String bidQuery = "SELECT * FROM ebay.BID B WHERE B.listing_id = " + listing_id + " AND B.username = '" + username + "';";
            ResultSet bid = stmt.executeQuery(bidQuery);
            if (bid.next() == false) {
                out.println("<h2>You have not made a bid on this item</h2>");
                out.println("Please make a bid on the item before creating an outbid alert");
            } else {
        	String newOutbidAlert = "INSERT INTO ebay.ALERTS values (" + (maxID + 1) + ", 'OUTBID ALERT'," + itemID + ",'" + username + "');";
        
            stmt.executeUpdate(newOutbidAlert);
            out.println("<b>SUCCESS</b> - Outbid alert created");
                
        }
       }
	}
	
	out.println("<br>");
	out.println("<br>");
	out.println("<a href='ListingPage.jsp?listing_id=" + listing_id + "'>Back to listing</a>");
}

catch (Exception ex) {

	out.println("Problem\n");
	out.println(ex);
}


%>     
        
<br>
        

         
    
</body>