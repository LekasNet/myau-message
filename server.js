const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./api/Users');
const conversationRouter = require('./api/Conversations');
const messageRouter = require('./api/Messages')
const neuralRouter = require('./api/NeuralServer')
const swaggerRouter = require('./api/SwaggerApiUi');
require('dotenv').config();


const app = express();
const appPort = process.env.APP_PORT || 8000;


app.use(bodyParser.json());
app.use('/api/users', userRouter);
app.use('/api/conversations', conversationRouter);
app.use('/api/conversations', messageRouter);
app.use('/api/admin', neuralRouter)
app.use('/api/docs', swaggerRouter);

app.listen(appPort, () => {
    console.log(`Server listening on port ${appPort}`);
});