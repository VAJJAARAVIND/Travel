<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="java.security.MessageDigest" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    boolean loginSuccess = false;
    boolean isAdmin = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");

            // First check if it's an admin login
            String adminQuery = "SELECT * FROM admins WHERE username=? AND password=?";
            PreparedStatement adminPs = con.prepareStatement(adminQuery);
            adminPs.setString(1, username);
            adminPs.setString(2, password);
            ResultSet adminRs = adminPs.executeQuery();

            if (adminRs.next()) {
                session.setAttribute("admin", username);
                isAdmin = true;
                loginSuccess = true;
            } else {
                // Try regular user login with hashed password
                String hashedPassword = null;
                if (password != null) {
                    try {
                        MessageDigest md = MessageDigest.getInstance("SHA-256");
                        byte[] hash = md.digest(password.getBytes("UTF-8"));
                        StringBuilder sb = new StringBuilder();
                        for (byte b : hash) {
                            sb.append(String.format("%02x", b));
                        }
                        hashedPassword = sb.toString();
                    } catch (Exception e) {
                        out.println("Error hashing password: " + e);
                    }
                }

                String userQuery = "SELECT * FROM users WHERE username=? AND (password=? OR password_hash=?)";
                PreparedStatement userPs = con.prepareStatement(userQuery);
                userPs.setString(1, username);
                userPs.setString(2, password); // Plain text password
                userPs.setString(3, hashedPassword); // Hashed password
                ResultSet userRs = userPs.executeQuery();

                if (userRs.next()) {
                    session.setAttribute("user", username);
                    loginSuccess = true;
                }
                userRs.close();
                userPs.close();
            }

            adminRs.close();
            adminPs.close();
            con.close();
        } catch (Exception e) {
            out.println("<p style='color:red;'>Login error: " + e.getMessage() + "</p>");
        }
    }

    if (loginSuccess) {
        if (isAdmin) {
%>
            <script>
                alert("Welcome Admin!");
                window.location.href = "adminDashboard.jsp";
            </script>
<%
        } else {
%>
            <script>
                sessionStorage.setItem("user", "<%= username %>");
                alert("Login successful!");
                window.location.href = "index.html";
            </script>
<%
        }
    } else if (request.getMethod().equalsIgnoreCase("POST")) {
%>
        <script>
            alert("Invalid username or password");
            window.location.href = "login.jsp";
        </script>
<%
    }
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Travel Booking System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 400px;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h2 {
            color: #333;
            margin: 0;
            font-size: 28px;
        }
        .login-header p {
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
        .login-btn {
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
        .login-btn:hover {
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
        .admin-note {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
            font-size: 14px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h2>🔐 Login</h2>
            <p>Access your travel booking account</p>
        </div>
        
        <form method="post" action="login.jsp">
            <div class="form-group">
                <label>Username</label>
                <input type="text" name="username" required placeholder="Enter your username">
            </div>
            
            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required placeholder="Enter your password">
            </div>
            
            <button type="submit" class="login-btn">Login</button>
        </form>
        
        <div class="links">
            <a href="signup.jsp">Create New Account</a>
            <a href="index.html">Back to Home</a>
        </div>
        
        <div class="admin-note">
            <strong>Test Accounts:</strong><br>
            User: test_user / test123<br>
            Admin: admin / admin123
        </div>
    </div>
</body>
</html>