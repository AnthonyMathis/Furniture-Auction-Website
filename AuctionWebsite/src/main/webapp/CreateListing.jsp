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
<a href="http://localhost:8080/AuctionWebsite/HomePage.jsp">Home</a>
<br>
</head>
<%
if(session.getAttribute("username") == null){
	String redirectURL = "http://localhost:8080/AuctionWebsite/HomePage.jsp";
    response.sendRedirect(redirectURL);
}
%>
<body>
<b>Create a listing:</b>
<br>
<br>

<form action = "ListingSuccess.jsp">
<label for="Category">Choose a category:</label>
  <select name="category" id="category">
  <option value="none" selected disabled hidden>Select an Option</option>
    <option value="bed">Bed</option>
    <option value="couch">Couch</option>
    <option value="desk">Desk</option>
  </select>
  <div id="attributes">
</div>
  <script>
// Print the value of category field
function printCategory() {
	let x = document.getElementById("category").value;
	let attributes = document.getElementById("attributes");


	switch (x) {
		case "bed":
			attributes.innerHTML = "Color: <input type=\"text\" name=\"color\"> <br> <label for=\"size\">Choose a size:</label> <select name=\"size\" id=\"size\"> <option value=\"Twin\">Twin</option> <option value=\"Twin XL\">Twin XL</option> <option value=\"Full\">Full</option> <option value=\"Queen\">Queen</option> <option value=\"King\">King</option> </select>";	
			submit.hidden = false;
			break;
		case "couch":
			attributes.innerHTML = "Capacity: <input type=\"text\" name=\"capacity\"><br><label for='recliner'>Recliner? </label><select name='recliner' id='recliner'><option value='true'>True</option><option value='false'>False</option><br>";	
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
  
  
    <br>
    <br>
  <label for="expire_date">When do you want the listing to expire?:
</label>
  <input type="datetime-local" id="expire_date" name="expire_date" required>   
    <br>
    <br>
    <label for="initial_price">Initial price:</label>
  <input type="number" step="0.01"  id="price" name="price" value=""  min="0" required>
  <br>
  <br>
  <label for="increment">Increment price:</label>
  <input type="number" step="0.01" id="increment" name="increment" value="" min="0" required>
  <br>
   <br>
  <label for="min_bid">Enter the minimum bid that you would accept:</label>
  <input type="number" step="0.01" id="min_bid" name="min_bid" value="" min="0" required>
  <br>
  <input type ="submit" value= "Submit">
  </form>
  
</body>