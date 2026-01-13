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
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      schoolName: map['school_name'] ?? '',
      grade: map['grade'] ?? '',
      photoUrl: map['photo_url'],
      gender: map['gender'],
      dob: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'])
          : null,
      medicalConditions: map['medical_conditions'],
      notes: map['notes'],
    );
  }
}
