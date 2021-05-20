import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hbms_flutter/models/m-user.dart';
import 'package:hbms_flutter/screens/dashboard.dart';
import 'package:hbms_flutter/services/auth-service.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _checked = false;
  bool notChecked = false;
  TextEditingController mobileTextCtrl = TextEditingController();
  TextEditingController passwordTextCtrl = TextEditingController();

  Future<void> callLoginAPI() async {
    var res = await login(mobileTextCtrl.text, passwordTextCtrl.text);
    print(res.body);
    if (res.statusCode == 200) {
      var result = userFromJson(res.body);
      if (result.status == 200) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        // getting something else in status from backend
      }
    } else {
      // something went wrong on either side
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                // I am going to use background image here
                image: DecorationImage(image: AssetImage('assets/images/login-bg.png'), fit: BoxFit.fitHeight),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    //here code starts
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(
                                height: 90,
                                child: Center(
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "Mobile No.",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: mobileTextCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Mobile No.',
                                  labelStyle: TextStyle(color: Colors.blue),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.4),
                                  contentPadding: EdgeInsets.all(8),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) return 'Mobile number is required';
                                  return null;
                                },
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  "Password",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: passwordTextCtrl,
                                obscureText: true,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  labelStyle: TextStyle(color: Colors.blue),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.4),
                                  contentPadding: EdgeInsets.all(8),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) return 'Password is required';
                                  return null;
                                },
                              ),
                              SizedBox(height: 20),
                              CheckboxListTile(
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: RichText(
                                    text: TextSpan(
                                      text: 'I have read and accepted ',
                                      style: TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: 'Terms and conditions',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value: _checked,
                                  onChanged: (value) {
                                    setState(() {
                                      _checked = value as bool;
                                    });
                                  }),
                              if (notChecked)
                                Text(
                                  "Please read and accept terms and conditions",
                                  style: TextStyle(color: Colors.red),
                                ),
                              Center(
                                child: RaisedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                      // Validation success

                                      callLoginAPI();
                                    } else {
                                      setState(() {
                                        notChecked = true;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "Login",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
