import 'package:flutter_test/flutter_test.dart';
import 'package:fpms_app/Models/machine_model.dart';

void main() {
  group('Machine Model - Unit Tests', () {
    // ✅ Test 1: fromJson parses all fields correctly
    test('fromJson creates Machine with all sensor fields', () {
      final json = {
        '_id': 'mongo_id_001',
        'machineId': 'MCH-001',
        'machineModel': 'Model X',
        'MachineType': 'CNC',
        'MachineStatus': '0',
        'temperature': 75.5,
        'pressure': 1.2,
        'humidity': 60.0,
        'vibration': 0.03,
        'tool_wear': 120.0,
        'rotational_speed': 1500.0,
        'torque': 45.0,
        'air_temperature': 22.0,
        'process_temperature': 310.0,
      };

      final machine = Machine.fromJson(json);

      expect(machine.id, 'mongo_id_001');
      expect(machine.machineId, 'MCH-001');
      expect(machine.machineModel, 'Model X');
      expect(machine.machineType, 'CNC');
      expect(machine.status, 0);
      expect(machine.temperature, 75.5);
      expect(machine.rotationalSpeed, 1500.0);
    });

    // ✅ Test 2: isWorking and isFault helpers
    test('isWorking returns true when status is 0', () {
      final json = {
        'machineId': 'M1',
        'machineModel': 'ModelA',
        'MachineType': 'Pump',
        'MachineStatus': '0',
      };
      final machine = Machine.fromJson(json);
      expect(machine.isWorking, true);
      expect(machine.isFault, false);
      expect(machine.statusText, 'Working');
    });

    test('isFault returns true when status is 1', () {
      final json = {
        'machineId': 'M2',
        'machineModel': 'ModelB',
        'MachineType': 'Generator',
        'MachineStatus': '1',
      };
      final machine = Machine.fromJson(json);
      expect(machine.isWorking, false);
      expect(machine.isFault, true);
      expect(machine.statusText, 'Fault');
    });

    // ✅ Test 3: toJson returns correct map for backend
    test('toJson returns correct map matching backend field names', () {
      final machine = Machine(
        machineId: 'MCH-002',
        machineModel: 'Model Y',
        machineType: 'Compressor',
        status: 0,
      );

      final json = machine.toJson();

      expect(json['machineId'], 'MCH-002');
      expect(json['machineModel'], 'Model Y');
      expect(json['MachineType'], 'Compressor'); // capital M backend format
      expect(json['MachineStatus'], '0');        // stored as string
    });

    // ✅ Test 4: MachineResponse.fromJson wraps Machine correctly
    test('MachineResponse.fromJson parses message and machine together', () {
      final json = {
        'message': 'Machine added successfully',
        'machine': {
          'machineId': 'M99',
          'machineModel': 'Model Z',
          'MachineType': 'Turbine',
          'MachineStatus': '0',
        },
      };

      final response = MachineResponse.fromJson(json);

      expect(response.message, 'Machine added successfully');
      expect(response.machine.machineId, 'M99');
      expect(response.machine.machineType, 'Turbine');
    });
  });
}
