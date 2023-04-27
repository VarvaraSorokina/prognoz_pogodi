import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_weather_client/enums/languages.dart';
import 'package:open_weather_client/open_weather.dart';
import 'package:open_weather_widget/open_weather_widget.dart';
import 'package:searchfield/searchfield.dart';
import '';

// Область видимости

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Данный элемент управления является корневым каталогом приложения
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Ниже показаны города которые есть в приложении

class City {
  final String name;
  final String engName;
  final double lat;
  final double lon;
  final String? tags;
  final int hours;

  City(this.name, this.engName, this.lat, this.lon, this.hours, [this.tags]);
}

class _MyHomePageState extends State<MyHomePage> {
  final cities = [
    City('Москва', 'Moscow', 55.7558, 37.6173, 3),
    City('Нефтеюганск', 'Nefteyugansk', 61.101, 72.617,5, 'siberia,oil,cold,'),
    City('Тюмень', 'Tyumen', 57.1553, 65.5619, 5, 'siberia,oil,cold,'),
    City(
        'Ханты-Мансийск', 'Khanty-Mansiysk', 61.0061, 69.0312, 5, 'siberia,cold,'),
    City('Санкт-Петербург', 'Saint-Petersburg', 59.9343, 30.33513, 3,
        'Petersburg,Peter,palace'),
    City('Омск', 'Omsk', 54.9914, 73.3645, 6, 'trains'),
    City('Ростов-на-Дону', 'Rostov-on-Don', 47.2357, 39.7015, 3, 'summer,'),
    City('Барнаул', 'Barnaul', 53.3497, 83.7836, 7, 'Cold,siberia,'),
    City('Владивосток', 'Vladivostok', 43.1332, 131.9113, 10, 'port,ships'),
    City('Пенза', 'Penza', 53.2273, 45.0000, 3, 'zoo,'),
    City('Лондон', 'London', 51.5072, 0.1276, 1),
    City('Нью Йорк', 'New York', 40.7128, 74.0060, -4),
    City('Париж', 'Paris', 48.8566, 2.3522, 2),
  ];

  final key = 'f64d707e2edcd1f50a18cd74c79c3408';

  OpenWeather openWeather =
      OpenWeather(apiKey: 'f64d707e2edcd1f50a18cd74c79c3408');
  final String _countryCode = 'RU';
  final Languages _language = Languages.RUSSIAN;
  final controller = TextEditingController();

  City? city;
  Function? timerState;

// Функция получения погоды

  Future update(City? city) async {
    if (city == null) {
      this.city = null;
      setState(() {});
      return;
    }
    this.city = city;

    await openWeather
        .currentWeatherByCityName(
          cityName: city.name,
          weatherUnits: WeatherUnits.METRIC,
        )
        .catchError((err) => print(err));
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        timerState?.call(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    timerState = null;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Stack(
          children: [
            Transform.scale(
              scale: 1.25,
              child: Image.network(
                city == null
                    ? "https://source.unsplash.com/480x960/?sun,rainbow" // Смена заднего фона
                    : "https://source.unsplash.com/480x960/?${city!.engName},${city!.tags ?? ''}panorama,",
                fit: BoxFit.fill,
                gaplessPlayback: true,
              ),
            ),
            SafeArea(child: Image.asset('assets/logo.png')), // Наш логотип
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SearchField<City>(
                      controller: controller,
                      hasOverlay: false,
                      suggestionAction: SuggestionAction.unfocus,
                      searchInputDecoration: const InputDecoration(
                        fillColor: Colors.white70,
                        filled: true,
                      ),
                      onSubmit: (v) {
                        final city1 =
                            cities.where((element) => element.name == v);
                        if (city1.isNotEmpty) {
                          city = city1.first;
                        }
                        setState(() {});
                      },
                      onSuggestionTap: (v) {
                        city = v.item;
                        setState(() {});
                      },
                      suggestions: cities
                          .map(
                            (e) => SearchFieldListItem<City>(
                              e.name,
                              item: e,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(e.name),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (city != null)
                    Padding( // Код времени
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Flexible(
                            child: Card(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(8.0),
                                child: StatefulBuilder(builder: (context, ss) {
                                  timerState = ss;
                                  final time = DateTime.now().toUtc().add(Duration(hours: city!.hours)); 
                                  return Text(
                                    '${time.hour}:${time.minute}:${time.second}',
                                    style: TextStyle(fontSize: 30),
                                    textAlign: TextAlign.center,
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (city != null)

                  // Получить погоду
                  
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OpenWeatherWidget(
                        key: GlobalKey(),
                        latitude: city!.lat,
                        longitude: city!.lon,
                        location: city!.name,
                        height: 180,
                        apiKey: key,
                        alignment: MainAxisAlignment.center,
                        margin: const EdgeInsets.all(5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
