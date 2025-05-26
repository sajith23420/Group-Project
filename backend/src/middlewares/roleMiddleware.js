const { USER_ROLES } = require('../config/constants');

const isAdmin = (req, res, next) => {
  if (!req.dbUser || req.dbUser.role !== USER_ROLES.ADMIN) {
    return res.status(403).send({ error: 'Forbidden. Admin access required.' });
  }
  next();
};

const isUser = (req, res, next) => {
  if (!req.dbUser || (req.dbUser.role !== USER_ROLES.USER && req.dbUser.role !== USER_ROLES.ADMIN)) {
    return res.status(403).send({ error: 'Forbidden. User access required.' });
  }
  next();
};

module.exports = {
  isAdmin,
  isUser,
};
