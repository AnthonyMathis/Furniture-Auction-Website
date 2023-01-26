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
	
String category = request.getParameter("category");
String min_bid = request.getParameter("min_bid");
String price = request.getParameter("price");
String increment = request.getParameter("increment");
String expire_date = request.getParameter("expire_date").replace("T", " ");


java.util.Date date = Calendar.getInstance().getTime();  
java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");  
String the_date = dateFormat.format(date);

java.util.Date now = dateFormat.parse(the_date);
java.util.Date expire = dateFormat.parse(expire_date);

if(now.after(expire)){
	%>
	<br>
		<a href="http://localhost:8080/AuctionWebsite/CreateListing.jsp"><% out.println("Invalid date, please fix!");%></a>
	
	<% 

	
}else{

if(category != null){
ApplicationDB db = new ApplicationDB();	
Connection con = db.getConnection();

//Create a SQL statement
Statement stmt = con.createStatement();

String str = "SELECT * FROM "+category;
ResultSet result = stmt.executeQuery(str);
String insert = "";
int lastCatIndex = 0;
int lastIndex = 0;

boolean foundSimilar = false;
try{

	while(result.next()){
		
		lastCatIndex = result.getInt(category+"_id");
		if(category.equalsIgnoreCase("couch")){
		String capacity = request.getParameter("capacity");
		String recliner = request.getParameter("recliner");
		String queryCapacity = result.getString("capacity");
		String queryRecliner = result.getString("recliner");
		if(queryRecliner.equalsIgnoreCase("1")){
			queryRecliner = "true";
		}else{
			queryRecliner = "false";
		}
		lastIndex = result.getInt("item_id"); 
		if(capacity.equalsIgnoreCase(queryCapacity)&& recliner.equalsIgnoreCase((queryRecliner))){
			
			foundSimilar = true;
			break;
		}
		}else if (category.equalsIgnoreCase("bed")){
		
		
				String size = request.getParameter("size");
				String color = request.getParameter("color");
				String querySize = result.getString("size");
				String queryColor = result.getString("color");
				lastIndex = result.getInt("item_id"); 
				if(size.equalsIgnoreCase(querySize)&& color.equalsIgnoreCase((queryColor))){
					
					foundSimilar = true;
					break;
				}
				
		}else if (category.equalsIgnoreCase("desk")){
			String length = request.getParameter("length");
			String material = request.getParameter("material");
			String queryLength = result.getString("length");
			String queryMaterial = result.getString("material");
			lastIndex = result.getInt("item_id"); 
			if(length.equalsIgnoreCase(queryLength)&& material.equalsIgnoreCase((queryMaterial))){
				
				foundSimilar = true;
				break;
			}
			
	}
	
		lastCatIndex = lastCatIndex + 1;
	}

	// Send alerts to users if there are any pending alerts for the item
if (foundSimilar) {
        int itemID = lastIndex;
        String username2;
        String alertQuery = "SELECT * FROM ebay.PENDING_ALERTS WHERE item_id = " + itemID;
        ResultSet alertResult = stmt.executeQuery(alertQuery);
        ArrayList<String> alertUsers = new ArrayList<String>();
        ArrayList<String> deleteAlerts = new ArrayList<String>();
        if (alertResult.next() != false) {
            do {
                username2 = alertResult.getString("username");
                alertUsers.add(username2);
                // Delete alerts stores the alert id's to delete from pending alerts
                deleteAlerts.add(alertResult.getString("alert_id"));
            } while (alertResult.next());
        }

        // Iterate through deleteAlerts and delete the alerts from pending alerts
        for (String alert : deleteAlerts) {
            alertQuery = "DELETE FROM ebay.PENDING_ALERTS WHERE alert_id = " + alert;
            stmt.executeUpdate(alertQuery);
        }
        // Get max alert id
        int alertID = 0;
        String alertIDQuery = "SELECT MAX(alert_id) FROM ebay.ALERTS";
        ResultSet alertIDResult = stmt.executeQuery(alertIDQuery);
        if (alertIDResult.next()) {
            String curr = alertIDResult.getString("MAX(alert_id)");
            if (curr != null && !curr.equals("")) {
                alertID = Integer.parseInt(curr);
            }
        }
        // Send alerts to users alert(alert_id, alert_type, item_id, username)
        for (String user : alertUsers) {
            alertQuery = "INSERT INTO ebay.ALERTS VALUES (" + alertID + 1 + ", 'INTEREST ALERT', " + itemID + ", '" + user + "')";
            stmt.executeUpdate(alertQuery);
        }
}
	
	if(!foundSimilar){
		 str = "SELECT * FROM items";
		 insert = "";
		 result = stmt.executeQuery(str);
		 lastIndex = 0;
		try{
		while(result.next()){
			lastIndex = result.getInt("item_id");
		}
		lastIndex = lastIndex+1;
		insert = "insert into items values("+lastIndex+",\""+category+"\")";
		stmt.executeUpdate(insert);

		}catch(Exception e){

		}
	}
	
	
	if(category.equalsIgnoreCase("couch") && !foundSimilar){

		String capacity = request.getParameter("capacity");
		String recliner = request.getParameter("recliner");
	
		insert = "insert into "+category+" values("+lastCatIndex+","+capacity+","+lastIndex+","+recliner+")";
		stmt.executeUpdate(insert);
		
		}else if(category.equalsIgnoreCase("bed")&& !foundSimilar){
			String size = request.getParameter("size");
			String color = request.getParameter("color");	
		
			insert = "insert into "+category+" values("+lastCatIndex+","+lastIndex+",\""+size+"\",\""+color+"\")";
			
			stmt.executeUpdate(insert);
	
			
		}else if(!foundSimilar){
			String length = request.getParameter("length");
			String material = request.getParameter("material");	
			insert = "insert into "+category+" values("+lastCatIndex+","+lastIndex+","+length+",\""+material+"\")";
			stmt.executeUpdate(insert);	
		}

}catch(Exception e){
out.println(e.toString());
}


str = "SELECT * FROM listings";
result = stmt.executeQuery(str);

int lastListingIndex = 0;
try{

	while(result.next()){
		lastListingIndex = result.getInt("listing_id");
		
	}
	lastListingIndex = lastListingIndex + 1;

		String capacity = request.getParameter("capacity");
		String recliner = request.getParameter("recliner");
	
		insert = "insert into listings values("+lastListingIndex+","+lastIndex+",\""+the_date+"\",\""+expire_date+"\","+price+","+increment+","+min_bid+","+"\""+session.getAttribute("username")+"\")";
		stmt.executeUpdate(insert);
		
		out.println("Listing successfully added!");
		
		%>
		<br>
		<a href="http://localhost:8080/AuctionWebsite/ListingPage.jsp?listing_id=<% out.println(lastListingIndex);%>">Go to listing!</a>

	<% 
}catch(Exception e){
out.println(e.toString());
}




con.close();
}else{
	
    String redirectURL = "http://localhost:8080/AuctionWebsite/CreateListing.jsp";
    response.sendRedirect(redirectURL);

}
}
} catch (Exception ex) {
	String redirectURL = "http://localhost:8080/AuctionWebsite/CreateListing.jsp";
    response.sendRedirect(redirectURL);
}

%>
  </form>
</body>