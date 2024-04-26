<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    <link rel="stylesheet" href="studentviewcss.css"> <!-- Link to external CSS for styling -->
</head>
<body>
<div class="header1">
    <h1>Welcome to the Dashboard!</h1> <!-- Main heading of the page -->
</div>

<div class="dashboard-container">
    <h2>Quiz Questions</h2>
    <form method="post" action="submitAnswers.jsp"> <!-- Form submission to process the answers -->
        <div id="quiz-questions">
            <% // starts for executing Java code in JSP
                Connection conn = null; // Declare a Connection object to manage the database connection
                PreparedStatement ps = null; // Declare a PreparedStatement object to execute SQL queries
                ResultSet rs = null; // Declare a ResultSet object to store the results of SQL query
                int configId = (int)(session.getAttribute("configId"));

                try {
                    // Load the JDBC driver
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    // Establish a connection to the database
                    conn = DriverManager.getConnection(
                            "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");

                    // SQL query to select all questions linked to config_attendance
                    String sql = "SELECT q.* FROM question q " +
                            "JOIN configure_attendance ca ON " +
                            "q.question_id IN (ca.question_id_1, ca.question_id_2, ca.question_id_3) " +
                            "WHERE ca.config_atten_id = ? ";
                    ps = conn.prepareStatement(sql); // Create a PreparedStatement object
                    ps.setInt(1, configId); // Set the parameter value
                    rs = ps.executeQuery(); // Execute the query and store the results in ResultSet

                    // Process each question retrieved from the database
                    while (rs.next()) {
                        int questionId = rs.getInt("question_id"); // Get the question ID
                        out.println("<div class='question'>");
                        out.println("<p>Question: " + rs.getString("question") + "</p>"); // Display the question
                        out.println("<input type='radio' name='answer_" + questionId + "' value='1'> " + rs.getString("option_1") + "<br>");
                        out.println("<input type='radio' name='answer_" + questionId + "' value='2'> " + rs.getString("option_2") + "<br>");
                        out.println("<input type='radio' name='answer_" + questionId + "' value='3'> " + rs.getString("option_3") + "<br>");
                        out.println("<input type='radio' name='answer_" + questionId + "' value='4'> " + rs.getString("option_4") + "<br>");
                        out.println("</div><hr>"); // End of question division
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    System.out.println("Error message2: " + e.getMessage() );
                } finally {
                    // ensure result sets, statements, and connections are closed
                    if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                    if (ps != null) try { ps.close(); } catch (SQLException e) { /* ignored */ }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
                }
            %>
        </div>
        <button type="submit">Submit Answers</button> <!-- Button to submit the form -->
    </form>
</div>
</body>
</html>