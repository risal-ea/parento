import 'package:flutter/material.dart';
import 'dart:convert';

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
                validator: (value){
                  if(value==null || value.isEmpty){
                    return "please enter your username";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "password"),
                validator: (value){
                  if(value==null || value.isEmpty){
                    return "please enter the password";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0,),
              ElevatedButton(onPressed: (){
                if(_formkey.currentState!.validate()){
                  print("form is validated");
                }else{
                  print("form is invalid");
                }
              }, child: Text("Login"))
            ],
          )
      ),

      ),
    );
  }
}
