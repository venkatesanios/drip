import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:oro_drip_irrigation/modules/open_ai/widget/chat_bubble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/chat_model.dart';
import '../model/message_model.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Message> _messages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage;
  String? _imageSource;
  List<Chat> _chatHistory = [];
  String _currentChatId = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initPermissions();
    _loadChatHistory();
  }

  Future<void> _initPermissions() async {
    await [Permission.camera, Permission.photos].request();
  }

  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatList = prefs.getStringList('chat_history') ?? [];
    setState(() {
      _chatHistory = chatList
          .map((chat) => Chat.fromJson(jsonDecode(chat)))
          .toList()
          .reversed
          .toList();
      if (_chatHistory.isNotEmpty) {
        _currentChatId = _chatHistory.first.id;
        _loadMessages(_currentChatId);
      } else {
        _startNewChat();
      }
    });
  }

  Future<void> _loadMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final messageList = prefs.getStringList('messages_$chatId') ?? [];
    setState(() {
      _messages = messageList.map((msg) => Message.fromJson(jsonDecode(msg))).toList();
    });
    _scrollToBottom();
  }

  Future<void> _saveMessage(Message message) async {
    final prefs = await SharedPreferences.getInstance();
    _messages.add(message);
    final messageList = _messages.map((msg) => jsonEncode(msg.toJson())).toList();
    await prefs.setStringList('messages_$_currentChatId', messageList);
    _updateChatHistory();
    _scrollToBottom();
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final chatList = _chatHistory.map((chat) => jsonEncode(chat.toJson())).toList();
    await prefs.setStringList('chat_history', chatList);
  }

  void _updateChatHistory() {
    final chatIndex = _chatHistory.indexWhere((chat) => chat.id == _currentChatId);
    if (chatIndex != -1 && _messages.isNotEmpty) {
      setState(() {
        _chatHistory[chatIndex] = Chat(
          id: _currentChatId,
          title: _messages.first.text != null && _messages.first.text!.isNotEmpty
              ? (_messages.first.text!.length > 30
              ? '${_messages.first.text!.substring(0, 30)}...'
              : _messages.first.text!)
              : _messages.first.isImage
              ? 'Image Message'
              : (_messages.first.content.length > 30
              ? '${_messages.first.content.substring(0, 30)}...'
              : _messages.first.content),
          lastModified: DateTime.now(),
        );
      });
      _saveChatHistory();
    }
  }

  void _startNewChat() {
    setState(() {
      _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages = [];
      _chatHistory.insert(
        0,
        Chat(
          id: _currentChatId,
          title: 'New Chat',
          lastModified: DateTime.now(),
        ),
      );
    });
    _saveChatHistory();
  }

  Future<void> _deleteChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _chatHistory.removeWhere((chat) => chat.id == chatId);
      if (_currentChatId == chatId) {
        _messages = [];
        if (_chatHistory.isNotEmpty) {
          _currentChatId = _chatHistory.first.id;
          _loadMessages(_currentChatId);
        } else {
          _startNewChat();
        }
      }
    });
    await prefs.remove('messages_$chatId');
    await _saveChatHistory();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }


  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty && _selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        final userMessage = Message(
          role: 'user',
          content: base64Image,
          isImage: true,
          source: _imageSource,
          text: _controller.text.isNotEmpty ? _controller.text : null,
          timestamp: DateTime.now(),
          chatId: _currentChatId,
        );
        await _saveMessage(userMessage);
        await _sendImageMessage(base64Image);
        setState(() {
          _selectedImage = null;
          _imageSource = null;
          _controller.clear();
        });
      } else {
        final userMessage = Message(
          role: 'user',
          content: _controller.text,
          timestamp: DateTime.now(),
          chatId: _currentChatId,
        );
        await _saveMessage(userMessage);
        await _sendTextMessage(userMessage.content);
        setState(() => _controller.clear());
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendTextMessage(String text) async {
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer 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', // Replace with your API key
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': text}
      ],
    });

    final response = await http.post(uri, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final assistantMessage = Message(
        role: 'assistant',
        content: data['choices'][0]['message']['content'],
        timestamp: DateTime.now(),
        chatId: _currentChatId,
      );
      await _saveMessage(assistantMessage);
    } else {
      _showError('Text request failed: ${response.statusCode}');
    }
  }

  Future<void> _sendImageMessage(String base64Image) async {
    final headers = {
      'Authorization': 'Bearer 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', // Replace with your API key
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
            {
              'type': 'text',
              'text': _controller.text.isNotEmpty ? _controller.text : 'What is in this image?',
            },
          ],
        },
      ],
      'max_tokens': 300,
    });

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final assistantMessage = Message(
        role: 'assistant',
        content: data['choices'][0]['message']['content'],
        timestamp: DateTime.now(),
        chatId: _currentChatId,
      );
      await _saveMessage(assistantMessage);
    } else {
      _showError('Image request failed: ${response.statusCode}');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!await _requestPermissions()) {
      _showError('Permission denied');
      return;
    }

    final image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _imageSource = source == ImageSource.camera ? 'camera' : 'gallery';
      });
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chat History',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.pop(context);
                _startNewChat();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  final chat = _chatHistory[index];
                  return ListTile(
                    leading: const Icon(Icons.chat),
                    title: Text(chat.title),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy').format(chat.lastModified),
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: chat.id == _currentChatId,
                    onTap: () {
                      setState(() {
                        _currentChatId = chat.id;
                        _loadMessages(chat.id);
                      });
                      Navigator.pop(context);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete Chat'),
                            content: const Text(
                                'Are you sure you want to delete this chat?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteChat(chat.id);
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: 'Open Chat History',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Start chatting!'))
                : ListView.builder(
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _messages.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final message = _messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          ChatInputField(
            controller: _controller,
            onSend: _sendMessage,
            onPickImage: _pickImage,
            selectedImage: _selectedImage,
          ),
        ],
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(ImageSource) onPickImage;
  final File? selectedImage;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5)],
      ),
      child: Column(
        children: [
          if (selectedImage != null) // Show image preview if an image is selected
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Stack(
                children: [
                  Image.file(
                    selectedImage!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        // Clear the selected image
                        (context as Element)
                            .findAncestorStateOfType<_AIChatScreenState>()
                            ?.setState(() {
                          (context as Element)
                              .findAncestorStateOfType<_AIChatScreenState>()
                              ?._selectedImage = null;
                          (context as Element)
                              .findAncestorStateOfType<_AIChatScreenState>()
                              ?._imageSource = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () => _showAttachmentOptions(context),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: onSend),
            ],
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.pop(context);
              onPickImage(ImageSource.camera);
            },
          ),
        ],
      ),
    );
  }
}