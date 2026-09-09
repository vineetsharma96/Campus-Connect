import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/academic_repository.dart';
import '../../domain/academic_models.dart';

class AcademicHubData {
  final List<TimetableSlot> timetable;
  final List<ExaminationItem> examinations;
  final List<FacultyMember> faculty;
  final List<AcademicCalendarItem> calendar;
  final AcademicDay selectedDay;

  const AcademicHubData({
    required this.timetable,
    required this.examinations,
    required this.faculty,
    required this.calendar,
    this.selectedDay = AcademicDay.monday,
  });

  List<TimetableSlot> get slotsForSelectedDay {
    return timetable.where((slot) => slot.day == selectedDay).toList();
  }

  AcademicHubData copyWith({
    List<TimetableSlot>? timetable,
    List<ExaminationItem>? examinations,
    List<FacultyMember>? faculty,
    List<AcademicCalendarItem>? calendar,
    AcademicDay? selectedDay,
  }) {
    return AcademicHubData(
      timetable: timetable ?? this.timetable,
      examinations: examinations ?? this.examinations,
      faculty: faculty ?? this.faculty,
      calendar: calendar ?? this.calendar,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}

sealed class AcademicState {
  const AcademicState();
}

class AcademicLoading extends AcademicState {
  const AcademicLoading();
}

class AcademicLoaded extends AcademicState {
  final AcademicHubData data;
  const AcademicLoaded(this.data);
}

class AcademicError extends AcademicState {
  final String message;
  const AcademicError(this.message);
}

final academicControllerProvider =
    StateNotifierProvider<AcademicController, AcademicState>((ref) {
  final repo = ref.watch(academicRepositoryProvider);
  return AcademicController(repo);
});

class AcademicController extends StateNotifier<AcademicState> {
  final AcademicRepository _repo;

  AcademicController(this._repo) : super(const AcademicLoading()) {
    loadAcademicData();
  }

  Future<void> loadAcademicData() async {
    state = const AcademicLoading();
    try {
      final results = await Future.wait([
        _repo.fetchTimetable(),
        _repo.fetchExaminations(),
        _repo.fetchFacultyDirectory(),
        _repo.fetchAcademicCalendar(),
      ]);

      // Set selected day to current weekday if Mon-Fri
      final currentWeekday = DateTime.now().weekday;
      final defaultDay = switch (currentWeekday) {
        DateTime.tuesday => AcademicDay.tuesday,
        DateTime.wednesday => AcademicDay.wednesday,
        DateTime.thursday => AcademicDay.thursday,
        DateTime.friday => AcademicDay.friday,
        DateTime.saturday => AcademicDay.saturday,
        _ => AcademicDay.monday,
      };

      state = AcademicLoaded(
        AcademicHubData(
          timetable: results[0] as List<TimetableSlot>,
          examinations: results[1] as List<ExaminationItem>,
          faculty: results[2] as List<FacultyMember>,
          calendar: results[3] as List<AcademicCalendarItem>,
          selectedDay: defaultDay,
        ),
      );
    } catch (e) {
      state = AcademicError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void selectDay(AcademicDay day) {
    if (state is AcademicLoaded) {
      final current = state as AcademicLoaded;
      state = AcademicLoaded(current.data.copyWith(selectedDay: day));
    }
  }

  Future<void> refresh() async => loadAcademicData();
}
