import 'package:flutter/material.dart';

class StrictModeDialog extends StatefulWidget {
  const StrictModeDialog({super.key});

  @override
  State<StrictModeDialog> createState() => StrictModeDialogState();
}

class StrictModeDialogState extends State<StrictModeDialog> {
  final TextEditingController controller = TextEditingController();
  final String targetText =
      'I acknowledge that I am breaking my commitment to focus. Disabling this block will enable distractions and reduce my productivity. I am choosing to proceed anyway.';
  bool isMatched = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(checkMatch);
  }

  void checkMatch() {
    setState(() {
      isMatched = controller.text == targetText;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Strict Mode Active'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This rule is protected by Strict Mode. To disable or delete it, you must type the following paragraph exactly as shown:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                targetText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type the paragraph here...',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isMatched
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              // Prevent pasting to enforce typing
              contextMenuBuilder: (context, editableTextState) {
                final List<ContextMenuButtonItem> buttonItems =
                    editableTextState.contextMenuButtonItems;
                buttonItems.removeWhere((ContextMenuButtonItem buttonItem) {
                  return buttonItem.type == ContextMenuButtonType.paste;
                });
                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: buttonItems,
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isMatched ? () => Navigator.of(context).pop(true) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Unlock'),
        ),
      ],
    );
  }
}
