enum UserRole {
  student('STUDENT', 'Student'),
  faculty('FACULTY', 'Faculty'),
  instituteAdmin('INSTITUTE_ADMIN', 'Institute Admin'),
  clubAdmin('CLUB_ADMIN', 'Club Admin');

  final String dbValue;
  final String label;

  const UserRole(this.dbValue, this.label);

  static UserRole fromString(String? value) {
    return switch (value?.toUpperCase()) {
      'FACULTY' => UserRole.faculty,
      'INSTITUTE_ADMIN' => UserRole.instituteAdmin,
      'CLUB_ADMIN' => UserRole.clubAdmin,
      _ => UserRole.student,
    };
  }
}
