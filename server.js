const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const {pool} = require('./configs/dbConfig');
const net = require('net');
const CryptoJS = require('js-crypto-aes').CryptoJS;

const appPort = process.env.APP_PORT || 8000;
const tcpPort = process.env.TCP_PORT || 8080;

app.use(bodyParser.json());
app.use('/api', require('./api/Users'));

const clients = {};

const tcpServer = net.createServer((socket) => {

    // Добавление сокета клиента
    socket.on('login', (userId) => {
        if (!clients[userId]) {
            clients[userId] = [];
        }
        clients[userId].push(socket);
        console.log('TCP client connected');
    });

    // Удаление сокета клиента
    socket.on('disconnect', () => {
        for (const userId in clients) {
            if (clients[userId].includes(socket)) {
                clients[userId].splice(clients[userId].indexOf(socket), 1);
            }
        }
        console.log('TCP client disconnected');
    });

    socket.on('data', async (data) => {
        const message = JSON.parse(data.toString());
        console.log(`Received message: ${message.content}`);

        const encryptedMessage = CryptoJS.AES.encrypt(message.content, process.env.AES_KEY).toString();

        const query = {
            text: `INSERT INTO messages (conversation_id, user_id, content, sent_at)
                   VALUES ($1, $2, $3, $4)
                   RETURNING *`,
            values: [message.conversationId, message.userId, encryptedMessage, new Date()],
        };

        try {
            const result = await pool.query(query);
            const savedMessage = result.rows[0];
            console.log(`Saved message with ID: ${savedMessage.id}`);

            // Отправляем зашифрованное сообщение всем участникам беседы
            const participantsQuery = {
                text: `SELECT user_id
                       FROM participants
                       WHERE conversation_id = $1`,
                values: [message.conversationId],
            };
            const participantsResult = await pool.query(participantsQuery);
            const participants = participantsResult.rows.map((row) => row.user_id);

            participants.forEach((participantId) => {
                if (clients[participantId]) {
                    clients[participantId].forEach((clientSocket) => {
                        clientSocket.write(JSON.stringify({
                            ...savedMessage,
                            content: encryptedMessage,
                        }));
                    });
                }
            });
        } catch (error) {
            console.error(error);
        }
    });
});

tcpServer.listen(tcpPort, () => {
    console.log(`TCP server listening on port ${tcpPort}`);
});

app.listen(appPort, () => {
    console.log(`Server listening on port ${appPort}`);
});