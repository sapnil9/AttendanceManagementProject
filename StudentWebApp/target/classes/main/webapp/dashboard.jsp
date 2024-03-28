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
    <form id="quiz-form">
      <div class="form-group">
        <label for="question1">Question 1:</label>
        <div>
          <input type="radio" id="question1_option1" name="question1" value="option1" required>
          <label for="question1_option1">Option 1</label>
        </div>
        <div>
          <input type="radio" id="question1_option2" name="question1" value="option2">
          <label for="question1_option2">Option 2</label>
        </div>
        <!-- Add more options for question 1 if needed -->
      </div>
      <div class="form-group">
        <label for="question2">Question 2:</label>
        <div>
          <input type="radio" id="question2_option1" name="question2" value="option1" required>
          <label for="question2_option1">Option 1</label>
        </div>
        <div>
          <input type="radio" id="question2_option2" name="question2" value="option2">
          <label for="question2_option2">Option 2</label>
        </div>
        <!-- Add more options for question 2 if needed -->
      </div>
      <button type="submit">Submit</button>
    </form>
    <div id="attendance-message" style="display: none;">Thank you for your attendance</div> <!-- Hidden by default -->
  </div>

  <script>
    document.getElementById('quiz-form').addEventListener('submit', function(event) {
      event.preventDefault();

      // Get the form element
      var form = event.target;

      // Display the attendance message
      var attendanceMessage = document.getElementById('attendance-message');
      attendanceMessage.style.display = 'block'; // Show the message
      form.reset(); // Reset the form
    });
  </script>
</body>
</html>