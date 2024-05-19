const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./api/Users');
const conversationRouter = require('./api/Conversations');
const swaggerRouter = require('./api/SwaggerApiUi');
const asyncApiRouter = require('./api/AsyncApiUi');

const app = express();
const appPort = process.env.APP_PORT || 8000;

app.use(bodyParser.json());
app.use('/api/users', userRouter);
app.use('/api/conversations', conversationRouter);
app.use('/api/docs', swaggerRouter);
app.use('/api/docs/tcp', asyncApiRouter);

app.listen(appPort, () => {
    console.log(`Server listening on port ${appPort}`);
});

const tcpServer = require('./tcpServer');
