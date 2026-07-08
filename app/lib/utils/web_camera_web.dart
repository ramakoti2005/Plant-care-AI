import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Future<Uint8List?> captureWebCamera(BuildContext context) async {
  return showDialog<Uint8List>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return const WebCameraDialog();
    },
  );
}

class WebCameraDialog extends StatefulWidget {
  const WebCameraDialog({super.key});

  @override
  State<WebCameraDialog> createState() => _WebCameraDialogState();
}

class _WebCameraDialogState extends State<WebCameraDialog> {
  html.VideoElement? _videoElement;
  html.MediaStream? _localStream;
  String _viewId = '';
  bool _initialized = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _viewId = 'web-camera-view-${DateTime.now().millisecondsSinceEpoch}';
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Request camera access
      if (html.window.navigator.mediaDevices == null) {
        throw Exception("Camera API is not supported in this browser (make sure you are using HTTPS or localhost).");
      }
      
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({'video': true});
      _localStream = stream;
      _videoElement!.srcObject = stream;

      // Register the VideoElement as a platform view factory
      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _videoElement!);

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Camera access error: $e. Make sure your browser has camera permission enabled and you are on localhost or HTTPS.';
      });
    }
  }

  void _capture() {
    if (_videoElement == null) return;
    
    final int width = _videoElement!.videoWidth;
    final int height = _videoElement!.videoHeight;
    
    if (width == 0 || height == 0) return;

    final canvas = html.CanvasElement(width: width, height: height);
    final ctx = canvas.context2D;
    ctx.drawImage(_videoElement!, 0, 0);

    final dataUrl = canvas.toDataUrl('image/jpeg');
    final String base64String = dataUrl.split(',')[1];
    final Uint8List bytes = base64.decode(base64String);

    _cleanup();
    Navigator.of(context).pop(bytes);
  }

  void _cleanup() {
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        track.stop();
      }
    }
    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? const Color(0xFF1E2D24) : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 550),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                Text(
                  "Web Camera Preview",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFA5D6A7) : const Color(0xFF1B5E20),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _cleanup();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black87,
                  child: _error.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _error,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : !_initialized
                          ? const Center(child: CircularProgressIndicator(color: Colors.green))
                          : HtmlElementView(viewType: _viewId),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    _cleanup();
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                if (_initialized && _error.isEmpty)
                  ElevatedButton.icon(
                    onPressed: _capture,
                    icon: const Icon(Icons.camera),
                    label: const Text("Capture Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
