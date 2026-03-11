import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:logger/logger.dart';

final logger = Logger(printer: PrettyPrinter());

class JsonViewScreen extends StatelessWidget {
  final String jsonString;

  const JsonViewScreen({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JSON Viewer"),
        // backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Copy formatted JSON
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: "Copy Formatted JSON",
            onPressed: () async {
              try {
                // Pretty print JSON
                final jsonObj = jsonDecode(jsonString);
                final prettyJson = const JsonEncoder.withIndent('  ').convert(jsonObj);
                
                await Clipboard.setData(ClipboardData(text: prettyJson));
                
                logger.i('📋 Formatted JSON copied to clipboard (${prettyJson.length} chars)');

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("✅ Formatted JSON copied to clipboard!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                logger.e('❌ Failed to copy formatted JSON: $e');
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("❌ Error: $e"),
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // Copy compact JSON
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: "Copy Compact JSON",
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: jsonString));
              
              logger.i('📋 Compact JSON copied to clipboard (${jsonString.length} chars)');

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("✅ Compact JSON copied to clipboard!"),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: JsonView.string(
            jsonString,
            theme: const JsonViewTheme(viewType: JsonViewType.collapsible,backgroundColor: Color.fromARGB(255, 17, 17, 17)),
            
          ),
        ),
      ),
      );
  }
}
