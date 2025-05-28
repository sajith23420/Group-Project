const Joi = require('joi');
const { FEEDBACK_STATUS } = require('../config/constants');

const submitFeedbackSchema = Joi.object({
  postOfficeId: Joi.string().optional().allow(null, ''),
  subject: Joi.string().min(5).max(100).required().messages({
    'string.min': 'Subject must be at least 5 characters',
    'string.max': 'Subject cannot exceed 100 characters',
    'any.required': 'Subject is required',
  }),
  message: Joi.string().min(10).max(1000).required().messages({
    'string.min': 'Message must be at least 10 characters',
    'string.max': 'Message cannot exceed 1000 characters',
    'any.required': 'Message is required',
  }),
  rating: Joi.number().integer().min(1).max(5).optional().allow(null).messages({
    'number.base': 'Rating must be a number',
    'number.integer': 'Rating must be an integer',
    'number.min': 'Rating must be at least 1',
    'number.max': 'Rating must be at most 5',
  }),
});

const adminUpdateFeedbackStatusSchema = Joi.object({
  status: Joi.string().valid(...Object.values(FEEDBACK_STATUS)).required().messages({
    'any.only': `Status must be one of [${Object.values(FEEDBACK_STATUS).join(', ')}]`,
    'any.required': 'Status is required',
  }),
  adminResponse: Joi.string().max(1000).optional().allow(null, ''),
});

module.exports = {
  submitFeedbackSchema,
  adminUpdateFeedbackStatusSchema,
};
