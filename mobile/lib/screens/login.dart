import 'package:flutter/material.dart';
import 'package:mobile/screens/home.dart';
import 'package:mobile/screens/registor.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class login extends StatelessWidget {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final TextEditingController usernameContoller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameContoller,
                decoration: InputDecoration(labelText: "username"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please enter your username";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "password"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please enter the password";
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formkey.currentState!.validate()) {
                    try {
                      final sh = await SharedPreferences.getInstance();
                      String username = usernameContoller.text.toString();
                      String password = passwordController.text.toString();
                      String url = sh.getString("url").toString();

                      var data = await http.post(
                        Uri.parse(url + "and_login"),
                        body: {
                          "username": username,
                          "password": password,
                        },
                      );

                      var jasonData = json.decode(data.body);
                      String status = jasonData['status'].toString();

                      if (status == 'success') {
                        String login_id = jasonData['login_id'].toString();
                        print(login_id);
                        sh.setString("login_id", login_id);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Home()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Invalid username or password'),
                          duration: Duration(seconds: 3),
                        ));
                      }
                    } catch (e) {
                      print("Error : " + e.toString());
                    }
                  } else {
                    print("form is invalid");
                  }
                },
                child: Text("Login"),
              ),
              ElevatedButton(onPressed: (){
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Register()));
              }, child: Text("Sing up"))
            ],
          ),
        ),
      ),
    );
  }
}
