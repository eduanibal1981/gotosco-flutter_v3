class ChildModel {
  final String id;
  final String name;
  final String schoolName;
  final String grade;
  final String? photoUrl;
  final String? gender; // 'male' or 'female'
  final DateTime? dob;
  final String? medicalConditions;
  final String? notes;
  final String? schoolId;
  final String? cityName;

  ChildModel({
    required this.id,
    required this.name,
    required this.schoolName,
    required this.grade,
    this.photoUrl,
    this.gender,
    this.dob,
    this.medicalConditions,
    this.notes,
    this.schoolId,
    this.cityName,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    // Handle join: school: { name: ... }
    String fetchedSchoolName = map['school_name'] ?? '';
    String? fetchedCityName;

    if (map['schools'] != null) {
      if (map['schools']['name'] != null) {
        fetchedSchoolName = map['schools']['name'];
      }
      // Check for nested city
      if (map['schools']['cities'] != null &&
          map['schools']['cities']['name'] != null) {
        fetchedCityName = map['schools']['cities']['name'];
      }
    }

    return ChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      schoolName: fetchedSchoolName,
      grade: map['grade'] ?? '',
      photoUrl: map['photo_url'],
      gender: map['gender'],
      dob: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'])
          : null,
      medicalConditions: map['medical_conditions'],
      notes: map['notes'],
      schoolId: map['school_id'],
      cityName: fetchedCityName,
    );
  }
}
