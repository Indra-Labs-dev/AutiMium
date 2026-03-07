import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/terminal_provider.dart';

class TerminalWidget extends StatefulWidget {
  final String? initialCommand;
  final bool autoConnect;

  const TerminalWidget({
    super.key,
    this.initialCommand,
    this.autoConnect = false,
  });

  @override
  State<TerminalWidget> createState() => _TerminalWidgetState();
}

class _TerminalWidgetState extends State<TerminalWidget> {
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showTimestamps = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TerminalProvider>().connect();
      });
    }
    
    if (widget.initialCommand != null && widget.autoConnect) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _executeCommand(widget.initialCommand!);
        });
      });
    }
  }

  @override
  void dispose() {
    _commandController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _executeCommand(String command) {
    if (command.trim().isEmpty) return;
    
    final provider = context.read<TerminalProvider>();
    if (!provider.isConnected) {
      provider.connect();
    }
    
    provider.sendCommand(command);
    _commandController.clear();
    
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TerminalProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E27),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF0066FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Terminal Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1535),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF0066FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: provider.isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.isConnected ? 'Terminal Connected' : 'Terminal Disconnected',
                      style: const TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Actions
                    IconButton(
                      icon: const Icon(Icons.clear_all, size: 20),
                      color: const Color(0xFF00D4FF),
                      tooltip: 'Clear',
                      onPressed: () => provider.clearMessages(),
                    ),
                    IconButton(
                      icon: Icon(
                        _showTimestamps ? Icons.access_time : Icons.block,
                        size: 20,
                      ),
                      color: const Color(0xFF00D4FF),
                      tooltip: 'Toggle Timestamps',
                      onPressed: () => setState(() => _showTimestamps = !_showTimestamps),
                    ),
                    if (!provider.isConnected)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: const Color(0xFF00D4FF),
                        tooltip: 'Connect',
                        onPressed: () => provider.connect(),
                      ),
                  ],
                ),
              ),

              // Terminal Output
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _buildMessageLine(message, _showTimestamps);
                  },
                ),
              ),

              // Command Input
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1535),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      r'$ ',
                      style: const TextStyle(
                        color: Color(0xFF00D4FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _commandController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter command...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontFamily: 'monospace',
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: _executeCommand,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _executeCommand(_commandController.text),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Run'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageLine(TerminalMessage message, bool showTimestamps) {
    Color textColor;
    IconData? icon;

    switch (message.type) {
      case 'start':
        textColor = const Color(0xFF00D4FF);
        icon = Icons.play_circle_outline;
        break;
      case 'output':
        textColor = Colors.white;
        break;
      case 'complete':
        textColor = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'error':
        textColor = Colors.red;
        icon = Icons.error_outline;
        break;
      default:
        textColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
          ],
          if (showTimestamps) ...[
            Text(
              '[${DateTime.now().toString().split(' ').last.split('.').first}] ',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontFamily: 'monospace',
              ),
            ),
          ],
          Expanded(
            child: SelectableText(
              message.data ?? message.error ?? '',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
