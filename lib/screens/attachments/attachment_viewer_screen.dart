import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AttachmentViewerScreen extends StatelessWidget {
  final String fileName;
  final String fileUrl;
  final String fileType;

  const AttachmentViewerScreen({
    super.key,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: fileType == 'image'
          ? InteractiveViewer(
              child: Image.network(fileUrl),
            )
          : WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(fileUrl)),
            ),
    );
  }
}
