// jest.config.js
module.exports = {
  testEnvironment: 'node',
  verbose: true,
  setupFiles: ['./jest.env.setup.js'],
  setupFilesAfterEnv: ['./jest.setup.js'],
  testMatch: ['**/__tests__/**/*.test.js?(x)', '**/?(*.)+(spec|test).js?(x)'],
  clearMocks: true,
  testTimeout: 30000, // Increase timeout to 30 seconds (or more if needed)
};