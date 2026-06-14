import 'package:flutter/material.dart';

Future<String?> showPasswordDialog(
  BuildContext context, {
  String? errorMessage,
}) {
  final passwordController = TextEditingController();
  bool obscureText = true;

  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.security, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text('Administrator Access'),
              ],
            ),
            content: SizedBox(
              width: 350,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restructed needs permission to securely modify your /etc/hosts file to enable blocking.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your password is only held in memory during this session and is never saved to disk.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: passwordController,
                    obscureText: obscureText,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Mac Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => obscureText = !obscureText),
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) Navigator.of(context).pop(val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final pwd = passwordController.text;
                  if (pwd.isNotEmpty) {
                    Navigator.of(context).pop(pwd);
                  }
                },
                child: const Text('Authorize'),
              ),
            ],
          );
        },
      );
    },
  );
}
