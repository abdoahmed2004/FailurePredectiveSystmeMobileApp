import 'package:flutter/material.dart';

class Machine {
  final String? id;
  final String machineId;
  final String machineModel;
  final String machineType;
  final int status; // 0 = working, 1 = fault

  // Sensor data fields
  final double? temperature;
  final double? pressure;
  final double? humidity;
  final double? vibration;
  final double? toolWear;
  final double? rotationalSpeed;
  final double? torque;
  final double? airTemperature;
  final double? processTemperature;
  
  // Prediction fields
  final int? remainingCycles;
  final double? daysToFailure;
  final double? failureProbability;
  final String? predictionStatus;
  final String? rootCause;

  // Extra sensor fields
  final double? light;
  
  final String? rawJsonString;

  Machine({
    this.id,
    required this.machineId,
    required this.machineModel,
    required this.machineType,
    this.status = 0, // Default to working
    this.temperature,
    this.pressure,
    this.humidity,
    this.vibration,
    this.toolWear,
    this.rotationalSpeed,
    this.torque,
    this.airTemperature,
    this.processTemperature,
    this.remainingCycles,
    this.daysToFailure,
    this.failureProbability,
    this.predictionStatus,
    this.rootCause,
    this.light,
    this.rawJsonString,
  });

  static double? _parseDouble(Map<String, dynamic> json, List<String> possibleKeys) {
    for (String key in possibleKeys) {
      if (json[key] != null) {
        return double.tryParse(json[key].toString());
      }
    }
    // Fallback: case-insensitive match
    final lowerCaseMap = json.map((k, v) => MapEntry(k.toLowerCase(), v));
    for (String key in possibleKeys) {
      final lowerKey = key.toLowerCase();
      if (lowerCaseMap[lowerKey] != null) {
        return double.tryParse(lowerCaseMap[lowerKey].toString());
      }
    }
    return null;
  }

  factory Machine.fromJson(Map<String, dynamic> json) {
    final sensorData = json['sensor_data'] as Map<String, dynamic>? ?? {};
    final predictionData = json['prediction'] as Map<String, dynamic>? ?? {};

    double? parseSensor(List<String> keys) {
      return _parseDouble(sensorData, keys) ?? _parseDouble(json, keys);
    }

    return Machine(
      id: json['_id'],
      machineId: json['machineId'] ?? json['MachineId'] ?? 'Unknown',
      machineModel: json['machineModel'] ?? json['MachineModel'] ?? 'Unknown',
      machineType: json['MachineType'] ?? json['machineType'] ?? 'Unknown',
      status: int.tryParse(json['MachineStatus']?.toString() ?? json['machineStatus']?.toString() ?? '0') ?? 0,
      temperature: parseSensor(['temp_dht', 'temperature', 'Temperature']),
      pressure: parseSensor(['pressure', 'Pressure']),
      humidity: parseSensor(['hum_dht', 'humidity', 'Humidity']),
      vibration: parseSensor(['vib_rms', 'vibration', 'Vibration']),
      toolWear: parseSensor(['tool_wear', 'toolWear', 'ToolWear', 'Tool_wear']),
      rotationalSpeed: parseSensor(['rotational_speed', 'rotationalSpeed', 'RotationalSpeed']),
      torque: parseSensor(['torque', 'Torque']),
      airTemperature: parseSensor(['air_temperature', 'airTemperature', 'AirTemperature']),
      processTemperature: parseSensor(['temp_ds', 'process_temperature', 'processTemperature', 'ProcessTemperature']),
      light: parseSensor(['light', 'Light']),
      remainingCycles: int.tryParse(predictionData['remainingCycles']?.toString() ?? ''),
      daysToFailure: double.tryParse(predictionData['daysToFailure']?.toString() ?? ''),
      failureProbability: double.tryParse(predictionData['failureProbability']?.toString() ?? ''),
      predictionStatus: predictionData['predictionStatus']?.toString(),
      rootCause: predictionData['rootCause']?.toString(),
      rawJsonString: json.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'machineId': machineId,
      'machineModel': machineModel,
      'MachineType': machineType, // Match backend field name
      'MachineStatus': status.toString(), // Match backend field name
    };
  }

  // Helper methods for status
  bool get isWorking => status == 0;
  bool get isFault => status == 1;

  String get statusText => isWorking ? 'Working' : 'Fault';

  Color get statusColor => isWorking ? const Color(0xFF00E676) : Colors.red;

  Color get statusDotColor =>
      isWorking ? const Color(0xFF69F0AE) : Colors.redAccent;
}

class MachineResponse {
  final String message;
  final Machine machine;

  MachineResponse({
    required this.message,
    required this.machine,
  });

  factory MachineResponse.fromJson(Map<String, dynamic> json) {
    return MachineResponse(
      message: json['message'],
      machine: Machine.fromJson(json['machine']),
    );
  }
}
