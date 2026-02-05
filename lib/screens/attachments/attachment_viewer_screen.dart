// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class AttachmentViewerScreen extends StatelessWidget {
//   final String url;
//   final String type;

//   const AttachmentViewerScreen({
//     super.key,
//     required this.url,
//     required this.type,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (type == 'image') {
//       return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: Image.network(url),
//         ),
//       );
//     }

//     // PDF / DOC
//     return Scaffold(
//       appBar: AppBar(),
//       body: WebViewWidget(
//         controller: WebViewController()
//           ..setJavaScriptMode(JavaScriptMode.unrestricted)
//           ..loadRequest(Uri.parse(url)),
//       ),
//     );
//   }
// }
