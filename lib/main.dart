// pubspec.yaml remains the same as before

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robinhood OAuth Logger',
      theme: ThemeData(
        primarySwatch: Colors.green,  // Robinhood theme
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  WebViewController? _controller;
  bool _showWebView = false;
  String? _capturedToken;

  @override
  void initState() {
    super.initState();
    _setupWebViewController();
  }

  void _setupWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            _injectTokenCaptureScript();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Capture token from navigation to token endpoint
            if (request.url.contains('oauth2/token')) {
              print('OAuth request detected: ${request.url}');
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'TokenChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            _capturedToken = message.message;
          });
          print('Token captured: ${message.message}');
        },
      );
  }

  void _injectTokenCaptureScript() {
    const String script = '''
      (function() {
        // Intercept XHR requests
        var originalXHR = window.XMLHttpRequest;
        window.XMLHttpRequest = function() {
          var xhr = new originalXHR();
          var originalOpen = xhr.open;
          var originalSend = xhr.send;
          
          xhr.open = function() {
            this.addEventListener('load', function() {
              if (this.responseURL.includes('oauth2/token')) {
                try {
                  var response = JSON.parse(this.responseText);
                  if (response.access_token) {
                    TokenChannel.postMessage(JSON.stringify({
                      access_token: response.access_token,
                      expires_in: response.expires_in,
                      token_type: response.token_type,
                      timestamp: new Date().toISOString()
                    }));
                  }
                } catch(e) {
                  console.error('Error parsing token response:', e);
                }
              }
            });
            originalOpen.apply(this, arguments);
          };
          
          xhr.send = function() {
            originalSend.apply(this, arguments);
          };
          
          return xhr;
        };

        // Intercept Fetch requests
        var originalFetch = window.fetch;
        window.fetch = function() {
          return originalFetch.apply(this, arguments).then(async response => {
            if (response.url.includes('oauth2/token')) {
              try {
                const clone = response.clone();
                const data = await clone.json();
                if (data.access_token) {
                  TokenChannel.postMessage(JSON.stringify({
                    access_token: data.access_token,
                    expires_in: data.expires_in,
                    token_type: data.token_type,
                    timestamp: new Date().toISOString()
                  }));
                }
              } catch(e) {
                console.error('Error intercepting fetch response:', e);
              }
            }
            return response;
          });
        };
      })();
    ''';

    _controller?.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Robinhood OAuth Logger'),
      ),
      body: Column(
        children: [
          if (_capturedToken != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Token Captured: ${_capturedToken!.substring(0, 20)}...'),
                ),
              ),
            ),
          Expanded(
            child: _showWebView
                ? WebViewWidget(controller: _controller!)
                : Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showWebView = true;
                        });
                        _controller?.loadRequest(
                          Uri.parse('https://robinhood.com/login'),
                        );
                      },
                      child: const Text('Login to Robinhood'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}