import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

import '../../env/env.dart';

Map<String, String> headersForAuth() {
  var unixTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  String newUnixTime = unixTime.toString();
  // Insert your Podcastindex.org API credentials here.
  // Available for free with registration at https://api.podcastindex.org/signup
  var apiKey = Env.apiKey;
  var apiSecret = Env.apiSecret;
  var firstChunk = utf8.encode(apiKey);
  var secondChunk = utf8.encode(apiSecret);
  var thirdChunk = utf8.encode(newUnixTime);

  var output = AccumulatorSink<Digest>();
  var input = sha1.startChunkedConversion(output);
  input.add(firstChunk);
  input.add(secondChunk);
  input.add(thirdChunk);
  input.close();
  var digest = output.events.single;

  Map<String, String> headers = {
    "X-Auth-Date": newUnixTime,
    "X-Auth-Key": apiKey,
    "Authorization": digest.toString(),
    "User-Agent": "SomethingAwesome/1.0.1"
  };

  return headers;
}