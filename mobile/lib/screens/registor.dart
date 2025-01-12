import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatelessWidget {
  Register({super.key});

  final GlobalKey<FormState> _registerKey = GlobalKey<FormState>();
  final TextEditingController parentName = TextEditingController();
  final TextEditingController parentEmail = TextEditingController();
  final TextEditingController parentPhone = TextEditingController();
  final TextEditingController parentAddress = TextEditingController();
  final TextEditingController parentDob = TextEditingController();
  final TextEditingController parentGender = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _registerKey,
            child: Column(
              children: [
                TextFormField(
                  controller: parentName,
                  decoration: InputDecoration(labelText: "Parent name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the name";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: parentPhone,
                  decoration: InputDecoration(labelText: "phone number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the number";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: parentEmail,
                  decoration: InputDecoration(labelText: "Email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the email";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: parentAddress,
                  decoration: InputDecoration(labelText: "Adress"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the adress";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: parentDob,
                  decoration: InputDecoration(labelText: "DOB"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the DOB";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: parentGender,
                  decoration: InputDecoration(labelText: "Gender"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter the gender";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: username,
                  decoration: InputDecoration(labelText: "username"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please enter your username";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: password,
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
                    if (_registerKey.currentState!.validate()) {
                      try {
                        final sh = await SharedPreferences.getInstance();
                        String name = parentName.text.toString();
                        String phn_num = parentPhone.text.toString();
                        String email = parentEmail.text.toString();
                        String addres = parentAddress.text.toString();
                        String DOB = parentDob.text.toString();
                        String gender = parentGender.text.toString();
                        String uname = username.text.toString();
                        String psw = password.text.toString();

                        String url = sh.getString("url").toString();

                        var data = await http.post(
                          Uri.parse(url + "and_registor"),
                          body: {
                            "name": name,
                            "phone_number": phn_num,
                            "email": email,
                            "addres": addres,
                            "dob": DOB,
                            "gender": gender,
                            "username": uname,
                            "password": psw,
                          },
                        );

                        print(data.body);

                        var jasonData = json.decode(data.body);
                      } catch (e) {
                        print("Error : " + e.toString());
                      }
                    } else {
                      print("form is invalid");
                    }
                  },
                  child: Text("Register"),
                ),
                ElevatedButton(onPressed: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => login()));
                }, child: Text('Login'))
              ],
            )),
      ),
    );
  }
}
