import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MLKit Text Translation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();
  String result = "Translated text...";
  late OnDeviceTranslator onDeviceTranslator;
  final TranslateLanguage sourceLanguage = TranslateLanguage.english;
  final TranslateLanguage targetLanguage = TranslateLanguage.turkish;
  late ModelManager modelManager;
  late LanguageIdentifier languageIdentifier;
  bool isSourceDownloaded = false;
  bool isTargetDownloaded = false;

  @override
  void initState() {
    super.initState();
    modelManager = OnDeviceTranslatorModelManager();
    languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    check_download_model();
  }

  check_download_model() async {
    print("Model checking.");

    isSourceDownloaded = await modelManager.isModelDownloaded(sourceLanguage.bcpCode);
    isTargetDownloaded = await modelManager.isModelDownloaded(targetLanguage.bcpCode);

    if (!isSourceDownloaded) {
      isSourceDownloaded = await modelManager.isModelDownloaded(sourceLanguage.bcpCode);
    }

    if (!isTargetDownloaded) {
      isTargetDownloaded = await modelManager.isModelDownloaded(targetLanguage.bcpCode);
    }

    if (isSourceDownloaded && isTargetDownloaded) {
      onDeviceTranslator = OnDeviceTranslator(sourceLanguage: sourceLanguage, targetLanguage: targetLanguage);
    }

    print("check finished.");
  }

  translate_text(String text) async {
    result = "";
    if (isSourceDownloaded && isTargetDownloaded) {
      result = await onDeviceTranslator.translateText(text);
      setState(() {
        result;
      });
    } else {
      check_download_model();
    }

    final String input = await languageIdentifier.identifyLanguage(text);
    print(input);
    textEditingController.text = "(${input}) ${textEditingController.text}";

    final String output = await languageIdentifier.identifyLanguage(result);
    result = "(${output}) ${result}";
    print(output);
    setState(() {
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  left: 2,
                  right: 2,
                ),
                width: double.infinity,
                height: 100,
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: textEditingController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: "Type text here...",
                          filled: true,
                          border: InputBorder.none,
                        ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      maxLines: 100,
                    ),
                  ),
                ),
              ),
            Container(
              margin: EdgeInsets.only(
                top: 5,
                left: 13,
                right: 13,
              ),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  primary: Colors.green,
                ),
                child: Text("Translate"),
                onPressed: () {
                  translate_text(textEditingController.text);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 5,
                left: 2,
                right: 2,
              ),
              width: double.infinity,
              height: 100,
              child: Card(
                color: Colors.white,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "$result",
                    style: TextStyle(
                      fontSize: 18,
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
