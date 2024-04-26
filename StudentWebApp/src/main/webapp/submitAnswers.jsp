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

            //seperate answers and then check for questions

            String[] answers = new String[3];


            Enumeration<String> responses = request.getParameterNames();
            while (responses.hasMoreElements()) {
                String paramName = responses.nextElement();
                if (paramName.startsWith("answer")) {
                    //System.out.println("hey");
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

            String getQuestionIdsQuery = "SELECT question_id_1, question_id_2, question_id_3 FROM configure_attendance WHERE config_atten_id = ?";
            PreparedStatement getQuestionIdsStmt = conn.prepareStatement(getQuestionIdsQuery);
            getQuestionIdsStmt.setInt(1, configAttenId);
            ResultSet questionIdsRs = getQuestionIdsStmt.executeQuery();

            int correctanswers = 0;
            int numquestions = 0;

            if(questionIdsRs.next()) {
                for (int i = 0; i < answers.length; i++) {
                    if (answers[i] != null) {
                        int idx = i + 1;
                        int questionId = questionIdsRs.getInt("question_id_" + idx);
//                        System.out.println(questionId);
                        correctanswers += checkAnswer(questionId, answers[i], configAttenId);
                        numquestions++;
                    }
                }
            }

            // Display a success message
            double grade = (double) correctanswers / numquestions * 100;
            int roundedGrade = (int) Math.round(grade);
            System.out.println("<p>Your answers have been submitted successfully. Your grade is: " + roundedGrade + "%</p>");

            } catch (Exception e) {
                e.printStackTrace(); // Log any exceptions
                // Display an error message
                System.out.println("Error message3: " + e.getMessage() );
                //out.println("<p>An error occurred while submitting your answers.</p>");
            } finally {
                // Ensure all database resources are closed
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
                if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
            }

            //retrieve answers seperately and loop through answers to see if they are null
            //loop1: getting answers + storing it
            //loop2: retrieve questionId @ index if answer is not null (+numquestions)
            //

//                    //if there is an answer, check with questionId1
//                    if (questionId1 != null) {
//                        System.out.println(questionId1);
//                        pstmt.setString(4, request.getParameter("answer" + questionId1 ));
//                    }
//                    if (questionId2 != 0) {
//                        pstmt.setString(5, request.getParameter("answer" + questionId2));
//                    }
//                    if (questionId3 != 0) {
//                        pstmt.setString(6, request.getParameter("answer" + questionId3));
//                    }
//
//
//
//                    String ipAddress = request.getRemoteAddr();
//
//                    java.sql.Date currentDate = new java.sql.Date(System.currentTimeMillis());
//                    java.sql.Time currentTime = new java.sql.Time(System.currentTimeMillis());
//
//
//                    // Retrieve the question IDs associated with the config_atten_id
//                    String getQuestionIdsQuery = "SELECT question_id_1, question_id_2, question_id_3 FROM configure_attendance WHERE config_atten_id = ?";
//                    PreparedStatement getQuestionIdsStmt = conn.prepareStatement(getQuestionIdsQuery);
//                    getQuestionIdsStmt.setInt(1, configAttenId);
//                    ResultSet questionIdsRs = getQuestionIdsStmt.executeQuery();
//
//                    int questionId1 = 0;
//                    int questionId2 = 0;
//                    int questionId3 = 0;
//
//                    if (questionIdsRs.next()) {
//                        System.out.println("I'm in here");
//                        questionId1 = questionIdsRs.getInt("question_id_1");
//                        questionId2 = questionIdsRs.getInt("question_id_2");
//                        questionId3 = questionIdsRs.getInt("question_id_3");
//
//                    }
//
//                    String correctAnswersQuery = "SELECT answer FROM question WHERE question_id = ?";
//                    PreparedStatement correctAnswersStmt = conn.prepareStatement(correctAnswersQuery);
//
//                    String insertQuery = "INSERT INTO attendance (UTD_ID, class_id, config_atten_id, response1, response2, response3, IP, date_atten, time_atten) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
//                    pstmt = conn.prepareStatement(insertQuery);
//                    pstmt.setString(1, utdId);
//                    pstmt.setString(2, classId);
//                    pstmt.setInt(3, configAttenId);
//                    pstmt.setString(4, null);
//                    pstmt.setString(5, null);
//                    pstmt.setString(6, null);
//                    pstmt.setString(7, ipAddress);
//                    pstmt.setDate(8, currentDate);
//                    pstmt.setTime(9, currentTime);
//
//                    pstmt.executeUpdate();
//                }
//            }
//
//
//
//            Map<Integer, String> correctAnswersMap = new HashMap<>();
//
//            for (int i = 1; i <= 3; i++) {
//                String questionIdParam = "questionId" + i;
//                if ((request.getParameter(questionIdParam)) != null) {
//                    int questionIdValue = Integer.parseInt(request.getParameter(questionIdParam));
//                    correctAnswersStmt.setInt(1, questionIdValue);
//                    ResultSet correctAnswersRs = correctAnswersStmt.executeQuery();
//
//                    // Process the result set
//                    while (correctAnswersRs.next()) {
//                        int questionId = correctAnswersRs.getInt("question_id");
//                        String answer = correctAnswersRs.getString("answer");
//                        correctAnswersMap.put(questionId, answer);
//                    }
//                }
//            }
//
//            int numQuestions = 0;
//            int numCorrect = 0;
//
//            String studentResponsesQuery = "SELECT response1, response2, response3 FROM attendance WHERE UTD_ID = ? AND config_atten_id = ?";
//            PreparedStatement studentResponsesStmt = conn.prepareStatement(studentResponsesQuery);
//            studentResponsesStmt.setString(1, utdId);
//            studentResponsesStmt.setInt(2, configAttenId);
//            ResultSet studentResponsesRs = studentResponsesStmt.executeQuery();
//
//            if (studentResponsesRs.next()) {
//                for (Map.Entry<Integer, String> entry : correctAnswersMap.entrySet()) {
//                    int questionId = entry.getKey();
//                    String correctAnswer = entry.getValue();
//                    String studentResponse = studentResponsesRs.getString("response" + questionId);
//
//                    if (studentResponse != null && studentResponse.equals(correctAnswer)) {
//                        numCorrect++;
//                    }
//                    numQuestions++;
//                }
//            }
//
//            double grade = (double) numCorrect / numQuestions * 100;
//            int roundedGrade = (int) Math.round(grade);
//
//            // Update attendance record with calculated grade
//            String updateGradeQuery = "UPDATE attendance SET grade = ? WHERE UTD_ID = ? AND config_atten_id = ?";
//            PreparedStatement updateGradeStmt = conn.prepareStatement(updateGradeQuery);
//            updateGradeStmt.setInt(1, roundedGrade);
//            updateGradeStmt.setString(2, utdId);
//            updateGradeStmt.setInt(3, configAttenId);
//            updateGradeStmt.executeUpdate();
//
//            // Display a success message
//            out.println("<p>Your answers have been submitted successfully. Your grade is: " + roundedGrade + "%</p>");


    %>
</div>
</body>
</html>


<%!
    public int checkAnswer(int question, String answer, int attenid) {
        // Initialize JDBC objects for database connection
        Connection conn = null;
//        PreparedStatement pstmt = null;
        try {
            // Load JDBC driver for MySQL
            Class.forName("com.mysql.cj.jdbc.Driver");
            // Establish a connection to the database
            conn = DriverManager.getConnection(
                    "jdbc:mysql://34.173.191.42:3306/attendancedb", "root", "monK3yban@naBread3!@3%5");
            String questionId = "ca.question_id_" + question;
            System.out.println(questionId);
            String getQuestionIdsQuery = "SELECT q.answer FROM configure_attendance ca " +
                    "JOIN question q ON ca.question_id_1 = q.question_id " +
                    "WHERE ca.config_atten_id = ?";
            PreparedStatement getQuestionIdsStmt = conn.prepareStatement(getQuestionIdsQuery);
            getQuestionIdsStmt.setInt(1, attenid);
            ResultSet questionIdsRs = getQuestionIdsStmt.executeQuery();

            if(questionIdsRs.next()) {
                String retrieved_answer = questionIdsRs.getString("answer");
                System.out.println(retrieved_answer);

                if(retrieved_answer.equals(answer))
                    return 1;
            }

        }
        catch(SQLException | ClassNotFoundException e) {
            System.out.println(e.getMessage());
        }
        return 0;
    }
%>