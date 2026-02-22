import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'message_model.freezed.dart';

// Custom converter for senderId that handles both String and Object
class SenderIdConverter implements JsonConverter<String, dynamic> {
  const SenderIdConverter();

  @override
  String fromJson(dynamic value) {
    if (value is String) {
      return value;
    } else if (value is Map<String, dynamic>) {
      return value['_id'] as String;
    }
    throw Exception('Invalid senderId format: $value');
  }

  @override
  dynamic toJson(String value) => value;
}

@Freezed(fromJson: false)
class Message with _$Message {
  const factory Message({
    @JsonKey(name: '_id') required String id,
    @SenderIdConverter() required String senderId,
    required String chatId,
    required String content,
    @Default('text') String type, // 'text' | 'file'
    required DateTime createdAt,
    @Default(null) User? sender,
    // File-specific fields
    @Default(null) String? fileName,
    @Default(null) int? fileSize,
    @Default(null) String? fileType,
    @Default(null) String? fileUrl, // Cloudinary URL
    // Encryption flag
    @Default(false) bool isEncrypted,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) {
    // Extract sender from senderId if it's populated (object instead of string)
    User? sender;
    if (json['senderId'] is Map<String, dynamic>) {
      sender = User.fromJson(json['senderId'] as Map<String, dynamic>);
    } else if (json['sender'] is Map<String, dynamic>) {
      sender = User.fromJson(json['sender'] as Map<String, dynamic>);
    }

    // Parse senderId
    String senderId;
    if (json['senderId'] is String) {
      senderId = json['senderId'] as String;
    } else if (json['senderId'] is Map<String, dynamic>) {
      senderId = json['senderId']['_id'] as String;
    } else {
      throw Exception('Invalid senderId format');
    }

    return Message(
      id: json['_id'] as String,
      senderId: senderId,
      chatId: json['chatId'] as String,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: sender,
      fileName: json['fileName'] as String?,
      fileSize: json['fileSize'] as int?,
      fileType: json['fileType'] as String?,
      fileUrl: json['fileUrl'] as String?,
      isEncrypted: json['isEncrypted'] as bool? ?? false,
    );
  }
}
