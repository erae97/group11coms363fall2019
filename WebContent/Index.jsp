<!-- Author: Taylor Premo -->
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
  pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<html>

<head>
  <title>Tweets Database</title>
  <style type="text/css">
    #flex {
      display: flex;
      flex-direction: row;
      flex-wrap: wrap;

    }

    input {
      align-content: space-around;
      margin-left: 5ch;
      margin-right: 1ch;
      flex: 30% 1 1;
    }
  </style>
</head>

<body>
  <h3>What would you like to know?</h3>
  <%@ include file="./DBInfo.jsp"%>
  <%
    Connection conn =null;
    Statement stmt =null;
    ResultSet rs =null;

    // Java way for handling an error using try catch
    try {
      Class.forName("com.mysql.jdbc.Driver");
      conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
      stmt = conn.createStatement();
      
  %>
  <form method="post" action="Result.jsp">
    <select name="query_selector">
      <option value="Q1">"Q1": List k most retweeted tweets in a given month and a given year;</option>
      <option value="Q3">"Q3": Find k hashtags that appeared in the most number of states in a given year;</option>
      <option value="Q6">"Q6": Find k users who used at least one of the hashtags in a given list of hashtags in their
        tweets.</option>
      <option value="Q9">"Q9": Find top k most followed users in a given party.</option>
      <option value="Q10">"Q10": Find the list of distinct hashtags that appeared in one of the states in a given list
        in a given month of a given year;</option>
      <option value="Q11">"Q11": Find k tweets (with hashtag) posted by republican or democrat members of a state in a
        month of a year.</option>
      <option value="Q15">"Q15": Find users in sub-category along with the list of URLs used in their tweets in a month
        of a year.</option>
      <option value="Q18">"Q18": Find k users who were mentioned the most in tweets of users of a given party in a given
        month of a given year.</option>
      <option value="Q23">"Q23": Find k most used hashtags posted by a given sub-category of users in a list of months,
        show hashtag with the count of tweets it appeared</option>
      <option value="I">"I": Insert information of a new user into the database.</option>
      <option value="D">"D": Delete a given user and all the tweets the user has tweeted, relevant hashtags, and users
        mentioned</option>
      <!--  <option value = "test">"test": run tests</option> -->
    </select>
    <p></p>
    <div id="flex">
      <input name="input_limit"       type="number" value="5">limit</input>
      <input name="input_month"       type="number" value="1">month</input>
      <input name="input_year"        type="number" value="2016">year</input>
      <input name="input_hashList"    type="text"   value="GOPDebate, DemDebate">input_hashList</input>
      <input name="input_hashtag"     type="text"   value="Ohio">input_hashtag</input>
      <input name="input_category"    type="text"   value="">input_category</input>
      <input name="input_subCategory" type="text"   value="GOP">input_subCategory</input>
      <input name="input_stateList"   type="text"   value="Ohio, Alaska, Alabama">input_stateList</input>
      <input name="input_state"       type="text"   value="Ohio">input_state</input>
      <input name="input_monthList"   type="text"   value="[1,2,3]">input_monthList</input>
    </div>
    <p></p>
    <input type="submit" value="GO">
  </form>

  <%

    } catch (SQLException e) {
      out.println("An exception occurred: " + e.getMessage());
    } finally {
      if (rs!= null) rs.close();
      if (stmt!= null) stmt.close();
      if (conn != null) conn.close();
    }
  %>
</body>

</html>