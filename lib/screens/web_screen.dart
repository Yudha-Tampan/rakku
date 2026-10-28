import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakku/app_chrome.dart';
import 'package:rakku/core/native_google.dart';
import 'package:rakku/screens/offline_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _nativeChannelName = 'RakkuNative';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key, required this.url});

  final String url;

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  late final WebViewController _controller;
  bool _failed = false;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(kAppBackground)
      ..addJavaScriptChannel(_nativeChannelName, onMessageReceived: _handleNativeMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setFailed(false),
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) {
              _setFailed(true);
            }
          },
        ),
      );
    _controller.loadRequest(Uri.parse(widget.url));
  }

  Future<void> _handleNativeMessage(JavaScriptMessage message) async {
    final request = _decodeRequest(message.message);
    if (request == null) return;
    if (request['type'] == 'fullscreen') {
      await _setFullscreen(request['on'] == true);
      return;
    }
    if (request['type'] != 'google-signin') return;
    Map<String, Object> result;
    try {
      result = await NativeGoogle.signIn();
    } catch (_) {
      result = {'error': 'Gagal masuk dengan Google. Coba lagi.'};
    }
    await _controller.runJavaScript(
      'window.rakkuNativeAuth && window.rakkuNativeAuth(${jsonEncode(result)});',
    );
  }

  Map<String, dynamic>? _decodeRequest(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> _setFullscreen(bool on) async {
    if (_fullscreen == on) return;
    if (mounted) setState(() => _fullscreen = on);
    if (on) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  Future<void> _exitFullscreenFromBack() async {
    await _setFullscreen(false);
    await _controller.runJavaScript(
      'window.rakkuNativeExitFullscreen && window.rakkuNativeExitFullscreen();',
    );
  }

  @override
  void dispose() {
    if (_fullscreen) {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  void _setFailed(bool value) {
    if (mounted && _failed != value) {
      setState(() => _failed = value);
    }
  }

  Future<void> _retry() async {
    _setFailed(false);
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_fullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _exitFullscreenFromBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppOverlayStyle,
      child: Scaffold(
        backgroundColor: kAppBackground,
        body: SafeArea(
          top: true,
          bottom: true,
          child: ColoredBox(
            color: kAppBackground,
            child: _failed
                ? OfflineScreen(
                    title: 'Server belum bisa diakses',
                    message: 'Coba lagi beberapa saat lagi.',
                    icon: Icons.cloud_off_rounded,
                    onRetry: _retry,
                  )
                : WebViewWidget(controller: _controller),
          ),
        ),
      ),
      ),
    );
  }
}
