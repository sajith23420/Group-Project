const handleErrors = (err, req, res, next) => {
  console.error('Unhandled error:', err.stack || err.message || err);

  if (err.isJoi) {
    return res.status(400).json({
      error: 'Validation Error',
      details: err.details.map(detail => ({
        message: detail.message.replace(/['"]/g, ''),
        path: detail.path.join('.'),
        type: detail.type,
      })),
    });
  }

  if (err.status && typeof err.status === 'number') {
    return res.status(err.status).json({ error: err.message || 'An error occurred' });
  }

  if (err.code && err.code.startsWith('auth/')) {
    return res.status(401).json({ error: 'Authentication error', detail: err.message });
  }
  
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ error: 'Bad Request. Invalid JSON format.'});
  }

  return res.status(500).json({ error: 'Internal Server Error' });
};

module.exports = {
  handleErrors,
};
