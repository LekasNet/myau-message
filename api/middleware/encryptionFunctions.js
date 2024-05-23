const crypto = require('crypto');
const forge = require('node-forge');

function generateRSAKeys() {
    return forge.pki.rsa.generateKeyPair({bits: 2048});
}

function publicKeyToPem(publicKey) {
    return forge.pki.publicKeyToPem(publicKey);
}

function privateKeyToPem(privateKey) {
    return forge.pki.privateKeyToPem(privateKey);
}

function pemToPrivateKey(pem) {
    return forge.pki.privateKeyFromPem(pem);
}


function decryptRSA(encryptedMessage, privateKeyPem) {
    try {
        const privateKey = pemToPrivateKey(privateKeyPem);
        return privateKey.decrypt(forge.util.decode64(encryptedMessage), 'RSAES-PKCS1-V1_5');
    } catch (e) {
        console.error('Decryption error:', e);
    }
}

function getSHA256Key(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
}

function aesEncrypt(text, hexKey) {
    const key = Buffer.from(hexKey, 'hex');
    const iv = Buffer.alloc(16); // Пока фиксированный вектор
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(text, 'ucs2', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
}

function aesDecrypt(encrypted, hexKey) {
    const key = Buffer.from(hexKey, 'hex');
    const iv = Buffer.alloc(16); // Пока фиксированный вектор
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    let decrypted = decipher.update(encrypted, 'hex');
    decrypted += decipher.final('ucs2');
    return decrypted;
}


module.exports = {generateRSAKeys, decryptRSA, getSHA256Key, aesEncrypt, aesDecrypt, publicKeyToPem, privateKeyToPem};