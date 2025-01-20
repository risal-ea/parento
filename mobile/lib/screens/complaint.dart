import 'package:flutter/material.dart';

class Complaint extends StatelessWidget {
  Complaint({super.key});

  final GlobalKey<FormState> complaintKey = GlobalKey<FormState>();
  final TextEditingController complaint = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Complaint"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(child: Column(
            children: [
              TextFormField(
                controller: complaint,
                decoration: InputDecoration(labelText: "Complaint"),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return "please enter you compliant";
                  }else{
                    return null;
                  }
                },
              ),
              SizedBox(height: 16.0,),
              ElevatedButton(onPressed: (){}, child: Text("Submit"))
            ],
          ),),
        ),
      ),
    );
  }
}
