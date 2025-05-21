const admin = require('../config/firebaseAdmin');
const BillPayment = require('../models/billPaymentModel');
const { BILL_PAYMENT_STATUS, BILL_TYPES } = require('../config/constants');

const initiateBillPayment = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const { billType, billReferenceNumber, billerName, amount } = req.validatedBody;

    const billPaymentsRef = admin.database().ref('billPayments');
    const newBillPaymentRef = billPaymentsRef.push();
    const billPaymentId = newBillPaymentRef.key;

    const newBillPayment = new BillPayment(
      billPaymentId,
      userId,
      billType,
      billReferenceNumber,
      billerName,
      amount,
      null, 
      null, 
      BILL_PAYMENT_STATUS.PENDING_PAYMENT
    );

    await newBillPaymentRef.set(newBillPayment.toFirestore());
    
    const userBillPaymentRef = admin.database().ref(`users/${userId}/paymentHistoryRefs/billPayments/${billPaymentId}`);
    await userBillPaymentRef.set(true);

    res.status(201).json({
      message: 'Bill payment initiated. Proceed to payment.',
      billPayment: newBillPayment,
      paymentDetails: {
        payableAmount: newBillPayment.amount,
      }
    });
  } catch (error) {
    next(error);
  }
};

const confirmBillPayment = async (req, res, next) => {
  try {
    const { billPaymentId } = req.params;
    const { transactionId, paymentGatewayResponse, status } = req.validatedBody;

    const billPaymentRef = admin.database().ref(`billPayments/${billPaymentId}`);
    const snapshot = await billPaymentRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Bill payment not found.' });
    }
    
    const billPaymentData = snapshot.val();
    if (billPaymentData.status !== BILL_PAYMENT_STATUS.PENDING_PAYMENT) {
        return res.status(400).json({ message: `Bill payment is already ${billPaymentData.status}.` });
    }

    const updates = {
      transactionId,
      paymentGatewayResponse,
      status,
      paymentDate: status === BILL_PAYMENT_STATUS.COMPLETED ? new Date().toISOString() : null,
    };

    await billPaymentRef.update(updates);
    const updatedSnapshot = await billPaymentRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const getUserBillPayments = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const billPaymentsRef = admin.database().ref('billPayments');
    const snapshot = await billPaymentsRef.orderByChild('userId').equalTo(userId).once('value');
    
    const billPayments = [];
    snapshot.forEach(childSnapshot => {
      billPayments.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });
    res.status(200).json(billPayments);
  } catch (error) {
    next(error);
  }
};

const getBillPaymentDetails = async (req, res, next) => {
  try {
    const { billPaymentId } = req.params;
    const userId = req.user.uid;
    const userRole = req.dbUser.role;

    const billPaymentRef = admin.database().ref(`billPayments/${billPaymentId}`);
    const snapshot = await billPaymentRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Bill payment not found.' });
    }
    
    const billPaymentData = snapshot.val();
    if (userRole !== 'admin' && billPaymentData.userId !== userId) {
        return res.status(403).json({ message: 'Forbidden. You do not have access to this bill payment.' });
    }

    res.status(200).json(billPaymentData);
  } catch (error) {
    next(error);
  }
};

const adminGetAllBillPayments = async (req, res, next) => {
  try {
    const { billType, status, startDate, endDate, limit = 20, offset = 0 } = req.query;
    let billPaymentsQuery = admin.database().ref('billPayments');

    const snapshot = await billPaymentsQuery.once('value');
    let billPayments = [];
    snapshot.forEach(childSnapshot => {
        billPayments.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });

    if (billType) {
        billPayments = billPayments.filter(bp => bp.billType === billType);
    }
    if (status) {
        billPayments = billPayments.filter(bp => bp.status === status);
    }
    if (startDate) {
        billPayments = billPayments.filter(bp => new Date(bp.createdAt) >= new Date(startDate));
    }
    if (endDate) {
        billPayments = billPayments.filter(bp => new Date(bp.createdAt) <= new Date(endDate));
    }
    
    const paginatedBillPayments = billPayments.slice(parseInt(offset), parseInt(offset) + parseInt(limit));

    res.status(200).json({
        total: billPayments.length,
        limit: parseInt(limit),
        offset: parseInt(offset),
        data: paginatedBillPayments
    });
  } catch (error) {
    next(error);
  }
};

const getAvailableBillTypes = (req, res, next) => {
  try {
    res.status(200).json(Object.values(BILL_TYPES));
  } catch (error) {
    next(error);
  }
};

module.exports = {
  initiateBillPayment,
  confirmBillPayment,
  getUserBillPayments,
  getBillPaymentDetails,
  adminGetAllBillPayments,
  getAvailableBillTypes,
};
