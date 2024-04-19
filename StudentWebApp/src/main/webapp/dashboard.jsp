<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link rel="stylesheet" href="studentviewcss.css">
</head>
<body>
<div class="header1">
    <h1>Welcome to the Dashboard!</h1>
</div>

<div class="dashboard-container">
    <h2>Quiz Questions</h2>
    <div id="quiz-questions">
        <%
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(
                        "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");

                String sql = "SELECT q.* FROM question q " +
                        "JOIN configure_attendance ca ON " +
                        "q.question_id IN (ca.question_id_1, ca.question_id_2, ca.question_id_3)";
                // Update this SQL based on your actual schema
                stmt = conn.createStatement();
                rs = stmt.executeQuery(sql);

                while (rs.next()) {
                    // Display each question and options (update this depending on your schema)
                    out.println("<p>Question: " + rs.getString("question") + "</p>");
                    out.println("<p>Option 1: " + rs.getString("option_1") + "</p>");
                    out.println("<p>Option 2: " + rs.getString("option_2") + "</p>");
                    out.println("<p>Option 3: " + rs.getString("option_3") + "</p>");
                    out.println("<p>Option 4: " + rs.getString("option_4") + "</p>");
                    out.println("<hr>");
                }
            } catch (Exception e) {
                e.printStackTrace(); // Proper error handling should be done here
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                if (stmt != null) try { stmt.close(); } catch (SQLException e) { /* ignored */ }
                if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
            }
        %>
    </div>
</div>
</body>
</html>
