<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<!--Import some libraries that have classes that we need -->
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="java.util.HashMap"%>

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
<%!
class Alert {
    private int id;
    private String type;
    private HashMap<String, String> attributes;

    public Alert(int id, String type, HashMap<String, String> attributes) {
        this.id = id;
        this.type = type;
        this.attributes = attributes;
    }

    public int getId() {
        return id;
    }

    public String getType() {
        return type;
    }

    public HashMap<String, String> getAttributes() {
        return attributes;
    }

	@Override
	public String toString() {
		return type + " for " + attributes.values();
	}
}
%>
<a href="HomePage.jsp">Home</a>
<%
try {
	String username = (String)session.getAttribute("username");
	
	out.println("<h3>");
	out.println("Alerts for " + username + ":");
	out.println("</h3>");
	
	int failure = 0;
	
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();

	//Create a SQL statement
	Statement stmt = con.createStatement();
	
	// Alert Tree Map, ordered in descending order by default
	TreeMap<Integer, Alert> Alerts = new TreeMap<Integer, Alert>(Collections.reverseOrder()); 
	
	// INTEREST ALERTS - generated by user on preexisting listings

	String couchQuery = "SELECT A.alert_id, A.alert_type, I.category, C.capacity, IF(C.recliner = 1, 'Yes', 'No') as 'Recliner?' FROM ebay.ALERTS A, ebay.ITEMS I, ebay.COUCH C WHERE A.item_id = I.item_id AND A.item_id = C.item_id AND A.username ='" + username + "';";
	ResultSet couchResult = stmt.executeQuery(couchQuery);
	
	int newAlertID;
	String newAlertType;
	HashMap<String, String> couchAttributes = new HashMap<String, String>();
	
	if (couchResult.next() != false) {
		do {
			newAlertID = Integer.parseInt(couchResult.getString("alert_id"));
			newAlertType = couchResult.getString("alert_type");
			couchAttributes.put("Category", couchResult.getString("category"));
			couchAttributes.put("Recliner", couchResult.getString("Recliner?"));
			couchAttributes.put("Capacity", couchResult.getString("capacity"));
			// Create new alert object
			Alerts.put(newAlertID, new Alert(newAlertID, newAlertType, couchAttributes));
			
		} while (couchResult.next());
	} else {
		failure += 1;
	}
	
	String deskQuery = "SELECT A.alert_id, A.alert_type, I.category, D.length, D.material FROM ebay.ALERTS A, ebay.ITEMS I, ebay.DESK D WHERE A.item_id = I.item_id AND A.item_id = D.item_id AND A.username ='" + username + "';";
	ResultSet deskResult = stmt.executeQuery(deskQuery);
	
	HashMap<String, String> deskAttributes = new HashMap<String, String>();

	if(deskResult.next() != false) {
		do {
			newAlertID = Integer.parseInt(deskResult.getString("alert_id"));
			newAlertType = deskResult.getString("alert_type");
			deskAttributes.put("Category", deskResult.getString("category"));
			deskAttributes.put("Length", deskResult.getString("length"));
			deskAttributes.put("Material", deskResult.getString("material"));
			// Create new alert object
			Alerts.put(newAlertID, new Alert(newAlertID, newAlertType, deskAttributes));
		} while (deskResult.next());
	} else {
		failure += 1;
	}
	
	String bedQuery = "SELECT A.alert_id, A.alert_type, I.category, B.size, B.color FROM ebay.ALERTS A, ebay.ITEMS I, ebay.BED B WHERE A.item_id = I.item_id AND A.item_id = B.item_id AND A.username ='" + username + "';";
	ResultSet bedResult = stmt.executeQuery(bedQuery);
	HashMap<String, String> bedAttributes = new HashMap<String, String>();

	if (bedResult.next() != false) {
		do {
			newAlertID = Integer.parseInt(bedResult.getString("alert_id"));
			newAlertType = bedResult.getString("alert_type");
			bedAttributes.put("Category", bedResult.getString("category"));
			bedAttributes.put("Size", bedResult.getString("size"));
			bedAttributes.put("Color", bedResult.getString("color"));
			// Create new alert object
			Alerts.put(newAlertID, new Alert(newAlertID, newAlertType, bedAttributes));
		} while (bedResult.next());
	} else {
		failure += 1;
	}
	
	if(failure == 3) {
		out.println("<h3>");
		out.println("No alerts.");
		out.println("</h3>");
	}
	else {
		// Print all values in the tree map (alerts)
		out.print("<ul>");
		for (Map.Entry<Integer, Alert> entry : Alerts.entrySet()) {
			// Print details for outbid alerts
			if (entry.getValue().getType().equals("OUTBID ALERT")) {
				String outbidQuery = "SELECT B.bid_value, L.price, B.username FROM ebay.ALERTS A, ebay.LISTINGS L, ebay.BID B WHERE A.item_id = L.item_id AND L.listing_id = B.listing_id AND A.alert_id = " + entry.getValue().id + " AND B.username = '" + username + "' ORDER BY bid_value DESC;"; 
				ResultSet resultBidInfo = stmt.executeQuery(outbidQuery);
				if (resultBidInfo.next()) {
					String yourBid = resultBidInfo.getString("bid_value");
					String newPrice = resultBidInfo.getString("price");
					// Outbid alert is valid only if the last bid >= current max price
					if (Float.parseFloat(yourBid) < Float.parseFloat(newPrice)) {
						out.println("<li>");
						out.println(entry.getValue().toString());
						out.print("Your Bid: " + resultBidInfo.getString("bid_value") + ", ");
						out.print("<b>New Price: " + resultBidInfo.getString("price") + "</b>" + ", ");
						String listingIDQuery = "SELECT L.listing_id FROM ebay.ALERTS A, ebay.LISTINGS L WHERE A.item_id = L.item_id AND A.username ='" + username + "'AND A.alert_id =" + entry.getValue().getId() + ";";
						ResultSet listingIDs = stmt.executeQuery(listingIDQuery);
						if (listingIDs.next()) {
							out.print("<a href='ListingPage.jsp?listing_id=" + listingIDs.getString("listing_id") + "'>Go To Listing</a>");
						}
					out.println("</li>");
					out.println("<br>");
					}
					// Otherwise delete expired alert
					else {
						String deleteQuery = "DELETE FROM ebay.ALERTS WHERE alert_id = " + entry.getValue().id + ";";
						stmt.executeUpdate(deleteQuery);
					}
				}	
			} else {
				out.println("<li>");
				out.println(entry.getValue().toString());
				String listingIDQuery = "SELECT L.listing_id FROM ebay.ALERTS A, ebay.LISTINGS L WHERE A.item_id = L.item_id AND A.username ='" + username + "'AND A.alert_id =" + entry.getValue().getId() + ";";
				ResultSet listingIDs = stmt.executeQuery(listingIDQuery);
				if (listingIDs.next()) {
					out.print("<a href='ListingPage.jsp?listing_id=" + listingIDs.getString("listing_id") + "'>Go To Listing</a>");
				}
				out.println("</li>");
				out.println("<br>");
			}
		}
		out.print("</ul>");
	}
	
} catch (Exception ex) {

	out.println("Problem\n");
	out.println(ex);
}
%>
     
<form method="post" action="HomePage.jsp">
	<input type="submit" value="Home Page">
</form>
        
<br>
        

         
    
</body>