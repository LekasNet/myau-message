const express = require('express');
const router = express.Router();
const {pool} = require("../configs/dbConfig");
const {authenticate} = require("./middleware/auth");

// Получить последнее сообщение из беседы с колонкой read_admin = false
router.get('/conversations/:conversationId/last_message', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;

    const query = {
        text: `SELECT *
               FROM messages
               WHERE conversation_id = $1
                 AND read_admin = false
               ORDER BY sent_at DESC
               LIMIT 1`,
        values: [conversationId],
    };

    try {
        const result = await pool.query(query);
        const message = result.rows;
        if (message) {
            await pool.query(`UPDATE messages
                              SET read_admin = true
                              WHERE id = $1`, [message.id]);
            res.json(message);
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