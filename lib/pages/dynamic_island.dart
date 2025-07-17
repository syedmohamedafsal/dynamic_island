import 'package:dynamic_island/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class DynamicIsland extends StatefulWidget {
  const DynamicIsland({super.key});

  @override
  State<DynamicIsland> createState() => _DynamicIslandState();
}

class _DynamicIslandState extends State<DynamicIsland>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  String currentMessage = "Now Playing";

  // Native bridge (optional, for Android/iOS service)
  static const platform = MethodChannel('com.example.dynamic_island/channel');
  @override
  void initState() {
    super.initState();
    requestOverlayPermission();
    DynamicIslandBridge.notificationStream.listen((text) {
      setState(() {
        currentMessage = text;
      });

      // Also update native notification text if expanded
      if (isExpanded) {
        DynamicIslandBridge.updateText(text);
      }
    });

    DynamicIslandBridge.startService();
  }

  void requestOverlayPermission() async {
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }
  }

  Future<void> updateIsland(String text) async {
    try {
      await platform.invokeMethod('updateText', {"text": text});
    } on PlatformException catch (e) {
      print("Failed to update island: '${e.message}'.");
    }
  }

  void toggleIsland() {
    setState(() {
      isExpanded = !isExpanded;
    });

    // Optional: Call native method when expanded
    if (isExpanded) {
      platform.invokeMethod('updateText', {'text': currentMessage});
    }
  }

  void updateMessage(String msg) {
    setState(() => currentMessage = msg);
    if (isExpanded) {
      platform.invokeMethod('updateText', {'text': msg});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: toggleIsland,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(top: 20),
              width: isExpanded ? 280 : 120,
              height: isExpanded ? 80 : 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isExpanded
                      ? ExpandedContent(
                          key: const ValueKey("expanded"),
                          message: currentMessage,
                        )
                      : const CollapsedContent(key: ValueKey("collapsed")),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isExpanded
          ? FloatingActionButton.extended(
              onPressed: () => updateMessage("📞 Incoming Call..."),
              label: const Text("Simulate Update"),
              icon: const Icon(Icons.update),
            )
          : null,
    );
  }
}

class ExpandedContent extends StatelessWidget {
  final String message;

  const ExpandedContent({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.music_note, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class CollapsedContent extends StatelessWidget {
  const CollapsedContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.music_note, color: Colors.white, size: 20);
  }
}
