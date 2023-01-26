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
<a href="HomePage.jsp">Home</a>
<br>
<% 
String item_type = "";
String seller = "";
String question_filter = request.getParameter("question_filter");
try {
	String listing_id = request.getParameter("listing_id");
	
	if(listing_id == null){
		out.println("Please add the listing id in the parameters");
		return;
	}
	
	item_type = "";
    String item_Id = "";
    String increment = "";
  
    String sellerLink = "";
    String price  = "";
	
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();
	//Create a SQL statement
	Statement stmt = con.createStatement();
	String str = "SELECT * FROM ebay.listings WHERE listing_id="+listing_id+";";
	//Run the query against the database.
	
	ResultSet result = stmt.executeQuery(str);
	if(result.next()){
	
		price  = result.getString("price");
		increment = result.getString("increment");
		item_Id = result.getString("item_Id");
		seller = result.getString("username");
		sellerLink = "<a href=\"http://localhost:8080/AuctionWebsite/UserPage.jsp?username="+seller+"\">" + seller + "</a>";
	}
	out.println("Seller: "+ sellerLink);
	out.println("<br>");
	str = "SELECT * FROM ebay.items WHERE item_id="+item_Id+";";
	
	result = stmt.executeQuery(str);
	if(result.next()){
	item_type = result.getString("category");
			
	}
	//Make a SELECT query from the table specified by the 'command' parameter at the index.jsp
	 str = "SELECT * FROM ebay."+item_type+" WHERE item_id="+item_Id+";";
	
			//Run the query against the database.
			
			 result = stmt.executeQuery(str);
			//No columns
			if(result.next()){
				
				 if(item_type.equals("bed")){
					String size = result.getString("size");
					String color = result.getString("color");
					out.println("Bed Length: "+size);
					out.println("<br>");
					out.println("Bed Color: "+color);
				
				}else if(item_type.equals("couch")){
					
					String capacity = result.getString("capacity");
					String recliner = result.getString("recliner");
					out.println("Couch capacity:" + capacity);
					out.println("<br>");
					if(Boolean.getBoolean(recliner)){
						out.println("Is the couch a recliner?: Yes");	
					}else{
						out.println("Is the couch a recliner?: No");	
					}
					
					
				}else if(item_type.equals("desk")){
					
					String length = result.getString("length");
					String material = result.getString("material");
				
					out.println("Desk Length: "+length);
					out.println("<br>");
					out.println("Desk material: "+material);
					
				}
				
			
			}
			out.println("<br>");
			out.println("The current price is: $"+price);
			out.println("<br>");
			out.println("This listing increments by at least $"+increment);
			con.close();
	
	
	
}
catch (Exception ex) {
	out.println(ex.toString());
}
%>
<br>
<table>
  <tr>
    <th>Username</th>
    <th>Bid value</th>
  </tr>
<tr>
   <% 
   ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();
	//Create a SQL statement
	Statement stmt = con.createStatement();
	String listing_id = request.getParameter("listing_id");
   String str = "SELECT * from ebay.bid WHERE listing_id ="+listing_id;
   ResultSet result = stmt.executeQuery(str);
 
   while(result.next()){
	  
	   String username = result.getString("username");
	   out.println(username);
	   String userLink = "<a href=\"UserPage.jsp?username="+username+"\">" + username + "</a>";
		out.print("<tr>");
		out.print("<th>"+userLink+"</th>");
		out.print("<th>"+result.getString("bid_value")+"</th>");
		out.print("</tr>");
	}
   
   %>
  </tr>
</table>

<%
 str = "SELECT * from listings WHERE listing_id ="+listing_id;
 result = stmt.executeQuery(str);

 while(result.next()){

 String expire_date = result.getString("expires_time");
 Float min_bid = result.getFloat("min_bid");
 Float price = result.getFloat("price");
 String item_id = result.getString("item_id");
 java.util.Date date = Calendar.getInstance().getTime();  
 java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");  
 String the_date = dateFormat.format(date);
 
 java.util.Date now = dateFormat.parse(the_date);
 java.util.Date expire = dateFormat.parse(expire_date);
 if(now.before(expire)){
		%>
		<form action = "UpdateListing.jsp">
<label for="increment">Increment price:</label>
<input type="number" step="0.01" id="buyer_increment" name="buyer_increment" value="" min ="0" required>

<p>Optional: </p>
<label for="increment">Auto bid upper limit price (Leave blank if you don't want to auto bid):</label>
<input type="number" step="0.01" id="auto_bid_limit" name="auto_bid_limit" value="" min ="0" >
<br>
<label for="increment">Auto bid increments (Leave blank if you don't want to auto bid):</label>
<input type="number" step="0.01" id="auto_increment" name="auto_increment" value="" min ="0">
<input type="hidden" id="listing_id" name="listing_id" value=${param.listing_id}>
<br>
<input type ="submit" value= "Click to bid">
</form>
<br>
 <form action="GenerateAlert.jsp" method="post">
 <select name="alertType">
 <option value="INTEREST ALERT">I'm Interested</option>
 <option value="OUTBID ALERT">If I am outbid</option>
 </select>
 <input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
 <input type="submit" value="Notify Me">
 </form>
		
		<% 
		
	}else{
		if(price >= min_bid){

			str = "SELECT * from ebay.bid WHERE listing_id ="+listing_id;
			 result = stmt.executeQuery(str);
			 String winner = "";
			 Float winningPrice = 0.00f;
			 while(result.next()){
				 winner = result.getString("username");
				 winningPrice = result.getFloat("bid_value");
			 }
			 if(winner.isEmpty()){
				 out.println("No one bid, no winner.");
			 }else{
				out.println("WINNER: "+ winner +" for $"+winningPrice);
				
				str  = "SELECT MAX(alert_id) as maxID FROM ebay.ALERTS;";
				result = stmt.executeQuery(str);
			
				
				int maxID = 0;
				if (result.next() != false) {
					maxID = Integer.parseInt(result.getString("maxID"));
				}	
				// Get item ID from listing ID
				String itemIDQuery = "SELECT L.item_id FROM EBAY.LISTINGS L WHERE L.listing_id=" + listing_id + ";";
				
				ResultSet itemIDs = stmt.executeQuery(itemIDQuery);
				int itemID = 0;
				if (itemIDs.next() != false) {
					itemID = Integer.parseInt(itemIDs.getString("item_id"));
				}
				// Generate alert Alert(Alert_ID, Alert_Type, Item_ID, Username)
				String winnerQuery = "INSERT INTO ebay.alerts VALUES (" + (maxID + 1) + ", 'WINNER ALERT', " + itemID + ", '" + winner + "');";
				stmt.executeUpdate(winnerQuery); 
				break;
			 }
		}else{	
			out.print("NO WINNER, the sellers reserve price was not met!");
	
	}
	
	}
 
 
 }
 
 
%>
<br>
<h2>Questions & Answers about the product:</h2>
<%
if(session.getAttribute("username").equals(seller)){
	%>
	
	<form action = "AnswerSuccess.jsp">
<% 
	int questionID = 0;
	str = "SELECT * from ebay.ItemQuestions WHERE listing_id ="+listing_id;
	 result = stmt.executeQuery(str);
	 int allAnswered = 0;
	 while (result.next()) { 
		 String question = result.getString("question");
		 String answer = result.getString("answer");
		 if(answer == null){
			 allAnswered = allAnswered + 1;
			 out.print("<p>Question: "+question+"</p>");
			 %>
			 <input type="text" id="answer" name="answer" value="" >
			 <br>
			 <input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
			  <input type="hidden" name="question" value="<%=result.getString("question")%>">
			 <input type ="submit" value= "Click to answer question">
			 <% 
		 }
		 questionID = questionID + 1;
	 }
	 if (allAnswered == 0 ){
	out.print("<p>No new questions from users at this time!</p>");
	 }
	
	%>
	</form>
	
<% 
}else{
	
		 
	%>
	<form action = "QuestionSuccess.jsp">
<label for="question">Ask your question about the item:</label>
<input type="text" id="question" name="question" value="" >
<br>
<input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
<input type ="submit" value= "Click to ask question">
</form>

<br>
<%
	
}

 if(question_filter == null){
	%>
	
	<form action = "ListingPage.jsp">
<label for="question">Filter questions by keyword:</label>
<input type="text" id="question_filter" name="question_filter" value="" >

<input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
<input type ="submit" value= "Click to filter">
</form>
<% 
}

str = "SELECT * from ebay.ItemQuestions WHERE listing_id ="+listing_id;
result = stmt.executeQuery(str);
boolean inResult = false;
while (result.next()) { 
	 String question = result.getString("question");
	 String answer = result.getString("answer");
	 inResult = true;
	 if(answer != null){
		 if(question_filter == null){
			 out.print("<p>Question: "+question+"</p>");
			 out.print("<p>Answer: "+answer+"</p>");
			 out.print("<br>"); 
		 }else if(question.toLowerCase().contains(question_filter.toLowerCase())){
			 out.print("<i>showing only listings that contain: " + question_filter + " </i>");
			 out.print("<p>Question: "+question+"</p>");
			 out.print("<p>Answer: "+answer+"</p>");
			 out.print("<br>");
			 %>
			 <form action = "ListingPage.jsp">

<input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
<input type ="submit" value= "Click to remove filter">
			 <% 
		 }else{
			 out.print("<i>showing only listings that contain: " + question_filter + " </i>");
			 %>
			 <form action = "ListingPage.jsp">

<input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
<input type ="submit" value= "Click to remove filter">
			 <% 
		 }

}
	
}
if(!inResult && question_filter != null){
	 out.print("<i>showing only listings that contain: " + question_filter + " </i>");
	 %>
	 <form action = "ListingPage.jsp">

<input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
<input type ="submit" value= "Click to remove filter">
	 <% 	
}

str = "SELECT * from ebay.bid WHERE listing_id ="+listing_id;
result = stmt.executeQuery(str);
%>


<h2>Similar items in the <%out.print(item_type);%> category within the last 30 days:</h2>



<%

String sort = request.getParameter("sort");

String q = "SELECT * FROM ebay.LISTINGS l JOIN ebay.ITEMS i ON l.item_id = i.item_id";



ResultSet res = stmt.executeQuery(q);
out.print("<ul>");
while (res.next()) {
	String id = res.getString("listing_id");
	String price = res.getString("price");
	String listingUser = res.getString("username");
	String sellerLink = "<a href=\"http://localhost:8080/AuctionWebsite/UserPage.jsp?username="+listingUser+"\">" + listingUser + "</a>";
	String increment = res.getString("increment");
	String expires = res.getString("expires_time");
	String itemId = res.getString("item_id");
	String q2 = "SELECT category FROM ebay.ITEMS WHERE item_id = " + itemId + ";";
	Statement stmt2 = con.createStatement();
	ResultSet res2 = stmt2.executeQuery(q2);
	res2.next();
	String category = res2.getString("category");
	 String q3 = "SELECT * FROM ebay.listings WHERE item_id = " + itemId + ";";
	 Statement stmt3 = con.createStatement();
	 ResultSet res3 = stmt3.executeQuery(q3);
	 res3.next();
	 String listDate = res3.getString("date_listed");
	 String current_listing = res3.getString("listing_id");
	 Calendar setup = Calendar.getInstance();
	 setup.add(Calendar.DATE, -30);
	 java.util.Date date = setup.getTime();  
	 java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");  
	 String the_date = dateFormat.format(date);
	 
	 java.util.Date beforeDate = dateFormat.parse(the_date);
	 java.util.Date date_listed = dateFormat.parse(listDate);
	
	
	if(category.equals(item_type) &&date_listed.after(beforeDate)&& !current_listing.equals(listing_id)){
    out.print("<li>");
    // Listing 1: Bed ($50, increment $10, minimum bid $10, expires 10/10/2022) listed by
    out.print("Listing " + id + ": <b>" + category + " $" + price + "</b> (increment $" + increment + ", expires " + expires + ") listed by " + sellerLink + ".");
    out.print(" <small><a href=\"ListingPage.jsp?listing_id="+id+"&item_type="+category+"\">Click here to view listing.</a></small>");
	}

     out.print("</li>");
}
out.print("</ul>");

%>


<input type="hidden" name="listing_id" value="<%=request.getParameter("listing_id")%>">
</body>
</html>