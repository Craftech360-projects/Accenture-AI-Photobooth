import 'dart:typed_data';
import 'package:flutter/material.dart';

class UserSelectionModel extends ChangeNotifier {
  String? _gender;
  String? _category;
  String? _theme;
  String? _selectedBackground;
  String? _uniqueId;
  Uint8List? _capturedImage;
  String? _processedImageUrl;
  String? _characterImageUrl;
  String? _userName;
  String? _userEmail;
  bool _isProcessing = false;

  // Getters
  String? get gender => _gender;
  String? get category => _category;
  String? get theme => _theme;
  String? get selectedBackground => _selectedBackground;
  String? get uniqueId => _uniqueId;
  Uint8List? get capturedImage => _capturedImage;
  String? get processedImageUrl => _processedImageUrl;
  String? get characterImageUrl => _characterImageUrl;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isProcessing => _isProcessing;

  // Setters with notification
  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void setTheme(String theme) {
    _theme = theme;
    notifyListeners();
  }

  void setSelectedBackground(String background) {
    _selectedBackground = background;
    notifyListeners();
  }

  void setUniqueId(String uniqueId) {
    _uniqueId = uniqueId;
    notifyListeners();
  }

  void setCapturedImage(Uint8List imageBytes) {
    _capturedImage = imageBytes;
    notifyListeners();
  }

  void setProcessedImageUrl(String url) {
    _processedImageUrl = url;
    notifyListeners();
  }

  void setCharacterImageUrl(String url) {
    _characterImageUrl = url;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setUserEmail(String email) {
    _userEmail = email;
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  // Reset all data
  void reset() {
    _gender = null;
    _category = null;
    _theme = null;
    _selectedBackground = null;
    _uniqueId = null;
    _capturedImage = null;
    _processedImageUrl = null;
    _characterImageUrl = null;
    _userName = null;
    _userEmail = null;
    _isProcessing = false;
    notifyListeners();
  }

  // Helper methods
  bool get isAiTransformation => _category == 'ai_transformation';
  bool get isBgRemoval => _category == 'bg_removal';
  bool get isMale => _gender == 'male';
  bool get isFemale => _gender == 'female';
  bool get hasImage => _capturedImage != null;
  bool get hasProcessedImage => _processedImageUrl != null;
}