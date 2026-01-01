class ChildModel {
  final String id;
  final String name;
  final String schoolName;
  final String grade;
  final String? photoUrl;
  final String? gender; // 'male' or 'female'

  ChildModel({
    required this.id,
    required this.name,
    required this.schoolName,
    required this.grade,
    this.photoUrl,
    this.gender,
  });

  factory ChildModel.fromMap(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      schoolName: map['school'] ?? '',
      grade: map['grade'] ?? '',
      photoUrl: map['photo_url'],
      gender: map['gender'],
    );
  }
}