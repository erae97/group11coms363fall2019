<!-- Author: Taylor Premo, Emily Young -->
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
  pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <title>Tweet Database</title>
</head>

<body>
  <!-- any error is redirected to ShowError.jsp -->
  <%@ page errorPage="Error.jsp"%>
  <!-- include all the database connection configurations -->
  <%@ include file="./DBInfo.jsp"%>
  <%!
  // global variables to make functions a bit cleaner
  Connection        conn     = null;
  PreparedStatement stmt     = null;
  ResultSet         rs       = null;
  JspWriter         jspOut   = null;
  PreparedStatement preState = null;

  // taken from https://coderwall.com/p/609ppa/printing-the-result-of-resultset
  // logs a ResultSet object.
  public void printResultSet(ResultSet rs)throws Exception{
    ResultSetMetaData rsmd = rs.getMetaData();
    System.out.println("querying SELECT * FROM XXX");
    int columnsNumber = rsmd.getColumnCount();
    while (rs.next()) {
        for (int i = 1; i <= columnsNumber; i++) {
            if (i > 1) System.out.print(",  ");
            String columnValue = rs.getString(i);
            System.out.print(columnValue + " " + rsmd.getColumnName(i));
        }
        System.out.println("");
    }
  }
  
  // uses code from printResultSet() above to log results along with display them on the jsp page.
  public void displayResultSet(String header, String[] columns) throws Exception
  {
    ResultSetMetaData rsmd = rs.getMetaData();
    System.out.println("querying...");
    int columnsNumber = rsmd.getColumnCount();

    //print header
    jspOut.println("<h3>" + header + "</h3>");
    // print table header 
    jspOut.println("<table><tr>");
    for(int i = 0; i < columns.length; i++){
      jspOut.println("<th>" + columns[i] + "</th>");
    }
    jspOut.println("</tr>");

    // print table rows
    while (rs.next()) {
      jspOut.println("<tr>");
      for(int i = 0; i < columns.length; i++){
        jspOut.println("<td>" + rs.getString(columns[i]) + "</td>");
      }
      jspOut.println("</tr>");

      for (int i = 1; i <= columnsNumber; i++) {
          if (i > 1) System.out.print(",  ");
          String columnValue = rs.getString(i);
          System.out.print(columnValue + " " + rsmd.getColumnName(i));
      }
      System.out.println("");
    }
    jspOut.println("</table>");
  }

  /**
   * List k most retweeted tweets in a given month and a given year; limited by limit
   * show:
     the retweet count, 
     the tweet text, 
     the posting user's screen name, 
     the posting user's category, 
     the posting user's sub-category 
     in descending order of the retweet
   */
  public ResultSet query1(int limit, int month, int year) throws Exception
  {
    String str = 	""
      + "SELECT t.retweet_count, t.tweet_text, u.screen_name, u.category, u.sub_category "
      + "FROM tweets t "
      + "	INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
      + "WHERE YEAR(t.created_at) = ? "
      + "	AND MONTH(t.created_at) = ? "
      + "ORDER BY t.retweet_count DESC "
      + "LIMIT ?; ";

    preState = conn.prepareStatement(str);
    preState.setInt(1, year);
    preState.setInt(2, month);
    preState.setInt(3, limit);

    rs = preState.executeQuery();

    String title  = "Here's the most retweeted tweets";
    String[] cols = {"retweet_count", "tweet_text", "screen_name", "category", "sub_category"};
    displayResultSet(title, cols);

    return rs;
  }

  /**
  -- Q3

  -- Find k hashtags that appeared in the most number of states in a given year;
  -- list the total number of states the hashtag appeared,
  -- the list of the distinct states it appeared (FL is the same as Florida*),
  -- and the hashtag itself in descending order of the number of states the hashtag appeared.
  -- Input:  Value of k and year (e.g., 2016)
  -- Rationale: This query finds k hashtags that are used across the most number of states,
  -- which could indicate a certain agenda (e.g., education, healthcare) that is widely discussed.
   */
  public ResultSet query3(int q3k, int q3year) throws Exception
  {
    String str = 	""
    + " SELECT COUNT(DISTINCT u.state) as statenum, GROUP_CONCAT(DISTINCT u.state) as states, hh.name "
    + " FROM hashashtag hh "
    + " 	INNER JOIN tweets t ON hh.id = t.id "
    + " 	INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
    + " WHERE YEAR(t.created_at) = ? "
    + " 	AND u.state != \"na\" "
    + " GROUP BY hh.name "
    + " ORDER BY COUNT(DISTINCT u.state) DESC "
    + " LIMIT ?; ";

    preState = conn.prepareStatement(str);

    preState.setInt(1, q3year);
    preState.setInt(2, q3k);

    rs = preState.executeQuery();

    String title  = "Here's hashtags that appeared in the most number of states in a given year";
    String[] cols = {"statenum", "states", "name"};
    displayResultSet(title, cols);

    return rs;
  }

  /**
  -- Q6

  -- Find k users who used at least one of the hashtags in a given list of hashtags in their tweets.
  -- Show the user’s screen name and the state the user lives in descending order of the number of this user’s followers.
  -- Input: Value of k and list of hashtags (e.g., [GOPDebate, DemDebate])
  -- Rationale: This is to find k users with similar interests.
  */
  public ResultSet query6(int limit, String hashtags) throws Exception
  {
    String str = 	""
      + "SELECT DISTINCT u.screen_name, u.state "
      + "FROM hashashtag hh "
      +	"INNER JOIN tweets t ON hh.id = t.id "
      +	"INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
      + "WHERE FIND_IN_SET(hh.name, ?) "
      + "ORDER BY u.followers DESC "
      + "LIMIT ?;";

    preState = conn.prepareStatement(str);


    preState.setString(1, hashtags);
    preState.setInt(2, limit);

    rs = preState.executeQuery();

    String title  = "Here's who used at least one hashtag:";
    String[] cols = {"screen_name", "state"};
    displayResultSet(title, cols);

    return rs;

  }

  /**
  -- Q9

  -- Find top kmost followed users in a given party.
  -- Show the user’s screen name, the user’s party, and the number of followers in descending order of the number of followers.
  -- Input:  Value of category (e.g., 'GOP', 'Democrat')
  -- Rationale: This query finds the most influential users measured by the number of followers.
  */
  public ResultSet query9(String category, int limit) throws Exception
  {
    String str = 	""
      + "SELECT DISTINCT u.screen_name, u.sub_category, u.followers "
      + "FROM hashashtag hh "
      +	"INNER JOIN tweets t ON hh.id = t.id "
      +	"INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
      + "WHERE u.sub_category = ? "
      + "ORDER BY u.followers DESC "
      + "LIMIT ?;";

    preState = conn.prepareStatement(str);
    preState.setString(1, category);
    preState.setInt(2, limit);


    rs = preState.executeQuery();

    String title  = "Here's the most followed user:";
    String[] cols = {"screen_name", "sub_category", "followers"};
    displayResultSet(title, cols);

    return rs;
  }

  /**
  -- Q10

  -- Find the list of distinct hashtags that appeared in one of the states in a given list in a given month of a given year;
  -- show the list of the hashtags and the names of the states in which they appeared.
  -- Input: list of states, (e.g., [Ohio, Alaska, Alabama]), month, year
  -- Rationale: This is to find common interests among the users in the states of interest.
  */
  public ResultSet query10(String stateList, int q10month, int q10year) throws Exception
  {
    String str = 	""
      + "SELECT DISTINCT hh.name, u.state "
      + "FROM hashashtag hh "
      +	"INNER JOIN tweets t ON hh.id = t.id "
      +	"INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
      + "WHERE FIND_IN_SET(u.state, ?) "
      +	"AND YEAR(t.created_at) = ? "
      +	"AND MONTH(t.created_at) = ?;";

      preState = conn.prepareStatement(str);

      preState.setString(1, stateList);
      preState.setInt(2, q10year);
      preState.setInt(3, q10month);

      rs = preState.executeQuery();

      String title  = "Here's some distinct hashtags:";
      String[] cols = {"name", "state"};
      displayResultSet(title, cols);

      return rs;
  }

  /**
  -- Q11

  -- Find k tweets (with the given hashtag)
  -- posted by republican (GOP) or democrat members of a given state in a given month of a given year.
  -- Show the tweet text, the hashtag, the screen name of the posting user, and the users’ party
  -- Input:  Values of k, state (e.g., Ohio), month, year, hashtag
  -- Rationale: This query explores the context in which the hashtag was used
  */
  public ResultSet query11(int limit, String state, int year, int month, String hashtagName) throws Exception
  {
    String str = 	""
    + "SELECT t.tweet_text, hh.name as hashtag, u.screen_name, u.sub_category as party "
    + "FROM hashashtag hh "
    +	"INNER JOIN tweets t ON hh.id = t.id "
    +	"INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
    + "WHERE hh.name = ? "
    +	"AND u.state = ? "
    + "AND (u.sub_category = \"GOP\" OR u.sub_category =  \"democrat\") "
    +	"AND YEAR(t.created_at) = ? "
    +	"AND MONTH(t.created_at) = ? "
    + "ORDER BY t.retweet_count DESC "
    + "LIMIT ?;";

    preState = conn.prepareStatement(str);

    preState.setString(1, hashtagName);
    preState.setString(2, state);
    preState.setInt(3, year);
    preState.setInt(4, month);
    preState.setInt(5, limit);

    rs = preState.executeQuery();

    String title  = "Here are some tweets with specific hashtags:";
    String[] cols = {"tweet_text", "hashtag", "screen_name", "party"};
    displayResultSet(title, cols);

    return rs;
  }

  /**
  -- Q15

  -- Find users in a given sub-category along with the list of URLs used in the user’s tweets in a given month of a given year.
  -- Show the user’s screen name, the state the user lives, and the list of URLs
  -- Input: Values of a sub-category (e.g.,  ' GOP'), month, year
  -- Rationale: This  query finds  URLs shared by a party.
  */
  public ResultSet query15(String sub_category, int month, int year)throws Exception
  {
    String str = 	""
      + "SELECT u.screen_name, u.state, GROUP_CONCAT(DISTINCT hu.address) as urls "
      + "FROM HasURLs hu "
      + "	INNER JOIN tweets t ON hu.id = t.id "
      + "	INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
      + "WHERE u.sub_category = ? "
      + "	AND YEAR(t.created_at) = ? "
      + "	AND MONTH(t.created_at) = ? "
      + "GROUP BY u.screen_name; ";

    preState = conn.prepareStatement(str);
    preState.setString(1, sub_category);
    preState.setInt(2, year);
    preState.setInt(3, month);

    rs = preState.executeQuery();

    String title  = "Here's users in sub-category along with the list of URLs used in their tweets in a month of a year.";
    String[] cols = {"screen_name", "state", "urls"};
    displayResultSet(title, cols);

    return rs;
  }

  /**
  -- Q18

  -- Find k users who were mentioned the most in tweets of users of a given party in a given month of a given year.
  -- Show the user’s screen name, user’s state, and the list of the screen name of the user(s) who mentioned this user
  -- in descending order of the number of tweets mentioning this user.
  -- Input: Values of k, sub-category (e.g., 'GOP'), month, year.
  */
  public ResultSet query18(int limit, String sub_category, int month, int year)throws Exception
  {
    String str = 	""
      + "SELECT u.screen_name, u.state, GROUP_CONCAT(DISTINCT op.screen_name) as postingUsers "
      + "FROM Mention m "
      + "	INNER JOIN useraccounts u ON m.screen_name = u.screen_name "
      + "	INNER JOIN tweets t ON m.id = t.id "
      + "      INNER JOIN useraccounts op ON t.tweeted_by = op.screen_name "
      + "WHERE op.sub_category = ? "
      + "	AND YEAR(t.created_at) = ? "
      + "	AND MONTH(t.created_at) = ? "
      + "GROUP BY m.screen_name "
      + "  ORDER BY COUNT(m.id) DESC "
      + "  LIMIT ?; ";

    preState = conn.prepareStatement(str);
    preState.setString(1, sub_category);
    preState.setInt(2, year);
    preState.setInt(3, month);
    preState.setInt(4, limit);

    rs = preState.executeQuery();

    String title  = "Here's users who were mentioned the most in tweets of users of a given party in a given month of a given year.";
    String[] cols = {"screen_name", "state", "screen_name", "postingUsers"};
    displayResultSet(title, cols);

    return rs;
}

  /**
  -- Q23

  -- Find k most used hashtags with the count of tweets it appeared posted by a given sub-category of users in a list of months.
  -- Show the hashtag name and the count in descending order of the count.
  -- Input:Values of k, sub-category (e.g.,  'GOP'), a list of months (e.g., [1, 2, 3]), year=2016
  */
  public ResultSet query23(int limit, String sub_category, String monthList, int year)throws Exception
  {

    String str = 	""
    + "SELECT hh.name, COUNT(DISTINCT t.id) as count "
    + "FROM HasHashtag hh "
    + "	INNER JOIN tweets t ON hh.id = t.id "
    + "	INNER JOIN useraccounts u ON t.tweeted_by = u.screen_name "
    + "WHERE u.sub_category = ? "
    + "	AND YEAR(t.created_at) = ? "
    + "      AND FIND_IN_SET(MONTH(t.created_at),  ? ) "
    + "GROUP BY hh.name "
    + "  ORDER BY count DESC "
    + "  LIMIT ?; ";

    preState = conn.prepareStatement(str);
    preState.setString(1, sub_category);
    preState.setInt(2, year);
    preState.setString(3, monthList);
    preState.setInt(4, limit);

    rs = preState.executeQuery();

    String title  = "Here's users who were mentioned the most in tweets of users of a given party in a given month of a given year.";
    String[] cols = {"name", "count"};
    displayResultSet(title, cols);

    return rs;
  }

  // All relevant attribute values of a user
  public ResultSet queryInsert(String screen_name)throws Exception
  {
    //TODO
    return null;
  }
  // screen name of the user to be deleted
  public ResultSet queryDelete(String screen_name)throws Exception
  {
    //TODO
    return null;
  }
  %>
  <%
  Class.forName("com.mysql.jdbc.Driver");

  conn   = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
  jspOut = out;

  String requestedQuery = request.getParameter("query_selector");

  //get user inputs from request
  int inputLimit = -1;
  int inputMonth = -1;
  int inputYear  = -1;
  // catch invalid values from parsing string to int.
  try{
    inputLimit = Integer.parseInt(request.getParameter("input_limit"));
    inputMonth = Integer.parseInt(request.getParameter("input_month"));
    inputYear  = Integer.parseInt(request.getParameter("input_year"));
  } catch( NumberFormatException e){
    System.out.println("error parsing input ints {limit, year, month}");
  }
  String inputHashtagList = request.getParameter("input_hashList");
  String inputHashtag     = request.getParameter("input_hashtag");
  String inputCategory    = request.getParameter("input_category");
  String inputSubCategory = request.getParameter("input_subCategory");
  String inputStateList   = request.getParameter("input_stateList");
  String inputState       = request.getParameter("input_state");
  String inputMonthList   = request.getParameter("input_monthList");

  // parse the selection in a switch statement, and call the appropriate method.
  System.out.println("requested query: " + requestedQuery);
  switch(requestedQuery){
    case "Q1":
      //Value of k (e.g., 10), month (e.g., 1), and year (e.g., 2016)
      query1(inputLimit, inputMonth, inputYear);
      break;
    case "Q3":
      //Value of k and year (e.g., 2016)
      query3(inputLimit, inputYear);
      break;
    case "Q6":
      // Value of k and list of hashtags (e.g., [GOPDebate, DemDebate])
      query6(inputLimit, inputHashtagList);
      break;
    case "Q9":
      //Value of category (e.g., ' GOP', 'Democrat'), limit
      query9(inputCategory, inputLimit);
      break;
    case "Q10":
      //list of states, (e.g., [Ohio, Alaska, Alabama]), month, year
      query10(inputStateList, inputMonth, inputYear);
      break;
    case "Q11":
      //Values of k, state (e.g., Ohio), year, month, hashtag
      query11(inputLimit, inputState, inputYear, inputMonth, inputHashtag);
      break;
    case "Q15":
      // Values of a sub-category (e.g., 'GOP'), month, year
      query15(inputSubCategory, inputMonth, inputYear);
      break;
    case "Q18":
      //  Values of k, sub-category (e.g., 'GOP'), month, year
      query18(inputLimit, inputSubCategory, inputMonth, inputYear);
      break;
    case "Q23":
      //Values of k, sub-category (e.g., 'GOP'), a list of months [1, 2, 3], year
      query23(inputLimit, inputSubCategory, inputMonthList, inputYear);
      break;
    case "I": //TODO
      break;
    case "D": //TODO
      break;
    case "test":
      break;
    default:
      break;
  }


  rs.close();
  preState.close();
  conn.close();
  %>
  <br/>
  <form action="Index.jsp">
  <!-- <input type="submit" value="BACK" /> -->
  </form>
</body>

</html>