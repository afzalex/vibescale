// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/person.dart';

class StorageService {
  static const String _personANameKey = 'person_a_name';
  static const String _personBNameKey = 'person_b_name';
  static const String _personABirthDateKey = 'person_a_birth_date';
  static const String _personBBirthDateKey = 'person_b_birth_date';
  static const String _personAGenderKey = 'person_a_gender';
  static const String _personBGenderKey = 'person_b_gender';
  static const String _personAWeightKey = 'person_a_weight';
  static const String _personBWeightKey = 'person_b_weight';
  static const String _personAHeightKey = 'person_a_height';
  static const String _personBHeightKey = 'person_b_height';
  static const String _personASocialEnergyKey = 'person_a_social_energy';
  static const String _personBSocialEnergyKey = 'person_b_social_energy';
  static const String _personAEmotionalStabilityKey = 'person_a_emotional_stability';
  static const String _personBEmotionalStabilityKey = 'person_b_emotional_stability';
  static const String _personAOpennessKey = 'person_a_openness';
  static const String _personBOpennessKey = 'person_b_openness';
  static const String _personAConscientiousnessKey = 'person_a_conscientiousness';
  static const String _personBConscientiousnessKey = 'person_b_conscientiousness';
  static const String _howMetKey = 'how_met';
  static const String _personAFavoriteActivitiesKey = 'person_a_favorite_activities';
  static const String _personBFavoriteActivitiesKey = 'person_b_favorite_activities';
  static const String _personARelationshipPriorityKey = 'person_a_relationship_priority';
  static const String _personBRelationshipPriorityKey = 'person_b_relationship_priority';

  static Future<void> saveFormData({
    required String personAName,
    required String personBName,
    required DateTime? personABirthDate,
    required DateTime? personBBirthDate,
    required Gender personAGender,
    required Gender personBGender,
    required double personAWeight,
    required double personBWeight,
    required double personAHeight,
    required double personBHeight,
    required PersonalityTraits personAPersonality,
    required PersonalityTraits personBPersonality,
    required HowMet howMet,
    required List<FavoriteActivity> personAFavoriteActivities,
    required List<FavoriteActivity> personBFavoriteActivities,
    required RelationshipPriority personARelationshipPriority,
    required RelationshipPriority personBRelationshipPriority,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_personANameKey, personAName);
    await prefs.setString(_personBNameKey, personBName);
    
    if (personABirthDate != null) {
      await prefs.setString(_personABirthDateKey, DateFormat('yyyy-MM-dd').format(personABirthDate));
    }
    if (personBBirthDate != null) {
      await prefs.setString(_personBBirthDateKey, DateFormat('yyyy-MM-dd').format(personBBirthDate));
    }
    
    await prefs.setString(_personAGenderKey, personAGender.name);
    await prefs.setString(_personBGenderKey, personBGender.name);
    
    await prefs.setDouble(_personAWeightKey, personAWeight);
    await prefs.setDouble(_personBWeightKey, personBWeight);
    await prefs.setDouble(_personAHeightKey, personAHeight);
    await prefs.setDouble(_personBHeightKey, personBHeight);
    
    await prefs.setInt(_personASocialEnergyKey, personAPersonality.socialEnergy);
    await prefs.setInt(_personBSocialEnergyKey, personBPersonality.socialEnergy);
    await prefs.setInt(_personAEmotionalStabilityKey, personAPersonality.emotionalStability);
    await prefs.setInt(_personBEmotionalStabilityKey, personBPersonality.emotionalStability);
    await prefs.setInt(_personAOpennessKey, personAPersonality.openness);
    await prefs.setInt(_personBOpennessKey, personBPersonality.openness);
    await prefs.setInt(_personAConscientiousnessKey, personAPersonality.conscientiousness);
    await prefs.setInt(_personBConscientiousnessKey, personBPersonality.conscientiousness);
    
    await prefs.setString(_howMetKey, howMet.name);
    
    await prefs.setStringList(_personAFavoriteActivitiesKey, personAFavoriteActivities.map((e) => e.displayName).toList());
    await prefs.setStringList(_personBFavoriteActivitiesKey, personBFavoriteActivities.map((e) => e.displayName).toList());
    
    await prefs.setString(_personARelationshipPriorityKey, personARelationshipPriority.name);
    await prefs.setString(_personBRelationshipPriorityKey, personBRelationshipPriority.name);
  }

  static Future<Map<String, dynamic>?> loadFormData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have any saved data
    if (!prefs.containsKey(_personANameKey)) {
      return null;
    }
    
    try {
      final personAName = prefs.getString(_personANameKey) ?? '';
      final personBName = prefs.getString(_personBNameKey) ?? '';
      
      DateTime? personABirthDate;
      DateTime? personBBirthDate;
      
      final personABirthDateStr = prefs.getString(_personABirthDateKey);
      if (personABirthDateStr != null) {
        personABirthDate = DateFormat('yyyy-MM-dd').parse(personABirthDateStr);
      }
      
      final personBBirthDateStr = prefs.getString(_personBBirthDateKey);
      if (personBBirthDateStr != null) {
        personBBirthDate = DateFormat('yyyy-MM-dd').parse(personBBirthDateStr);
      }
      
      final personAGender = Gender.values.firstWhere(
        (e) => e.name == prefs.getString(_personAGenderKey),
        orElse: () => Gender.male,
      );
      final personBGender = Gender.values.firstWhere(
        (e) => e.name == prefs.getString(_personBGenderKey),
        orElse: () => Gender.male,
      );
      
      final personAWeight = prefs.getDouble(_personAWeightKey) ?? 70.0;
      final personBWeight = prefs.getDouble(_personBWeightKey) ?? 70.0;
      final personAHeight = prefs.getDouble(_personAHeightKey) ?? 170.0;
      final personBHeight = prefs.getDouble(_personBHeightKey) ?? 170.0;
      
      final personAPersonality = PersonalityTraits(
        socialEnergy: prefs.getInt(_personASocialEnergyKey) ?? 50,
        emotionalStability: prefs.getInt(_personAEmotionalStabilityKey) ?? 50,
        openness: prefs.getInt(_personAOpennessKey) ?? 50,
        conscientiousness: prefs.getInt(_personAConscientiousnessKey) ?? 50,
      );
      
      final personBPersonality = PersonalityTraits(
        socialEnergy: prefs.getInt(_personBSocialEnergyKey) ?? 50,
        emotionalStability: prefs.getInt(_personBEmotionalStabilityKey) ?? 50,
        openness: prefs.getInt(_personBOpennessKey) ?? 50,
        conscientiousness: prefs.getInt(_personBConscientiousnessKey) ?? 50,
      );
      
      final howMet = HowMet.values.firstWhere(
        (e) => e.name == prefs.getString(_howMetKey),
        orElse: () => HowMet.friends,
      );
      
      final personAFavoriteActivities = (prefs.getStringList(_personAFavoriteActivitiesKey) ?? [])
          .map((e) => FavoriteActivity.values.firstWhere((fa) => fa.displayName == e, orElse: () => FavoriteActivity.travel))
          .toList();
      
      final personBFavoriteActivities = (prefs.getStringList(_personBFavoriteActivitiesKey) ?? [])
          .map((e) => FavoriteActivity.values.firstWhere((fa) => fa.displayName == e, orElse: () => FavoriteActivity.travel))
          .toList();
      
      final personARelationshipPriority = RelationshipPriority.values.firstWhere(
        (e) => e.name == prefs.getString(_personARelationshipPriorityKey),
        orElse: () => RelationshipPriority.trust,
      );
      
      final personBRelationshipPriority = RelationshipPriority.values.firstWhere(
        (e) => e.name == prefs.getString(_personBRelationshipPriorityKey),
        orElse: () => RelationshipPriority.trust,
      );
      
      return {
        'personAName': personAName,
        'personBName': personBName,
        'personABirthDate': personABirthDate,
        'personBBirthDate': personBBirthDate,
        'personAGender': personAGender,
        'personBGender': personBGender,
        'personAWeight': personAWeight,
        'personBWeight': personBWeight,
        'personAHeight': personAHeight,
        'personBHeight': personBHeight,
        'personAPersonality': personAPersonality,
        'personBPersonality': personBPersonality,
        'howMet': howMet,
        'personAFavoriteActivities': personAFavoriteActivities,
        'personBFavoriteActivities': personBFavoriteActivities,
        'personARelationshipPriority': personARelationshipPriority,
        'personBRelationshipPriority': personBRelationshipPriority,
      };
    } catch (e) {
      // If there's an error loading data, return null
      return null;
    }
  }

  static Future<void> clearFormData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
