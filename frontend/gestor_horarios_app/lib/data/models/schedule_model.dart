class Schedule {
  final String id;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String role; // 'TCAE', 'ENFERMERO', 'MEDICO'
  final String? description;
  final bool isPublished;
  final String? createdBy;
  final String? assignedTo;
  final String status; // 'AVAILABLE', 'PENDING', 'APPROVED', 'REJECTED'

  Schedule({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.role,
    this.description,
    this.isPublished = false,
    this.createdBy,
    this.assignedTo,
    this.status = 'AVAILABLE',
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      date: DateTime.parse(json['date']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      role: json['role'],
      description: json['description'],
      isPublished: json['isPublished'] ?? false,
      createdBy: json['createdBy'],
      assignedTo: json['assignedTo'],
      status: json['status'] ?? 'AVAILABLE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'role': role,
      'description': description,
      'isPublished': isPublished,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'status': status,
    };
  }

  Schedule copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? role,
    String? description,
    bool? isPublished,
    String? createdBy,
    String? assignedTo,
    String? status,
  }) {
    return Schedule(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      role: role ?? this.role,
      description: description ?? this.description,
      isPublished: isPublished ?? this.isPublished,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
    );
  }
}
