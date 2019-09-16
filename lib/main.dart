import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './myhomepage.dart';

Future main() async {
	await DotEnv().load('.env');
	runApp(MyApp());
}

class MyApp extends StatefulWidget {
	@override
	_MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			theme: ThemeData(
				primaryColor: Colors.indigo
			),
			home: MyHomePage(),
		);
	}
}