require('dotenv').config();
const express = require('express');
const firebaseAdmin = require('./src/config/firebaseAdmin');
const path = require('path'); // Added path
const fs = require('fs'); // Added fs

const userAuthRoutes = require('./src/routes/userAuthRoutes');
const postOfficeRoutes = require('./src/routes/postOfficeRoutes');
const officerRoutes = require('./src/routes/officerRoutes');
const moneyOrderRoutes = require('./src/routes/moneyOrderRoutes');
const billPaymentRoutes = require('./src/routes/billPaymentRoutes');
const resortRoutes = require('./src/routes/resortRoutes');
const bookingRoutes = require('./src/routes/bookingRoutes');
const feedbackRoutes = require('./src/routes/feedbackRoutes');
const fineRoutes = require('./src/routes/fineRoutes');      // Add this line
const mailRoutes = require('./src/routes/mailRoutes');      // Add this line

const { handleErrors } = require('./src/middlewares/errorHandlingMiddleware');

const app = express();
const PORT = process.env.PORT || 3000;

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
const userProfileUploadsDir = path.join(__dirname, 'uploads', 'user_profile_pictures');
if (!fs.existsSync(userProfileUploadsDir)) {
  fs.mkdirSync(userProfileUploadsDir, { recursive: true });
}
const resortImageUploadsDir = path.join(__dirname, 'uploads', 'resort_images');
if (!fs.existsSync(resortImageUploadsDir)) {
  fs.mkdirSync(resortImageUploadsDir, { recursive: true });
}


app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files statically
app.use('/uploads', express.static(uploadsDir));


app.get('/', (req, res) => {
  res.status(200).send('Sri Lanka Post Mobile Application Backend');
});

app.use('/api/auth', userAuthRoutes);
app.use('/api/post-offices', postOfficeRoutes);
app.use('/api/officers', officerRoutes);
app.use('/api/money-orders', moneyOrderRoutes);
app.use('/api/bill-payments', billPaymentRoutes);
app.use('/api/resorts', resortRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/feedback', feedbackRoutes);
app.use('/api/fines', fineRoutes);         // Add this line
app.use('/api/mails', mailRoutes);         // Add this line

app.use(handleErrors);

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
    if (firebaseAdmin.app()) {
      console.log('Firebase Admin SDK initialized successfully.');
    } else {
      console.error('Firebase Admin SDK failed to initialize.');
    }
  });
}

module.exports = app;