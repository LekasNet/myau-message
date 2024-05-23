const crypto = require('crypto');
const forge = require('node-forge');

function generateRSAKeys() {
    return forge.pki.rsa.generateKeyPair({bits: 2048});
}

function publicKeyToPem(publicKey) {
    return forge.pki.publicKeyToPem(publicKey);
}

function decryptRSA(privateKey, encryptedMessage) {
    try {
        return privateKey.decrypt(forge.util.decode64(encryptedMessage), 'RSA-OAEP');
    } catch (e) {
        console.error('Decryption error:', e);
    }
}

// Пример использования
const {publicKey, privateKey} = generateRSAKeys();
console.log(publicKeyToPem(publicKey));
const encrypted = forge.util.encode64(publicKey.encrypt('Hello, world!', 'RSA-OAEP'));
const decrypted = decryptRSA(privateKey, encrypted);
console.log('Decrypted message:', decrypted);

function getSHA256Key(data) {
    return crypto.createHash('sha256').update(data).digest('hex');
}

function aesEncrypt(text, hexKey) {
    const key = Buffer.from(hexKey, 'hex');
    const iv = Buffer.alloc(16); // Пока фиксированный вектор
    const cipher = crypto.createCipheriv('aes-256-cbc', key, iv);
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    return encrypted;
}

function aesDecrypt(encrypted, hexKey) {
    const key = Buffer.from(hexKey, 'hex');
    const iv = Buffer.alloc(16); // Пока фиксированный вектор
    const decipher = crypto.createDecipheriv('aes-256-cbc', key, iv);
    let decrypted = decipher.update(encrypted, 'hex');
    decrypted += decipher.final('utf8');
    return decrypted;
}

module.exports = {generateRSAKeys, decryptRSA, getSHA256Key, aesEncrypt, aesDecrypt, publicKeyToPem};