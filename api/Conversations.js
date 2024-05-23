const express = require('express');
const router = express.Router();
const {authenticate} = require('./middleware/auth');
const {pool} = require("../configs/dbConfig");

// Создать беседу
router.post('/', authenticate, async (req, res) => {
    const {name, theme, conversation_img} = req.body;
    if (!name || !theme) {
        return res.status(400).json({error: 'Conversation name and theme are required'});
    }

    try {
        await pool.query('BEGIN');

        const conversationQuery = {
            text: `INSERT INTO conversations (name, creator_id, theme, conversation_img)
                   VALUES ($1, $2, $3, $4)
                   RETURNING *`,
            values: [name, req.userId, theme, conversation_img],
        };

        const conversationResult = await pool.query(conversationQuery);
        const conversation = conversationResult.rows[0];

        const participantQuery = {
            text: `INSERT INTO participants (conversation_id, user_id)
                   VALUES ($1, $2)`,
            values: [conversation.id, req.userId],
        };

        await pool.query(participantQuery);

        const adminQuery = {
            text: `SELECT id
                   FROM users
                   WHERE username = $1`,
            values: ['admin'],
        };

        const adminResult = await pool.query(adminQuery);

        if (adminResult.rows.length > 0) {
            const adminId = adminResult.rows[0].id;

            const adminParticipantQuery = {
                text: `INSERT INTO participants (conversation_id, user_id)
                       VALUES ($1, $2)`,
                values: [conversation.id, adminId],
            };

            await pool.query(adminParticipantQuery);
        }

        await pool.query('COMMIT');

        res.json({id: conversation.id, name: conversation.name});
    } catch (error) {
        await pool.query('ROLLBACK');
        console.error(error);
        res.status(500).json({error: 'Failed to create conversation'});
    }
});

// Добавить пользователя в беседу
router.post('/:conversationId/users', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const {username} = req.body;
    if (!username) {
        return res.status(400).json({error: 'Username is required'});
    }

    try {
        const userQuery = {
            text: `SELECT id
                   FROM users
                   WHERE username = $1`,
            values: [username],
        };

        const userResult = await pool.query(userQuery);
        if (userResult.rows.length === 0) {
            return res.status(404).json({error: 'User not found'});
        }

        const userId = userResult.rows[0].id;

        const query = {
            text: `INSERT INTO participants (conversation_id, user_id)
                   VALUES ($1, $2)
                   RETURNING *`,
            values: [conversationId, userId],
        };

        await pool.query(query);
        res.json({message: 'User added to conversation'});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to add user to conversation'});
    }
});

// Получить беседы, в которых состоит пользователь
router.get('/user-conversations', authenticate, async (req, res) => {
    const query = {
        text: `SELECT c.id, c.name, c.conversation_img
               FROM participants p
                        JOIN conversations c ON p.conversation_id = c.id
               WHERE p.user_id = $1`,
        values: [req.userId],
    };

    try {
        const result = await pool.query(query);
        const conversations = result.rows;
        res.status(200).json(conversations);
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to get user conversations'});
    }
});

// Получить участников беседы
router.get('/:conversationId/users', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;

    const query = {
        text: `SELECT u.id, u.username
               FROM participants p
                        JOIN users u ON p.user_id = u.id
               WHERE p.conversation_id = $1`,
        values: [conversationId],
    };

    try {
        const result = await pool.query(query);
        const users = result.rows;
        res.status(200).json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to get conversation participants'});
    }
});

// Удалить беседу
router.delete('/:conversationId', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const userId = req.userId;

    try {
        // Удалить сообщения в беседе
        await pool.query({
            text: `DELETE
                   FROM messages
                   WHERE conversation_id = $1`,
            values: [conversationId],
        });

        // Удалить участников беседы
        await pool.query({
            text: `DELETE
                   FROM participants
                   WHERE conversation_id = $1`,
            values: [conversationId],
        });

        // Удалить саму беседу
        await pool.query({
            text: `DELETE
                   FROM conversations
                   WHERE id = $1
                     AND creator_id = $2`,
            values: [conversationId, userId],
        });

        res.status(200).json({message: 'Conversation deleted'});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to delete conversation'});
    }
});

// Удалить пользователя из беседы
router.delete('/:conversationId/users/:userId', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const userId = req.params.userId;

    const query = {
        text: `DELETE
               FROM participants
               WHERE conversation_id = $1
                 AND user_id = $2`,
        values: [conversationId, userId],
    };

    try {
        await pool.query(query);
        res.json({message: 'User removed from conversation'});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to remove user from conversation'});
    }
});

module.exports = router;