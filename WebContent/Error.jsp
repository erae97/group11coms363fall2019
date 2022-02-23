<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!--isErrorPage is important  -->
<%@ page isErrorPage="true"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Error</title>
</head>
<body>
	<p>Here is the exception stack trace:</p>
	<p>
		<%
			exception.printStackTrace(response.getWriter());
		%>
	</p>
</body>
</html>