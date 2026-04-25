import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcutsService {
  static final KeyboardShortcutsService _instance =
      KeyboardShortcutsService._internal();
  factory KeyboardShortcutsService() => _instance;
  KeyboardShortcutsService._internal();

  // Shortcut definitions
  static const focusSearch = SingleActivator(LogicalKeyboardKey.f1);
  static const openPayment = SingleActivator(LogicalKeyboardKey.f2);
  static const globalSearch = SingleActivator(LogicalKeyboardKey.f3);
  static const quickCashSale = SingleActivator(LogicalKeyboardKey.f12);
  static const clearClose = SingleActivator(LogicalKeyboardKey.escape);

  // Callback storage
  VoidCallback? onFocusSearch;
  VoidCallback? onOpenPayment;
  VoidCallback? onGlobalSearch;
  VoidCallback? onQuickCashSale;
  VoidCallback? onClearClose;

  void registerCallbacks({
    VoidCallback? onFocusSearch,
    VoidCallback? onOpenPayment,
    VoidCallback? onGlobalSearch,
    VoidCallback? onQuickCashSale,
    VoidCallback? onClearClose,
  }) {
    this.onFocusSearch = onFocusSearch;
    this.onOpenPayment = onOpenPayment;
    this.onGlobalSearch = onGlobalSearch;
    this.onQuickCashSale = onQuickCashSale;
    this.onClearClose = onClearClose;
  }

  void unregisterCallbacks() {
    onFocusSearch = null;
    onOpenPayment = null;
    onGlobalSearch = null;
    onQuickCashSale = null;
    onClearClose = null;
  }

  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final logicalKey = event.logicalKey;

    // F1: Focus search
    if (logicalKey == LogicalKeyboardKey.f1) {
      onFocusSearch?.call();
      return KeyEventResult.handled;
    }

    // F2: Open payment dialog
    if (logicalKey == LogicalKeyboardKey.f2) {
      onOpenPayment?.call();
      return KeyEventResult.handled;
    }

    // F3: Global quick search
    if (logicalKey == LogicalKeyboardKey.f3) {
      onGlobalSearch?.call();
      return KeyEventResult.handled;
    }

    // F12: Quick cash sale
    if (logicalKey == LogicalKeyboardKey.f12) {
      onQuickCashSale?.call();
      return KeyEventResult.handled;
    }

    // ESC: Clear/close
    if (logicalKey == LogicalKeyboardKey.escape) {
      onClearClose?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }
}
