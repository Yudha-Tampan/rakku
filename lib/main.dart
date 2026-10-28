import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rakku/app_chrome.dart';
import 'package:rakku/core/endpoint.dart';
import 'package:rakku/core/url_cipher.dart';
import 'package:rakku/screens/offline_screen.dart';
import 'package:rakku/screens/web_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(kAppOverlayStyle);
  runApp(const RakkuApp());
}

class RakkuApp extends StatelessWidget {
  const RakkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rakku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: kAppAccent,
        scaffoldBackgroundColor: kAppBackground,
        canvasColor: kAppBackground,
        useMaterial3: true,
      ),
      home: const ConnectionGate(),
    );
  }
}

class ConnectionGate extends StatefulWidget {
  const ConnectionGate({super.key});

  @override
  State<ConnectionGate> createState() => _ConnectionGateState();
}

class _ConnectionGateState extends State<ConnectionGate> {
  final Connectivity _connectivity = Connectivity();
  final String _endpoint = UrlCipher.reveal(sealedEndpoint);
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _connectivity.checkConnectivity().then(_applyResults);
    _subscription = _connectivity.onConnectivityChanged.listen(_applyResults);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _applyResults(List<ConnectivityResult> results) {
    final online = results.any((result) => result != ConnectivityResult.none);
    if (online != _online && mounted) {
      setState(() => _online = online);
    }
  }

  Future<void> _retry() async {
    final results = await _connectivity.checkConnectivity();
    _applyResults(results);
  }

  @override
  Widget build(BuildContext context) {
    if (_online) {
      return WebScreen(url: _endpoint);
    }
    return OfflineScreen(
      title: 'Lagi offline',
      message: 'Cek koneksi lu, terus coba lagi.',
      icon: Icons.wifi_off_rounded,
      onRetry: _retry,
    );
  }
}
