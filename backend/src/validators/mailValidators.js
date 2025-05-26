const Joi = require('joi');
const { PARCEL_STATUS } = require('../config/constants');

const createMailSchema = Joi.object({
  userId: Joi.string().required().messages({
    'any.required': 'User ID is required',
  }),
  senderName: Joi.string().min(2).max(100).required().messages({
    'string.min': 'Sender name must be at least 2 characters',
    'string.max': 'Sender name cannot exceed 100 characters',
    'any.required': 'Sender name is required',
  }),
  receiverName: Joi.string().min(2).max(100).required().messages({
    'string.min': 'Receiver name must be at least 2 characters',
    'string.max': 'Receiver name cannot exceed 100 characters',
    'any.required': 'Receiver name is required',
  }),
  receiverAddress: Joi.string().min(5).max(300).required().messages({
    'string.min': 'Receiver address must be at least 5 characters',
    'string.max': 'Receiver address cannot exceed 300 characters',
    'any.required': 'Receiver address is required',
  }),
  weight: Joi.number().positive().precision(2).required().messages({
    'number.base': 'Weight must be a number',
    'number.positive': 'Weight must be a positive number',
    'number.precision': 'Weight can have at most 2 decimal places',
    'any.required': 'Weight is required',
  }),
});

const adminUpdateMailStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(PARCEL_STATUS)).required().messages({
    'any.only': `Status must be one of [${Object.values(PARCEL_STATUS).join(', ')}]`,
    'any.required': 'Status is required',
  }),
});

module.exports = {
  createMailSchema,
  adminUpdateMailStatusSchema,
};