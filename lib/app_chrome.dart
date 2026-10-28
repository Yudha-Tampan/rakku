import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

const Color kAppBackground = Color(0xFF0B0C10);
const Color kAppBackgroundElevated = Color(0xFF1A1425);
const Color kAppAccent = Color(0xFF6EC1FF);
const Color kAppPurple = Color(0xFF8B5CF6);
const Color kAppTextSecondary = Color(0xFFB0A8C8);

const SystemUiOverlayStyle kAppOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: kAppBackground,
  systemNavigationBarDividerColor: kAppBackground,
  systemNavigationBarIconBrightness: Brightness.light,
);
