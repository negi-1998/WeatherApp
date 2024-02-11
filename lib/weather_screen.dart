import "dart:convert";
import "dart:ui";
import "package:intl/intl.dart";
import "package:flutter/material.dart";
import "package:timezone/timezone.dart" as tz;
import "package:timezone/data/latest.dart" as tzdata;
import "package:weather_app/additional_info_item.dart";
import "package:weather_app/secrets.dart";
import "package:weather_app/weather_forecast_item.dart";
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Dehradun';
      final res = await http.get(Uri.parse('http://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$openWeatherAPIKey',),
    
    );

    final data = jsonDecode(res.body);

    if(data['cod']!='200') {
      throw 'An unexpected error occured';
    }
    return data;
    } catch (e) {
      throw e.toString();
    }
  }  

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions:  [
          IconButton(
            onPressed: (){
              setState(() {
          
              });
            }, 
            icon: const Icon(Icons.refresh))
        ],
      ),
      body:  FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if(snapshot.connectionState== ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError) {
            return  Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currentTemp = double.parse((data['list'][0]['main']['temp'] - 273.15).toStringAsFixed(2));
          final currentSky = data['list'][0]['weather'][0]['main'];
          final currentPressure = data['list'][0]['main']['pressure'];
          final currentSpeed = data['list'][0]['wind']['speed'];
          final currentHumidity = data['list'][0]['main']['humidity'];

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child:  Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('$currentTemp ° C',
                              style:  const TextStyle(fontWeight: FontWeight.bold,
                                fontSize: 32
                              ),
                            ),
                             const SizedBox(height: 16,),
                             Icon(currentSky=='Clouds' || currentSky=='Rain'? Icons.cloud : Icons.sunny, size: 64,),
                            const SizedBox(height: 16,),
                             Text( currentSky, 
                              style: const TextStyle(fontSize: 30),
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25,),
              const Text('Hourly Forecast', 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16,),
              /* const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    HourlyForecastItem(
                      time: '00:00',
                      icon: Icons.cloud,
                      temp: '100'
                    ),
                    HourlyForecastItem(
                      time: '03:00',
                      icon: Icons.sunny,
                      temp: '202',
                    ),
                    HourlyForecastItem(
                      time: '06:00',
                      icon: Icons.sunny,
                      temp: '324.5',
                    ),
                    HourlyForecastItem(
                      time: '09:00',
                      icon: Icons.sunny,
                      temp: '524.5',
                    ),
                    HourlyForecastItem(
                      time: '06:00',
                      icon: Icons.cloud,
                      temp: '124.5',
                    ),
                  ],
                ),
              ), */

              SizedBox(
                height: 121,
                child: ListView.builder(
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final hourlyForecast = data['list'][index+1];
                    final hourlySky = data['list'][index+1]['weather'][0]['main'];
                    tzdata.initializeTimeZones();
                    final time = DateTime.parse(hourlyForecast['dt_txt']);
                    final location = tz.getLocation('Asia/Kolkata');
                    final timeLocal = tz.TZDateTime.from(time, location);
                    return HourlyForecastItem(
                      time: DateFormat.Hm().format(timeLocal), 
                      temp: '${double.parse((hourlyForecast['main']['temp']-273.15).toStringAsFixed(2))}° C', 
                      icon: hourlySky=='Clouds' || hourlySky=='Rain' ? Icons.cloud:
                        Icons.sunny,);
                  }
                  ),
              ),

              const SizedBox(height: 25,),
        
              const Text('Additional Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        
              const SizedBox(height: 16,),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: currentHumidity.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: currentSpeed.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: currentPressure.toString(),
                  ),
                ],
              )
            ],
          ),
        );
        },
      ),
    );
  }
}





