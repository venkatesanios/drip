import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../StateManagement/mqtt_payload_provider.dart';
import '../../StateManagement/overall_use.dart';
import '../../modules/IrrigationProgram/view/program_library.dart';
import '../../services/mqtt_service.dart';
import '../../utils/environment.dart';
import '../../utils/snack_bar.dart';

// Enum for log types
enum LogType {
  schedule(7),
  uart(8),
  uart0(9),
  uart4(10),
  mqtt(11);

  final int value;
  const LogType(this.value);
}

class ControllerLog extends StatefulWidget {
  final String deviceID;

  const ControllerLog({Key? key, required this.deviceID}) : super(key: key);

  @override
  _ControllerLogState createState() => _ControllerLogState();
}

class _ControllerLogState extends State<ControllerLog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OverAllUse overAllPvd;
  late MqttPayloadProvider mqttPayloadProvider;
  final MqttService manager = MqttService();
  LogType currentLogType = LogType.schedule;
  String logString = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: false);
    overAllPvd = Provider.of<OverAllUse>(context, listen: false);
    _tabController = TabController(length: 5, vsync: this);

    // MQTT subscriptions
    manager.topicToUnSubscribe('${Environment.mqttSubscribeTopic}/${widget.deviceID}');
    manager.topicToUnSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
    manager.topicToSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
  }

  Future<String> getLogFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/log.txt';
  }

  Future<void> writeLog(String message) async {
    final path = await getLogFilePath();
    final file = File(path);
    await file.writeAsString('$message\n', mode: FileMode.append);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    mqttPayloadProvider = Provider.of<MqttPayloadProvider>(context, listen: true);
    status();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Controller Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Logs',
            onPressed: () => getlog(currentLogType.value),
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All Logs',
            onPressed: () => _clearLog(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            setState(() {
              currentLogType = LogType.values[index];
            });
          },
          tabs: const [
            Tab(text: 'Schedule'),
            Tab(text: 'UART'),
            Tab(text: 'UART-0'),
            Tab(text: 'UART-4'),
            Tab(text: 'Mqtt'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLogView(mqttPayloadProvider.sheduleLog),
                    _buildLogView(mqttPayloadProvider.uardLog),
                    _buildLogView(mqttPayloadProvider.uard0Log),
                    _buildLogView(mqttPayloadProvider.uard4Log),
                    _buildLogView(""),
                  ],
                ),
              ),
              _buildActionButtons(),
            ],
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildLogView(String text) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ScrollableTextWithSearch(
          key: ValueKey(text), // Ensure widget rebuilds on text change
          text: text.isNotEmpty ? text : "Waiting...",
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: currentLogType != LogType.mqtt
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            label: 'Start',
            color: Colors.green,
            icon: Icons.play_arrow,
            onPressed: () {
              _showSnackBar("Start sending to Controller log...");
              getlog(currentLogType.value);
            },
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Stop',
            color: Colors.red,
            icon: Icons.stop,
            onPressed: () {
              _showSnackBar("Stop sending to Controller log...");
              getlog(LogType.mqtt.value);
            },
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Clear',
            color: Colors.grey,
            icon: Icons.clear,
            onPressed: () => _clearLog(),
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Today FTP',
            color: Colors.blue,
            icon: Icons.cloud_upload,
            onPressed: () {
              _showSnackBar("Today log send FTP...");
              getlog(currentLogType.value + 5);
            },
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Yesterday FTP',
            color: Colors.blue,
            icon: Icons.cloud_upload,
            onPressed: () {
              _showSnackBar("Yesterday log send FTP...");
              getlog(currentLogType.value + 10);
            },
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildButton(
            label: 'Today Mqtt FTP',
            color: Colors.cyan,
            icon: Icons.cloud_upload,
            onPressed: () {
              _showSnackBar("Today Mqtt log send FTP...");
              getlog(16);
            },
          ),
          const SizedBox(width: 10),
          _buildButton(
            label: 'Yesterday Mqtt FTP',
            color: Colors.cyan,
            icon: Icons.cloud_upload,
            onPressed: () {
              _showSnackBar("Yesterday Mqtt log FTP...");
              getlog(21);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      onPressed: onPressed,
    );
  }

  void _clearLog() {
    _showSnackBar("Clear Controller log...");
    setState(() {
      switch (currentLogType) {
        case LogType.schedule:
          mqttPayloadProvider.sheduleLog = '';
          break;
        case LogType.uart:
          mqttPayloadProvider.uardLog = '';
          break;
        case LogType.uart0:
          mqttPayloadProvider.uard0Log = '';
          break;
        case LogType.uart4:
          mqttPayloadProvider.uard4Log = '';
          break;
        case LogType.mqtt:
          break;
      }
    });
  }

  Future<void> ftpStatusDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<MqttPayloadProvider>(
              builder: (context, mqttPayloadProvider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    logString.contains("LogFileDetailsUpdated - Success")
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 50)
                        : const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      logString.contains("LogFileDetailsUpdated - Success")
                          ? "Success"
                          : "Please wait...",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(logString, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        logString.contains("LogFileDetailsUpdated - Success") ? "Ok" : "Cancel",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void status() {
    Map<String, dynamic>? ctrlData = mqttPayloadProvider.messageFromHw;
    if (ctrlData != null && ctrlData.isNotEmpty) {
      logString = ctrlData['Name'] ?? '';
    }
  }

  Future<void> getlog(int data) async {
    setState(() => isLoading = true);
    try {
      manager.topicToUnSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
      manager.topicToSubscribe('${Environment.mqttSubscribeTopic}/${widget.deviceID}');

      await Future.delayed(const Duration(seconds: 1));
      if (LogType.values.any((logType) => logType.value == data)) {
        String payloadCode = "5700";
        Map<String, dynamic> payload = {
          "5700": {"5701": "$data"},
        };

        if (manager.isConnected) {
          await validatePayloadSent(
            dialogContext: context,
            context: context,
            mqttPayloadProvider: mqttPayloadProvider,
            acknowledgedFunction: () {
              manager.topicToUnSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
              manager.topicToSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
            },
            payload: payload,
            payloadCode: payloadCode,
            deviceId: widget.deviceID,
          );
        } else {
          GlobalSnackBar.show(context, 'MQTT is Disconnected', 201);
        }
      } else {
        String payload = jsonEncode({
          "5700": {"5701": "$data"},
        });
        manager.topicToPublishAndItsMessage(payload, '${Environment.mqttPublishTopic}/${widget.deviceID}');
        await ftpStatusDialog(context);
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    getlog(LogType.mqtt.value);
    _tabController.dispose();
    manager.topicToUnSubscribe('${Environment.mqttLogTopic}/${widget.deviceID}');
    super.dispose();
  }
}

class ScrollableTextWithSearch extends StatefulWidget {
  final String text;

  const ScrollableTextWithSearch({Key? key, required this.text}) : super(key: key);

  @override
  _ScrollableTextWithSearchState createState() => _ScrollableTextWithSearchState();
}

class _ScrollableTextWithSearchState extends State<ScrollableTextWithSearch> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<int> _matches = [];
  int _currentMatchIndex = -1;
  int _matchCount = 0;
  bool _isUserScrolling = false;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    // Initial scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  @override
  void didUpdateWidget(ScrollableTextWithSearch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if text has changed
    if (widget.text != _lastText) {
      _lastText = widget.text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Update matches and auto-scroll if not searching or manually scrolling
        _matches = _findMatches(widget.text, _searchQuery);
        _matchCount = _matches.length;
        if (_searchQuery.isEmpty && !_isUserScrolling) {
          _autoScroll();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Detect if user is scrolling
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      // Consider user scrolling if not near the bottom
      _isUserScrolling = (maxScroll - currentScroll) > 50.0;
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _matches = _findMatches(widget.text, _searchQuery);
      _currentMatchIndex = -1;
      _matchCount = _matches.length;
      // Disable auto-scroll when searching
      _isUserScrolling = _searchQuery.isNotEmpty;
    });
  }

  List<int> _findMatches(String text, String query) {
    List<int> matches = [];
    if (query.isEmpty) return matches;

    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();
    int start = 0;

    while (start < lowerText.length) {
      start = lowerText.indexOf(lowerQuery, start);
      if (start == -1) break;
      matches.add(start);
      start += lowerQuery.length;
    }
    return matches;
  }

  List<TextSpan> _highlightText(String text, List<int> matchPositions) {
    List<TextSpan> children = [];
    int start = 0;

    for (int i = 0; i < matchPositions.length; i++) {
      if (start < matchPositions[i]) {
        children.add(TextSpan(text: text.substring(start, matchPositions[i])));
      }
      children.add(TextSpan(
        text: text.substring(matchPositions[i], matchPositions[i] + _searchQuery.length),
        style: TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: _currentMatchIndex == i ? FontWeight.bold : null,
        ),
      ));
      start = matchPositions[i] + _searchQuery.length;
    }

    if (start < text.length) {
      children.add(TextSpan(text: text.substring(start)));
    }
    return children;
  }

  void _scrollToMatch(int index) {
    if (index < 0 || index >= _matches.length) return;
    final matchPosition = _matches[index];
    const fontSize = 16.0;
    const lineHeight = fontSize * 1.5;
    final estimatedLine = (matchPosition / 50).floor();
    final offset = estimatedLine * lineHeight;

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentMatchIndex = index;
      _isUserScrolling = true; // Prevent auto-scroll during match navigation
    });
  }

  void _autoScroll() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Logs',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _matches = [];
                          _currentMatchIndex = -1;
                          _isUserScrolling = false; // Re-enable auto-scroll
                          _autoScroll();
                        });
                      },
                    ),
                  ),
                ),
              ),
              if (_matches.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: 'Previous Match',
                  onPressed: () {
                    setState(() {
                      _currentMatchIndex = (_currentMatchIndex - 1) % _matches.length;
                      if (_currentMatchIndex < 0) _currentMatchIndex = _matches.length - 1;
                      _scrollToMatch(_currentMatchIndex);
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward),
                  tooltip: 'Next Match',
                  onPressed: () {
                    setState(() {
                      _currentMatchIndex = (_currentMatchIndex + 1) % _matches.length;
                      _scrollToMatch(_currentMatchIndex);
                    });
                  },
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Matches found: $_matchCount',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText.rich(
                TextSpan(children: _highlightText(widget.text, _matches)),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}