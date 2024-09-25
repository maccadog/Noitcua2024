import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:start/firebase_options.dart';
import 'app.dart';

// TODO(codelab user): Get API key
const clientId = '450739637054-vum9d6j4asbb96ln9beva047det5l9li.apps.googleusercontent.com';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );


 runApp(const MyApp());
}





