<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mysql.cj.exceptions.MysqlErrorNumbers" %>
<%@ page import="java.util.Arrays" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz Results</title>
    <link rel="stylesheet" href="studentviewcss.css">
</head>
<body>
<div class="header1">
    <h1>Quiz Results</h1>
</div>

<div class="results-container">
    <%
        // Initialize JDBC objects for database connection
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            // Load JDBC driver for MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Establish a connection to the database
            conn = DriverManager.getConnection(
                    "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");

            // Get user's UTD-ID from session
            String utdId = (String) session.getAttribute("user");
            System.out.println("UTD-ID: " + utdId);

            // Retrieve class_id and config_atten_id associated with the quiz
            int configAttenId = (int)(session.getAttribute("configId")); // Set the appropriate config_atten_id
            System.out.println("configAttenID: " + configAttenId);

            // Retrieve class_id using config_atten_id
            String classId = "";
            String getClassIdQuery = "SELECT p.class_id " +
                    "FROM configure_attendance c " +
                    "JOIN passwords p ON c.password_id = p.password_id " +
                    "WHERE c.config_atten_id = ?";
            PreparedStatement getClassIdStmt = conn.prepareStatement(getClassIdQuery);
            getClassIdStmt.setInt(1, configAttenId);
            ResultSet classIdRs = getClassIdStmt.executeQuery();
            if (classIdRs.next()) {
                classId = classIdRs.getString("class_id");
                System.out.println("Class ID: " + classId);
            }

            // Separate answers and then check for questions
            String[] answers = new String[3];
            Enumeration<String> responses = request.getParameterNames();
            while (responses.hasMoreElements()) {
                String paramName = responses.nextElement();
                if (paramName.startsWith("answer")) {
                    // System.out.println("hey");
                    int questionId = Integer.parseInt(paramName.substring(7)); // Adjust the substring index to 8
                    String answer = request.getParameter(paramName);
                    System.out.println("Question ID: " + questionId + ", Answer: " + answer);
                    if (answer.equals("1")) {
                        answer = "A";
                    }
                    if (answer.equals("2")) {
                        answer = "B";
                    }
                    if (answer.equals("3")) {
                        answer = "C";
                    }
                    if (answer.equals("4")) {
                        answer = "D";
                    }
                    answers[questionId - 1] = answer;
                }
            }
            System.out.println(Arrays.toString(answers));

            // Fetch right answers from database
            String[] rightAnswers = new String[3];
            rightAnswers = checkAnswer(configAttenId);

            int numQuestions = 0;
            int correctAnswers = 0;
            System.out.println(Arrays.toString(checkAnswer(configAttenId)));

            for(int i = 0; i < answers.length; i++) {
                if(rightAnswers[i] != null) {
                    numQuestions++;
                    if(rightAnswers[i].equals(answers[i])) {
                        correctAnswers++;
                    }
                }
            }

            // Calculate grade and display success message
            double grade = (double) correctAnswers / numQuestions * 100;
            int roundedGrade = (int) Math.round(grade);
            out.println("<p>Your answers have been submitted successfully. Your grade is: " + roundedGrade + "%</p>");
            String studentStatus = "Present";
            String ipAddress = request.getRemoteAddr();
            java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
            java.sql.Time currentTime = new java.sql.Time(System.currentTimeMillis());
            String correctAnswersQuery = "SELECT answer FROM question WHERE question_id = ?";
            PreparedStatement correctAnswersStmt = conn.prepareStatement(correctAnswersQuery);
            String insertQuery = "INSERT INTO attendance (UTD_ID, class_id, config_atten_id, response1, response2, response3, IP, date_atten, time_atten, student_status, grade) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(insertQuery);
            pstmt.setString(1, utdId);
            pstmt.setString(2, classId);
            pstmt.setInt(3, configAttenId);
            pstmt.setString(4, answers[0]);
            pstmt.setString(5, answers[1]);
            pstmt.setString(6, answers[2]);
            pstmt.setString(7, ipAddress);
            pstmt.setDate(8, currentDate);
            pstmt.setTime(9, currentTime);
            pstmt.setString(10, studentStatus);
            pstmt.setInt(11, roundedGrade);
            pstmt.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace(); // Log any exceptions
            // Display an error message
            System.out.println("Error message3: " + e.getMessage() );
        } finally {
            // Ensure all database resources are closed
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
            if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
        }
    %>
</div>
</body>
</html>


<%!
    // Method to check answers against the database
    public String[] checkAnswer(int attenid) {
        String[] answers = new String[3];
        // Initialize JDBC objects for database connection
        Connection conn = null;
//        PreparedStatement pstmt = null;
        try {
            // Load JDBC driver for MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Establish a connection to the database
            conn = DriverManager.getConnection(
                    "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");
            String getQuestionAnswersQuery = "SELECT q.answer " +
                    "FROM configure_attendance ca " +
                    "JOIN question q ON ca.question_id_1 = q.question_id " +
                    "                 OR ca.question_id_2 = q.question_id " +
                    "                 OR ca.question_id_3 = q.question_id " +
                    "WHERE ca.config_atten_id = ?";
            PreparedStatement getQuestionAnswerStmt = conn.prepareStatement(getQuestionAnswersQuery);
            getQuestionAnswerStmt.setInt(1, attenid);
            ResultSet questionIdsRs = getQuestionAnswerStmt.executeQuery();

            for(int i = 0; i < answers.length; i++) {
                if(questionIdsRs.next()) {
                    answers[i] = questionIdsRs.getString("answer");
                }
            }

        }
        catch(SQLException | ClassNotFoundException e) {
            System.out.println(e.getMessage());
        }
        return answers;
    }
%>
