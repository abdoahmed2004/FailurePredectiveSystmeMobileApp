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
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      id: json['_id'],
      machineId: json['machineId'],
      machineModel: json['machineModel'],
      machineType: json['MachineType'], // Note: Backend uses 'MachineType' with capital M
      status: int.tryParse(json['MachineStatus']?.toString() ?? '0') ?? 0, // Parse MachineStatus as int
      temperature: json['temperature']?.toDouble(),
      pressure: json['pressure']?.toDouble(),
      humidity: json['humidity']?.toDouble(),
      vibration: json['vibration']?.toDouble(),
      toolWear: json['tool_wear']?.toDouble(),
      rotationalSpeed: json['rotational_speed']?.toDouble(),
      torque: json['torque']?.toDouble(),
      airTemperature: json['air_temperature']?.toDouble(),
      processTemperature: json['process_temperature']?.toDouble(),
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
  
  Color get statusColor => isWorking ? Colors.green : Colors.red;
  
  Color get statusDotColor => isWorking ? Colors.greenAccent : Colors.redAccent;
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