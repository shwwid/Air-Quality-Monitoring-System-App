class SensorData {
  final double temperature;
  final double humidity;
  final double pressure;
  final double nh3;
  final double co;
  final double no2;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.nh3,
    required this.co,
    required this.no2,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    final feeds = json['feeds'][0];
    return SensorData(
      temperature: double.parse(feeds['field1'] ?? '0'),
      humidity: double.parse(feeds['field2'] ?? '0'),
      pressure: double.parse(feeds['field3'] ?? '0'),
      nh3: double.parse(feeds['field4'] ?? '0'),
      co: double.parse(feeds['field5'] ?? '0'),
      no2: double.parse(feeds['field6'] ?? '0'),
    );
  }
}
