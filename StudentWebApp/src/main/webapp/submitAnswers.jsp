<%@ page import="java.sql.*" %> <!-- Import necessary SQL classes for database operations -->
<%@ page contentType="text/html;charset=UTF-8" language="java" %> <!-- Set the content type and character set for the page -->

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Results</title> <!-- Set the title of the webpage -->
    <link rel="stylesheet" href="studentviewcss.css"> <!-- Link to external CSS for page styling -->
</head>
<body>
<div class="header1">
    <h1>Quiz Results</h1> <!-- Title for the results section -->
</div>

<div class="results-container">
    <%
        // Initialize JDBC objects for database connection
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            // Load JDBC driver for MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Establish a connection to the database
            conn = DriverManager.getConnection(
                    "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");

            // SQL query to retrieve questions and answers from the database
            String query = "SELECT \n" +
                    "    q.question_id,\n" +
                    "    q.question,\n" +
                    "    q.answer\n" +
                    "FROM \n" +
                    "    configure_attendance ca\n" +
                    "JOIN \n" +
                    "    question q ON ca.question_id_1 = q.question_id OR ca.question_id_2 = q.question_id OR ca.question_id_3 = q.question_id";
            // Create a statement to execute SQL
            stmt = conn.createStatement();
            // Execute the query and store the results in rs
            rs = stmt.executeQuery(query);

            // Process each row in the result set
            while (rs.next()) {
                int questionId = rs.getInt("question_id");
                String correctAnswer = rs.getString("answer");

                // Display the question and correct answer
                out.println("<p>Question " + questionId +
                        " (Correct answer: " + correctAnswer + ")</p>");
            }
        } catch (Exception e) {
            e.printStackTrace(); // Log any exceptions
        } finally {
            // Ensure all database resources are closed
            if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { /* ignored */ }
            if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
        }
    %>
</div>
</body>
</html>
