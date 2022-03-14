import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main(List<String> args) {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int? temprature;

  String location = 'Jakarta';
  String weather = 'clear';
  int woeid = 1047378;
  String abbreviation = 'c';

  String errormassage = "";

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';

  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void iniState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result['title'];
        woeid = result['woeid'];
        errormassage = '';
      });
    } catch (error) {
      errormassage =
      "maaf kita tidak ada data untuk kota tersebut, silahkan untuk mencoba kota yang lain";
    }
  }

  Future<void> fetchLocation() async {
    var locationResult =
    await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode((locationResult.body));
    var consolidated_weather = result['consolidated_weather'];
    var data = consolidated_weather[0];

    var minTemperature = List.filled(7, 0);
    var maxTemperature = List.filled(7, 0);
    var abbreviationForecast = List.filled(7, ' ');

    setState(() {
      temprature = data['the_temp'].round();
      weather = data['weather_state_name'].replaceAll(' ', '').toLowerCase();
      abbreviation = data['weather_state_abbr'];
    });
  }

  void fetchLocationDay() async {
    var today = DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(Uri.parse(locationApiUrl +
          woeid.toString() +'/' +DateFormat('y/M/d').format(today.add(Duration(days: i + 1))).toString()));
      var resault = jsonDecode(locationDayResult.body);
      var data = resault[0];

      setState(() {
        temprature = data['the t']
      });
    }
  }

  void onTxtFieldSubmitted(String input) {
    fetchSearch(input);
    fetchLocation();
  }
@override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'), fit: BoxFit.cover)),
        child: temprature == null ? const Center(
          child: CircularProgressIndicator(),) :
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Center(
                    child: Image.network(
                      'https://www.metaweather.com/static/img/weather/png/' +
                          abbreviation +
                          '.png',
                      width: 100,
                    ),
                  ),
                  Center(
                    child: Text(
                      temprature.toString() + '°C',
                      style: TextStyle(color: Colors.white, fontSize: 60),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for(var i=0;i<7; i++)
                      forecastElement(i+i,
                       abbreviation, minTemperature, maxTemperature)
                    ],
                  ),
                ),
                ),
              Column(
                children: [
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input) {
                        onTxtFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 25),
                      decoration: InputDecoration(
                          hintStyle:
                          TextStyle(color: Colors.white, fontSize: 18),
                          hintText: 'Search another locatio...',
                          prefixIcon: Icon(Icons.search)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errormassage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: Platform.isAndroid ? 15 : 20
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, minTemperature, maxTemperature) {
  var now = DateTime.now();
  var oneDayFromNow = now.add(Duration(days: daysFromNow));
  return Padding(
    padding:  EdgeInsets.only(left: 16),
    child: Container(
      decoration: BoxDecoration(
          color:  Color.fromRGBO(205, 212, 228, 0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding:  EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              DateFormat.E().format(oneDayFromNow),
              style:  TextStyle(color: Colors.white, fontSize: 25),
            ),
            Text(
              DateFormat.MMMd().format(oneDayFromNow),
              style:  TextStyle(color: Colors.white, fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
              vertical: 16,
              ),
              child: Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviation +
                    '.png',
                width: 50,
              ),
            ),
            Text(
              'High: ' + maxTemperature.toString() + ' °C',
              style:  TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            Text(
              'Low: ' + minTemperature.toString() + ' °C',
              style:  TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}