package main.webapp;

import java.sql.*;

public class jdbc {
    public static void main(String[] args) {
        // Define JDBC connection parameters
        String jdbcUrl = "jdbc:mysql://34.173.191.42:3306/attendancedb";
        String username = "root";
        String password = "monK3yban@naBread3!@3%5";

        // Method to establish database connection
        Connection connection = null;
        try {
            // Load the MySQL JDBC driver
            Class.forName("com.mysql.jdbc.Driver");

            // Create connection
            connection = DriverManager.getConnection(jdbcUrl, username, password);

            // Create statement
            Statement statement = connection.createStatement();

            // Execute query to retrieve quiz questions based on configure_attendance
            ResultSet resultSet = statement.executeQuery("SELECT q.* FROM question q " +
                    "JOIN configure_attendance ca ON " +
                    "q.question_id IN (ca.question_id_1, ca.question_id_2, ca.question_id_3)");

            // Process and display quiz questions
            while (resultSet.next()) {
                System.out.println("Question: " + resultSet.getString("question"));
                System.out.println("Option 1: " + resultSet.getString("option_1"));
                System.out.println("Option 2: " + resultSet.getString("option_2"));
                System.out.println("Option 3: " + resultSet.getString("option_3"));
                System.out.println("Option 4: " + resultSet.getString("option_4"));
                System.out.println("----------");
            }

            // Close result set and statement
            resultSet.close();
            statement.close();
        } catch (ClassNotFoundException e) {
            // Handle ClassNotFoundException
            e.printStackTrace();
            System.out.println("Failed to load MySQL JDBC driver: " + e.getMessage());
        } catch (SQLException e) {
            // Handle SQLException
            e.printStackTrace();
            System.out.println("SQL Exception: " + e.getMessage());
        } finally {
            // Close the connection in the finally block
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    // Handle SQLException while closing connection
                    e.printStackTrace();
                    System.out.println("Failed to close connection: " + e.getMessage());
                }
            }
        }
    }
}
