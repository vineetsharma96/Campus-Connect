enum AttendanceStatus {
  present('PRESENT'),
  absent('ABSENT'),
  excused('EXCUSED');

  final String dbValue;
  const AttendanceStatus(this.dbValue);

  static AttendanceStatus fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'ABSENT' => AttendanceStatus.absent,
      'EXCUSED' => AttendanceStatus.excused,
      _ => AttendanceStatus.present,
    };
  }
}

class AttendanceLogEntry {
  final String id;
  final String subjectName;
  final String subjectCode;
  final AttendanceStatus status;
  final DateTime sessionDate;

  const AttendanceLogEntry({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.status,
    required this.sessionDate,
  });

  factory AttendanceLogEntry.fromJson(Map<String, dynamic> json) {
    final sub = json['subjects'] as Map<String, dynamic>? ?? {};
    return AttendanceLogEntry(
      id: json['id'] as String,
      subjectName: sub['name'] as String? ?? 'Subject',
      subjectCode: sub['code'] as String? ?? 'GEN',
      status: AttendanceStatus.fromString(json['status'] as String?),
      sessionDate: DateTime.tryParse(json['session_date'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SubjectAttendance {
  final String subjectId;
  final String code;
  final String name;
  final String facultyName;
  final int totalConducted;
  final int totalAttended;
  final int totalAbsent;

  const SubjectAttendance({
    required this.subjectId,
    required this.code,
    required this.name,
    required this.facultyName,
    required this.totalConducted,
    required this.totalAttended,
    required this.totalAbsent,
  });

  double get percentage =>
      totalConducted == 0 ? 100.0 : (totalAttended / totalConducted) * 100.0;

  bool get isBelowThreshold => percentage < 75.0;

  /// Calculates how many consecutive classes must be attended to reach target threshold (75%)
  int classesNeededToReach(double targetPercentage) {
    if (percentage >= targetPercentage) {
      return 0;
    }
    final target = targetPercentage / 100.0;
    final needed = ((target * totalConducted - totalAttended) / (1.0 - target)).ceil();
    return needed > 0 ? needed : 0;
  }

  /// Calculates how many classes a student can safely miss without dropping below threshold
  int classesCanMiss(double targetPercentage) {
    if (percentage < targetPercentage) {
      return 0;
    }
    final target = targetPercentage / 100.0;
    final canMiss = ((totalAttended - (target * totalConducted)) / target).floor();
    return canMiss > 0 ? canMiss : 0;
  }
}

class OverallAttendanceSummary {
  final double overallPercentage;
  final int totalConducted;
  final int totalAttended;
  final int totalAbsent;
  final List<SubjectAttendance> subjects;
  final List<AttendanceLogEntry> recentLogs;

  const OverallAttendanceSummary({
    required this.overallPercentage,
    required this.totalConducted,
    required this.totalAttended,
    required this.totalAbsent,
    required this.subjects,
    required this.recentLogs,
  });

  bool get isOverallLow => overallPercentage < 75.0;
}