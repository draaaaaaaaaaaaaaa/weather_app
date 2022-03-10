import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(const WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}
class _WeatherAppState extends State<WeatherApp> {
  int temperatured = 0;
  String location = 'Jakarta';
  String weather = 'clear';
  int woeid = 1047378;
  String abbviation = 'c';

  String searchApiUrl = 'https://www.metaweather.com/api/location/search/?query';

  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  Future<void> fetchSearch(String input) async {
    var searchResult = await http.get(Uri.parse(searchApiUrl+input));
    var result = json.decode(searchResult.body)[0];

    setState(() {
      location = result['title'];
      woeid = result['woeid'];
    });
  }
  Future<void> fetchLocation() async {
    var locationResult = await http.get(Uri.parse(locationApiUrl+woeid.toString()));
    var result = json.decode((locationResult.body));
    var consolidated_weather = result['consolidated_weather'];
    var data = consolidated_weather[0];
    

    setState(() {
      temperatured = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ','').toLowerCase();
      abbviation = 
    });
  }

  void onTextFieldSubmitted(String input) async{
     fetchLocation();
     fetchSearch(input);
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Center(
                    child:  Image.network(''),
                  ),
                  Center(
                    child: Text(
                      temperatured.toString() + '°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  )
                ],
              ),
              Container(
                width: 300,
                child: TextField(
                  onSubmitted: (String input){
                    onTextFieldSubmitted(input);
                  },
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search another location...',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

