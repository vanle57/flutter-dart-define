import 'package:flutter/material.dart';

class EnvironmentConfig {
  static const APP_NAME =
      String.fromEnvironment('APP_NAME', defaultValue: 'awesomeApp');
  static const APP_SUFFIX = String.fromEnvironment('APP_SUFFIX');
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage('DEMO DART DEFINE'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'You defined ENV variables like',
              style: Theme.of(context).textTheme.headline5,
            ),
            Text(
              'APP_NAME: ${EnvironmentConfig.APP_NAME}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              'APP_SUFFIX: ${EnvironmentConfig.APP_SUFFIX}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
