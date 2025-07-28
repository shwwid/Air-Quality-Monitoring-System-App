import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sensor_data.dart';

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
      print('Error: $e');
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
                child: _loading || _sensorData == null
                    ? const SizedBox(
                    height: 500,
                    child: Center(child: CircularProgressIndicator()))
                    : Column(
                  children: [
                    const SizedBox(height: 100),

                    // AQI & Temperature
                    Column(
                      children: [
                        Text(
                          'AQI: 40',
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Satisfactory',
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_sensorData!.temperature.toStringAsFixed(1)}°',
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
                            '${_sensorData!.humidity.toStringAsFixed(0)}%'),
                        _infoBox(
                            title: 'Pressure',
                            value:
                            '${_sensorData!.pressure.toStringAsFixed(0)} hPa'),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Gases Detected Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
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
                          _gasSlider('CO', 'Carbon Monoxide',
                              _sensorData!.co),
                          _gasSlider('NH₃', 'Ammonia',
                              _sensorData!.nh3),
                          _gasSlider('NO₂', 'Nitrogen Dioxide',
                              _sensorData!.no2),
                        ],
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
      width: 180,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$gas ($label)',
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
        ),
        Slider(
          value: value.clamp(0, 100),
          max: 100,
          divisions: 100,
          activeColor: Colors.blue,
          inactiveColor: Colors.white24,
          label: '${value.toInt()}%',
          onChanged: null,
        ),
      ],
    );
  }
}
