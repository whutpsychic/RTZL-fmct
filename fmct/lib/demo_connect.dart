import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  InAppWebViewSettings settings = InAppWebViewSettings();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(title: Text("Web Message Channels")),
          body: SafeArea(
              child: Column(children: <Widget>[
            Expanded(
              child: InAppWebView(
                initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebMessageChannel Test</title>
</head>
<body>
    <!-- when you click this button, it will send a message to the Dart side -->
    <button id="button" onclick="port.postMessage(input.value);" />Send</button>
    <br />
    <input id="input" type="text" value="JavaScript To Native" />

    <script>
      // variable that will represents the port used to communicate with the Dart side
      var port;
      // listen for messages
      window.addEventListener('message', function(event) {
          if (event.data == 'capturePort') {
              // capture port2 coming from the Dart side
              if (event.ports[0] != null) {
                  // the port is ready for communication,
                  // so you can use port.postMessage(message); wherever you want
                  port = event.ports[0];
                  // To listen to messages coming from the Dart side, set the onmessage event listener
                  port.onmessage = function (event) {
                      // event.data contains the message data coming from the Dart side
                      console.log(event.data);
                  };
              }
          }
      }, false);
    </script>
</body>
</html>
"""),
                initialSettings: settings,
                onConsoleMessage: (controller, consoleMessage) {
                  print(
                      "Message coming from the Dart side: ${consoleMessage.message}");
                },
                onLoadStop: (controller, url) async {
                  if (defaultTargetPlatform != TargetPlatform.android ||
                      await WebViewFeature.isFeatureSupported(
                          WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL)) {
                    // wait until the page is loaded, and then create the Web Message Channel
                    var webMessageChannel =
                        await controller.createWebMessageChannel();
                    var port1 = webMessageChannel!.port1;
                    var port2 = webMessageChannel.port2;

                    // set the web message callback for the port1
                    await port1.setWebMessageCallback((message) async {
                      print(
                          "Message coming from the JavaScript side: $message");
                      // when it receives a message from the JavaScript side, respond back with another message.
                      await port1
                          .postMessage(WebMessage(data: "$message and back"));
                    });

                    // transfer port2 to the webpage to initialize the communication
                    await controller.postWebMessage(
                        message:
                            WebMessage(data: "capturePort", ports: [port2]),
                        targetOrigin: WebUri("*"));
                  }
                },
              ),
            ),
          ]))),
    );
  }
}
