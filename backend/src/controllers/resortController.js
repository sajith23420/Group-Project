const admin = require('../config/firebaseAdmin');
const Resort = require('../models/resortModel');
const path = require('path');
const fs = require('fs'); // Import fs module
const { v4: uuidv4 } = require('uuid');

const UPLOAD_BASE_URL = '/uploads'; // Or read from config if dynamic
const RESORT_IMAGES_DIR = path.join(__dirname, '..', '..', 'uploads', 'resort_images');

const createResort = async (req, res, next) => {
  try {
    const { name, location, description, amenities, capacityPerUnit, numberOfUnits, pricePerNightPerUnit, images, contactInfo, availabilityData } = req.validatedBody;
    const resortsRef = admin.database().ref('resorts');
    const newResortRef = resortsRef.push();
    const resortId = newResortRef.key;

    const newResort = new Resort(
      resortId,
      name,
      location,
      description,
      amenities,
      capacityPerUnit,
      numberOfUnits,
      pricePerNightPerUnit,
      images, // Assuming these are URLs if provided at creation
      contactInfo,
      availabilityData
    );

    await newResortRef.set(newResort.toFirestore());
    res.status(201).json(newResort);
  } catch (error) {
    next(error);
  }
};

const getResortById = async (req, res, next) => {
  try {
    const { resortId } = req.params;
    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const snapshot = await resortRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }
    res.status(200).json(snapshot.val());
  } catch (error) {
    next(error);
  }
};

const getAllResorts = async (req, res, next) => {
  try {
    const { limit = 10, offset = 0, location, amenities, minPrice, maxPrice } = req.query;
    let resortsQuery = admin.database().ref('resorts');
    
    const snapshot = await resortsQuery.once('value');
    let resorts = [];
    snapshot.forEach(childSnapshot => {
        resorts.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });

    if (location) {
        resorts = resorts.filter(r => r.location && r.location.toLowerCase().includes(location.toLowerCase()));
    }
    if (amenities) {
        const amenitiesArr = amenities.split(',');
        resorts = resorts.filter(r => r.amenities && amenitiesArr.every(a => r.amenities.includes(a)));
    }
    if (minPrice) {
        resorts = resorts.filter(r => r.pricePerNightPerUnit >= parseFloat(minPrice));
    }
    if (maxPrice) {
        resorts = resorts.filter(r => r.pricePerNightPerUnit <= parseFloat(maxPrice));
    }

    const paginatedResorts = resorts.slice(parseInt(offset), parseInt(offset) + parseInt(limit));
    
    res.status(200).json({
        total: resorts.length,
        limit: parseInt(limit),
        offset: parseInt(offset),
        data: paginatedResorts
    });
  } catch (error) {
    next(error);
  }
};

const updateResort = async (req, res, next) => {
  try {
    const { resortId } = req.params;
    const updates = req.validatedBody;

    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const snapshot = await resortRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }

    updates.updatedAt = new Date().toISOString();
    await resortRef.update(updates);
    const updatedSnapshot = await resortRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const deleteResort = async (req, res, next) => {
  try {
    const { resortId } = req.params;
    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const resortSnapshot = await resortRef.once('value');

    if (!resortSnapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }
    
    // Delete associated images from local storage
    const resortData = resortSnapshot.val();
    if (resortData.images && resortData.images.length > 0) {
        resortData.images.forEach(imageUrl => {
            if (imageUrl.startsWith(UPLOAD_BASE_URL)) {
                const imagePath = path.join(__dirname, '..', '..', imageUrl.replace(UPLOAD_BASE_URL, 'uploads'));
                if (fs.existsSync(imagePath)) {
                    try {
                        fs.unlinkSync(imagePath);
                        console.log(`Deleted resort image: ${imagePath}`);
                    } catch (unlinkErr) {
                        console.error(`Error deleting resort image ${imagePath}:`, unlinkErr);
                    }
                }
            }
        });
    }
    // Delete resort directory
    const resortUploadDir = path.join(RESORT_IMAGES_DIR, resortId);
    if (fs.existsSync(resortUploadDir)) {
        try {
            fs.rmSync(resortUploadDir, { recursive: true, force: true });
            console.log(`Deleted resort directory: ${resortUploadDir}`);
        } catch (rmErr) {
            console.error(`Error deleting resort directory ${resortUploadDir}:`, rmErr);
        }
    }


    await resortRef.remove();
    res.status(200).json({ message: 'Resort deleted successfully.' });
  } catch (error) {
    next(error);
  }
};

const checkResortAvailability = async (req, res, next) => {
  try {
    const { resortId } = req.params;
    const { checkInDate, checkOutDate, numberOfGuests, numberOfUnits } = req.validatedBody;

    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const resortSnapshot = await resortRef.once('value');

    if (!resortSnapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }
    const resortData = resortSnapshot.val();

    if (numberOfGuests > resortData.capacityPerUnit * numberOfUnits) {
        return res.status(400).json({ available: false, message: `Number of guests exceeds capacity for ${numberOfUnits} unit(s). Max capacity per unit is ${resortData.capacityPerUnit}.` });
    }
    if (numberOfUnits > resortData.numberOfUnits) {
        return res.status(400).json({ available: false, message: `Requested number of units (${numberOfUnits}) exceeds available units (${resortData.numberOfUnits}).` });
    }

    const bookingsRef = admin.database().ref('bookings');
    const bookingsSnapshot = await bookingsRef.orderByChild('resortId').equalTo(resortId).once('value');
    
    let bookedUnitsOnDate = 0;
    const requestedCheckIn = new Date(checkInDate);
    const requestedCheckOut = new Date(checkOutDate);

    bookingsSnapshot.forEach(bookingSnap => {
      const booking = bookingSnap.val();
      if (booking.status === 'confirmed' || booking.status === 'pending_payment') {
        const existingCheckIn = new Date(booking.checkInDate);
        const existingCheckOut = new Date(booking.checkOutDate);

        if (requestedCheckIn < existingCheckOut && requestedCheckOut > existingCheckIn) {
          bookedUnitsOnDate += booking.numberOfUnitsBooked;
        }
      }
    });

    const availableUnits = resortData.numberOfUnits - bookedUnitsOnDate;

    if (availableUnits >= numberOfUnits) {
      res.status(200).json({ available: true, availableUnits: availableUnits, message: 'Resort is available for the selected dates and units.' });
    } else {
      res.status(200).json({ available: false, availableUnits: availableUnits, message: `Resort is not available. Only ${availableUnits} unit(s) available for the selected dates.` });
    }
  } catch (error) {
    next(error);
  }
};

const uploadResortImage = async (req, res, next) => {
  try {
    const { resortId } = req.params;
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded.' });
    }

    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const resortSnapshot = await resortRef.once('value');
    if (!resortSnapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }

    const resortUploadDir = path.join(RESORT_IMAGES_DIR, resortId);
    if (!fs.existsSync(resortUploadDir)) {
      fs.mkdirSync(resortUploadDir, { recursive: true });
    }

    const fileExtension = path.extname(req.file.originalname);
    const uniqueFileName = `${uuidv4()}${fileExtension}`;
    const localFilePath = path.join(resortUploadDir, uniqueFileName);
    const publicUrl = `${UPLOAD_BASE_URL}/resort_images/${resortId}/${uniqueFileName}`;

    fs.writeFile(localFilePath, req.file.buffer, async (err) => {
      if (err) {
        console.error('Error saving resort image locally:', err);
        return next(err);
      }
      try {
        const currentImages = resortSnapshot.val().images || [];
        currentImages.push(publicUrl);

        await resortRef.update({
          images: currentImages,
          updatedAt: new Date().toISOString(),
        });

        const updatedSnapshot = await resortRef.once('value');
        res.status(200).json({
          message: 'Resort image uploaded successfully.',
          imageUrl: publicUrl,
          resort: updatedSnapshot.val(),
        });
      } catch (error) {
        console.error('Error updating resort database with local image URL:', error);
        try {
          fs.unlinkSync(localFilePath);
        } catch (cleanupErr) {
          console.error('Error cleaning up uploaded resort image after DB error:', cleanupErr);
        }
        return next(error);
      }
    });
  } catch (error) {
    next(error);
  }
};

const deleteResortImage = async (req, res, next) => {
  try {
    const { resortId } = req.params;
    const { imageUrl } = req.validatedBody;

    const resortRef = admin.database().ref(`resorts/${resortId}`);
    const resortSnapshot = await resortRef.once('value');
    if (!resortSnapshot.exists()) {
      return res.status(404).json({ message: 'Resort not found.' });
    }

    const resortData = resortSnapshot.val();
    const currentImages = resortData.images || [];
    
    if (!currentImages.includes(imageUrl)) {
        return res.status(404).json({ message: 'Image URL not found in resort images.' });
    }

    const updatedImages = currentImages.filter(url => url !== imageUrl);

    // Delete from local file system if it's a local URL
    if (imageUrl.startsWith(UPLOAD_BASE_URL)) {
        // Construct the absolute file path from the public URL
        // Example imageUrl: /uploads/resort_images/resort123/image.jpg
        // __dirname for resortController.js is src/controllers
        // We need to go up two levels to the project root, then into uploads
        const relativePathFromProjectRoot = imageUrl.substring(1); // Remove leading '/'
        const localFilePath = path.join(__dirname, '..', '..', relativePathFromProjectRoot);

        if (fs.existsSync(localFilePath)) {
            try {
                fs.unlinkSync(localFilePath);
                console.log(`Successfully deleted ${localFilePath} from local storage.`);
            } catch (storageError) {
                console.error(`Failed to delete image ${localFilePath} from local storage:`, storageError);
                // Decide if you want to proceed with DB update or return error
            }
        } else {
            console.warn(`Local file not found for deletion: ${localFilePath}`);
        }
    } else {
        console.warn(`Image URL ${imageUrl} does not appear to be a local file, skipping local deletion.`);
    }


    await resortRef.update({
      images: updatedImages,
      updatedAt: new Date().toISOString(),
    });

    const updatedSnapshot = await resortRef.once('value');
    res.status(200).json({
      message: 'Resort image deleted successfully.',
      resort: updatedSnapshot.val(),
    });

  } catch (error) {
    next(error);
  }
};

module.exports = {
  createResort,
  getResortById,
  getAllResorts,
  updateResort,
  deleteResort,
  checkResortAvailability,
  uploadResortImage,
  deleteResortImage,
};