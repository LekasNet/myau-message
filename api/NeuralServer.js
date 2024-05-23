const express = require('express');
const router = express.Router();
const {pool} = require("../configs/dbConfig");
const {authenticate} = require("./middleware/auth");
const {getSHA256Key, aesEncrypt} = require("./middleware/encryptionFunctions");

// Получить последнее сообщение из беседы с колонкой read_admin = false
router.get('/conversations/:conversationId/last_message', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const query = {
        text: `SELECT m.*, c.theme
               FROM messages m
                        JOIN conversations c ON m.conversation_id = c.id
               WHERE m.conversation_id = $1
                 AND m.read_admin = false
               ORDER BY m.sent_at DESC
               LIMIT 1`,
        values: [conversationId],
    };

    try {
        const result = await pool.query(query);
        const message = result.rows[0];
        if (message) {
            await pool.query(`UPDATE messages
                              SET read_admin = true
                              WHERE id = $1`, [message.id]);

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

            res.status(200).json(aesEncrypt(JSON.stringify(message), key));
        } else {
            res.status(404).json({error: 'No messages found'});
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to retrieve message'});
    }
});

// Прислать id сообщение с пометкой ban = false или true
router.patch('/messages/:messageId/ban', authenticate, async (req, res) => {
    const messageId = req.params.messageId;
    const {ban} = req.body;

    if (ban === undefined) {
        return res.status(400).json({error: 'Ban status is required'});
    }

    const query = {
        text: `UPDATE messages
               SET ban = $1
               WHERE id = $2`,
        values: [ban, messageId],
    };

    try {
        await pool.query(query);
        res.json({message: 'Message updated'});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to update message'});
    }
});

module.exports = router;