// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// enum Environment { development, production, testing }
//
// class GlobalConfig {
//   static late Environment environment;
//
//   static void setEnvironment(Environment env) {
//     environment = env;
//   }
//
//   static T getService<T>() {
//     switch (environment) {
//       case Environment.development:
//         return _developmentServices[T] as T;
//       case Environment.production:
//         return _productionServices[T] as T;
//       case Environment.testing:
//         return _testingServices[T] as T;
//     }
//   }
//
//   static final Map<Type, dynamic> _developmentServices = {
//     Logger: ConsoleLogger(),
//   };
//
//   static final Map<Type, dynamic> _productionServices = {
//     Logger: RemoteLogger(),
//   };
//
//   static final Map<Type, dynamic> _testingServices = {
//     Logger: ConsoleLogger(),
//   };
// }
//
// abstract class Logger {
//   void log(String message);
// }
//
// class ConsoleLogger implements Logger {
//   @override
//   void log(String message) {
//     print("Development Log: $message");
//   }
// }
//
// class RemoteLogger implements Logger {
//   @override
//   void log(String message) {
//     print("Sending to server: $message");
//   }
// }
//
// class LoggingWidget extends StatelessWidget {
//   const LoggingWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final logger = Provider.of<Logger>(context);
//
//     logger.log("Widget built!");
//     return Text("Check logs for details");
//   }
// }
