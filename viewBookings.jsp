<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>

<%
    String user = (String) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String filter = request.getParameter("filter");
    String deleteBooking = request.getParameter("delete");
    String message = "";
    
    // Handle booking deletion
    if (deleteBooking != null && "POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
            PreparedStatement ps = con.prepareStatement(
                "DELETE FROM bookings WHERE id = ? AND user_id = (SELECT id FROM users WHERE username = ?)"
            );
            ps.setInt(1, Integer.parseInt(deleteBooking));
            ps.setString(2, user);
            int deleted = ps.executeUpdate();
            con.close();
            
            if (deleted > 0) {
                message = "<div class='success-message'>Booking cancelled successfully!</div>";
            } else {
                message = "<div class='error-message'>Unable to cancel booking.</div>";
            }
        } catch (Exception e) {
            message = "<div class='error-message'>Error: " + e.getMessage() + "</div>";
        }
    }
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>My Bookings - Travel Booking System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background-color: white;
            border-radius: 15px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #2c3e50, #34495e);
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 32px;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
        }
        .search-section {
            padding: 20px 30px;
            background-color: #f8f9fa;
            border-bottom: 1px solid #e9ecef;
        }
        .search-form {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        .search-form input {
            flex: 1;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
        }
        .search-form input:focus {
            outline: none;
            border-color: #667eea;
        }
        .search-btn {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        .search-btn:hover {
            transform: translateY(-1px);
        }
        .clear-btn {
            background: #6c757d;
            color: white;
            border: none;
            padding: 12px 20px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-size: 16px;
        }
        .clear-btn:hover {
            background: #5a6268;
        }
        .bookings-content {
            padding: 30px;
        }
        .booking-card {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .booking-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.15);
        }
        .booking-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
        }
        .booking-type {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .booking-time {
            color: #6c757d;
            font-size: 14px;
        }
        .booking-details {
            color: #333;
            font-size: 16px;
            line-height: 1.5;
            margin: 10px 0;
        }
        .booking-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }
        .cancel-btn {
            background: #dc3545;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
        }
        .cancel-btn:hover {
            background: #c82333;
        }
        .no-bookings {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        .no-bookings h3 {
            color: #495057;
            margin-bottom: 15px;
        }
        .navigation {
            padding: 20px 30px;
            background-color: #f8f9fa;
            text-align: center;
            border-top: 1px solid #e9ecef;
        }
        .nav-link {
            display: inline-block;
            margin: 0 10px;
            padding: 12px 24px;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            transition: transform 0.2s;
        }
        .nav-link:hover {
            transform: translateY(-2px);
        }
        .nav-link.secondary {
            background: #6c757d;
        }
        .nav-link.secondary:hover {
            background: #5a6268;
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border: 1px solid #c3e6cb;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 8px;
            margin: 20px 0;
            border: 1px solid #f5c6cb;
        }
        .stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        .stat-card {
            flex: 1;
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .stat-number {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 My Bookings</h1>
            <p>Welcome back, <%= user %>! Manage your travel bookings</p>
        </div>
        
        <div class="search-section">
            <form method="get" class="search-form">
                <input type="text" name="filter" placeholder="Search bookings..." 
                       value="<%= filter != null ? filter : "" %>">
                <button type="submit" class="search-btn">🔍 Search</button>
                <% if (filter != null && !filter.isEmpty()) { %>
                    <a href="viewBookings.jsp" class="clear-btn">Clear</a>
                <% } %>
            </form>
        </div>
        
        <div class="bookings-content">
            <%= message %>
            
            <%
                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
                    
                    // Get booking statistics
                    String countQuery = "SELECT COUNT(*) as total FROM bookings WHERE user_id=(SELECT id FROM users WHERE username=?)";
                    PreparedStatement countPs = con.prepareStatement(countQuery);
                    countPs.setString(1, user);
                    ResultSet countRs = countPs.executeQuery();
                    int totalBookings = 0;
                    if (countRs.next()) {
                        totalBookings = countRs.getInt("total");
                    }
                    countRs.close();
                    countPs.close();
                    
                    // Get filtered count
                    int filteredBookings = totalBookings;
                    if (filter != null && !filter.isEmpty()) {
                        String filteredCountQuery = "SELECT COUNT(*) as filtered FROM bookings WHERE user_id=(SELECT id FROM users WHERE username=?) AND item LIKE ?";
                        PreparedStatement filteredPs = con.prepareStatement(filteredCountQuery);
                        filteredPs.setString(1, user);
                        filteredPs.setString(2, "%" + filter + "%");
                        ResultSet filteredRs = filteredPs.executeQuery();
                        if (filteredRs.next()) {
                            filteredBookings = filteredRs.getInt("filtered");
                        }
                        filteredRs.close();
                        filteredPs.close();
                    }
            %>
            
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-number"><%= totalBookings %></div>
                    <div class="stat-label">Total Bookings</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number"><%= filteredBookings %></div>
                    <div class="stat-label">
                        <%= filter != null && !filter.isEmpty() ? "Search Results" : "Active Bookings" %>
                    </div>
                </div>
            </div>
            
            <%
                    String query = "SELECT id, item, booking_time FROM bookings WHERE user_id=(SELECT id FROM users WHERE username=?)";
                    if (filter != null && !filter.isEmpty()) {
                        query += " AND item LIKE ?";
                    }
                    query += " ORDER BY booking_time DESC";
                    
                    PreparedStatement ps = con.prepareStatement(query);
                    ps.setString(1, user);
                    if (filter != null && !filter.isEmpty()) {
                        ps.setString(2, "%" + filter + "%");
                    }
                    
                    ResultSet rs = ps.executeQuery();
                    boolean hasBookings = false;
                    
                    while (rs.next()) {
                        hasBookings = true;
                        String bookingItem = rs.getString("item");
                        String bookingType = "General";
                        String icon = "🎫";
                        
                        if (bookingItem.toLowerCase().contains("flight")) {
                            bookingType = "Flight";
                            icon = "✈️";
                        } else if (bookingItem.toLowerCase().contains("hotel")) {
                            bookingType = "Hotel";
                            icon = "🏨";
                        } else if (bookingItem.toLowerCase().contains("activity")) {
                            bookingType = "Activity";
                            icon = "🎯";
                        }
            %>
            
            <div class="booking-card">
                <div class="booking-header">
                    <span class="booking-type"><%= icon %> <%= bookingType %></span>
                    <span class="booking-time"><%= rs.getTimestamp("booking_time") %></span>
                </div>
                <div class="booking-details">
                    <%= bookingItem %>
                </div>
                <div class="booking-actions">
                    <form method="post" style="display: inline;" 
                          onsubmit="return confirm('Are you sure you want to cancel this booking?')">
                        <input type="hidden" name="delete" value="<%= rs.getInt("id") %>">
                        <button type="submit" class="cancel-btn">🗑️ Cancel Booking</button>
                    </form>
                </div>
            </div>
            
            <%
                    }
                    
                    if (!hasBookings) {
            %>
            <div class="no-bookings">
                <h3>😔 No bookings found</h3>
                <p>
                    <% if (filter != null && !filter.isEmpty()) { %>
                        No bookings match your search criteria. Try a different search term.
                    <% } else { %>
                        You haven't made any bookings yet. Start planning your next adventure!
                    <% } %>
                </p>
                <% if (filter == null || filter.isEmpty()) { %>
                    <a href="ticketBooking.jsp" class="nav-link" style="margin-top: 15px;">
                        🎫 Book Your First Trip
                    </a>
                <% } %>
            </div>
            <%
                    }
                    
                    rs.close();
                    ps.close();
                    con.close();
                } catch (Exception e) {
            %>
            <div class="error-message">
                <strong>Error loading bookings:</strong> <%= e.getMessage() %>
            </div>
            <%
                }
            %>
        </div>
        
        <div class="navigation">
            <a href="index.html" class="nav-link">🏠 Home</a>
            <a href="ticketBooking.jsp" class="nav-link">🎫 New Booking</a>
            <a href="flightSearch.jsp" class="nav-link">✈️ Search Flights</a>
            <a href="logout.jsp" class="nav-link secondary">🚪 Logout</a>
        </div>
    </div>
</body>
</html>