import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_telegram/http.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

Future<void> main() async {
  // Ensure your app binds to the correct port, especially when deployed to services like Heroku
  int port = int.parse(Platform.environment['PORT'] ?? '8080');
  var server = await HttpServer.bind(InternetAddress.anyIPv4, port);
  log('Server running on port $port');

  // Bot token for the Telegram bot (replace with a more secure way in production)
  var BOT_TOKEN = '7415144478:AAEOHwSrJ7q60XC0XjP59lsmFT9WECtZ26I';
  print('Initializing bot with token: $BOT_TOKEN');

  // Retrieve the bot username from the Telegram API
  final username = (await Telegram(BOT_TOKEN).getMe()).username;
  print('Retrieved bot username: $username');

  // Initialize the TeleDart bot with the retrieved username
  var teledart = TeleDart(BOT_TOKEN, Event(username!));
  print('Bot started with username: $username');

  // Start listening for messages containing the keyword 'Fight for freedom'
  teledart.start();
  print('Listening for messages...');

  // Periodically send gas prices
  Timer.periodic(Duration(minutes: 1), (timer) {
    print('Fetching gas prices...');
    GasOracle.getGasPrices().then((value) {
      print('Gas prices fetched successfully: $value');
      teledart.sendMessage(
        "@gastestp",
        '🛴Safe: ${value['low']}\n🚗Proposed: ${value['average']}\n🏎Fast: ${value['high']}',
      );
      print('Gas prices message sent to @gastestp');
    }, onError: (e) {
      print("Error fetching gas prices: ${e.toString()}");
    });
  });

  // Keep the server running and log incoming requests
  await for (HttpRequest request in server) {
    print('Received a request: ${request.uri}');
    request.response
      ..write('Telegram Bot is running')
      ..close();
    print('Response sent to the client.');
  }
}
