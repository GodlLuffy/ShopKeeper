import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final apiKey = 'AIzaSyC5zwfYC7gNZDCUdyJ11qHWEgeYEgU-Ge8'; // From firebase_options.dart
  final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
  
  print('Enter your exact ShopKeeper registered Email:');
  final email = stdin.readLineSync()?.trim();
  
  print('Enter your Password:');
  final password = stdin.readLineSync()?.trim();
  
  if (email == null || password == null || email.isEmpty || password.isEmpty) {
    print('Email and Password cannot be empty.');
    return;
  }
  
  print('\nTesting Google Firebase Login directly via REST API...');
  
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    
    if (response.statusCode == 200) {
      print('\n✅ SUCCESS: Status 200');
      print('Your Email & Password are fully working on the Google backend!');
    } else {
      print('\n❌ FAILED: Status ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('This means the Email/Password combination is still incorrect on the Google backend.');
    }
  } catch (e) {
    print('Network Error: $e');
  }
}
