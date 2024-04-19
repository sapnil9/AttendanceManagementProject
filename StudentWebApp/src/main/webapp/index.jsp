<%@ page import="java.sql.*" %>
<%
  String utdId = request.getParameter("utd_id");
  String password = request.getParameter("password");
  String errorMessage = null;
  boolean isAuthenticated = false;

  if ("POST".equalsIgnoreCase(request.getMethod()) && utdId != null && password != null) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      conn = DriverManager.getConnection(
              "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");

      String sql = "SELECT password FROM passwords INNER JOIN student ON student.class_id = passwords.class_id WHERE student.UTD_ID = ?";
      ps = conn.prepareStatement(sql);
      ps.setString(1, utdId);
      rs = ps.executeQuery();

      if (rs.next() && password.equals(rs.getString("password"))) {
        isAuthenticated = true;
      } else {
        errorMessage = "Invalid UTD-ID or Password";
      }
    } catch (Exception e) {
      e.printStackTrace(); // Replace with proper error handling
      errorMessage = "An error occurred.";
    } finally {
      if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
      if (ps != null) try { ps.close(); } catch (SQLException e) { /* ignored */ }
      if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
    }
  }

  if (isAuthenticated) {
    session.setAttribute("user", utdId);
    response.sendRedirect("dashboard.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login Page</title>
  <link rel="stylesheet" href="studentviewcss.css">
</head>
<body>
<div class="header">
  <h1>Enter Information Below!</h1>
</div>
<div class="login-container">
  <h2>Login</h2>
  <% if (errorMessage != null) { %>
  <p style='color: red;'><%= errorMessage %></p>
  <% } %>
  <form method="POST" action="index.jsp">
    <div class="form-group">
      <label for="utd_id">UTD-ID</label>
      <input type="text" id="utd_id" name="utd_id" required>
    </div>
    <div class="form-group">
      <label for="password">Password (given in class)</label>
      <input type="text" id="password" name="password" required>
    </div>
    <input type="submit" value="Continue">
  </form>
  <div id="error-message"></div>
</div>
</body>
</html>
