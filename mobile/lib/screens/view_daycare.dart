import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Daycare extends StatefulWidget {
  const Daycare({super.key});

  @override
  State<Daycare> createState() => _DaycareState();
}

class _DaycareState extends State<Daycare> {
  List<String> daycare_name = <String>[];
  List<String> did = <String>[];

  List<String> owner_name = <String>[];
  List<String> phone = <String>[];
  List<String> adress = <String>[];
  List<String> license_number = <String>[];
  List<String> capacity = <String>[];
  List<String> operating_time = <String>[];
  List<String> daycare_discription = <String>[];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final sh = await SharedPreferences.getInstance();
      String login_id = sh.getString('login_id') ?? '';
      String ip = sh.getString('url') ?? '';
      String url = ip + 'view_daycare';

      var data = await http.post(
        Uri.parse(url),
        body: {'lid': login_id},
      );

      var jasonData = json.decode(data.body);
      String status = jasonData['status'];
      if (status == 'success') {
        var arr = jasonData['data'];

        for (int i = 0; i < arr.length; i++) {
          did.add(arr[i]['day_care_id'].toString());
          daycare_name.add(arr[i]['day_care_name'].toString());
          owner_name.add(arr[i]['owner_name'].toString());
          phone.add(arr[i]['phone'].toString());
        }

        // Trigger UI update after data is loaded
        setState(() {});
      }
    } catch (e) {
      print("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('View daycare'),
        ),
        body: WillPopScope(child: SafeArea(
            child: Container(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: did.length,
                itemBuilder: (BuildContext context,int index){
                  return ListTile(
                    title: Padding(
                        padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children:[
                          SizedBox(height: 16,),
                          Row(
                            children: [
                              SizedBox(height: 10,),
                              Text("Daycare Name: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold)),
                                  SizedBox(width: 10),
                                Flexible(
                                  flex:1,
                                      fit:FlexFit.loose,
                                  child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: 200,
                                      ),
                                    child: Text(
                                      daycare_name[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                      )),

                            ],
                          ),

                          SizedBox(height: 16,),
                          Row(
                            children: [
                              SizedBox(height: 10,),
                              Text("Owner Name: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                              Flexible(
                                  flex:1,
                                  fit:FlexFit.loose,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      owner_name[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )),

                            ],
                          ),

                          SizedBox(height: 16,),
                          Row(
                            children: [
                              SizedBox(height: 10,),
                              Text("Phone number: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                              Flexible(
                                  flex:1,
                                  fit:FlexFit.loose,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      phone[index],
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  )),

                            ],
                          ),


                        ]
                      ),
                    ),
                  );
                },
              ),
            )), onWillPop: () async {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));

          return true;
        })
      ),
    );
  }
}
