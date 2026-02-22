import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../models/message_model.dart';
import '../utils/extensions.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final Widget? senderName;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
    this.senderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (senderName != null && !isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                child: senderName!,
              ),
            ),
          Container(
            margin: EdgeInsets.only(
              left: isCurrentUser ? 48 : 12,
              right: isCurrentUser ? 12 : 48,
              top: 4,
              bottom: 4,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: isCurrentUser
                  ? const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isCurrentUser ? null : AppTheme.cardColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
              ),
              border: isCurrentUser
                  ? null
                  : Border.all(color: AppTheme.borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: isCurrentUser
                      ? AppTheme.primaryColor.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display file if it's a file message with URL
                if (message.type == 'file' && message.fileUrl != null) ...[
                  _buildFileContent(context),
                  if (message.content.isNotEmpty &&
                      !message.content.startsWith('File:'))
                    const SizedBox(height: 8),
                ],
                if (message.type != 'file' ||
                    (message.content.isNotEmpty &&
                        !message.content.startsWith('File:')))
                  Text(
                    message.type == 'file' ? message.content : message.content,
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white
                          : AppTheme.textPrimary,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  message.createdAt.toFormattedTime(),
                  style: TextStyle(
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.8)
                        : AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileContent(BuildContext context) {
    final fileType = message.fileType ?? '';
    final fileName = message.fileName ?? 'File';
    final fileSize = message.fileSize ?? 0;
    final fileSizeKB = (fileSize / 1024).toStringAsFixed(2);

    // Check if it's an image
    if (fileType.startsWith('image/')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message.fileUrl!,
              fit: BoxFit.cover,
              width: 220,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 220,
                  height: 220,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: isCurrentUser ? Colors.white : AppTheme.primaryColor,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 50,
                    color: isCurrentUser
                        ? Colors.white60
                        : AppTheme.textTertiary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fileName,
            style: TextStyle(
              color: isCurrentUser ? Colors.white70 : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    // For other files, show download button with improved design
    return InkWell(
      onTap: () {
        // Open file in browser
        print('Download file: ${message.fileUrl}');
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.white.withOpacity(0.15)
              : AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrentUser
                ? Colors.white.withOpacity(0.3)
                : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(fileType),
                color: isCurrentUser ? Colors.white : AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white
                          : AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$fileSizeKB KB',
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.2)
                    : AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.download_rounded,
                color: isCurrentUser ? Colors.white : Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileType) {
    if (fileType.startsWith('image/')) return Icons.image;
    if (fileType.startsWith('video/')) return Icons.video_file;
    if (fileType.contains('pdf')) return Icons.picture_as_pdf;
    if (fileType.contains('word') || fileType.contains('document')) {
      return Icons.description;
    }
    if (fileType.contains('text')) return Icons.text_snippet;
    return Icons.insert_drive_file;
  }
}
