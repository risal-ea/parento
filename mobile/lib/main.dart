import 'package:flutter/material.dart';
import 'screens/login.dart';
// import 'screens/registor.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(const Ambulance());
}

class Ambulance extends StatefulWidget {
  const Ambulance({super.key});

  @override
  State<Ambulance> createState() => _AmbulanceState();
}

class _AmbulanceState extends State<Ambulance> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: const ipset(),
    );
  }
}

class ipset extends StatefulWidget {
  const ipset({super.key});

  @override
  State<ipset> createState() => _ipsetstate();
}

class _ipsetstate extends State<ipset> {
  final TextEditingController ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Add a global key for the form

  final RegExp ipreg =
  RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
  r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Parento"),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Stack(
              children: <Widget>[

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: TextFormField(
                          controller: ipController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "IP Address",
                            hintText: "Enter a valid IP address",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the IP';
                            } else if (!ipreg.hasMatch(value)) {
                              return 'IP must be a valid one';
                            }
                            return null; // Return null if the input is valid
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) {
                              print("Not validated");
                            }
                            else
                            {
                              String ip = ipController.text.toString();
                              final sh = await SharedPreferences.getInstance();
                              sh.setString("url", "http://" + ip + ":5001/");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => login())
                              );
                            }
                          },
                          child: const Icon(Icons.key),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.of(context).pop(true);
        return true;
      },
    );
  }
}