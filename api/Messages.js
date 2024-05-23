const express = require('express');
const router = express.Router();
const {authenticate} = require('./middleware/auth');
const {pool} = require("../configs/dbConfig");
const crypto = require('crypto');
require('dotenv').config();

// Функции для шифрования
function getSHA256Key(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
}

function aesEncrypt(text, hexKey) {
    const key = Buffer.from(hexKey, 'hex');
    const iv = Buffer.alloc(16); // Пока фиксированный вектор
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return {
        iv: iv.toString('hex'),
        encryptedData: encrypted
    };
}

function aesDecrypt(encrypted, hexKey) {
    const key = Buffer.from(hexKey, 'hex');
    const iv = Buffer.alloc(16); // Пока фиксированный вектор
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    let decrypted = decipher.update(encrypted.encryptedData, 'hex');
    decrypted += decipher.final('utf8');
    return decrypted;
}

// Отправить сообщение в беседу
router.post('/:conversationId/messages', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const message = req.body.content;
    if (!message) {
        return res.status(400).json({error: 'Message content is required'});
    }

    try {
        const userQuery = {
            text: `SELECT last_login
                   FROM users
                   WHERE id = $1`,
            values: [req.userId],
        };
        const userResult = await pool.query(userQuery);
        const user = userResult.rows[0];
        const timestamp = user.last_login;

        const key = getSHA256Key(req.headers.authorization + timestamp).substring(0, 64);

        const query = {
            text: `INSERT INTO messages (conversation_id, user_id, content, sent_at)
                   VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
                   RETURNING *`,
            values: [conversationId, req.userId, aesDecrypt(message, key)],
        };

        try {
            await pool.query(query);
            res.status(200).json({message: 'Message sent successfully'});
        } catch (error) {
            console.error(error);
            res.status(500).json({error: 'Failed to send message'});
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to retrieve user'});
    }
});

// Получить 100 сообщений из беседы от конкретной даты
router.get('/:conversationId/messages', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const fromDate = req.query.fromDate;

    try {
        const userQuery = {
            text: `SELECT last_login
                   FROM users
                   WHERE id = $1`,
            values: [req.userId],
        };
        const userResult = await pool.query(userQuery);
        const user = userResult.rows[0];
        const timestamp = user.last_login;

        const key = getSHA256Key(req.headers.authorization + timestamp).substring(0, 64);

        const query = {
            text: `WITH unread_messages AS (
                UPDATE messages
                    SET read = true
                    WHERE conversation_id = $1 AND user_id != $2 AND read = false
                    RETURNING *)
                   SELECT *
                   FROM messages
                   WHERE conversation_id = $1
                     AND sent_at < $3
                   ORDER BY sent_at DESC
                   LIMIT 100;`,
            values: [conversationId, req.userId, fromDate],
        };

        try {
            const result = await pool.query(query);
            const messages = result.rows.map((message) => {
                return {
                    ...aesEncrypt(message, key)
                };
            });
            res.status(200).json(messages);
        } catch (error) {
            console.error(error);
            res.status(500).json({error: 'Failed to retrieve messages'});
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to retrieve user'});
    }
});


module.exports = router;