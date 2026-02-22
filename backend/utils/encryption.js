const crypto = require("crypto");

// AES-256-CBC encryption
const ALGORITHM = "aes-256-cbc";
const ENCRYPTION_SECRET =
    process.env.ENCRYPTION_SECRET || "default-secret-key-change-this-32b"; // Must be 32 bytes

console.log(
    `[ENCRYPTION] Using secret: ${ENCRYPTION_SECRET.substring(0, 10)}...`,
);
console.log(
    `[ENCRYPTION] Secret loaded from: ${process.env.ENCRYPTION_SECRET ? ".env file" : "DEFAULT FALLBACK"}`,
);

/**
 * Generate a unique encryption key for each chat
 * This ensures each chat has its own encryption key
 */
function generateChatKey(chatId) {
    // Create a deterministic key from chatId + secret
    const hash = crypto
        .createHash("sha256")
        .update(chatId + ENCRYPTION_SECRET)
        .digest();
    return hash; // 32 bytes for AES-256
}

/**
 * Encrypt a message for a specific chat
 * @param {string} text - Plain text message
 * @param {string} chatId - Chat ID to derive encryption key
 * @returns {string} - Encrypted text in format "iv:encryptedData"
 */
function encryptMessage(text, chatId) {
    try {
        if (!text || typeof text !== "string") {
            console.log("[ENCRYPTION] Invalid text, returning as-is");
            return text;
        }

        const key = generateChatKey(chatId);
        const iv = crypto.randomBytes(16); // Initialization vector

        const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
        let encrypted = cipher.update(text, "utf8", "hex");
        encrypted += cipher.final("hex");

        const result = iv.toString("hex") + ":" + encrypted;
        console.log(
            `[ENCRYPTION] Encrypted message for chat ${chatId.substring(0, 8)}...`,
        );
        return result;
    } catch (error) {
        console.error(`[ENCRYPTION ERROR] ${error.message}`);
        return text;
    }
}

/**
 * Decrypt a message for a specific chat
 * @param {string} encryptedText - Encrypted text in format "iv:encryptedData"
 * @param {string} chatId - Chat ID to derive decryption key
 * @returns {string} - Decrypted plain text
 */
function decryptMessage(encryptedText, chatId) {
    try {
        if (!encryptedText || typeof encryptedText !== "string") {
            console.log("[DECRYPTION] Invalid encrypted text");
            return encryptedText;
        }

        if (!encryptedText.includes(":")) {
            console.log("[DECRYPTION] Message not encrypted, returning as-is");
            return encryptedText;
        }

        const parts = encryptedText.split(":");
        if (parts.length !== 2) {
            console.log("[DECRYPTION] Invalid encrypted format");
            return encryptedText;
        }

        const key = generateChatKey(chatId);
        const iv = Buffer.from(parts[0], "hex");
        const encrypted = parts[1];

        const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
        let decrypted = decipher.update(encrypted, "hex", "utf8");
        decrypted += decipher.final("utf8");

        console.log(
            `[DECRYPTION] Decrypted message for chat ${chatId.substring(0, 8)}...`,
        );
        return decrypted;
    } catch (error) {
        console.error(`[DECRYPTION ERROR] ${error.message}`);
        return encryptedText;
    }
}

/**
 * Check if a message is encrypted
 * @param {string} text - Text to check
 * @returns {boolean} - True if encrypted
 */
function isEncrypted(text) {
    if (!text || typeof text !== "string") return false;
    // Encrypted messages have format "iv:encryptedData"
    return text.includes(":") && text.split(":").length === 2;
}

module.exports = {
    encryptMessage,
    decryptMessage,
    isEncrypted,
};
