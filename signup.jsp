<%@ page import="java.sql.*" %>
<%@ page import="java.security.MessageDigest" %>
<%
    String message = "";
    if (request.getMethod().equalsIgnoreCase("POST")) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String hashedPassword = null;

        try {
            // Hash the password
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            hashedPassword = sb.toString();
        } catch (Exception e) {
            message = "Error hashing password: " + e.getMessage();
        }

        if (hashedPassword != null) {
            try {
                Class.forName("com.mysql.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
                
                // Check if username already exists
                PreparedStatement checkPs = con.prepareStatement("SELECT username FROM users WHERE username = ?");
                checkPs.setString(1, username);
                ResultSet checkRs = checkPs.executeQuery();
                
                if (checkRs.next()) {
                    message = "Username already exists. Please choose a different username.";
                } else {
                    // Insert new user
                    PreparedStatement ps = con.prepareStatement("INSERT INTO users (username, password_hash, email, phone) VALUES (?, ?, ?, ?)");
                    ps.setString(1, username);
                    ps.setString(2, hashedPassword);
                    ps.setString(3, email);
                    ps.setString(4, phone);
                    ps.executeUpdate();
                    ps.close();
                    message = "success";
                }
                
                checkRs.close();
                checkPs.close();
                con.close();
                
            } catch (Exception e) {
                message = "Database error: " + e.getMessage();
            }
        }
    }
    
    if ("success".equals(message)) {
%>
        <script>
            alert("Account created successfully! Please login.");
            window.location.href = "login.jsp";
        </script>
<%
    }
%>

<html>
<head>
    <title>Sign Up - Travel Booking System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .signup-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 450px;
        }
        .signup-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .signup-header h2 {
            color: #333;
            margin: 0;
            font-size: 28px;
        }
        .signup-header p {
            color: #666;
            margin: 10px 0 0 0;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: bold;
        }
        .form-group input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        .signup-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.3s;
        }
        .signup-btn:hover {
            transform: translateY(-2px);
        }
        .links {
            text-align: center;
            margin-top: 20px;
        }
        .links a {
            color: #667eea;
            text-decoration: none;
            margin: 0 10px;
        }
        .links a:hover {
            text-decoration: underline;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
        .form-row {
            display: flex;
            gap: 15px;
        }
        .form-row .form-group {
            flex: 1;
        }
    </style>
</head>
<body>
    <div class="signup-container">
        <div class="signup-header">
            <h2>📝 Sign Up</h2>
            <p>Create your travel booking account</p>
        </div>
        
        <% if (!message.isEmpty() && !"success".equals(message)) { %>
            <div class="error-message">
                <%= message %>
            </div>
        <% } %>
        
        <form method="post" action="signup.jsp">
            <div class="form-group">
                <label>Username *</label>
                <input type="text" name="username" required placeholder="Choose a unique username" 
                       value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>">
            </div>
            
            <div class="form-group">
                <label>Password *</label>
                <input type="password" name="password" required placeholder="Enter a secure password" minlength="6">
            </div>
            
            <div class="form-group">
                <label>Email Address *</label>
                <input type="email" name="email" required placeholder="your.email@example.com"
                       value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
            </div>
            
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" name="phone" placeholder="Your phone number"
                       value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>">
            </div>
            
            <button type="submit" class="signup-btn">Create Account</button>
        </form>
        
        <div class="links">
            <a href="login.jsp">Already have an account? Login</a>
            <a href="index.html">Back to Home</a>
        </div>
    </div>
</body>
</html>