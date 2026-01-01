// Global enums
// lib/core/constants/enums.dart

enum UserRole {
  parent,
  driver,
  admin;

  String toDbString() => name; // Helper for Supabase
}

enum SubscriptionType {
  monthlyTwoWay, // Morning & Afternoon
  monthlyOneWay, // Morning OR Afternoon only
  daily, // One-off trip
}

enum RideStatus { pending, accepted, enRoute, droppedOff, cancelled }

// For your "Drivers cover specific areas" logic
enum CityRegion {
  muscat,
  salalah,
  sohar,
  // Add more...
}
