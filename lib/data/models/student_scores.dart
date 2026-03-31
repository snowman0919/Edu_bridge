enum StudentSubject { korean, english, math }

class StudentScores {
  const StudentScores({
    required this.korean,
    required this.english,
    required this.math,
  });

  final double korean;
  final double english;
  final double math;

  double get average => (korean + english + math) / 3;

  StudentSubject get weakestSubject {
    final entries = <MapEntry<StudentSubject, double>>[
      MapEntry(StudentSubject.korean, korean),
      MapEntry(StudentSubject.english, english),
      MapEntry(StudentSubject.math, math),
    ]..sort((a, b) => a.value.compareTo(b.value));
    return entries.first.key;
  }

  StudentSubject get strongestSubject {
    final entries = <MapEntry<StudentSubject, double>>[
      MapEntry(StudentSubject.korean, korean),
      MapEntry(StudentSubject.english, english),
      MapEntry(StudentSubject.math, math),
    ]..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'korean': korean,
    'english': english,
    'math': math,
    'average': average,
    'weakest_subject': subjectLabel(weakestSubject),
    'strongest_subject': subjectLabel(strongestSubject),
  };

  String averageLabel() => average.toStringAsFixed(1);

  static String subjectLabel(StudentSubject subject) {
    return switch (subject) {
      StudentSubject.korean => '국어',
      StudentSubject.english => '영어',
      StudentSubject.math => '수학',
    };
  }
}
