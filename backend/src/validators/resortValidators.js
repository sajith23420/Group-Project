const Joi = require('joi');

const resortSchema = Joi.object({
  name: Joi.string().min(3).max(100).required().messages({
    'string.min': 'Resort name must be at least 3 characters',
    'string.max': 'Resort name cannot exceed 100 characters',
    'any.required': 'Resort name is required',
  }),
  location: Joi.string().min(5).max(255).required().messages({
    'string.min': 'Location must be at least 5 characters',
    'string.max': 'Location cannot exceed 255 characters',
    'any.required': 'Location is required',
  }),
  description: Joi.string().min(10).max(1000).required().messages({
    'string.min': 'Description must be at least 10 characters',
    'string.max': 'Description cannot exceed 1000 characters',
    'any.required': 'Description is required',
  }),
  amenities: Joi.array().items(Joi.string().min(2).max(50)).optional().default([]).messages({
    'array.base': 'Amenities must be an array of strings',
    'string.min': 'Each amenity must be at least 2 characters',
    'string.max': 'Each amenity cannot exceed 50 characters',
  }),
  capacityPerUnit: Joi.number().integer().min(1).required().messages({
    'number.base': 'Capacity per unit must be a number',
    'number.integer': 'Capacity per unit must be an integer',
    'number.min': 'Capacity per unit must be at least 1',
    'any.required': 'Capacity per unit is required',
  }),
  numberOfUnits: Joi.number().integer().min(1).required().messages({
    'number.base': 'Number of units must be a number',
    'number.integer': 'Number of units must be an integer',
    'number.min': 'Number of units must be at least 1',
    'any.required': 'Number of units is required',
  }),
  pricePerNightPerUnit: Joi.number().positive().precision(2).required().messages({
    'number.base': 'Price per night must be a number',
    'number.positive': 'Price per night must be a positive number',
    'number.precision': 'Price per night can have at most 2 decimal places',
    'any.required': 'Price per night is required',
  }),
  images: Joi.array().items(Joi.string().uri()).optional().default([]).messages({
    'array.base': 'Images must be an array of valid URIs',
    'string.uri': 'Each image must be a valid URI',
  }),
  contactInfo: Joi.string().min(5).max(100).required().messages({
    'string.min': 'Contact info must be at least 5 characters',
    'string.max': 'Contact info cannot exceed 100 characters',
    'any.required': 'Contact info is required',
  }),
  availabilityData: Joi.object().optional().default({}),
});

const updateResortSchema = resortSchema.fork(
  ['name', 'location', 'description', 'capacityPerUnit', 'numberOfUnits', 'pricePerNightPerUnit', 'contactInfo'],
  (schema) => schema.optional()
);

const checkAvailabilitySchema = Joi.object({
  checkInDate: Joi.date().iso().required().messages({
    'date.base': 'Check-in date must be a valid date',
    'date.format': 'Check-in date must be in ISO format (YYYY-MM-DD)',
    'any.required': 'Check-in date is required',
  }),
  checkOutDate: Joi.date().iso().greater(Joi.ref('checkInDate')).required().messages({
    'date.base': 'Check-out date must be a valid date',
    'date.format': 'Check-out date must be in ISO format (YYYY-MM-DD)',
    'date.greater': 'Check-out date must be after check-in date',
    'any.required': 'Check-out date is required',
  }),
  numberOfGuests: Joi.number().integer().min(1).optional().default(1),
  numberOfUnits: Joi.number().integer().min(1).optional().default(1),
});

const deleteResortImageSchema = Joi.object({
  imageUrl: Joi.string().required().messages({
    'string.uri': 'Image URL must be a valid URI',
    'any.required': 'Image URL is required for deletion',
  }),
});

module.exports = {
  resortSchema,
  updateResortSchema,
  checkAvailabilitySchema,
  deleteResortImageSchema,
};