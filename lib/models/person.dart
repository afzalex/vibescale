class Person {
  final String name;
  final DateTime birthDate;
  final Gender gender;
  final int weightKg;
  final int heightCm;
  final PersonalityTraits personality;
  final List<String> favoriteActivities;
  final RelationshipPriority relationshipPriority;

  Person({
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    required this.personality,
    required this.favoriteActivities,
    required this.relationshipPriority,
  });

  int get age {
    final now = DateTime.now();
    return now.year - birthDate.year - (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day) ? 1 : 0);
  }

  String get zodiacSign {
    final month = birthDate.month;
    final day = birthDate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }
}

enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.displayName);
  final String displayName;
}

enum HowMet {
  online('Online'),
  friends('Friends'),
  work('Work'),
  school('School'),
  event('Event');

  const HowMet(this.displayName);
  final String displayName;
}

// Personality traits with slider values (0-100)
class PersonalityTraits {
  final int socialEnergy;      // 0 = Very Introverted, 100 = Very Extroverted
  final int emotionalStability; // 0 = Very Sensitive, 100 = Very Stable
  final int openness;          // 0 = Very Traditional, 100 = Very Open
  final int conscientiousness; // 0 = Very Spontaneous, 100 = Very Organized

  PersonalityTraits({
    required this.socialEnergy,
    required this.emotionalStability,
    required this.openness,
    required this.conscientiousness,
  });

  // Helper method to get overall personality type
  String get personalityType {
    if (socialEnergy >= 70) return 'Extrovert';
    if (socialEnergy <= 30) return 'Introvert';
    return 'Ambivert';
  }
}

// Removed Physique enum - now using weight and height

enum RelationshipPriority {
  trust('Trust'),
  communication('Communication'),
  adventure('Adventure'),
  loyalty('Loyalty');

  const RelationshipPriority(this.displayName);
  final String displayName;
}

enum FavoriteActivity {
  movies('Movies'),
  sports('Sports'),
  reading('Reading'),
  travel('Travel');

  const FavoriteActivity(this.displayName);
  final String displayName;
}
