<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    // Check if user is logged in
    String user = (String) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle flight booking
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String flightNo = request.getParameter("flight_no");
        String source = request.getParameter("source");
        String destination = request.getParameter("destination");
        String departureTime = request.getParameter("departure_time");
        String price = request.getParameter("price");
        String passengers = request.getParameter("passengers");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
            
            // Insert booking
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO bookings (user_id, item) VALUES ((SELECT id FROM users WHERE username = ?), ?)"
            );
            ps.setString(1, user);
            ps.setString(2, "Flight: " + flightNo + " from " + source + " to " + destination + 
                         " on " + departureTime + " for " + passengers + " passenger(s) - Price: $" + price);
            ps.executeUpdate();
            
            // Update available seats (optional - if you want to track seat availability)
            PreparedStatement updateSeats = con.prepareStatement(
                "UPDATE flights SET seats = seats - ? WHERE flight_no = ?"
            );
            updateSeats.setInt(1, Integer.parseInt(passengers));
            updateSeats.setString(2, flightNo);
            updateSeats.executeUpdate();
            
            con.close();
            out.println("<div style='background-color: #d4edda; color: #155724; padding: 10px; margin: 10px; border-radius: 5px;'>");
            out.println("<strong>Flight Booked Successfully!</strong><br>");
            out.println("Flight: " + flightNo + "<br>");
            out.println("Route: " + source + " → " + destination + "<br>");
            out.println("Passengers: " + passengers + "<br>");
            out.println("Total Cost: $" + (Double.parseDouble(price) * Integer.parseInt(passengers)) + "<br>");
            out.println("<a href='viewBookings.jsp'>View All Bookings</a>");
            out.println("</div>");
        } catch (Exception e) {
            out.println("<div style='background-color: #f8d7da; color: #721c24; padding: 10px; margin: 10px; border-radius: 5px;'>");
            out.println("Booking Error: " + e.getMessage());
            out.println("</div>");
        }
    }

    // DB connection setup
    String url = "jdbc:mysql://localhost:3306/travel";
    String dbUser = "root";
    String dbPass = "valle";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Flight Search & Booking</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f8ff;
            margin: 0;
            padding: 20px;
        }
        table {
            border-collapse: collapse;
            width: 95%;
            margin: 20px auto;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: center;
        }
        th {
            background-color: #007bff;
            color: white;
            font-weight: bold;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .book-btn {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .book-btn:hover {
            background-color: #218838;
        }
        .book-btn:disabled {
            background-color: #6c757d;
            cursor: not-allowed;
        }
        .search-form {
            background-color: white;
            padding: 20px;
            margin: 20px auto;
            width: 80%;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group {
            margin: 10px 0;
        }
        .form-group input, .form-group select {
            padding: 8px;
            margin: 0 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .search-btn {
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-btn:hover {
            background-color: #0056b3;
        }
        .passenger-input {
            width: 60px;
        }
    </style>
</head>
<body>
    <h2 style="text-align:center; color: #333;">Flight Search & Booking</h2>
    
    <!-- Search Form -->
    <div class="search-form">
        <h3>Search Flights</h3>
        <form method="get">
            <div class="form-group">
                <label>From:</label>
                <input type="text" name="source" placeholder="Source City" value="<%= request.getParameter("source") != null ? request.getParameter("source") : "" %>">
                
                <label>To:</label>
                <input type="text" name="destination" placeholder="Destination City" value="<%= request.getParameter("destination") != null ? request.getParameter("destination") : "" %>">
                
                <button type="submit" class="search-btn">Search Flights</button>
            </div>
        </form>
    </div>

<%
    try {
        Class.forName("com.mysql.jdbc.Driver");
        con = DriverManager.getConnection(url, dbUser, dbPass);
        
        // Build query based on search parameters
        String query = "SELECT * FROM flights WHERE seats > 0";
        String sourceParam = request.getParameter("source");
        String destParam = request.getParameter("destination");
        
        if (sourceParam != null && !sourceParam.trim().isEmpty()) {
            query += " AND source LIKE ?";
        }
        if (destParam != null && !destParam.trim().isEmpty()) {
            query += " AND destination LIKE ?";
        }
        query += " ORDER BY departure_time";
        
        ps = con.prepareStatement(query);
        int paramIndex = 1;
        if (sourceParam != null && !sourceParam.trim().isEmpty()) {
            ps.setString(paramIndex++, "%" + sourceParam + "%");
        }
        if (destParam != null && !destParam.trim().isEmpty()) {
            ps.setString(paramIndex++, "%" + destParam + "%");
        }
        
        rs = ps.executeQuery();
%>
    <table>
        <tr>
            <th>Flight No</th>
            <th>Source</th>
            <th>Destination</th>
            <th>Departure</th>
            <th>Arrival</th>
            <th>Available Seats</th>
            <th>Price per Person</th>
            <th>Passengers</th>
            <th>Book Now</th>
        </tr>
<%
        boolean hasFlights = false;
        while (rs.next()) {
            hasFlights = true;
            int availableSeats = rs.getInt("seats");
%>
        <form method="post" style="display: contents;">
            <tr>
                <td><%= rs.getString("flight_no") %></td>
                <td><%= rs.getString("source") %></td>
                <td><%= rs.getString("destination") %></td>
                <td><%= rs.getTimestamp("departure_time") %></td>
                <td><%= rs.getTimestamp("arrival_time") %></td>
                <td><%= availableSeats %></td>
                <td>$<%= rs.getDouble("price") %></td>
                <td>
                    <input type="number" name="passengers" min="1" max="<%= availableSeats %>" 
                           value="1" class="passenger-input" <%= availableSeats > 0 ? "" : "disabled" %>>
                    <input type="hidden" name="flight_no" value="<%= rs.getString("flight_no") %>">
                    <input type="hidden" name="source" value="<%= rs.getString("source") %>">
                    <input type="hidden" name="destination" value="<%= rs.getString("destination") %>">
                    <input type="hidden" name="departure_time" value="<%= rs.getTimestamp("departure_time") %>">
                    <input type="hidden" name="price" value="<%= rs.getDouble("price") %>">
                </td>
                <td>
                    <button type="submit" class="book-btn" <%= availableSeats > 0 ? "" : "disabled" %>>
                        <%= availableSeats > 0 ? "Book Flight" : "Sold Out" %>
                    </button>
                </td>
            </tr>
        </form>
<%
        }
        
        if (!hasFlights) {
%>
            <tr>
                <td colspan="9" style="text-align: center; color: #666; padding: 20px;">
                    No flights found matching your criteria
                </td>
            </tr>
<%
        }
    } catch (Exception e) {
        out.println("<tr><td colspan='9' style='color:red;text-align:center;'>Error: " + e.getMessage() + "</td></tr>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
%>
    </table>
    
    <div style="text-align: center; margin: 20px;">
        <a href="index.html" style="background-color: #6c757d; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px;">Back to Home</a>
        <a href="viewBookings.jsp" style="background-color: #17a2b8; color: white; padding: 10px 20px; text-decoration: none; border-radius: 4px; margin-left: 10px;">View My Bookings</a>
    </div>
</body>
</html>