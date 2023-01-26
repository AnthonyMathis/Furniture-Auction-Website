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
<a href="HomePage.jsp">Home</a>
<br>
<%

if(session.getAttribute("username") == null){
	String redirectURL = "HomePage.jsp";
	response.sendRedirect(redirectURL);
}
String category = request.getParameter("category");
String username = (String) session.getAttribute("username");

ApplicationDB db = new ApplicationDB();	
Connection con = db.getConnection();
//Create a SQL statement
Statement stmt = con.createStatement();

// Get max item id
int maxItemId = 0;
String query = "SELECT MAX(item_id) FROM ebay.items";
ResultSet rs = stmt.executeQuery(query);
if (rs.next() && rs.getString("MAX(item_id)") != null){
	do{
	
	    maxItemId = Integer.parseInt(rs.getString("MAX(item_id)"));
	} while ((rs.next()));
}else{
	
}

Boolean success = false;

if (category.equalsIgnoreCase("couch")) {
	String size = request.getParameter("size");
	String recliner = request.getParameter("recliner");
	/* out.print("COUCH [" + size + ", " + recliner + "]"); */
    // Get max couch id
    // Insert into item (item_id, category)
    String query1 = "INSERT INTO ebay.items VALUES (" + (maxItemId + 1) + ", '" + category + "')";
    stmt.executeUpdate(query1);
    
    int maxCouchId = 0;
    String query2 = "SELECT MAX(couch_id) FROM ebay.couch";
    ResultSet rs1 = stmt.executeQuery(query2);
    if (rs1.next() && rs1.getString("MAX(couch_id)") != null) {
    	do{
            maxCouchId = Integer.parseInt(rs1.getString("MAX(couch_id)"));
        } while(rs1.next());
    }
    
    // Insert into couch (couch_id, capacity, item_id, recliner)
    String query3 = "INSERT INTO ebay.couch VALUES (" + (maxCouchId + 1) + ", '" + size + ", " + (maxItemId + 1) + ", " + recliner + ")";
    stmt.executeUpdate(query3);
    success = true;
    
} else if (category.equalsIgnoreCase("bed")) {
	String size = request.getParameter("size");
	String color = request.getParameter("color");
	/* out.print("BED [" + size + ", " + color + "]"); */
    // Get max bed id
    // Insert into item (item_id, category)
    String query1 = "INSERT INTO ebay.items VALUES (" + (maxItemId + 1) + ", '" + category + "')";
    stmt.executeUpdate(query1);
    
    int maxBedId = 0;
    String query2 = "SELECT MAX(bed_id) FROM ebay.bed";
    ResultSet rs1 = stmt.executeQuery(query2);
    if (rs1.next() && rs1.getString("MAX(bed_id)") != null) {
    	do{
            maxBedId = Integer.parseInt(rs1.getString("MAX(bed_id)"));
        } while(rs1.next());
    }
     
    // Insert into bed (bed_id, item_id, size, color)
    String query3 = "INSERT INTO ebay.bed VALUES (" + (maxBedId + 1) + ", " + (maxItemId + 1) + ", '" + size + "', '" + color + "')"; stmt.executeUpdate(query3);
    success = true;

} else if (category.equalsIgnoreCase("desk")) {
	String length = request.getParameter("length");
	String material = request.getParameter("material");
	/* out.print("DESK [" + size + ", " + material + "]"); */
    // Get max desk id
    // Insert into item (item_id, category)
    String query1 = "INSERT INTO ebay.items VALUES (" + (maxItemId + 1) + ", '" + category + "')";
    stmt.executeUpdate(query1);
    int maxDeskId = 0;
    String query2 = "SELECT MAX(desk_id) FROM ebay.desk";
    ResultSet rs1 = stmt.executeQuery(query2);
    if (rs1.next() && rs1.getString("MAX(desk_id)") != null) {
    	do {
            maxDeskId = Integer.parseInt(rs1.getString("MAX(desk_id)"));
        }
    	while(rs1.next());
    }
    
    // Insert into desk (desk_id, item_id, size, material)
    String query3 = "INSERT INTO ebay.desk VALUES (" + (maxDeskId + 1) + ", " + (maxItemId + 1) + ", " + length + ", " + material + ")";
    stmt.executeUpdate(query3);
    success = true;
}

if (success) {
    out.print("<h2>Item successfully added!</h2>");
    // Create pending alert for item
    // Get alert ID 
	String maxQuery = "SELECT MAX(alert_id) as maxID FROM ebay.PENDING_ALERTS;";
	
	ResultSet maxIDs = stmt.executeQuery(maxQuery);
	int maxID = 0;
	if (maxIDs.next() != false) {
        String curr = maxIDs.getString("maxID");
		if (curr != null && !curr.equals("")) {
            maxID = Integer.parseInt(curr);
        }
	} 
	int itemID = maxItemId + 1;
	// Insert into pending alerts
    String insertQuery = "INSERT INTO ebay.PENDING_ALERTS VALUES (" + (maxID + 1) + ", 'INTEREST ALERT'," + itemID + ", '" + username + "');";
    stmt.executeUpdate(insertQuery);
    out.print("SUCCESS: You will be notified if a listing is created for your item.");
} else {
    out.print("ERROR: Item not added!");
}
%>
</body>