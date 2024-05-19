const express = require('express');
const router = express.Router();
const swaggerApiUi = require('swagger-ui-express');
const swaggerDocumentHTTP = require('../swagger.json');

// Отображения Swagger UI
router.use('/', swaggerApiUi.serve);
router.get('/http', swaggerApiUi.setup(swaggerDocumentHTTP));

module.exports = router;