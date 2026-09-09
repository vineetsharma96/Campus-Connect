class CourseItem {
  final String id;
  final String code;
  final String name;
  final int totalSemesters;

  const CourseItem({
    required this.id,
    required this.code,
    required this.name,
    required this.totalSemesters,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) => CourseItem(
        id: json['id'] as String,
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        totalSemesters: json['total_semesters'] as int? ?? 8,
      );
}

class SectionItem {
  final String id;
  final String courseId;
  final int semester;
  final String sectionName;
  final String academicYear;

  const SectionItem({
    required this.id,
    required this.courseId,
    required this.semester,
    required this.sectionName,
    required this.academicYear,
  });

  factory SectionItem.fromJson(Map<String, dynamic> json) => SectionItem(
        id: json['id'] as String,
        courseId: json['course_id'] as String? ?? '',
        semester: json['semester'] as int? ?? 1,
        sectionName: json['section_name'] as String? ?? '',
        academicYear: json['academic_year'] as String? ?? '',
      );
}

class FacultyAllocation {
  final String id;
  final String subjectId;
  final String subjectName;
  final String subjectCode;
  final String sectionId;
  final String sectionName;
  final String courseCode;
  final int semester;

  const FacultyAllocation({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.sectionId,
    required this.sectionName,
    required this.courseCode,
    required this.semester,
  });

  factory FacultyAllocation.fromJson(Map<String, dynamic> json) {
    final sub = json['subjects'] as Map<String, dynamic>? ?? {};
    final sec = json['sections'] as Map<String, dynamic>? ?? {};
    final crs = sec['courses'] as Map<String, dynamic>? ?? {};

    return FacultyAllocation(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String? ?? '',
      subjectName: sub['name'] as String? ?? '',
      subjectCode: sub['code'] as String? ?? '',
      sectionId: json['section_id'] as String? ?? '',
      sectionName: sec['section_name'] as String? ?? '',
      courseCode: crs['code'] as String? ?? '',
      semester: sec['semester'] as int? ?? 1,
    );
  }
}

class SectionStudent {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;

  const SectionStudent({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });

  factory SectionStudent.fromJson(Map<String, dynamic> json) => SectionStudent(
        id: json['id'] as String,
        fullName: json['full_name'] as String? ?? 'Student',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatar_url'] as String?,
      );
}

class MentorNoticeItem {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;

  const MentorNoticeItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory MentorNoticeItem.fromJson(Map<String, dynamic> json) => MentorNoticeItem(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}