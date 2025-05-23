const admin = require('../config/firebaseAdmin');
const Booking = require('../models/bookingModel');
const Resort = require('../models/resortModel');
const { BOOKING_STATUS } = require('../config/constants');

const calculateTotalAmount = (pricePerNightPerUnit, checkInDate, checkOutDate, numberOfUnitsBooked) => {
  const checkIn = new Date(checkInDate);
  const checkOut = new Date(checkOutDate);
  const timeDiff = checkOut.getTime() - checkIn.getTime();
  const nights = Math.ceil(timeDiff / (1000 * 3600 * 24));
  return nights * pricePerNightPerUnit * numberOfUnitsBooked;
};

const createBooking = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const { resortId, checkInDate, checkOutDate, numberOfGuests, numberOfUnitsBooked, specialRequests } = req.validatedBody;

    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const resortSnapshot = await resortRef.once('value');
    if (!resortSnapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }
    const resortData = resortSnapshot.val();

    if (numberOfGuests > resortData.capacityPerUnit * numberOfUnitsBooked) {
      return res.status(400).json({ message: `Number of guests exceeds capacity for ${numberOfUnitsBooked} unit(s).` });
    }
    
    const bookingsRefDb = admin.database().ref('bookings');
    const existingBookingsSnapshot = await bookingsRefDb.orderByChild('resortId').equalTo(resortId).once('value');
    let bookedUnitsOnDate = 0;
    const requestedCheckIn = new Date(checkInDate);
    const requestedCheckOut = new Date(checkOutDate);

    existingBookingsSnapshot.forEach(bookingSnap => {
      const booking = bookingSnap.val();
      if (booking.status === BOOKING_STATUS.CONFIRMED || booking.status === BOOKING_STATUS.PENDING_PAYMENT) {
        const existingCheckIn = new Date(booking.checkInDate);
        const existingCheckOut = new Date(booking.checkOutDate);
        if (requestedCheckIn < existingCheckOut && requestedCheckOut > existingCheckIn) {
          bookedUnitsOnDate += booking.numberOfUnitsBooked;
        }
      }
    });

    if ((resortData.numberOfUnits - bookedUnitsOnDate) < numberOfUnitsBooked) {
        return res.status(400).json({ message: `Not enough units available for the selected dates. Available: ${resortData.numberOfUnits - bookedUnitsOnDate}` });
    }

    const totalAmount = calculateTotalAmount(resortData.pricePerNightPerUnit, checkInDate, checkOutDate, numberOfUnitsBooked);

    const newBookingRef = bookingsRefDb.push();
    const bookingId = newBookingRef.key;

    const newBooking = new Booking(
      bookingId,
      userId,
      resortId,
      checkInDate,
      checkOutDate,
      numberOfGuests,
      numberOfUnitsBooked,
      totalAmount,
      null, 
      null, 
      BOOKING_STATUS.PENDING_PAYMENT,
      specialRequests
    );

    await newBookingRef.set(newBooking.toFirestore());
    
    const userBookingRef = admin.database().ref(`users/${userId}/paymentHistoryRefs/bookings/${bookingId}`);
    await userBookingRef.set(true);

    res.status(201).json({
      message: 'Booking initiated. Proceed to payment.',
      booking: newBooking,
      paymentDetails: {
        payableAmount: totalAmount,
      }
    });
  } catch (error) {
    next(error);
  }
};

const confirmBookingPayment = async (req, res, next) => {
  try {
    const { bookingId } = req.params;
    const { transactionId, paymentGatewayResponse } = req.validatedBody;

    const bookingRef = admin.database().ref(`bookings/${bookingId}`);
    const snapshot = await bookingRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Booking not found.' });
    }
    
    const bookingData = snapshot.val();
    if (bookingData.status !== BOOKING_STATUS.PENDING_PAYMENT) {
        return res.status(400).json({ message: `Booking is already ${bookingData.status}.` });
    }

    const updates = {
      transactionId,
      paymentGatewayResponse,
      status: BOOKING_STATUS.CONFIRMED,
      updatedAt: new Date().toISOString(),
    };

    await bookingRef.update(updates);
    const updatedSnapshot = await bookingRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const getUserBookings = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const bookingsRef = admin.database().ref('bookings');
    const snapshot = await bookingsRef.orderByChild('userId').equalTo(userId).once('value');
    
    const bookings = [];
    snapshot.forEach(childSnapshot => {
      bookings.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });
    res.status(200).json(bookings);
  } catch (error) {
    next(error);
  }
};

const getBookingDetails = async (req, res, next) => {
  try {
    const { bookingId } = req.params;
    const userId = req.user.uid;
    const userRole = req.dbUser.role;

    const bookingRef = admin.database().ref(`bookings/${bookingId}`);
    const snapshot = await bookingRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Booking not found.' });
    }

    const bookingData = snapshot.val();
    if (userRole !== 'admin' && bookingData.userId !== userId) {
        return res.status(403).json({ message: 'Forbidden. You do not have access to this booking.' });
    }
    res.status(200).json(bookingData);
  } catch (error) {
    next(error);
  }
};

const cancelBooking = async (req, res, next) => {
  try {
    const { bookingId } = req.params;
    const userId = req.user.uid;

    const bookingRef = admin.database().ref(`bookings/${bookingId}`);
    const snapshot = await bookingRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Booking not found.' });
    }

    const bookingData = snapshot.val();
    if (bookingData.userId !== userId) {
      return res.status(403).json({ message: 'Forbidden. You can only cancel your own bookings.' });
    }

    if (bookingData.status !== BOOKING_STATUS.CONFIRMED && bookingData.status !== BOOKING_STATUS.PENDING_PAYMENT) {
      return res.status(400).json({ message: `Cannot cancel booking with status: ${bookingData.status}.` });
    }
    
    // Add cancellation policy logic here (e.g., time before check-in)

    await bookingRef.update({ status: BOOKING_STATUS.CANCELLED_BY_USER, updatedAt: new Date().toISOString() });
    const updatedSnapshot = await bookingRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const adminGetAllBookings = async (req, res, next) => {
  try {
    const { resortId, status, startDate, endDate, limit = 20, offset = 0 } = req.query;
    let bookingsQuery = admin.database().ref('bookings');

    const snapshot = await bookingsQuery.once('value');
    let bookings = [];
    snapshot.forEach(childSnapshot => {
        bookings.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });

    if (resortId) {
        bookings = bookings.filter(b => b.resortId === resortId);
    }
    if (status) {
        bookings = bookings.filter(b => b.status === status);
    }
    if (startDate) {
        bookings = bookings.filter(b => new Date(b.checkInDate) >= new Date(startDate));
    }
    if (endDate) {
        bookings = bookings.filter(b => new Date(b.checkOutDate) <= new Date(endDate));
    }
    
    const paginatedBookings = bookings.slice(parseInt(offset), parseInt(offset) + parseInt(limit));

    res.status(200).json({
        total: bookings.length,
        limit: parseInt(limit),
        offset: parseInt(offset),
        data: paginatedBookings
    });
  } catch (error) {
    next(error);
  }
};

const adminUpdateBookingStatus = async (req, res, next) => {
  try {
    const { bookingId } = req.params;
    const { status } = req.validatedBody;

    const bookingRef = admin.database().ref(`bookings/${bookingId}`);
    const snapshot = await bookingRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Booking not found.' });
    }

    await bookingRef.update({ status, updatedAt: new Date().toISOString() });
    const updatedSnapshot = await bookingRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createBooking,
  confirmBookingPayment,
  getUserBookings,
  getBookingDetails,
  cancelBooking,
  adminGetAllBookings,
  adminUpdateBookingStatus,
};
