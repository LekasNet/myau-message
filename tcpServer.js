const net = require('net');
const crypto = require('crypto');
const { pool } = require('./configs/dbConfig');
const jwt = require('jsonwebtoken');

const clients = {};
const tcpServer = net.createServer((socket) => {
    console.log('TCP server opened');

    socket.on('data', (data) => {
        try {
            const message = JSON.parse(data.toString());

            if (!message.token) {
                throw new Error('Token is required');
            }

            // Верифицируем токен
            const decoded = jwt.verify(message.token, process.env.ACCESS_KEY);
            const userId = decoded.userId;

            if (!clients[userId]) {
                clients[userId] = [];
            }
            if (!clients[userId].includes(socket)) {
                clients[userId].push(socket);
            }

            console.log(`Received message from user ${userId}: ${message.content}`);

            // Шифруем сообщение
            const cipher = crypto.createCipher('aes-256-cbc', process.env.AES_KEY);
            let encryptedMessage = cipher.update(message.content, 'utf8', 'hex');
            encryptedMessage += cipher.final('hex');

            // Сохраняем зашифрованное сообщение в базе данных
            const query = {
                text: `INSERT INTO messages (conversation_id, user_id, content, sent_at)
                       VALUES ($1, $2, $3, $4)
                       RETURNING *`,
                values: [message.conversationId, userId, encryptedMessage, new Date()],
            };
            pool.query(query, (err, result) => {
                if (err) {
                    console.error(err);
                } else {
                    const savedMessage = result.rows;
                    console.log(`Saved message with ID: ${savedMessage.id}`);

                    // Отправляем зашифрованное сообщение всем участникам беседы
                    const participantsQuery = {
                        text: `SELECT user_id
                               FROM participants
                               WHERE conversation_id = $1`,
                        values: [message.conversationId],
                    };
                    pool.query(participantsQuery, (err, result) => {
                        if (err) {
                            console.error(err);
                        } else {
                            const participants = result.rows.map((row) => row.user_id);
                            participants.forEach((participantId) => {
                                // Отправляем зашифрованное сообщение всем сокетам участника
                                if (clients[participantId]) {
                                    clients[participantId].forEach((clientSocket) => {
                                        clientSocket.write(JSON.stringify({
                                            ...savedMessage,
                                            content: encryptedMessage,
                                        }));
                                    });
                                }
                            });
                        }
                    });
                }
            });
        } catch (err) {
            console.error(err);
            // Отправляем ошибку клиенту
            socket.write(JSON.stringify({ error: err.message }));
        }
    });

    socket.on('close', () => {
        console.log('TCP server closed');
        // Удаляем сокет из списка клиентов
        Object.keys(clients).forEach((userId) => {
            const index = clients[userId].indexOf(socket);
            if (index !== -1) {
                clients[userId].splice(index, 1);
            }
        });
    });
});

module.exports = tcpServer;