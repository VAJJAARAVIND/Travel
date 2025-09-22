<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    String user = (String) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String message = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String hotelName = request.getParameter("hotel_name");
        String location = request.getParameter("location");
        String checkinDate = request.getParameter("checkin_date");
        String checkoutDate = request.getParameter("checkout_date");
        String rooms = request.getParameter("rooms");
        String roomType = request.getParameter("room_type");
        String guests = request.getParameter("guests");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
            
            String bookingDetails = "Hotel: " + hotelName + " in " + location + 
                                  " from " + checkinDate + " to " + checkoutDate + 
                                  " - " + rooms + " " + roomType + " room(s) for " + guests + " guest(s)";
            
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO bookings (user_id, item) VALUES ((SELECT id FROM users WHERE username = ?), ?)"
            );
            ps.setString(1, user);
            ps.setString(2, bookingDetails);
            ps.executeUpdate();
            con.close();
            
            message = "<div class='success-message'>" +
                     "<strong>🎉 Hotel Booked Successfully!</strong><br>" +
                     "Hotel: " + hotelName + "<br>" +
                     "Location: " + location + "<br>" +
                     "Dates: " + checkinDate + " to " + checkoutDate + "<br>" +
                     "Rooms: " + rooms + " " + roomType + " room(s)<br>" +
                     "<a href='viewBookings.jsp' style='color: #155724; text-decoration: underline;'>View All Bookings</a>" +
                     "</div>";
        } catch (Exception e) {
            message = "<div class='error-message'>" +
                     "<strong>Booking Error:</strong> " + e.getMessage() +
                     "</div>";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Hotel Search & Booking - Travel Booking System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 900px;
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
        .booking-content {
            padding: 40px;
        }
        .form-section {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        .form-section h2 {
            color: #2c3e50;
            margin: 0 0 25px 0;
            font-size: 24px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #333;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
            box-sizing: border-box;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        .form-row {
            display: flex;
            gap: 20px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .book-btn {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 40px;
            font-size: 18px;
            font-weight: bold;
            border-radius: 50px;
            cursor: pointer;
            width: 100%;
            transition: transform 0.3s;
        }
        .book-btn:hover {
            transform: translateY(-2px);
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            border: 1px solid #c3e6cb;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 20px;
            border-radius: 8px;
            margin: 20px 0;
            border: 1px solid #f5c6cb;
        }
        .featured-hotels {
            margin-top: 40px;
        }
        .featured-hotels h3 {
            color: #2c3e50;
            font-size: 22px;
            margin-bottom: 20px;
        }
        .hotel-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
        }
        .hotel-card {
            background: white;
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .hotel-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .hotel-name {
            font-size: 18px;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 8px;
        }
        .hotel-location {
            color: #6c757d;
            margin-bottom: 10px;
        }
        .hotel-rating {
            color: #ffc107;
            margin-bottom: 10px;
        }
        .hotel-price {
            font-size: 16px;
            font-weight: bold;
            color: #28a745;
        }
        .quick-fill-btn {
            background: #17a2b8;
            color: white;
            border: none;
            padding: 5px 10px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            margin-left: 10px;
        }
        .quick-fill-btn:hover {
            background: #138496;
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
        .tips-section {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 20px;
            border-radius: 10px;
            margin-top: 30px;
        }
        .tips-section h4 {
            margin: 0 0 15px 0;
        }
        .tips-section ul {
            margin: 0;
            padding-left: 20px;
        }
        .tips-section li {
            margin-bottom: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🏨 Hotel Search & Booking</h1>
            <p>Find and book the perfect accommodation for your stay</p>
        </div>
        
        <div class="booking-content">
            <%= message %>
            
            <div class="form-section">
                <h2>Book Your Hotel</h2>
                <form method="post">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Hotel Name *</label>
                            <input type="text" name="hotel_name" required placeholder="Enter hotel name"
                                   value="<%= request.getParameter("hotel_name") != null ? request.getParameter("hotel_name") : "" %>">
                        </div>
                        <div class="form-group">
                            <label>Location *</label>
                            <input type="text" name="location" required placeholder="City or area"
                                   value="<%= request.getParameter("location") != null ? request.getParameter("location") : "" %>">
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Check-in Date *</label>
                            <input type="date" name="checkin_date" required>
                        </div>
                        <div class="form-group">
                            <label>Check-out Date *</label>
                            <input type="date" name="checkout_date" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Number of Rooms *</label>
                            <select name="rooms" required>
                                <option value="">Select rooms</option>
                                <option value="1">1 Room</option>
                                <option value="2">2 Rooms</option>
                                <option value="3">3 Rooms</option>
                                <option value="4">4 Rooms</option>
                                <option value="5">5+ Rooms</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Room Type *</label>
                            <select name="room_type" required>
                                <option value="">Select room type</option>
                                <option value="Standard">Standard Room</option>
                                <option value="Deluxe">Deluxe Room</option>
                                <option value="Suite">Suite</option>
                                <option value="Presidential">Presidential Suite</option>
                                <option value="Family">Family Room</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Number of Guests *</label>
                        <select name="guests" required>
                            <option value="">Select guests</option>
                            <option value="1">1 Guest</option>
                            <option value="2">2 Guests</option>
                            <option value="3">3 Guests</option>
                            <option value="4">4 Guests</option>
                            <option value="5">5+ Guests</option>
                        </select>
                    </div>
                    
                    <button type="submit" class="book-btn">🏨 Book Hotel Now</button>
                </form>
            </div>
            
            <div class="featured-hotels">
                <h3>✨ Featured Hotels</h3>
                <div class="hotel-grid">
                    <div class="hotel-card">
                        <div class="hotel-name">Grand Palace Hotel</div>
                        <div class="hotel-location">📍 Downtown Mumbai</div>
                        <div class="hotel-rating">⭐⭐⭐⭐⭐ (4.8/5)</div>
                        <div class="hotel-price">₹5,500/night</div>
                        <button class="quick-fill-btn" onclick="fillHotelDetails('Grand Palace Hotel', 'Downtown Mumbai')">
                            Quick Fill
                        </button>
                    </div>
                    
                    <div class="hotel-card">
                        <div class="hotel-name">Seaside Resort</div>
                        <div class="hotel-location">📍 Goa Beach</div>
                        <div class="hotel-rating">⭐⭐⭐⭐ (4.5/5)</div>
                        <div class="hotel-price">₹4,200/night</div>
                        <button class="quick-fill-btn" onclick="fillHotelDetails('Seaside Resort', 'Goa Beach')">
                            Quick Fill
                        </button>
                    </div>
                    
                    <div class="hotel-card">
                        <div class="hotel-name">Mountain View Inn</div>
                        <div class="hotel-location">📍 Shimla Hills</div>
                        <div class="hotel-rating">⭐⭐⭐⭐ (4.3/5)</div>
                        <div class="hotel-price">₹3,800/night</div>
                        <button class="quick-fill-btn" onclick="fillHotelDetails('Mountain View Inn', 'Shimla Hills')">
                            Quick Fill
                        </button>
                    </div>
                    
                    <div class="hotel-card">
                        <div class="hotel-name">Heritage Palace</div>
                        <div class="hotel-location">📍 Rajasthan</div>
                        <div class="hotel-rating">⭐⭐⭐⭐⭐ (4.9/5)</div>
                        <div class="hotel-price">₹8,500/night</div>
                        <button class="quick-fill-btn" onclick="fillHotelDetails('Heritage Palace', 'Rajasthan')">
                            Quick Fill
                        </button>
                    </div>
                </div>
            </div>

            <div class="tips-section">
                <h4>Tips for a Great Hotel Stay ✈️</h4>
                <ul>
                    <li>Book in advance for better deals and availability.</li>
                    <li>Read reviews to get insights from other travelers.</li>
                    <li>Check for amenities like free breakfast, Wi-Fi, and parking.</li>
                    <li>Consider location and proximity to attractions.</li>
                    <li>Compare prices on different booking platforms.</li>
                </ul>
            </div>
        </div>

        <div class="navigation">
            <a href="index.html" class="nav-link">🏠 Home</a>
            <a href="viewBookings.jsp" class="nav-link">📝 View Bookings</a>
            <a href="logout.jsp" class="nav-link secondary">🚪 Logout</a>
        </div>
    </div>

    <script>
        function fillHotelDetails(hotelName, location) {
            document.querySelector('input[name="hotel_name"]').value = hotelName;
            document.querySelector('input[name="location"]').value = location;
        }
    </script>
</body>
</html>
