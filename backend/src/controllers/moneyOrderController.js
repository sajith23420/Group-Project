const admin = require('../config/firebaseAdmin');
const MoneyOrder = require('../models/moneyOrderModel');
const { MONEY_ORDER_STATUS } = require('../config/constants');

const SERVICE_CHARGE_PERCENTAGE = 0.02; // Example: 2% service charge

const calculateServiceCharge = (amount) => {
  return parseFloat((amount * SERVICE_CHARGE_PERCENTAGE).toFixed(2));
};

const initiateMoneyOrder = async (req, res, next) => {
  try {
    const senderUserId = req.user.uid;
    const { recipientName, recipientAddress, recipientContact, amount, notes } = req.validatedBody;

    const serviceCharge = calculateServiceCharge(amount);
    
    const moneyOrdersRef = admin.database().ref('moneyOrders');
    const newMoneyOrderRef = moneyOrdersRef.push();
    const moneyOrderId = newMoneyOrderRef.key;

    const newMoneyOrder = new MoneyOrder(
      moneyOrderId,
      senderUserId,
      recipientName,
      recipientAddress,
      recipientContact,
      amount,
      serviceCharge,
      null, 
      null, 
      MONEY_ORDER_STATUS.PENDING_PAYMENT,
      notes
    );

    await newMoneyOrderRef.set(newMoneyOrder.toFirestore());

    const userMoneyOrderRef = admin.database().ref(`users/${senderUserId}/paymentHistoryRefs/moneyOrders/${moneyOrderId}`);
    await userMoneyOrderRef.set(true);


    res.status(201).json({ 
      message: 'Money order initiated. Proceed to payment.',
      moneyOrder: newMoneyOrder,
      paymentDetails: {
        payableAmount: newMoneyOrder.totalAmount,
        
      }
    });
  } catch (error) {
    next(error);
  }
};

const confirmMoneyOrderPayment = async (req, res, next) => {
  try {
    const { moneyOrderId } = req.params;
    const { transactionId, paymentGatewayResponse, status } = req.validatedBody;

    const moneyOrderRef = admin.database().ref(`moneyOrders/${moneyOrderId}`);
    const snapshot = await moneyOrderRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Money order not found.' });
    }

    const moneyOrderData = snapshot.val();
    if (moneyOrderData.status !== MONEY_ORDER_STATUS.PENDING_PAYMENT) {
        return res.status(400).json({ message: `Money order is already ${moneyOrderData.status}.` });
    }
    
    const updates = {
      transactionId,
      paymentGatewayResponse,
      status,
      updatedAt: new Date().toISOString(),
    };

    await moneyOrderRef.update(updates);
    const updatedSnapshot = await moneyOrderRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

const getUserMoneyOrders = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const moneyOrdersRef = admin.database().ref('moneyOrders');
    const snapshot = await moneyOrdersRef.orderByChild('senderUserId').equalTo(userId).once('value');
    
    const moneyOrders = [];
    snapshot.forEach(childSnapshot => {
      moneyOrders.push({ id: childSnapshot.key, ...childSnapshot.val() });
    });
    res.status(200).json(moneyOrders);
  } catch (error) {
    next(error);
  }
};

const getMoneyOrderDetails = async (req, res, next) => {
  try {
    const { moneyOrderId } = req.params;
    const userId = req.user.uid; 
    const userRole = req.dbUser.role;

    const moneyOrderRef = admin.database().ref(`moneyOrders/${moneyOrderId}`);
    const snapshot = await moneyOrderRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Money order not found.' });
    }

    const moneyOrderData = snapshot.val();
    if (userRole !== 'admin' && moneyOrderData.senderUserId !== userId) {
        return res.status(403).json({ message: 'Forbidden. You do not have access to this money order.' });
    }

    res.status(200).json(moneyOrderData);
  } catch (error) {
    next(error);
  }
};

const adminGetAllMoneyOrders = async (req, res, next) => {
  try {
    const { status, startDate, endDate, limit = 20, offset = 0 } = req.query;
    let moneyOrdersQuery = admin.database().ref('moneyOrders');

    const snapshot = await moneyOrdersQuery.once('value');
    let moneyOrders = [];
    snapshot.forEach(childSnapshot => {
        moneyOrders.push({ id: childSnapshot.key, ...childSnapshot.val()});
    });

    if (status) {
        moneyOrders = moneyOrders.filter(mo => mo.status === status);
    }
    if (startDate) {
        moneyOrders = moneyOrders.filter(mo => new Date(mo.createdAt) >= new Date(startDate));
    }
    if (endDate) {
        moneyOrders = moneyOrders.filter(mo => new Date(mo.createdAt) <= new Date(endDate));
    }

    const paginatedMoneyOrders = moneyOrders.slice(parseInt(offset), parseInt(offset) + parseInt(limit));

    res.status(200).json({
        total: moneyOrders.length,
        limit: parseInt(limit),
        offset: parseInt(offset),
        data: paginatedMoneyOrders
    });
  } catch (error) {
    next(error);
  }
};

const adminUpdateMoneyOrderStatus = async (req, res, next) => {
  try {
    const { moneyOrderId } = req.params;
    const { status } = req.validatedBody;

    const moneyOrderRef = admin.database().ref(`moneyOrders/${moneyOrderId}`);
    const snapshot = await moneyOrderRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Money order not found.' });
    }

    await moneyOrderRef.update({ status, updatedAt: new Date().toISOString() });
    const updatedSnapshot = await moneyOrderRef.once('value');
    res.status(200).json(updatedSnapshot.val());
  } catch (error) {
    next(error);
  }
};

module.exports = {
  initiateMoneyOrder,
  confirmMoneyOrderPayment,
  getUserMoneyOrders,
  getMoneyOrderDetails,
  adminGetAllMoneyOrders,
  adminUpdateMoneyOrderStatus,
};
