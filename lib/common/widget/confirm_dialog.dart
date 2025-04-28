import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirm,
    this.cancel,
    this.textAlign = TextAlign.center,
    this.contentColor = Colors.grey,
  });

  final String title;
  final String content;
  final Function confirm;
  final Function? cancel;
  final TextAlign textAlign;
  final Color contentColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // 圆角大一点
          elevation: 10, // 添加阴影悬浮感
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: 15,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                          if (cancel != null) cancel!();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("No"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          confirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Yes"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}