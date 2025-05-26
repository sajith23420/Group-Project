const Joi = require('joi');
const { USER_ROLES } = require('../config/constants');

const updateUserProfileSchema = Joi.object({
  displayName: Joi.string().min(3).max(50).optional().messages({
    'string.base': 'Display name must be a string',
    'string.min': 'Display name must be at least 3 characters long',
    'string.max': 'Display name cannot exceed 50 characters',
  }),
  phoneNumber: Joi.string().pattern(/^[0-9]{10,15}$/).optional().allow(null, '').messages({
    'string.pattern.base': 'Phone number must be between 10 to 15 digits',
  }),
});

const adminUpdateUserRoleSchema = Joi.object({
  role: Joi.string().valid(USER_ROLES.USER, USER_ROLES.ADMIN).required().messages({
    'any.required': 'Role is required',
    'any.only': `Role must be one of [${USER_ROLES.USER}, ${USER_ROLES.ADMIN}]`,
  }),
});

module.exports = {
  updateUserProfileSchema,
  adminUpdateUserRoleSchema,
};
