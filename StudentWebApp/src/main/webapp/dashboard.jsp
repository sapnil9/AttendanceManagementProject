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
        <!-- Quiz questions will be dynamically inserted here -->
    </div>
</div>

<script>
    // Function to make AJAX request and update quiz questions
    function fetchQuizQuestions() {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function() {
            if (this.readyState == 4 && this.status == 200) {
                document.getElementById("quiz-questions").innerHTML = this.responseText;
            }
        };
        xhttp.open("GET", "jdbc", true);
        xhttp.send();
    }

    // Call fetchQuizQuestions function to load quiz questions on page load
    window.onload = fetchQuizQuestions;
</script>
</body>
</html>
