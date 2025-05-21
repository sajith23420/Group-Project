const admin = require('../config/firebaseAdmin');
const Fine = require('../models/fineModel');
const { FINE_STATUS, USER_ROLES } = require('../config/constants');

// Admin: Create a fine for a user
const createFine = async (req, res, next) => {
  try {
    const { userId, reason, amount } = req.validatedBody;
    const createdBy = req.user.uid;
    const finesRef = admin.database().ref('fines');
    const newFineRef = finesRef.push();
    const fineId = newFineRef.key;

    const fine = new Fine(
      fineId,
      userId,
      reason,
      amount,
      FINE_STATUS.PAYMENT_PENDING,
      createdBy
    );

    await newFineRef.set(fine.toFirestore());
    res.status(201).json({ message: 'Fine created.', fine });
  } catch (error) {
    next(error);
  }
};

// Customer: Mark fine as pay-by-customer
const customerPayFine = async (req, res, next) => {
  try {
    const { fineId } = req.params;
    const userId = req.user.uid;
    const fineRef = admin.database().ref(`fines/${fineId}`);
    const snapshot = await fineRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Fine not found.' });
    }
    const fineData = snapshot.val();
    if (fineData.userId !== userId) {
      return res.status(403).json({ message: 'Forbidden.' });
    }
    if (fineData.status !== FINE_STATUS.PAYMENT_PENDING) {
      return res.status(400).json({ message: 'Fine cannot be paid in current status.' });
    }

    await fineRef.update({
      status: FINE_STATUS.PAY_BY_CUSTOMER,
      updatedAt: new Date().toISOString(),
    });
    res.status(200).json({ message: 'Fine marked as pay-by-customer.' });
  } catch (error) {
    next(error);
  }
};

// Admin: Update fine status (confirm/decline/pending)
const adminUpdateFineStatus = async (req, res, next) => {
  try {
    const { fineId } = req.params;
    const { status } = req.validatedBody;
    const fineRef = admin.database().ref(`fines/${fineId}`);
    const snapshot = await fineRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Fine not found.' });
    }
    const fineData = snapshot.val();

    // Only allow valid transitions
    if (
      (fineData.status === FINE_STATUS.PAY_BY_CUSTOMER && 
        (status === FINE_STATUS.PAYMENT_CONFIRMED || status === FINE_STATUS.PAYMENT_DECLINED)) ||
      (fineData.status === FINE_STATUS.PAYMENT_DECLINED && status === FINE_STATUS.PAYMENT_PENDING)
    ) {
      await fineRef.update({ status, updatedAt: new Date().toISOString() });
      return res.status(200).json({ message: 'Fine status updated.' });
    }
    return res.status(400).json({ message: 'Invalid status transition.' });
  } catch (error) {
    next(error);
  }
};

// Get all fines for a user
const getUserFines = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const finesRef = admin.database().ref('fines');
    const snapshot = await finesRef.orderByChild('userId').equalTo(userId).once('value');
    const fines = [];
    snapshot.forEach(child => {
      fines.push({ id: child.key, ...child.val() });
    });
    res.status(200).json(fines);
  } catch (error) {
    next(error);
  }
};

// Admin: Get all fines
const adminGetAllFines = async (req, res, next) => {
  try {
    const finesRef = admin.database().ref('fines');
    const snapshot = await finesRef.once('value');
    const fines = [];
    snapshot.forEach(child => {
      fines.push({ id: child.key, ...child.val() });
    });
    res.status(200).json(fines);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createFine,
  customerPayFine,
  adminUpdateFineStatus,
  getUserFines,
  adminGetAllFines,
};