class RegionMetrics {
  const RegionMetrics({
    required this.regionName,
    required this.schoolCount,
    required this.studentCount,
    required this.maleStudents,
    required this.femaleStudents,
    required this.classCount,
    required this.teacherCount,
    required this.avgStudentsPerSchool,
    required this.avgStudentsPerClass,
    required this.studentsPerTeacher,
    required this.population,
    required this.academyCount,
    required this.academyCapacity,
    required this.pensionAvgIncome,
    required this.academyPer1000Students,
    required this.schoolsPer100kPopulation,
    required this.highSchoolStudentsPer1000Population,
    required this.maleShare,
    required this.femaleShare,
    required this.sourceScope,
  });

  factory RegionMetrics.fromCsv(Map<String, String> row) {
    double parse(String key) => double.tryParse(row[key] ?? '') ?? 0;

    return RegionMetrics(
      regionName: row['region_name'] ?? '',
      schoolCount: parse('school_count'),
      studentCount: parse('student_count'),
      maleStudents: parse('male_students'),
      femaleStudents: parse('female_students'),
      classCount: parse('class_count'),
      teacherCount: parse('teacher_count'),
      avgStudentsPerSchool: parse('avg_students_per_school'),
      avgStudentsPerClass: parse('avg_students_per_class'),
      studentsPerTeacher: parse('students_per_teacher'),
      population: parse('population'),
      academyCount: parse('academy_count'),
      academyCapacity: parse('academy_capacity'),
      pensionAvgIncome: parse('pension_avg_income'),
      academyPer1000Students: parse('academy_per_1000_students'),
      schoolsPer100kPopulation: parse('schools_per_100k_population'),
      highSchoolStudentsPer1000Population: parse(
        'high_school_students_per_1000_population',
      ),
      maleShare: parse('male_share'),
      femaleShare: parse('female_share'),
      sourceScope: row['source_scope'] ?? '',
    );
  }

  final String regionName;
  final double schoolCount;
  final double studentCount;
  final double maleStudents;
  final double femaleStudents;
  final double classCount;
  final double teacherCount;
  final double avgStudentsPerSchool;
  final double avgStudentsPerClass;
  final double studentsPerTeacher;
  final double population;
  final double academyCount;
  final double academyCapacity;
  final double pensionAvgIncome;
  final double academyPer1000Students;
  final double schoolsPer100kPopulation;
  final double highSchoolStudentsPer1000Population;
  final double maleShare;
  final double femaleShare;
  final String sourceScope;

  List<String> get tokens => regionName.split(' ');

  String get province => tokens.isEmpty ? regionName : tokens.first;

  String get district =>
      tokens.length <= 1 ? regionName : tokens.sublist(1).join(' ');
}
