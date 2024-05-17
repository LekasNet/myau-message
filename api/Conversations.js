const express = require('express');
const router = express.Router();
const { pool } = require('../server');
const authenticate = require('./middleware/auth');

// Создать беседу
router.post('/', authenticate, async (req, res) => {
    const { name } = req.body;
    if (!name) {
        return res.status(400).json({ error: 'Conversation name is required' });
    }

    const query = {
        text: `INSERT INTO conversations (name, creator_id) VALUES ($1, $2) RETURNING *`,
        values: [name, req.userId],
    };

    try {
        const result = await pool.query(query);
        const conversation = result.rows[0];
        res.json({ id: conversation.id, name: conversation.name });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to create conversation' });
    }
});

// Добавить пользователя в беседу
router.post('/:conversationId/users', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const { userId } = req.body;
    if (!userId) {
        return res.status(400).json({ error: 'User ID is required' });
    }

    const query = {
        text: `INSERT INTO participants (conversation_id, user_id) VALUES ($1, $2) RETURNING *`,
        values: [conversationId, userId],
    };

    try {
        const result = await pool.query(query);
        res.json({ message: 'User added to conversation' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to add user to conversation' });
    }
});

// Получить участников беседы
router.get('/:conversationId/users', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;

    const query = {
        text: `SELECT u.id, u.username FROM participants p JOIN users u ON p.user_id = u.id WHERE p.conversation_id = $1`,
        values: [conversationId],
    };

    try {
        const result = await pool.query(query);
        const users = result.rows;
        res.json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to get conversation participants' });
    }
});

// Удалить беседу
router.delete('/:conversationId', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;

    const query = {
        text: `DELETE FROM conversations WHERE id = $1 AND creator_id = $2`,
        values: [conversationId, req.userId],
    };

    try {
        await pool.query(query);
        res.json({ message: 'Conversation deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to delete conversation' });
    }
});

// Удалить пользователя из беседы
router.delete('/:conversationId/users/:userId', authenticate, async (req, res) => {
    const conversationId = req.params.conversationId;
    const userId = req.params.userId;

    const query = {
        text: `DELETE FROM participants WHERE conversation_id = $1 AND user_id = $2`,
        values: [conversationId, userId],
    };

    try {
        await pool.query(query);
        res.json({ message: 'User removed from conversation' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Failed to remove user from conversation' });
    }
});

module.exports = router;