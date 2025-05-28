const Joi = require('joi');

const officerSchema = Joi.object({
  name: Joi.string().min(3).max(100).required().messages({
    'string.base': 'Officer name must be a string',
    'string.min': 'Officer name must be at least 3 characters long',
    'string.max': 'Officer name cannot exceed 100 characters',
    'any.required': 'Officer name is required',
  }),
  designation: Joi.string().min(2).max(100).required().messages({
    'string.base': 'Designation must be a string',
    'string.min': 'Designation must be at least 2 characters long',
    'string.max': 'Designation cannot exceed 100 characters',
    'any.required': 'Designation is required',
  }),
  assignedPostOfficeId: Joi.string().required().messages({
    'any.required': 'Assigned post office ID is required',
  }),
  contactNumber: Joi.string().pattern(/^[0-9]{10,15}$/).optional().allow(null, '').messages({
    'string.pattern.base': 'Contact number must be between 10 to 15 digits',
  }),
  email: Joi.string().email().optional().allow(null, '').messages({
    'string.email': 'Email must be a valid email address',
  }),
  photoUrl: Joi.string().uri().optional().allow(null, '').messages({
    'string.uri': 'Photo URL must be a valid URI',
  }),
});

const updateOfficerSchema = officerSchema.fork(
  ['name', 'designation', 'assignedPostOfficeId'],
  (schema) => schema.optional()
);

module.exports = {
  officerSchema,
  updateOfficerSchema,
};
