<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>

<%
    String user = (String) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String bookingType = request.getParameter("type");
    String message = "";
    
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/travel", "root", "valle");
            
            String bookingDetails = "";
            
            if ("flight".equals(bookingType)) {
                String flightNo = request.getParameter("flight_no");
                String source = request.getParameter("source");
                String destination = request.getParameter("destination");
                String date = request.getParameter("travel_date");
                String passengers = request.getParameter("passengers");
                String seatClass = request.getParameter("seat_class");
                
                bookingDetails = "Flight Ticket - " + flightNo + " from " + source + " to " + destination + 
                               " on " + date + " for " + passengers + " passenger(s) (" + seatClass + " class)";
                               
            } else if ("hotel".equals(bookingType)) {
                String hotelName = request.getParameter("hotel_name");
                String location = request.getParameter("location");
                String checkin = request.getParameter("checkin_date");
                String checkout = request.getParameter("checkout_date");
                String rooms = request.getParameter("rooms");
                String roomType = request.getParameter("room_type");
                
                bookingDetails = "Hotel Booking - " + hotelName + " in " + location + 
                               " from " + checkin + " to " + checkout + " (" + rooms + " " + roomType + " room(s))";
                               
            } else if ("activity".equals(bookingType)) {
                String activityName = request.getParameter("activity_name");
                String location = request.getParameter("activity_location");
                String date = request.getParameter("activity_date");
                String participants = request.getParameter("participants");
                
                bookingDetails = "Activity Booking - " + activityName + " in " + location + 
                               " on " + date + " for " + participants + " participant(s)";
            }
            
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO bookings (user_id, item) VALUES ((SELECT id FROM users WHERE username = ?), ?)"
            );
            ps.setString(1, user);
            ps.setString(2, bookingDetails);
            ps.executeUpdate();
            con.close();
            
            message = "<div class='success-message'>Booking Successful! Your " + bookingType + " has been booked.</div>";
            
        } catch (Exception e) {
            message = "<div class='error-message'>Booking Failed: " + e.getMessage() + "</div>";
        }
    }
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>Ticket Booking System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
        }
        .booking-tabs {
            display: flex;
            background-color: #34495e;
        }
        .tab {
            flex: 1;
            padding: 15px;
            text-align: center;
            color: white;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .tab:hover, .tab.active {
            background-color: #2c3e50;
        }
        .booking-form {
            padding: 30px;
            display: none;
        }
        .booking-form.active {
            display: block;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        .form-row {
            display: flex;
            gap: 15px;
        }
        .form-row .form-group {
            flex: 1;
        }
        .book-button {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 30px;
            font-size: 18px;
            border-radius: 50px;
            cursor: pointer;
            width: 100%;
            transition: transform 0.3s;
        }
        .book-button:hover {
            transform: translateY(-2px);
        }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #c3e6cb;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            border: 1px solid #f5c6cb;
        }
        .navigation {
            padding: 20px;
            text-align: center;
            background-color: #f8f9fa;
        }
        .nav-link {
            display: inline-block;
            margin: 0 10px;
            padding: 10px 20px;
            background-color: #6c757d;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }
        .nav-link:hover {
            background-color: #5a6268;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎫 Ticket Booking System</h1>
            <p>Welcome, <%= user %>! Book your next adventure</p>
        </div>
        
        <%= message %>
        
        <div class="booking-tabs">
            <div class="tab active" onclick="showBookingForm('flight')">✈️ Flight</div>
            <div class="tab" onclick="showBookingForm('hotel')">🏨 Hotel</div>
            <div class="tab" onclick="showBookingForm('activity')">🎯 Activity</div>
        </div>
        
        <!-- Flight Booking Form -->
        <div id="flight-form" class="booking-form active">
            <h2>✈️ Book Flight Ticket</h2>
            <form method="post">
                <input type="hidden" name="type" value="flight">
                <div class="form-row">
                    <div class="form-group">
                        <label>Flight Number</label>
                        <input type="text" name="flight_no" required placeholder="e.g., AI101">
                    </div>
                    <div class="form-group">
                        <label>Seat Class</label>
                        <select name="seat_class" required>
                            <option value="">Select Class</option>
                            <option value="Economy">Economy</option>
                            <option value="Business">Business</option>
                            <option value="First">First Class</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>From</label>
                        <input type="text" name="source" required placeholder="Departure City">
                    </div>
                    <div class="form-group">
                        <label>To</label>
                        <input type="text" name="destination" required placeholder="Arrival City">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Travel Date</label>
                        <input type="date" name="travel_date" required>
                    </div>
                    <div class="form-group">
                        <label>Passengers</label>
                        <input type="number" name="passengers" min="1" max="9" value="1" required>
                    </div>
                </div>
                <button type="submit" class="book-button">Book Flight Ticket</button>
            </form>
        </div>
        
        <!-- Hotel Booking Form -->
        <div id="hotel-form" class="booking-form">
            <h2>🏨 Book Hotel</h2>
            <form method="post">
                <input type="hidden" name="type" value="hotel">
                <div class="form-row">
                    <div class="form-group">
                        <label>Hotel Name</label>
                        <input type="text" name="hotel_name" required placeholder="Hotel Name">
                    </div>
                    <div class="form-group">
                        <label>Location</label>
                        <input type="text" name="location" required placeholder="City/Area">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Check-in Date</label>
                        <input type="date" name="checkin_date" required>
                    </div>
                    <div class="form-group">
                        <label>Check-out Date</label>
                        <input type="date" name="checkout_date" required>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Number of Rooms</label>
                        <input type="number" name="rooms" min="1" max="10" value="1" required>
                    </div>
                    <div class="form-group">
                        <label>Room Type</label>
                        <select name="room_type" required>
                            <option value="">Select Room Type</option>
                            <option value="Standard">Standard</option>
                            <option value="Deluxe">Deluxe</option>
                            <option value="Suite">Suite</option>
                            <option value="Presidential">Presidential Suite</option>
                        </select>
                    </div>
                </div>
                <button type="submit" class="book-button">Book Hotel</button>
            </form>
        </div>
        
        <!-- Activity Booking Form -->
        <div id="activity-form" class="booking-form">
            <h2>🎯 Book Activity</h2>
            <form method="post">
                <input type="hidden" name="type" value="activity">
                <div class="form-row">
                    <div class="form-group">
                        <label>Activity Name</label>
                        <input type="text" name="activity_name" required placeholder="e.g., City Tour, Adventure Sports">
                    </div>
                    <div class="form-group">
                        <label>Location</label>
                        <input type="text" name="activity_location" required placeholder="Activity Location">
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Activity Date</label>
                        <input type="date" name="activity_date" required>
                    </div>
                    <div class="form-group">
                        <label>Participants</label>
                        <input type="number" name="participants" min="1" max="20" value="1" required>
                    </div>
                </div>
                <button type="submit" class="book-button">Book Activity</button>
            </form>
        </div>
        
        <div class="navigation">
            <a href="index.html" class="nav-link">🏠 Home</a>
            <a href="flightSearch.jsp" class="nav-link">✈️ Search Flights</a>
            <a href="viewBookings.jsp" class="nav-link">📋 My Bookings</a>
            <a href="logout.jsp" class="nav-link">🚪 Logout</a>
        </div>
    </div>
    
    <script>
        function showBookingForm(type) {
            // Hide all forms
            document.querySelectorAll('.booking-form').forEach(form => {
                form.classList.remove('active');
            });
            
            // Remove active class from all tabs
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected form
            document.getElementById(type + '-form').classList.add('active');
            
            // Add active class to clicked tab
            event.target.classList.add('active');
        }
        
        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.querySelectorAll('input[type="date"]').forEach(input => {
                input.min = today;
            });
        });
    </script>
</body>
</html>