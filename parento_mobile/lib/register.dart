import 'package:flutter/material.dart';

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
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter the name";
                      }return null;
                    },
                  ),

                  TextFormField(
                    controller: parentPhone,
                    decoration: InputDecoration(labelText: "phone number"),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter the number";
                      }return null;
                    },
                  ),

                  TextFormField(
                    controller: parentEmail,
                    decoration: InputDecoration(labelText: "Email"),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter the email";
                      }return null;
                    },
                  ),

                  TextFormField(
                    controller: parentAddress,
                    decoration: InputDecoration(labelText: "Adress"),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter the adress";
                      }return null;
                    },
                  ),

                  TextFormField(
                    controller: parentDob,
                    decoration: InputDecoration(labelText: "DOB"),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter the DOB";
                      }return null;
                    },
                  ),

                  TextFormField(
                    controller: parentGender,
                    decoration: InputDecoration(labelText: "Gender"),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter the gender";
                      }return null;
                    },
                  ),

                  TextFormField(
                    controller: username,
                    decoration: InputDecoration(labelText: "username"),
                    validator: (value){
                      if(value==null || value.isEmpty){
                        return "please enter your username";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: password,
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
                    if(_registerKey.currentState!.validate()){
                      print("form is validated");
                    }else{
                      print("form is invalid");
                    }
                  }, child: Text("Register"))
                ],
              )),
      ),
    );
  }
}
