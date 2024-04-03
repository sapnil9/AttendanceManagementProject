<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login Page</title>
  <link rel="stylesheet" href="studentviewcss.css">
</head>
<body>
  <div class="header">
    <h1>Enter Information Below!</h1>
  </div>
  <div class="login-container">
    <h2>Login</h2>
    <div class="form-group">
      <label for="net_id">NET ID</label>
      <input type="text" id="net_id" name="net_id" required>
    </div>
    <div class="form-group">
      <label for="password">Password (given in class)</label>
      <input type="text" id="password" name="password" required>
    </div>
    <button type="button" id="continue-btn">Continue</button> <!-- Change type to "button" -->
    <div id="error-message"></div>
  </div>

  <script>
    document.getElementById('continue-btn').addEventListener('click', function() {
      // Get the value of UTD ID and password
      var utdId = document.getElementById('net_id').value;
      var password = document.getElementById('password').value;

      // Redirect to the dashboard page if validation passes
      if (utdId && password) {
        window.location.href = 'dashboard.jsp'; // Replace 'dashboard.html' with the actual URL of your dashboard page
      } else {
        // Display an error message if any field is empty
        document.getElementById('error-message').innerText = 'Please enter both UTD ID and password.';
      }
    });
  </script>
</body>
</html>

