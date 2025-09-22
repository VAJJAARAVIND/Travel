<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    String admin = (String) session.getAttribute("admin");
    if (admin == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String action = request.getParameter("action");
    String message = "";
    
    // Handle admin actions
    if ("POST".equalsIgnoreCase(request.getMethod()) && action != null) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
            
            if ("add_flight".equals(action)) {
                PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO flights (flight_no, source, destination, departure_time, arrival_time, seats, total_seats, price, airline) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
                );
                ps.setString(1, request.getParameter("flight_no"));
                ps.setString(2, request.getParameter("source"));
                ps.setString(3, request.getParameter("destination"));
                ps.setString(4, request.getParameter("departure_time"));
                ps.setString(5, request.getParameter("arrival_time"));
                ps.setInt(6, Integer.parseInt(request.getParameter("seats")));
                ps.setInt(7, Integer.parseInt(request.getParameter("seats")));
                ps.setDouble(8, Double.parseDouble(request.getParameter("price")));
                ps.setString(9, request.getParameter("airline"));
                ps.executeUpdate();
                message = "Flight added successfully!";
            }
            
            con.close();
        } catch (Exception e) {
            message = "Error: " + e.getMessage();
        }
    }
%>

<html>
<head>
    <title>Admin Dashboard - Travel Booking System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .header {
            background: linear-gradient(135deg, #2c3e50, #34495e);
            color: white;
            padding: 20px;
            text-align: center;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        .dashboard-nav {
            background: white;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .nav-btn {
            background: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            margin: 5px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
        }
        .nav-btn:hover {
            background: #2980b9;
        }
        .section {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .section h3 {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .form-row {
            display: flex;
            gap: 15px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .btn {
            background: #27ae60;