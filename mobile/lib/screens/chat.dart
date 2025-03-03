import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class Chat extends StatefulWidget {
  final String babyId;

  const Chat({Key? key, required this.babyId}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  String baseUrl = "";
  String loginId = "";
  final Color primaryColor = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();
    _initializeAndFetchMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndFetchMessages() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = (sh.getString("url") ?? "").endsWith('/') ? sh.getString("url")! : '${sh.getString("url")!}/';
      loginId = sh.getString("login_id") ?? "";
    });
    await fetchMessages();
    _scrollToBottom();
  }

  Future<void> fetchMessages() async {
    try {
      String url = '${baseUrl}get_chat_messages';

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "baby_id": widget.babyId,
          "login_id": loginId,
        },
      );

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        setState(() {
          messages = List<Map<String, dynamic>>.from(jsonData['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar("Failed to load messages: ${jsonData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("Error loading messages");
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Optimistically add message to UI
    final optimisticMessage = {
      'message': message,
      'sender_type': 'parent',
      'timestamp': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'is_sending': true,
    };

    setState(() {
      messages.insert(0, optimisticMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      String url = '${baseUrl}send_chat_message';

      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "baby_id": widget.babyId,
          "login_id": loginId,
          "message": message,
        },
      );

      var jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        await fetchMessages();
      } else {
        // Remove optimistic message and show error
        setState(() {
          messages.removeWhere((msg) => msg == optimisticMessage);
        });
        _showErrorSnackBar("Failed to send message: ${jsonData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      // Remove optimistic message and show error
      setState(() {
        messages.removeWhere((msg) => msg == optimisticMessage);
      });
      _showErrorSnackBar("Error sending message");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => fetchMessages(),
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();

      if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
        return "Today, ${DateFormat('h:mm a').format(dateTime)}";
      } else if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day - 1) {
        return "Yesterday, ${DateFormat('h:mm a').format(dateTime)}";
      } else {
        return DateFormat('MMM d, h:mm a').format(dateTime);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daycare Chat",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "Baby ID: ${widget.babyId}",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchMessages,
            tooltip: "Refresh messages",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
        ),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
                  : messages.isEmpty
                  ? _buildEmptyState()
                  : _buildMessageList(),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: primaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            "No messages yet",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Start the conversation with the daycare",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        bool isSentByParent = message['sender_type'] == 'parent';
        return _buildMessageBubble(message, isSentByParent);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSentByParent) {
    final bool isSending = message['is_sending'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isSentByParent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSentByParent) ...[
            CircleAvatar(
              backgroundColor: Colors.orange.shade200,
              radius: 16,
              child: Icon(
                Icons.school,
                size: 16,
                color: Colors.orange.shade800,
              ),
            ),
            SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSentByParent
                    ? primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: isSentByParent ? Radius.circular(18) : Radius.circular(4),
                  bottomRight: isSentByParent ? Radius.circular(4) : Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['message'] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: isSentByParent ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTimestamp(message['timestamp'] ?? ""),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSentByParent
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (isSentByParent) ...[
                        SizedBox(width: 4),
                        isSending
                            ? SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                          ),
                        )
                            : Icon(
                          Icons.done_all,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isSentByParent) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade200,
              radius: 16,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                    onPressed: () {
                      // Functionality for attachments could be added here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Attachments coming soon!"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () {
                if (_messageController.text.trim().isNotEmpty) {
                  sendMessage(_messageController.text.trim());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}