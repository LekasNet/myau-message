const jwt = require('jsonwebtoken');

const authenticate = async (req, res, next) => {
    const token = req.header('Authorization');
    if (!token) {
        return res.status(401).json({error: 'Unauthorized'});
    }

    try {
        const decoded = jwt.verify(token, process.env.ACCESS_KEY);
        req.userId = decoded.userId;
        next();
    } catch (error) {
        return res.status(401).json({error: 'Invalid token'});
    }
};

const refreshToken = async (req, res) => {
    const refreshToken = req.body.refreshToken;
    if (!refreshToken) {
        return res.status(401).json({error: 'Refresh token is required'});
    }

    try {
        const decoded = jwt.verify(refreshToken, process.env.REFRESH_KEY);
        const userId = decoded.userId;
        const newAccessToken = jwt.sign({userId}, process.env.ACCESS_KEY, {expiresIn: '1h'});
        const newRefreshToken = jwt.sign({userId}, process.env.REFRESH_KEY, {expiresIn: '7d'});
        res.json({accessToken: newAccessToken, refreshToken: newRefreshToken});
    } catch (error) {
        return res.status(401).json({error: 'Invalid refresh token'});
    }
};

module.exports = {authenticate, refreshToken};