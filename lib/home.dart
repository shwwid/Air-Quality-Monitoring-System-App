import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iotproject/gases_detected.dart';
import 'dart:convert';
import 'sensor_data.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  flutterLocalNotificationsPlugin.initialize(initSettings);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SensorData? _sensorData;
  bool _loading = true;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _refreshData(); // Initial fetch
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 11), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel(); // Clean up the timer
    super.dispose();
  }

  Future<void> _refreshData() async {
    const url =
        'https://api.thingspeak.com/channels/3018057/feeds.json?api_key=5Z3B4R8TQGLWD850&results=1';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = SensorData.fromJson(jsonDecode(response.body));
        setState(() {
          _sensorData = data;
          const double nh3Threshold = 10;
          const double lpgThreshold = 10.0;
          const double ch4Threshold = 15.0;

          if (_sensorData!.nh3 > nh3Threshold) {
            _showGasAlertNotification("NH₃", _sensorData!.nh3);
          }
          if (_sensorData!.lpg > lpgThreshold) {
            _showGasAlertNotification("lpg", _sensorData!.lpg);
          }
          if (_sensorData!.ch4 > ch4Threshold) {
            _showGasAlertNotification("CH₄", _sensorData!.ch4);
          }
          _loading = false;
        });

        // Show snackbar after successful refresh
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data refreshed successfully!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      //print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showGasAlertNotification(String gasName, double value) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'gas_alerts',
          'Gas Alerts',
          channelDescription: 'Notifies when gas level exceeds safe threshold',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      '⚠️ High $gasName Level Detected!',
      '$gasName level is ${value.toStringAsFixed(1)} ppm. Stay safe!',
      notificationDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/earth.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child:
                    _loading || _sensorData == null
                        ? const SizedBox(
                          height: 500,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            const SizedBox(height: 100),

                            // AQI & Temperature
                            Column(
                              children: [
                                /*Text(
                                  'AQI: 40',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                                Text(
                                  'Temperature',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_sensorData!.temperature.toStringAsFixed(1)}°C',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 60,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // Humidity and Pressure Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _infoBox(
                                  title: 'Humidity',
                                  value:
                                      '${_sensorData!.humidity.toStringAsFixed(0)}%',
                                ),
                                _infoBox(
                                  title: 'Pressure',
                                  value:
                                      '${_sensorData!.pressure.toStringAsFixed(0)} hPa',
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Gases Detected Box
                            GestureDetector(
                              onLongPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GasesDetected(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'Gases Detected',
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _gasSlider(
                                      'NH₃',
                                      'Ammonia',
                                      _sensorData!.nh3,
                                    ),
                                    _gasSlider(
                                      'LPG',
                                      'Liquified Petroleum Gas',
                                      _sensorData!.lpg,
                                    ),
                                    _gasSlider(
                                      'CH₄',
                                      'Methane',
                                      _sensorData!.ch4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox({required String title, required String value}) {
    return Container(
      width: 160,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gasSlider(String gas, String label, double value) {
    double displayValue = value.clamp(0, 100).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$gas ($label)',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
            ),
            Text(
              '${displayValue.toStringAsFixed(1)}ppm',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            thumbColor: Colors.white,
            //overlayColor: Colors.blue.withAlpha(32),
            inactiveTrackColor: const Color.fromARGB(80, 158, 158, 158),
          ),
          child: Slider(
            value: displayValue,
            max: 100,
            divisions: 100,
            onChanged: (newValue) {
              setState(() {
                displayValue = newValue;
              });
            },
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
