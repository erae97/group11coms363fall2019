<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Food Web App for Demo</title>
</head>
<body>
	<!-- any error is redirected to ShowError.jsp -->
	<%@ page errorPage="ShowError.jsp"%>
	<!-- include all the database connection configurations -->
	<%@ include file="./DBInfo.jsp"%>
	
	<%
		Connection conn=null;
		PreparedStatement stmt=null;
		ResultSet rs=null;

		Class.forName("com.mysql.jdbc.Driver");
		conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				
		String sqlQuery = "select f.FNAME from food f where f.FID = ?";
		
		stmt = conn.prepareStatement(sqlQuery);
		
		// request.getParameter() always return string type or null if not exists
		
		stmt.setInt(1,Integer.parseInt(request.getParameter("food_selector")));
		
		rs = stmt.executeQuery();
		while (rs.next()) {
			out.println("<h3>Here's the recipe of " + rs.getString("FNAME") + ":</h3>");
		}
		out.println("<br/>");
		
		sqlQuery = "select i.INAME, r.AMOUNT from food f inner join recipe r on r.FID = f.FID inner join ingredient i on i.IID = r.IID where f.FID = ?";
		
		stmt = conn.prepareStatement(sqlQuery);
		stmt.clearParameters();
		
		// this works as seen in a previous example
		// stmt.setInt(1,Integer.parseInt(request.getParameter("food_selector")));
		
		// the method does some conversion for us
		stmt.setString(1, request.getParameter("food_selector"));
		
		rs = stmt.executeQuery();
		out.println("<table><tr><th>Ingredient</th><th>Amount</th></tr>");
		while (rs.next()) {
			out.println("<tr>");
			out.println("<td>" + rs.getString("INAME") + "</td>");
			out.println("<td>" + rs.getString("AMOUNT") + "</td>");
			out.println("</tr>");
		}
		out.println("</table>");
		
		rs.close();
		stmt.close();
		conn.close();
	%>
	<br />
	<form action="Index.jsp">
		<input type="submit" value="BACK" />
	</form>
</body>
</html>