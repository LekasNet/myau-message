const net = require('net');
const CryptoJS = require('js-crypto-aes').CryptoJS;
const {pool} = require('./configs/dbConfig');

const clients = {};

const tcpServer = net.createServer((socket) => {
    console.log('TCP server opened!');

    // Обработка данных, полученных от клиента
    socket.on('data', (data) => {
        try {
            const message = JSON.parse(data.toString());
            console.log(`Received message: ${message.content}`);

            // Шифруем сообщение
            const encryptedMessage = CryptoJS.AES.encrypt(message.content, process.env.AES_KEY).toString();

            // Сохраняем зашифрованное сообщение в базе данных
            const query = {
                text: `INSERT INTO messages (conversation_id, user_id, content, sent_at)
                       VALUES ($1, $2, $3, $4)
                       RETURNING *`,
                values: [message.conversationId, message.userId, encryptedMessage, new Date()],
            };
            pool.query(query, (err, result) => {
                if (err) {
                    console.error(err);
                } else {
                    const savedMessage = result.rows[0];
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
        }
    });

    console.log('TCP server closed');
});

module.exports = tcpServer;