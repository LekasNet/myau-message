const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const {refreshToken} = require('./middleware/auth');
const {pool} = require("../configs/dbConfig");
const {generateRSAKeys, decryptRSA, publicKeyToPem, privateKeyToPem} = require('./middleware/encryptionFunctions');


// Регистрация пользователя
router.post('/register', async (req, res) => {
    const {username, password, phone, user_img} = req.body;
    if (!username || !password) {
        return res.status(400).json({error: 'Username and password are required'});
    }

    try {
        const usernameQuery = {
            text: `SELECT 1
                   FROM users
                   WHERE username = $1`,
            values: [username],
        };

        const usernameResult = await pool.query(usernameQuery);
        if (usernameResult.rows.length > 0) {
            return res.status(400).json({error: 'Username already exists'});
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const query = {
            text: `INSERT INTO users (username, password, phone, user_img)
                   VALUES ($1, $2, $3, $4)
                   RETURNING *`,
            values: [username, hashedPassword, phone, user_img],
        };

        await pool.query(query);
        res.status(200).json({message: "Successfully Registered"});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to register user'});
    }
});

// Запрос на логин пользователя
router.post('/login', async (req, res) => {
    const {username} = req.body;
    if (!username) {
        return res.status(400).json({error: 'Username is required'});
    }

    const query = {
        text: `SELECT *
               FROM users
               WHERE username = $1`,
        values: [username],
    };

    try {
        const result = await pool.query(query);
        const user = result.rows[0];
        if (!user) {
            return res.status(401).json({error: 'Invalid username'});
        }

        const {publicKey, privateKey} = await generateRSAKeys();

        const privateKeyPem = privateKeyToPem(privateKey);

        const updateQuery = {
            text: `UPDATE users
                   SET temporary_key = $1
                   WHERE id = $2`,
            values: [privateKeyPem, user.id],
        };
        await pool.query(updateQuery);

        const pem = publicKeyToPem(publicKey)

        res.status(200).json({pem});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to login user'});
    }
});

// Верификация логина
router.post('/login/verify', async (req, res) => {
    const {username, password, lastLoginTimestamp} = req.body;
    if (!username || !password) {
        return res.status(400).json({error: 'Username and password are required'});
    }

    const query = {
        text: `SELECT *
               FROM users
               WHERE username = $1`,
        values: [username],
    };

    try {
        const result = await pool.query(query);
        const user = result.rows[0];
        if (!user) {
            return res.status(401).json({error: 'Invalid username or password'});
        }

        const privateKey = user.temporary_key;
        const decryptedPassword = await decryptRSA(password, privateKey);
        const decryptedLastLogin = await decryptRSA(lastLoginTimestamp, privateKey);

        const isValid = await bcrypt.compare(decryptedPassword, user.password);
        if (!isValid) {
            return res.status(401).json({error: 'Invalid username or password'});
        }

        const updateQuery = {
            text: `UPDATE users
                   SET last_login    = $1,
                       temporary_key = null
                   WHERE id = $2`,
            values: [decryptedLastLogin, user.id],
        };
        await pool.query(updateQuery);

        const accessToken = jwt.sign({userId: user.id}, process.env.ACCESS_KEY, {expiresIn: '1h'});
        const refreshToken = jwt.sign({userId: user.id}, process.env.REFRESH_KEY, {expiresIn: '7d'});
        res.status(200).json({accessToken, refreshToken});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to login user'});
    }
});

// Логин администратора
router.post('/admin/login-admin', async (req, res) => {
    const {username, password} = req.body;
    if (!username || !password) {
        return res.status(400).json({error: 'Username and password are required'});
    }

    const query = {
        text: `SELECT *
               FROM users
               WHERE username = $1`,
        values: [username],
    };

    try {
        const result = await pool.query(query);
        const user = result.rows[0];
        if (!user || user.username !== 'admin') {
            return res.status(401).json({error: 'Invalid username or password'});
        }

        const isValid = await bcrypt.compare(password, user.password);
        if (!isValid) {
            return res.status(401).json({error: 'Invalid username or password'});
        }

        const accessToken = jwt.sign({userId: user.id}, process.env.ACCESS_KEY);
        res.json({accessToken});
    } catch (error) {
        console.error(error);
        res.status(500).json({error: 'Failed to login admin'});
    }
});

// Обновление токена
router.post('/refresh', refreshToken);

module.exports = router;