const Joi = require('joi');

const validateRequestBody = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => ({
        message: detail.message.replace(/['"]/g, ''),
        path: detail.path.join('.'),
        type: detail.type,
      }));
      return res.status(400).json({
        error: 'Validation failed',
        details: errors,
      });
    }
    req.validatedBody = value;
    next();
  };
};

module.exports = {
  validateRequestBody,
};
