import 'package:flutter/material.dart';
import 'package:mobile/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewFacilities extends StatefulWidget {
  const ViewFacilities({super.key});

  @override
  State<ViewFacilities> createState() => _ViewFacilitiesState();
}

class _ViewFacilitiesState extends State<ViewFacilities> {
  List<String> facility_name = <String>[];
  List<String> fid = <String>[];

  List<String> facility_type = <String>[];
  List<String> facility_des = <String>[];
  List<String> facility_capacity = <String>[];
  List<String> facility_img = <String>[];
  List<String> operating_hr = <String>[];
  List<String> safty_msur = <String>[];

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
      String url = ip + 'view_facility';

      var data = await http.post(
        Uri.parse(url),
        body: {'lid': login_id},
      );

      var jasonData = json.decode(data.body);
      String status = jasonData['status'];
      if (status == 'success') {
        var arr = jasonData['data'];

        for (int i = 0; i < arr.length; i++) {
          fid.add(arr[i]['facility_id'].toString());
          facility_name.add(arr[i]['facility_name'].toString());
          facility_type.add(arr[i]['facility_type'].toString());
          facility_capacity.add(arr[i]['facility_capacity'].toString());
        }

        // Trigger UI update after data is loaded
        setState(() {});
      }
    } catch (e) {
      print("Error: $e");
    }
  }
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
                  itemCount: fid.length,
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
                                  Text("Facility Name: ",
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
                                          facility_name[index],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )),

                                ],
                              ),

                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  SizedBox(height: 10,),
                                  Text("Facility type: ",
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
                                          facility_type[index],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )),

                                ],
                              ),

                              SizedBox(height: 16,),
                              Row(
                                children: [
                                  SizedBox(height: 10,),
                                  Text("Facility capacity: ",
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
                                          facility_capacity[index],
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
