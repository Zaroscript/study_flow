import 'package:flutter/material.dart';

Future<void> deleteWithUndo(
  BuildContext context, {
  required Future<void> Function() onDelete,
  required Future<void> Function() onUndo,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await onDelete();
    if (!context.mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('تم الحذف'),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () async {
            try {
              await onUndo();
            } catch (_) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('تعذّرت الاستعادة. حاول مرة أخرى.'),
                ),
              );
            }
          },
        ),
      ),
    );
  } catch (_) {
    if (context.mounted)
      messenger.showSnackBar(
        const SnackBar(content: Text('تعذّر الحذف. حاول مرة أخرى.')),
      );
  }
}
