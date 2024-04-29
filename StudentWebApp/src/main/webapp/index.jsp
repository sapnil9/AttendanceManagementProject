<%@ page import="java.sql.*" %>
<%
  // Get parameters from the form submission
  String utdId = request.getParameter("utd_id");
  java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
  java.sql.Time currentTime = new java.sql.Time(System.currentTimeMillis());
  String password = request.getParameter("password");
  String errorMessage = null;
  boolean isAuthenticated = false;

  // Check if  both username and password are not null
  if ("POST".equalsIgnoreCase(request.getMethod()) && utdId != null && password != null) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
      // Load MySQL JDBC Driver
      Class.forName("com.mysql.cj.jdbc.Driver");
      // Establish a connection to the database
      conn = DriverManager.getConnection(
              "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");

      // SQL query to authenticate the user. Checks if the entered UTD-ID has the password stored in the database.
      String sql = "SELECT ca.config_atten_id, p.password FROM configure_attendance ca " +
              "INNER JOIN passwords p ON ca.password_id = p.password_ID " +
              "INNER JOIN student s ON p.class_id = s.class_id " +
              "WHERE ca.date = ? AND ? BETWEEN ca.start_time AND ca.end_time " +
              "AND s.UTD_ID = ?";
      ps = conn.prepareStatement(sql);
      Date dateValue = Date.valueOf("2024-04-26");
      ps.setDate(1, dateValue);
      Time timeValue = Time.valueOf("08:30:00");
      ps.setTime(2, timeValue);
      ps.setString(3, utdId);
      rs = ps.executeQuery();


      // Check if a password was returned and if it matches the one provided by the user
      if (rs.next() && password.equals(rs.getString("password"))) {
        isAuthenticated = true; // Set authenticated flag to true if match found
        int config_atten_id = rs.getInt("config_atten_id");
        System.out.println("config_atten_id value: " + config_atten_id);
        session.setAttribute("configId", config_atten_id);
      } else {
        errorMessage = "Invalid UTD-ID or Password"; // Set error message for incorrect credentials
        System.out.println(password);
      }
    } catch (Exception e) {
      e.printStackTrace(); // Log exception to server's log files
      errorMessage = "An error occurred."; // Set error message for exceptions
      System.out.println("Error message1: " + e.getMessage() );
    } finally {
      // Close all database related objects
      if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
      if (ps != null) try { ps.close(); } catch (SQLException e) { /* ignored */ }
      if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
    }
  }

  // If user is authenticated, redirect to the dashboard page and end further processing
  if (isAuthenticated) {
    session.setAttribute("user", utdId); // Set user attribute in session to store logged user's ID
    response.sendRedirect("dashboard.jsp"); // Redirect to the dashboard
    return; // Stop processing the JSP
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login Page</title>
  <link rel="stylesheet" href="studentviewcss.css"> <!-- Linking CSS for styling the login page -->
</head>
<body>
<div class="header">
  <h1>Enter Information Below!</h1> <!-- Title for the login form -->
</div>
<div class="login-container">
  <h2>Login</h2>
  <% if (errorMessage != null) { %>
  <p style='color: red;'><%= errorMessage %></p> <!-- Display an error message if any -->
  <% } %>
  <form method="POST" action="index.jsp"> <!-- Form for user login submission -->
    <div class="form-group">
      <label for="utd_id">UTD-ID</label> <!-- Field for UTD-ID -->
      <input type="text" id="utd_id" name="utd_id" required> <!-- Input for UTD-ID -->
    </div>
    <div class="form-group">
      <label for="password">Password (given in class)</label> <!-- Field for password -->
      <input type="text" id="password" name="password" required> <!-- Input for password -->
    </div>
    <input type="submit" value="Continue"> <!-- Submit button for the form -->
  </form>
  <div id="error-message"></div> <!-- Container for potential additional error messages -->
</div>
</body>
</html>