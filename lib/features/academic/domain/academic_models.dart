enum AcademicDay {
  monday('MONDAY', 'Mon'),
  tuesday('TUESDAY', 'Tue'),
  wednesday('WEDNESDAY', 'Wed'),
  thursday('THURSDAY', 'Thu'),
  friday('FRIDAY', 'Fri'),
  saturday('SATURDAY', 'Sat');

  final String dbValue;
  final String label;

  const AcademicDay(this.dbValue, this.label);

  static AcademicDay fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'TUESDAY' => AcademicDay.tuesday,
      'WEDNESDAY' => AcademicDay.wednesday,
      'THURSDAY' => AcademicDay.thursday,
      'FRIDAY' => AcademicDay.friday,
      'SATURDAY' => AcademicDay.saturday,
      _ => AcademicDay.monday,
    };
  }
}

class TimetableSlot {
  final String id;
  final String subjectCode;
  final String subjectName;
  final String facultyName;
  final AcademicDay day;
  final String startTime;
  final String endTime;
  final String roomNumber;

  const TimetableSlot({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.facultyName,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  factory TimetableSlot.fromJson(Map<String, dynamic> json) {
    final sub = json['subjects'] as Map<String, dynamic>? ?? {};
    final fac = json['faculty'] as Map<String, dynamic>? ?? {};

    return TimetableSlot(
      id: json['id'] as String,
      subjectCode: sub['code'] as String? ?? 'GEN',
      subjectName: sub['name'] as String? ?? 'Subject Class',
      facultyName: fac['full_name'] as String? ?? 'Faculty Member',
      day: AcademicDay.fromString(json['day'] as String?),
      startTime: (json['start_time'] as String? ?? '09:00:00').substring(0, 5),
      endTime: (json['end_time'] as String? ?? '10:00:00').substring(0, 5),
      roomNumber: json['room_number'] as String? ?? 'Classroom',
    );
  }
}

class ExaminationItem {
  final String id;
  final String subjectCode;
  final String subjectName;
  final DateTime examDate;
  final String startTime;
  final String endTime;
  final String venue;

  const ExaminationItem({
    required this.id,
    required this.subjectCode,
    required this.subjectName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.venue,
  });

  int get daysUntilExam {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(examDate.year, examDate.month, examDate.day);
    return target.difference(today).inDays;
  }

  factory ExaminationItem.fromJson(Map<String, dynamic> json) {
    final sub = json['subjects'] as Map<String, dynamic>? ?? {};

    return ExaminationItem(
      id: json['id'] as String,
      subjectCode: sub['code'] as String? ?? 'GEN',
      subjectName: sub['name'] as String? ?? 'Exam Paper',
      examDate: DateTime.tryParse(json['exam_date'] as String? ?? '') ??
          DateTime.now(),
      startTime: (json['start_time'] as String? ?? '09:30:00').substring(0, 5),
      endTime: (json['end_time'] as String? ?? '12:30:00').substring(0, 5),
      venue: json['venue'] as String? ?? 'Exam Wing',
    );
  }
}

class FacultyMember {
  final String id;
  final String fullName;
  final String designation;
  final String department;
  final String email;
  final String officeLocation;

  const FacultyMember({
    required this.id,
    required this.fullName,
    required this.designation,
    required this.department,
    required this.email,
    required this.officeLocation,
  });

  factory FacultyMember.fromJson(Map<String, dynamic> json) {
    return FacultyMember(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Faculty Member',
      designation: json['designation'] as String? ?? 'Lecturer',
      department: json['department'] as String? ?? 'General Department',
      email: json['email'] as String? ?? '',
      officeLocation: json['office_location'] as String? ?? 'Campus Office',
    );
  }
}

enum CalendarEventType {
  holiday('HOLIDAY', 'Holiday'),
  examination('EXAMINATION', 'Exam'),
  semesterEvent('SEMESTER_EVENT', 'Event'),
  deadline('DEADLINE', 'Deadline');

  final String dbValue;
  final String label;

  const CalendarEventType(this.dbValue, this.label);

  static CalendarEventType fromString(String? val) {
    return switch (val?.toUpperCase()) {
      'HOLIDAY' => CalendarEventType.holiday,
      'EXAMINATION' => CalendarEventType.examination,
      'DEADLINE' => CalendarEventType.deadline,
      _ => CalendarEventType.semesterEvent,
    };
  }
}

class AcademicCalendarItem {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime? endDate;
  final CalendarEventType eventType;

  const AcademicCalendarItem({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.endDate,
    required this.eventType,
  });

  factory AcademicCalendarItem.fromJson(Map<String, dynamic> json) {
    return AcademicCalendarItem(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Academic Milestone',
      description: json['description'] as String?,
      eventDate: DateTime.tryParse(json['event_date'] as String? ?? '') ??
          DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      eventType: CalendarEventType.fromString(json['event_type'] as String?),
    );
  }
}
