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
<a href="http://localhost:8080/AuctionWebsite/HomePage.jsp">Home</a>
<br>
<h1> ALL LISTINGS: </h1>
<form name="input">
Search for:
<input type="checkbox" name="category" value="bed">Bed
<input type="checkbox" name="category" value="couch">Couch
<input type="checkbox" name="category" value="desk">Desk
<br>
Sort by:
<input type="radio" name="sort" value="price">Lowest Price
<input type="radio" name="sort" value="date">Newest
<input type="radio" name="sort" value="expiry">Expiring Soon
<input type="submit" value="Submit">
</form>
<br>
<% 
try {
	if(session.getAttribute("username") == null){
		String redirectURL = "http://localhost:8080/AuctionWebsite/HomePage.jsp";
	    response.sendRedirect(redirectURL);
	}
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();
	//Create a SQL statement
	Statement stmt = con.createStatement();
	
	String[] categories = request.getParameterValues("category");
	String sort = request.getParameter("sort");
	
	String q = "SELECT * FROM ebay.LISTINGS l JOIN ebay.ITEMS i ON l.item_id = i.item_id";
	
	if (categories != null && categories.length > 0) {
		String[] quotedCategories = new String[categories.length];
		for (int i=0; i<categories.length; i++) {
			quotedCategories[i] = "\"" + categories[i] + "\"";
		}
		String categoriesString = String.join(",", quotedCategories);
		out.print("<i>showing only listings for: " + categoriesString + " </i>");
		q += " WHERE category IN (" + categoriesString + ")";
	}
	
	if (sort != null) {
		out.print("<i>sorting by: " + sort + "</i>");
		String sortParam = "";
		String sortDirection = "ASC";
		if (sort.equals("price")) {
			sortParam = "price";
		}
		else if (sort.equals("date")) {
			sortParam = "date_listed";
			sortDirection = "DESC";
		}
		else {
			sortParam = "expires_time";
			sortDirection = "ASC";
		}
		q += " ORDER BY " + sortParam + " " + sortDirection;
	}
	
	q += ";";
	
	
	ResultSet res = stmt.executeQuery(q);
	out.print("<ul>");
	while (res.next()) {
		String id = res.getString("listing_id");
		String initPrice = res.getString("price");
		String listingUser = res.getString("username");
		String increment = res.getString("increment");
		String minBid = res.getString("min_bid");
		String expires = res.getString("expires_time");
		String itemId = res.getString("item_id");
		String q2 = "SELECT category FROM ebay.ITEMS WHERE item_id = " + itemId + ";";
		Statement stmt2 = con.createStatement();
		ResultSet res2 = stmt2.executeQuery(q2);
		res2.next();
		String category = res2.getString("category");
        out.print("<li>");
        // Listing 1: Bed ($50, increment $10, minimum bid $10, expires 10/10/2022) listed by
        out.print("Listing " + id + ": <b>" + category + " $" + initPrice + "</b> (increment $" + increment + ", minimum bid $" + minBid + ", expires " + expires + ") listed by " + listingUser + ".");
        out.print("<small><a href=\"ListingPage.jsp?listing_id="+id+"\">Click here to view listing.</a></small>");
        
         out.print("</li>");
    }
	out.print("</ul>");

}

catch (Exception ex) {
	out.print(ex.toString());
}

// form to set alert to show if listing of desired item is available
out.print("<h3>Can't find what you're looking for? Know when items of your choice are available: </h3>");
out.print("  I'm interested in: ");

%>
<form id="set_alert" action="SetAlert.jsp">
<label for="Category">Choose a category:</label>
  <select name="category" id="category">
  <option value="none" selected disabled hidden>Select an Option</option>
    <option value="bed">Bed</option>
    <option value="couch">Couch</option>
    <option value="desk">Desk</option>
  </select>

<div id="attributes">
</div>

<input id="alert_submit" type="submit" value="Set Alert" hidden>
<br>
</form>
<br>
		<form method="post" action="logout.jsp">
			<input type="submit" value="Logout">
		</form>
	<br>
	
</body>

<script>
// Print the value of category field
function printCategory() {
	let x = document.getElementById("category").value;
	let attributes = document.getElementById("attributes");
	let submit = document.getElementById("alert_submit");

	switch (x) {
		case "bed":
			attributes.innerHTML = "Color: <input type=\"text\" name=\"color\"> <br> <label for=\"size\">Choose a size:</label> <select name=\"size\" id=\"size\"> <option value=\"Twin\">Twin</option> <option value=\"Twin XL\">Twin XL</option> <option value=\"Full\">Full</option> <option value=\"Queen\">Queen</option> <option value=\"King\">King</option> </select>";	
			submit.hidden = false;
			break;
		case "couch":
			attributes.innerHTML = "Capacity: <input type=\"text\" name=\"size\"><br><label for='recliner'>Recliner? </label><select name='recliner' id='recliner'><option value='true'>True</option><option value='false'>False</option><br>";	
			submit.hidden = false;
			break;
		case "desk":
			attributes.innerHTML = "Length: <input type=\"text\" name=\"length\"><br>Material: <input type=\"text\" name=\"material\">";	
			submit.hidden = false;
			break;
		default:
			break;
	}
}
document.getElementById("category").addEventListener("change", printCategory);
</script>

</html>