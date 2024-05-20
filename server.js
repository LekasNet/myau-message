const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./api/Users');
const conversationRouter = require('./api/Conversations');
const swaggerRouter = require('./api/SwaggerApiUi');
const tcpServer = require("./tcpServer");

const app = express();
const appPort = process.env.APP_PORT || 8000;
const tcpPort = process.env.TCP_PORT || 8080;


app.use(bodyParser.json());
app.use('/api/users', userRouter);
app.use('/api/conversations', conversationRouter);
app.use('/api/docs', swaggerRouter);

app.listen(appPort, () => {
    console.log(`Server listening on port ${appPort}`);
});

tcpServer.listen(tcpPort, () => {
    console.log(`TCP server listening on port ${tcpPort}`);
});