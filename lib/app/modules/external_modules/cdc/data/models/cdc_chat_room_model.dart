class CdcChatRoomModel {
  final String id;
  final String name;
  final String link;
  final String type;
  final bool allCourses;
  final List<String> courses;

  const CdcChatRoomModel({
    required this.id,
    required this.name,
    required this.link,
    required this.type,
    required this.allCourses,
    required this.courses,
  });

  factory CdcChatRoomModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    final dynamic rawCourses = map['courses'];

    final List<String> normalizedCourses =
        (rawCourses is List ? rawCourses : const [])
            .whereType<dynamic>()
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();

    return CdcChatRoomModel(
      id: id,
      name: (map['name'] ?? '').toString().trim(),
      link: (map['link'] ?? '').toString().trim(),
      type: (map['type'] ?? '').toString().trim(),
      allCourses: map['all_courses'] == true,
      courses: normalizedCourses,
    );
  }

  bool isVisibleForCourse(String userCourse) {
    if (allCourses) return true;

    final String normalizedUserCourse = userCourse.trim().toLowerCase();
    if (normalizedUserCourse.isEmpty || normalizedUserCourse == '-') {
      return false;
    }

    return courses.any(
      (course) => course.trim().toLowerCase() == normalizedUserCourse,
    );
  }

  bool hasRequiredFields() {
    return name.isNotEmpty && link.isNotEmpty;
  }
}
