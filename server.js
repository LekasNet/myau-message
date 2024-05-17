const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const userRouter = require('./api/Users');
const conversationRouter = require('./api/Conversations');
const swaggerRouter = require('./api/swaggerUi')

const appPort = process.env.APP_PORT || 8000;
app.use(bodyParser.json());

app.use('/api/users', userRouter);
app.use('/api/conversations', conversationRouter);
app.use('/api/swagger', swaggerRouter)

app.listen(appPort, () => {
    console.log(`Server listening on port ${appPort}`);
});

const tcpServer = require('./tcpServer');
