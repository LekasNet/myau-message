const express = require('express');
const router = express.Router();
const {authenticate} = require('./middleware/auth');
const {pool} = require("../configs/dbConfig");
const crypto = require('crypto');
require('dotenv').config();

const key = process.env.AES_KEY;

function encrypt(message) {
    const cipher = crypto.createCipher('aes-256-cbc', key);
    let encrypted = cipher.update(message, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
}

// Отправить сообщение в беседу
router.post('/:conversationId/messages', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const {content} = req.body;
    if (!content) {
        return res.status(400).json({error: 'Message content is required'});
    }

    const encryptedContent = encrypt(content);

    const query = {
        text: `INSERT INTO messages (conversation_id, user_id, content, sent_at)
               VALUES ($1, $2, $3, CURRENT_TIMESTAMP)
               RETURNING *`,
        values: [conversationId, req.userId, encryptedContent],
    };

    try {
        const result = await pool.query(query);
        const message = result.rows;
        res.json({id: message.id, content: message.content});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to send message'});
    }
});

// Получить 100 сообщений из беседы от конкретной даты
router.get('/:conversationId/messages', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const fromDate = req.query.fromDate;

    const query = {
        text: `WITH unread_messages AS (
            UPDATE messages
                SET read = true
                WHERE conversation_id = $1 AND user_id != $2 AND read = false
                RETURNING *)
               SELECT *
               FROM messages
               WHERE conversation_id = $1
                 AND sent_at > $3
               ORDER BY sent_at DESC
               LIMIT 100;`,
        values: [conversationId, req.userId, fromDate],
    };

    try {
        const result = await pool.query(query);
        const messages = result.rows.map((message) => {
            return {
                ...message
            };
        });
        res.json(messages);
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to retrieve messages'});
    }
});


module.exports = router;