const Joi = require('joi');
const { POST_OFFICE_SERVICES } = require('../config/constants');

const postOfficeSchema = Joi.object({
  name: Joi.string().min(3).max(100).required().messages({
    'string.base': 'Post office name must be a string',
    'string.min': 'Post office name must be at least 3 characters long',
    'string.max': 'Post office name cannot exceed 100 characters',
    'any.required': 'Post office name is required',
  }),
  postalCode: Joi.string().pattern(/^[0-9]{5}$/).required().messages({
    'string.pattern.base': 'Postal code must be 5 digits',
    'any.required': 'Postal code is required',
  }),
  address: Joi.string().min(5).max(255).required().messages({
    'string.base': 'Address must be a string',
    'string.min': 'Address must be at least 5 characters long',
    'string.max': 'Address cannot exceed 255 characters',
    'any.required': 'Address is required',
  }),
  contactNumber: Joi.string().pattern(/^[0-9]{10,15}$/).optional().allow(null, '').messages({
    'string.pattern.base': 'Contact number must be between 10 to 15 digits',
  }),
  postmasterName: Joi.string().min(3).max(100).optional().allow(null, '').messages({
    'string.min': 'Postmaster name must be at least 3 characters long',
    'string.max': 'Postmaster name cannot exceed 100 characters',
  }),
  subPostOfficeIds: Joi.array().items(Joi.string()).optional().default([]),
  servicesOffered: Joi.array().items(Joi.string().valid(...Object.values(POST_OFFICE_SERVICES))).required().min(1).messages({
    'array.base': 'Services offered must be an array',
    'array.min': 'At least one service must be offered',
    'any.required': 'Services offered are required',
    'any.only': 'Invalid service offered',
  }),
  operatingHours: Joi.alternatives().try(Joi.string(), Joi.object()).required().messages({
    'any.required': 'Operating hours are required',
  }),
  latitude: Joi.number().min(-90).max(90).required().messages({
    'number.base': 'Latitude must be a number',
    'number.min': 'Latitude must be at least -90',
    'number.max': 'Latitude must be at most 90',
    'any.required': 'Latitude is required',
  }),
  longitude: Joi.number().min(-180).max(180).required().messages({
    'number.base': 'Longitude must be a number',
    'number.min': 'Longitude must be at least -180',
    'number.max': 'Longitude must be at most 180',
    'any.required': 'Longitude is required',
  }),
});

const updatePostOfficeSchema = postOfficeSchema.fork(
  ['name', 'postalCode', 'address', 'servicesOffered', 'operatingHours', 'latitude', 'longitude'],
  (schema) => schema.optional()
);


const searchPostOfficeSchema = Joi.object({
  name: Joi.string().optional(),
  postalCode: Joi.string().pattern(/^[0-9]{5}$/).optional().messages({
    'string.pattern.base': 'Postal code must be 5 digits',
  }),
  service: Joi.string().valid(...Object.values(POST_OFFICE_SERVICES)).optional().messages({
     'any.only': 'Invalid service for search',
  }),
  limit: Joi.number().integer().min(1).max(100).default(10),
  offset: Joi.number().integer().min(0).default(0),
});


module.exports = {
  postOfficeSchema,
  updatePostOfficeSchema,
  searchPostOfficeSchema,
};
