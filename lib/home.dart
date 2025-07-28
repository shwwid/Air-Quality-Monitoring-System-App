import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Future<void> _handleRefresh() async {
    // Simulate a refresh operation
    await Future.delayed(const Duration(seconds: 2));
    // TODO: Add logic to refresh data.
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
            child: RefreshIndicator(
              color: Colors.grey,
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      // AQI & Temperature
                      Column(
                        children: [
                          Text(
                            'AQI:40',
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Satisfactory',
                            style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          //SizedBox(height: 8),
                          Text(
                            '27°',
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
                          _infoBox(title: 'Humidity', value: '40%'),
                          _infoBox(title: 'Pressure', value: '1005hPa'),
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
                            _gasSlider('CO', 'Carbon Monoxide', 60),
                            _gasSlider('NH₃', 'Ammonia', 30),
                            _gasSlider('NO', 'Nitrogen Dioxide', 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Info Box for Humidity & Pressure
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

  // Gas Detection Slider
  Widget _gasSlider(String gas, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$gas ($label)',
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
        ),
        Slider(
          value: value,
          max: 100,
          divisions: 100,
          activeColor: Colors.blue,
          inactiveColor: Colors.white24,
          label: '${value.toInt()}%',
          onChanged: (_) {}, // Static now, dynamic later
        ),
      ],
    );
  }
}
