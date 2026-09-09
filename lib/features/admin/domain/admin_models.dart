import '../../academic/domain/academic_models.dart';
import '../../notices/domain/notice_models.dart';

class NoticePayload {
  final String? id;
  final String title;
  final String content;
  final NoticeCategory category;
  final bool isImportant;

  const NoticePayload({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isImportant,
  });

  Map<String, dynamic> toMap(String publisherId) => {
        'title': title.trim(),
        'content': content.trim(),
        'category': category.dbValue,
        'is_important': isImportant,
        'published_by': publisherId,
        'published_at': DateTime.now().toUtc().toIso8601String(),
      };
}

class FacultyPayload {
  final String? id;
  final String fullName;
  final String designation;
  final String department;
  final String email;
  final String officeLocation;

  const FacultyPayload({
    this.id,
    required this.fullName,
    required this.designation,
    required this.department,
    required this.email,
    required this.officeLocation,
  });

  Map<String, dynamic> toMap() => {
        'full_name': fullName.trim(),
        'designation': designation.trim(),
        'department': department.trim(),
        'email': email.trim().toLowerCase(),
        'office_location': officeLocation.trim(),
      };
}

class TimetablePayload {
  final String? id;
  final String subjectId;
  final String? facultyId;
  final AcademicDay day;
  final String startTime;
  final String endTime;
  final String roomNumber;

  const TimetablePayload({
    this.id,
    required this.subjectId,
    this.facultyId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.roomNumber,
  });

  Map<String, dynamic> toMap() => {
        'subject_id': subjectId,
        'faculty_id': facultyId,
        'day': day.dbValue,
        'start_time': startTime,
        'end_time': endTime,
        'room_number': roomNumber.trim(),
      };
}

class CandidateStudent {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? assignedClubName;

  const CandidateStudent({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.assignedClubName,
  });

  factory CandidateStudent.fromJson(Map<String, dynamic> json) {
    return CandidateStudent(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Student',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'STUDENT',
      assignedClubName: json['club_name'] as String?,
    );
  }
}
