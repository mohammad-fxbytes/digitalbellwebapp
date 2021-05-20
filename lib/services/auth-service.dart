import 'dart:convert';

import 'package:http/http.dart';

Future<Response> login(String mobile, String password) async {
  var payload = {"mobile": mobile, "password": password};
  print(payload);
  Response response = await post(
    Uri.tryParse("https://hbmsapi.rxhealth.in/api/admin_login")!,
    headers: {"Content-Type": 'application/json'},
    body: json.encode(payload),
  );
  return response;

  // We should always use try catch exception block here. I am skipping for now
}
