import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class EncryptionService {
  // Must match backend secret (32 bytes)
  static const String ENCRYPTION_SECRET = 'collab-chat-encryption-key-32b!';

  /// Generate a unique encryption key for each chat
  /// This ensures each chat has its own encryption key
  encrypt.Key _generateChatKey(String chatId) {
    // Create a deterministic key from chatId + secret
    final bytes = utf8.encode(chatId + ENCRYPTION_SECRET);
    final hash = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  /// Encrypt a message for a specific chat
  /// Returns encrypted text in format "iv:encryptedData"
  String encryptMessage(String text, String chatId) {
    try {
      if (text.isEmpty) {
        print('[ENCRYPTION] Empty text, returning as-is');
        return text;
      }

      final key = _generateChatKey(chatId);
      final iv = encrypt.IV.fromSecureRandom(16);

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      final encrypted = encrypter.encrypt(text, iv: iv);

      final result = '${iv.base16}:${encrypted.base16}';
      print(
        '[ENCRYPTION] Encrypted message for chat ${chatId.substring(0, 8)}...',
      );
      return result;
    } catch (error) {
      print('[ENCRYPTION ERROR] $error');
      return text;
    }
  }

  /// Decrypt a message for a specific chat
  /// Expects encrypted text in format "iv:encryptedData"
  String decryptMessage(String encryptedText, String chatId) {
    try {
      if (encryptedText.isEmpty) {
        print('[DECRYPTION] Empty encrypted text');
        return encryptedText;
      }

      if (!encryptedText.contains(':')) {
        print('[DECRYPTION] Message not encrypted, returning as-is');
        return encryptedText;
      }

      final parts = encryptedText.split(':');
      if (parts.length != 2) {
        print('[DECRYPTION] Invalid encrypted format');
        return encryptedText;
      }

      print('[DECRYPTION DEBUG] IV hex: ${parts[0]}');
      print('[DECRYPTION DEBUG] Encrypted hex: ${parts[1]}');
      print('[DECRYPTION DEBUG] ChatId for key: $chatId');

      final key = _generateChatKey(chatId);
      print(
        '[DECRYPTION DEBUG] Generated key (first 16 bytes): ${key.bytes.sublist(0, 16)}',
      );

      final iv = encrypt.IV.fromBase16(parts[0]);
      print('[DECRYPTION DEBUG] IV parsed: ${iv.bytes}');

      final encrypted = encrypt.Encrypted.fromBase16(parts[1]);
      print(
        '[DECRYPTION DEBUG] Encrypted data length: ${encrypted.bytes.length}',
      );

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );

      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      print(
        '[DECRYPTION] Decrypted message for chat ${chatId.substring(0, 8)}...',
      );
      return decrypted;
    } catch (error) {
      print('[DECRYPTION ERROR] $error');
      return encryptedText;
    }
  }

  /// Check if a message is encrypted
  bool isEncrypted(String text) {
    if (text.isEmpty) return false;
    // Encrypted messages have format "iv:encryptedData"
    return text.contains(':') && text.split(':').length == 2;
  }
}
