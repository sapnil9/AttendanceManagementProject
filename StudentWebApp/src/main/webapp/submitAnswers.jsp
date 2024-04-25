<%@ page import="java.util.Enumeration" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.sql.*" %>
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
            int configAttenId = 1; // Set the appropriate config_atten_id
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

            Enumeration<String> parameterNames = request.getParameterNames();
            while (parameterNames.hasMoreElements()) {
                String paramName = parameterNames.nextElement();
                if (paramName.startsWith("response")) {
                    int questionId = Integer.parseInt(paramName.substring(8)); // Adjust the substring index to 8
                    String answer = request.getParameter(paramName);
                    System.out.println("Question ID: " + questionId + ", Answer: " + answer);


                    String ipAddress = request.getRemoteAddr();

                    java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());

                    java.sql.Time currentTime = new java.sql.Time(System.currentTimeMillis());


                    // Retrieve the question IDs associated with the config_atten_id
                    String getQuestionIdsQuery = "SELECT question_id_1, question_id_2, question_id_3 FROM configure_attendance WHERE config_atten_id = ?";
                    PreparedStatement getQuestionIdsStmt = conn.prepareStatement(getQuestionIdsQuery);
                    getQuestionIdsStmt.setInt(1, configAttenId);
                    ResultSet questionIdsRs = getQuestionIdsStmt.executeQuery();

                    int questionId1 = 0;
                    int questionId2 = 0;
                    int questionId3 = 0;

                    if (questionIdsRs.next()) {
                        questionId1 = questionIdsRs.getInt("question_id_1");
                        questionId2 = questionIdsRs.getInt("question_id_2");
                        questionId3 = questionIdsRs.getInt("question_id_3");
                    }

                    String insertQuery = "INSERT INTO attendance (UTD_ID, class_id, config_atten_id, response1, response2, response3, IP, date_atten, time_atten) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(insertQuery);
                    pstmt.setString(1, utdId);
                    pstmt.setString(2, classId);
                    pstmt.setInt(3, configAttenId);
                    pstmt.setString(4, "");
                    pstmt.setString(5, "");
                    pstmt.setString(6, "");
                    pstmt.setString(7, ipAddress);
                    pstmt.setDate(8, currentDate);
                    pstmt.setTime(9, currentTime);

                    if (questionId1 != 0) {
                        pstmt.setString(4, request.getParameter("response" + questionId1));
                    }
                    if (questionId2 != 0) {
                        pstmt.setString(5, request.getParameter("response" + questionId2));
                    }
                    if (questionId3 != 0) {
                        pstmt.setString(6, request.getParameter("response" + questionId3));
                    }

                    pstmt.executeUpdate();
                }
            }

            // Calculate grade
            String correctAnswersQuery = "SELECT question_id, answer FROM question WHERE class_id = ?";
            PreparedStatement correctAnswersStmt = conn.prepareStatement(correctAnswersQuery);
            correctAnswersStmt.setString(1, classId);
            ResultSet correctAnswersRs = correctAnswersStmt.executeQuery();

            Map<Integer, String> correctAnswersMap = new HashMap<>();
            while (correctAnswersRs.next()) {
                int questionId = correctAnswersRs.getInt("question_id");
                String answer = correctAnswersRs.getString("answer");
                correctAnswersMap.put(questionId, answer);
            }

            int numQuestions = 0;
            int numCorrect = 0;

            String studentResponsesQuery = "SELECT response1, response2, response3 FROM attendance WHERE UTD_ID = ? AND config_atten_id = ?";
            PreparedStatement studentResponsesStmt = conn.prepareStatement(studentResponsesQuery);
            studentResponsesStmt.setString(1, utdId);
            studentResponsesStmt.setInt(2, configAttenId);
            ResultSet studentResponsesRs = studentResponsesStmt.executeQuery();

            if (studentResponsesRs.next()) {
                for (Map.Entry<Integer, String> entry : correctAnswersMap.entrySet()) {
                    int questionId = entry.getKey();
                    String correctAnswer = entry.getValue();
                    String studentResponse = studentResponsesRs.getString("response" + questionId);

                    if (studentResponse != null && studentResponse.equals(correctAnswer)) {
                        numCorrect++;
                    }
                    numQuestions++;
                }
            }

            double grade = (double) numCorrect / numQuestions * 100;
            int roundedGrade = (int) Math.round(grade);

            // Update attendance record with calculated grade
            String updateGradeQuery = "UPDATE attendance SET grade = ? WHERE UTD_ID = ? AND config_atten_id = ?";
            PreparedStatement updateGradeStmt = conn.prepareStatement(updateGradeQuery);
            updateGradeStmt.setInt(1, roundedGrade);
            updateGradeStmt.setString(2, utdId);
            updateGradeStmt.setInt(3, configAttenId);
            updateGradeStmt.executeUpdate();

            // Display a success message
            out.println("<p>Your answers have been submitted successfully. Your grade is: " + roundedGrade + "%</p>");

        } catch (Exception e) {
            e.printStackTrace(); // Log any exceptions
            // Display an error message
            out.println("<p>An error occurred while submitting your answers.</p>");
        } finally {
            // Ensure all database resources are closed
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
            if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
        }
    %>
</div>
</body>
</html>


