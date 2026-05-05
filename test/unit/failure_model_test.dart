import 'package:flutter_test/flutter_test.dart';
import 'package:fpms_app/Models/failure_model.dart';

void main() {
  group('Failure Model - Unit Tests', () {
    // ✅ Test 1: fromJson parses all fields correctly (using backend key names)
    test('fromJson creates Failure object from backend JSON (capital keys)', () {
      final json = {
        '_id': 'abc123',
        'machineId': 'M001',
        'MachineType': 'Pump',
        'MachineName': 'Pump A',
        'Description': 'Overheating issue',
        'AssignedTo': 'tech@company.com',
        'ReportedBy': 'eng@company.com',
        'SeverityLevel': 'Critical',
        'status': 'open',
        'createdAt': '2024-01-15T10:00:00.000Z',
      };

      final failure = Failure.fromJson(json);

      expect(failure.id, 'abc123');
      expect(failure.machineId, 'M001');
      expect(failure.machineType, 'Pump');
      expect(failure.description, 'Overheating issue');
      expect(failure.assignedTo, 'tech@company.com');
      expect(failure.reportedBy, 'eng@company.com');
      expect(failure.severityLevel, 'Critical');
      expect(failure.status, 'open');
      expect(failure.createdAt, isNotNull);
    });

    // ✅ Test 2: fromJson handles lowercase keys too
    test('fromJson creates Failure object from lowercase JSON keys', () {
      final json = {
        'id': 'xyz789',
        'machineId': 'M002',
        'machineType': 'CNC',
        'machineName': 'CNC Machine 1',
        'description': 'Vibration anomaly',
        'assignedTo': 'tech2@company.com',
        'reportedBy': 'eng2@company.com',
        'severity': 'Medium',
        'status': 'fixed',
      };

      final failure = Failure.fromJson(json);

      expect(failure.id, 'xyz789');
      expect(failure.severityLevel, 'Medium');
      expect(failure.status, 'fixed');
      expect(failure.createdAt, isNull); // no date provided
    });

    // ✅ Test 3: status is trimmed and lowercased
    test('fromJson lowercases and trims status field', () {
      final json = {
        '_id': '1',
        'machineId': 'M003',
        'MachineType': 'Generator',
        'machineName': 'Gen-1',
        'description': 'Test',
        'assignedTo': 'a@b.com',
        'reportedBy': 'c@d.com',
        'SeverityLevel': 'Low',
        'status': '  Open  ', // with whitespace + capital
      };

      final failure = Failure.fromJson(json);
      expect(failure.status, 'open'); // should be trimmed and lowercased
    });

    // ✅ Test 4: handles missing optional fields gracefully
    test('fromJson handles missing fields with empty string defaults', () {
      final json = <String, dynamic>{
        '_id': 'min001',
        'machineId': 'M004',
        'status': 'open',
      };

      final failure = Failure.fromJson(json);
      expect(failure.machineType, '');
      expect(failure.description, '');
      expect(failure.assignedTo, '');
      expect(failure.severityLevel, '');
      expect(failure.createdAt, isNull);
    });
  });
}
