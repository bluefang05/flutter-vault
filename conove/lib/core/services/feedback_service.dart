import 'package:flutter/services.dart';
import 'storage_service.dart';

class FeedbackService {
  static void lightClick() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.selectionClick();
    }
  }

  static void success() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.mediumImpact();
    }
  }

  static void error() {
    if (StorageService.getHapticsEnabled()) {
      HapticFeedback.heavyImpact();
    }
  }
}
