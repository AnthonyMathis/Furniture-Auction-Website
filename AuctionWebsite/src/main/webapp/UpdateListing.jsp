<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
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
String listing_id = request.getParameter("listing_id");
String item_Id = "";
String increment = "";
String seller = "";
String price = "";
String buyerIncrement = request.getParameter("buyer_increment");
String auto_bid_limit = request.getParameter("auto_bid_limit");
String auto_bid_increment = request.getParameter("auto_increment");
Float auto_increment = 0f;
Float upper_limit = 0f;
if(auto_bid_limit.isEmpty()||auto_bid_increment.isEmpty()){
	if(auto_bid_limit.isEmpty() && auto_bid_increment.isEmpty()){
	
	}else{
		out.println("One of the autobid fields was not filled out, defaulting to a regular bid.");
		out.println("<br>");
		out.println("Please bid again to setup autobid");
		out.println("<br>");
	}
}else{
	upper_limit = Float.parseFloat(auto_bid_limit);
	auto_increment = Float.parseFloat(auto_bid_increment);
}
	
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();
	//Create a SQL statement
	Statement stmt = con.createStatement();
	String str = "SELECT * FROM ebay.listings WHERE listing_id="+listing_id+";";
	//Run the query against the database.
	
	ResultSet result = stmt.executeQuery(str);
	if(result.next()){
	
		price = result.getString("price");
		increment = result.getString("increment");
		item_Id = result.getString("item_Id");
		seller = result.getString("username");
	
	}
	
	
	
	
if(session.getAttribute("username").toString().equals(seller)){	
	out.println("Seller can not bid on their own item.");
}else if(Float.parseFloat(buyerIncrement) < Float.parseFloat(increment)){
	out.println("Increment can not be lower than the minimum increment price");
}else if((upper_limit != 0)&& upper_limit < Float.parseFloat(price)){
	out.println("Automatic price can not be lower than the current price!");
}
else{
	float newPrice = Float.parseFloat(price)+ Float.parseFloat(buyerIncrement);
	str = "UPDATE ebay.listings SET price = "+(newPrice)+" WHERE listing_id = "+listing_id+";";
	stmt.executeUpdate(str);
	
	str = "SELECT * from ebay.bid";
	result = stmt.executeQuery(str);
int bidIndex = 0;
while(result.next()){
		bidIndex = result.getInt("bid_id");
		
	}
bidIndex = bidIndex + 1;
	
	
	String insert = "insert into ebay.bid values("+bidIndex+","+newPrice+","+upper_limit+","+auto_increment+",\""+session.getAttribute("username")+"\","+listing_id+")";
	
	stmt.executeUpdate(insert);
	
	
	out.println("Successfully bid on the item! New item price is: "+newPrice);
//AUTOMATIC BIDDINNG
str = "SELECT * from ebay.bid";
	result = stmt.executeQuery(str);
 bidIndex = 0;
while(result.next()){
		bidIndex = result.getInt("bid_id");
		
	}
bidIndex = bidIndex + 1;
str = "SELECT * from ebay.bid WHERE listing_id="+listing_id+" AND upper_limit >="+price;
result = stmt.executeQuery(str);
ArrayList<String> upperLimits = new ArrayList<String>();
ArrayList<String> usernames = new ArrayList<String>();
ArrayList<String> increments = new ArrayList<String>();
while(result.next()){
upperLimits.add(result.getString("upper_limit"));
usernames.add(result.getString("username"));
increments.add(result.getString("auto_increment"));
}
String newWinner = session.getAttribute("username").toString();
boolean beat = false;
while(true){
boolean moreThanOne = false;
for(int i = 0; i < upperLimits.size(); i++){
     
	str = "SELECT * FROM ebay.listings WHERE listing_id="+listing_id+";";
	 result = stmt.executeQuery(str);
	if(result.next()){
		price = result.getString("price");
		increment = result.getString("increment");
		item_Id = result.getString("item_Id");
		
	}
	
	float theUpperLimit = Float.parseFloat(upperLimits.get(i));
	float theBidIncrement = Float.parseFloat(increments.get(i));
	
	if((Float.parseFloat(price) + theBidIncrement) <= theUpperLimit&&(theUpperLimit + theBidIncrement) >= Float.parseFloat(price)&& !newWinner.equals(usernames.get(i))){
		newWinner = usernames.get(i);
		newPrice = Float.parseFloat(price)+ Float.parseFloat(increments.get(i));
		str = "UPDATE ebay.listings SET price = "+(newPrice)+" WHERE listing_id = "+listing_id+";";
		stmt.executeUpdate(str);
		insert = "insert into ebay.bid values("+bidIndex+","+newPrice+","+upperLimits.get(i)+","+auto_increment+",\""+usernames.get(i)+"\","+listing_id+")";
		stmt.executeUpdate(insert);
		bidIndex = bidIndex + 1;
		beat = true;
		moreThanOne = true;
	}else if(newWinner.equals(usernames.get(i))){
		
	}else{
		upperLimits.remove(i);
		usernames.remove(i);
		increments.remove(i);
	}
	
}
if(!moreThanOne){
	break;
}
}
if(beat){
	out.println("<br>");
	out.println("Another user has autobid enabled, your bid might have been beaten.");
}

// Send alert to the people who have been outbid
str = "SELECT B.username, L.listing_id, L.price, B.bid_value FROM ebay.BID B, ebay.LISTINGS L WHERE B.listing_id = L.listing_id AND L.listing_id = '" + listing_id + "' ORDER BY B.bid_value DESC LIMIT 1, 1;";

// Get itemID from listing_id
String str2 = "SELECT * FROM ebay.listings WHERE listing_id="+listing_id+";";
result = stmt.executeQuery(str);

usernames = new ArrayList<String>();
String newUsername;
while(result.next()){
	newUsername = result.getString("username");
	if(session.getAttribute("username") != newUsername) {
		usernames.add(result.getString("username"));
	} 
}
ResultSet result2 = stmt.executeQuery(str2);
ArrayList<Integer> itemsID = new ArrayList<Integer>();
while(result2.next()){
	itemsID.add(result2.getInt("item_id"));
}

for(int i = 0; i < usernames.size(); i++){
	if(!usernames.get(i).equals(newWinner)){
		str = "SELECT * FROM ebay.users WHERE username=\""+usernames.get(i)+"\";";
		result = stmt.executeQuery(str);
		if(result.next()){
			String maxQuery = "SELECT MAX(alert_id) as maxID FROM ebay.ALERTS;";
			ResultSet maxIDs = stmt.executeQuery(maxQuery);
			int maxID = 0;
			if (maxIDs.next() != false) {
                String curr = maxIDs.getString("maxID");
                if (curr != null && !curr.equals("")) {
                    maxID = Integer.parseInt(curr);
                }
            }
        	String newOutbidAlert = "INSERT INTO ebay.ALERTS values (" + (maxID + 1) + ", 'OUTBID ALERT'," + itemsID.get(i) + ",'" + usernames.get(i) + "');";
			try {
        		stmt.executeUpdate(newOutbidAlert);
			} catch (Exception Ex) {
				out.print(Ex.toString());
			}
		}

	}
}

}
%>

<br>
   <form method="post" action="ListingPage.jsp">
          <input type="hidden" id="listing_id" name="listing_id" value=${param.listing_id}>
            <input type="submit" value="Go back to item.">
        </form>    
        
         
    
</body>