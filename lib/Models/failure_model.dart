class Failure {
  final String id;
  final String machineId;
  final String machineType;
  final String machineName;
  final String description;
  final String assignedTo; // email
  final String reportedBy; // email
  final String severityLevel; // Low | Medium | Critical
  final String status; // open | critical | fixed
  final DateTime? createdAt;

  Failure({
    required this.id,
    required this.machineId,
    required this.machineType,
    required this.machineName,
    required this.description,
    required this.assignedTo,
    required this.reportedBy,
    required this.severityLevel,
    required this.status,
    this.createdAt,
  });

  factory Failure.fromJson(Map<String, dynamic> json) {
    final created = (json['createdAt'] ?? json['DateReported'])?.toString();
    return Failure(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      machineId: (json['machineId'] ?? '').toString(),
      machineType: (json['machineType'] ?? json['MachineType'] ?? '').toString(),
      machineName: (json['machineName'] ?? json['MachineName'] ?? '').toString(),
      description: (json['Description'] ?? json['description'] ?? '').toString(),
      assignedTo: (json['AssignedTo'] ?? json['assignedTo'] ?? '').toString(),
      reportedBy: (json['ReportedBy'] ?? json['reportedBy'] ?? '').toString(),
      severityLevel: (json['SeverityLevel'] ?? json['severity'] ?? '').toString(),
      status: (json['status'] ?? 'open').toString().trim().toLowerCase(),
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}