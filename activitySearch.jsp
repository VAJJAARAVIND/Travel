<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    String user = (String) session.getAttribute("user");
    String message = "";

    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String activity = request.getParameter("activity");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO bookings (user_id, item) VALUES ((SELECT id FROM users WHERE username = ?), ?)"
            );
            ps.setString(1, user);
            ps.setString(2, "Activity: " + activity);
            ps.executeUpdate();
            con.close();

            message = "<div class='success-message'>🎉 <strong>Activity Booked!</strong> You have successfully booked: <strong>" + activity + "</strong>.</div>";
        } catch (Exception e) {
            message = "<div class='error-message'><strong>Booking Error:</strong> " + e.getMessage() + "</div>";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Book Activity - Travel Booking</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #74ebd5, #ACB6E5);
            margin: 0;
            padding: 40px;
        }
        .container {
            max-width: 600px;
            margin: auto;
            background: #fff;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        }
        h2 {
            text-align: center;
            color: #333;
        }
        .form-group {
            margin: 20px 0;
        }
        input[type="text"] {
            width: 100%;
            padding: 12px;
            border: 2px solid #ccc;
            border-radius: 6px;
            font-size: 16px;
        }
        input[type="submit"] {
            background: #667eea;
            color: white;
            border: none;
            padding: 12px 25px;
            font-size: 16px;
            border-radius: 30px;
            cursor: pointer;
            width: 100%;
            transition: background 0.3s;
        }
        input[type="submit"]:hover {
            background: #5a67d8;
        }
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            border: 1px solid #c3e6cb;
        }
        .error-message {
            background: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 15px;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>🎯 Book an Activity</h2>
        <%= message %>
        <form method="post">
            <div class="form-group">
                <label for="activity">Activity Name *</label>
                <input type="text" id="activity" name="activity" required placeholder="e.g., Scuba Diving in Goa">
            </div>
            <input type="submit" value="📅 Book Activity">
        </form>
    </div>
</body>
</html>
