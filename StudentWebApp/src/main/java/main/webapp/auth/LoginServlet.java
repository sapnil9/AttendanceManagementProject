package main.java.main.webapp.auth;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String utdId = request.getParameter("utd_id");
        String password = request.getParameter("password");

        if (authenticateUser(utdId, password)) {
            HttpSession session = request.getSession();
            session.setAttribute("user", utdId);
            response.sendRedirect("dashboard.jsp");
        } else {
            request.setAttribute("errorMessage", "Invalid UTD-ID or Password");
            request.getRequestDispatcher("index.jsp").forward(request, response);
        }
    }

    private boolean authenticateUser(String utdId, String password) {
        boolean isAuthenticated = false;
        Connection connection = null;

        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");

            // Create a connection to the database
            String jdbcUrl = "jdbc:mysql://34.173.191.42:3306/attendancedb";
            String username = "root";
            String passwordDb = "monK3yban@naBread3!@3%5";
            connection = DriverManager.getConnection(jdbcUrl, username, passwordDb);

            // Query to find the class_id for the given UTD_ID from the student table
            String studentSql = "SELECT class_id FROM student WHERE UTD_ID = ?";
            try (PreparedStatement studentStmt = connection.prepareStatement(studentSql)) {
                studentStmt.setString(1, utdId);
                ResultSet studentRs = studentStmt.executeQuery();

                // If a student record is found
                if (studentRs.next()) {
                    String classId = studentRs.getString("class_id");

                    // Query to find the password for the retrieved class_id from the passwords table
                    String passwordSql = "SELECT password FROM passwords WHERE class_id = ?";
                    try (PreparedStatement passwordStmt = connection.prepareStatement(passwordSql)) {
                        passwordStmt.setString(1, classId);
                        ResultSet passwordRs = passwordStmt.executeQuery();

                        // If a password record is found
                        if (passwordRs.next()) {
                            String storedPassword = passwordRs.getString("password");
                            // Compare the provided password with the stored one (plaintext as per project scope)
                            isAuthenticated = password.equals(storedPassword);
                        }
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace(); // Log this properly in a real-world scenario
        } catch (SQLException e) {
            e.printStackTrace(); // Log this properly in a real-world scenario
        } finally {
            // Always close the database connection to avoid resource leaks
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace(); // Log this properly in a real-world scenario
                }
            }
        }
        return isAuthenticated;
    }

}
