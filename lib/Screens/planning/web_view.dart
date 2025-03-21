// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class WebViewExample extends StatefulWidget {
//   const WebViewExample(
//       {Key? key,
//         required this.userId,
//         required this.controllerId});
//   final userId, controllerId;
//
//   @override
//   State<WebViewExample> createState() => _WebViewExampleState();
// }
//
// class _WebViewExampleState extends State<WebViewExample> {
//   late final WebViewController controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//     print("widget.controllerId === ${widget.controllerId}");
//
//
//     // Initialize controllers
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             // Handle progress
//           },
//           onPageStarted: (String url) {
//             // Handle page start
//           },
//           onPageFinished: (String url) {
//             // Handle page finished
//           },
//           onHttpError: (HttpResponseError error) {
//             // Handle HTTP errors
//           },
//           onWebResourceError: (WebResourceError error) {
//             // Handle Web resource errors
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             if (request.url.startsWith( (widget.controllerId == 300) ?
//                 'https://www.ecowitt.net/home/share?authorize=T9TPX8&device_id=aU01eTh1OTdQaEpsRGs4MjRudTBQdz09' : 'https://www.weatherandradar.in/' )) {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // HTML content that includes your iframe
//     String iframeUrl = ( widget.controllerId == 300)
//         ? "https://www.ecowitt.net/home/share?authorize=T9TPX8"
//         : "https://www.weatherandradar.in/";
//
//
//     String htmlContent = '''
//       <!DOCTYPE html>
//       <html lang="en">
//       <head>
//         <meta charset="UTF-8">
//         <meta name="viewport" content="width=device-width, initial-scale=1.0">
//         <title>Weather Widget</title>
//       </head>
//       <body>
//        <iframe src="$iframeUrl" name="CW2" scrolling="yes" width=${MediaQuery.of(context).size.width} height="${MediaQuery.of(context).size.height}" frameborder="0" style="border: 1px solid #10658E;border-radius: 8px"></iframe>
//       </body>
//       </html>
//     ''';
//
//     // Load the HTML content into the WebView
//     controller.loadRequest(Uri.dataFromString(htmlContent,
//         mimeType: 'text/html', encoding: Encoding.getByName('utf-8')));
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('External Weathers')),
//       // body: WebViewWidget(controller: controller),
//       body: Column(
//         children: [
//           Expanded(
//             child: Container(
//               height: MediaQuery.of(context).size.height,
//               child: WebViewWidget(
//                 controller: controller,
//               ),
//             ),
//           ),
//           // Container(
//           //   height: 300,
//           //   child: WebViewWidget(
//           //     controller: controller1,
//           //   ),
//           // ),
//         ],
//       ),
//     );
//
//   }
// @override
//   void dispose() {
//     // TODO: implement dispose
//   controller.clearCache();
//
//     super.dispose();
//
//   }
//
// }
