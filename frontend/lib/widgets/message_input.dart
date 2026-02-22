import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_theme.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;
  final Function(PlatformFile)? onFileSelected;
  final Function()? onTyping;
  final bool isLoading;

  const MessageInput({
    Key? key,
    required this.onSend,
    this.onFileSelected,
    this.onTyping,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() {
        if (_controller.text.isNotEmpty && !_isTyping) {
          _isTyping = true;
          widget.onTyping?.call();
        } else if (_controller.text.isEmpty && _isTyping) {
          _isTyping = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: AppTheme.borderColor, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // File picker button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.attach_file_rounded),
              onPressed: () async {
                try {
                  print('Opening file picker...');
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.first;
                    print('File selected: ${file.name} (${file.size} bytes)');
                    widget.onFileSelected?.call(file);
                  } else {
                    print('File picker cancelled');
                  }
                } catch (e) {
                  print('Error picking file: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Error: $e')),
                        ],
                      ),
                      backgroundColor: AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              tooltip: 'Attach file',
              color: AppTheme.primaryColor,
              iconSize: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppTheme.primaryColor
                      : AppTheme.borderColor,
                  width: _focusNode.hasFocus ? 1.5 : 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 5,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: _controller.text.isEmpty
                  ? null
                  : const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: _controller.text.isEmpty ? AppTheme.borderColor : null,
              shape: BoxShape.circle,
              boxShadow: _controller.text.isEmpty
                  ? null
                  : [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: IconButton(
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 22),
              color: Colors.white,
              onPressed: _controller.text.isEmpty || widget.isLoading
                  ? null
                  : () {
                      print('Sending message: ${_controller.text}');
                      widget.onSend(_controller.text);
                      _controller.clear();
                      _isTyping = false;
                    },
            ),
          ),
        ],
      ),
    );
  }
}
