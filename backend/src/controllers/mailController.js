const admin = require('../config/firebaseAdmin');
const Mail = require('../models/mailModel');
const { PARCEL_STATUS, USER_ROLES } = require('../config/constants');

// Admin: Create a parcel/mail
const createMail = async (req, res, next) => {
  try {
    const { userId, senderName, receiverName, receiverAddress, weight } = req.validatedBody;
    const createdBy = req.user.uid;
    const mailsRef = admin.database().ref('mails');
    const newMailRef = mailsRef.push();
    const mailId = newMailRef.key;

    const mail = new Mail(
      mailId,
      userId,
      senderName,
      receiverName,
      receiverAddress,
      weight,
      PARCEL_STATUS.PENDING,
      createdBy
    );

    await newMailRef.set(mail.toFirestore());
    res.status(201).json({ message: 'Mail/Parcel created.', mail });
  } catch (error) {
    next(error);
  }
};

// Get all mails/parcels for a user
const getUserMails = async (req, res, next) => {
  try {
    const userId = req.user.uid;
    const mailsRef = admin.database().ref('mails');
    const snapshot = await mailsRef.orderByChild('userId').equalTo(userId).once('value');
    const mails = [];
    snapshot.forEach(child => {
      mails.push({ id: child.key, ...child.val() });
    });
    res.status(200).json(mails);
  } catch (error) {
    next(error);
  }
};

// Admin: Update parcel/mail status
const adminUpdateMailStatus = async (req, res, next) => {
  try {
    const { mailId } = req.params;
    const { status } = req.validatedBody;
    const mailRef = admin.database().ref(`mails/${mailId}`);
    const snapshot = await mailRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Mail/Parcel not found.' });
    }

    await mailRef.update({ status, updatedAt: new Date().toISOString() });
    res.status(200).json({ message: 'Mail/Parcel status updated.' });
  } catch (error) {
    next(error);
  }
};

// Admin: Get all mails/parcels
const adminGetAllMails = async (req, res, next) => {
  try {
    const mailsRef = admin.database().ref('mails');
    const snapshot = await mailsRef.once('value');
    const mails = [];
    snapshot.forEach(child => {
      // Return the key as 'mailId' to match the frontend MailModel
      mails.push({ mailId: child.key, ...child.val() });
    });
    res.status(200).json(mails);
  } catch (error) {
    next(error);
  }
};

// Get mails/parcels by NIC (userId)
const getMailsByNic = async (req, res, next) => {
  try {
    const { nic } = req.params;
    const mailsRef = admin.database().ref('mails');
    const snapshot = await mailsRef.orderByChild('userId').equalTo(nic).once('value');
    const mails = [];
    snapshot.forEach(child => {
      mails.push({ id: child.key, ...child.val() });
    });
    res.status(200).json(mails);
  } catch (error) {
    next(error);
  }
};

// Admin: Delete mail/parcel by mailId
const deleteMail = async (req, res, next) => {
  try {
    const { mailId } = req.params;
    const mailRef = admin.database().ref(`mails/${mailId}`);
    const snapshot = await mailRef.once('value');

    if (!snapshot.exists()) {
      return res.status(404).json({ message: 'Mail/Parcel not found.' });
    }

    await mailRef.remove(); // Delete the mail
    res.status(200).json({ message: 'Mail/Parcel deleted successfully.' });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createMail,
  getUserMails,
  adminUpdateMailStatus,
  adminGetAllMails,
  getMailsByNic,
  deleteMail, // Export the new delete function
};