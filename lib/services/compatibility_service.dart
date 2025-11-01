import 'dart:math';
import '../models/person.dart';
import '../models/compatibility_result.dart';

class CompatibilityService {
  static const Map<String, Map<String, double>> _zodiacCompatibility = {
    'Aries': {
      'Aries': 0.8, 'Taurus': 0.6, 'Gemini': 0.7, 'Cancer': 0.5,
      'Leo': 0.9, 'Virgo': 0.6, 'Libra': 0.7, 'Scorpio': 0.6,
      'Sagittarius': 0.8, 'Capricorn': 0.5, 'Aquarius': 0.7, 'Pisces': 0.6,
    },
    'Taurus': {
      'Aries': 0.6, 'Taurus': 0.8, 'Gemini': 0.5, 'Cancer': 0.7,
      'Leo': 0.6, 'Virgo': 0.9, 'Libra': 0.8, 'Scorpio': 0.7,
      'Sagittarius': 0.5, 'Capricorn': 0.8, 'Aquarius': 0.6, 'Pisces': 0.7,
    },
    'Gemini': {
      'Aries': 0.7, 'Taurus': 0.5, 'Gemini': 0.8, 'Cancer': 0.6,
      'Leo': 0.7, 'Virgo': 0.6, 'Libra': 0.9, 'Scorpio': 0.5,
      'Sagittarius': 0.8, 'Capricorn': 0.6, 'Aquarius': 0.9, 'Pisces': 0.6,
    },
    'Cancer': {
      'Aries': 0.5, 'Taurus': 0.7, 'Gemini': 0.6, 'Cancer': 0.8,
      'Leo': 0.6, 'Virgo': 0.7, 'Libra': 0.6, 'Scorpio': 0.8,
      'Sagittarius': 0.5, 'Capricorn': 0.7, 'Aquarius': 0.6, 'Pisces': 0.9,
    },
    'Leo': {
      'Aries': 0.9, 'Taurus': 0.6, 'Gemini': 0.7, 'Cancer': 0.6,
      'Leo': 0.8, 'Virgo': 0.5, 'Libra': 0.8, 'Scorpio': 0.7,
      'Sagittarius': 0.9, 'Capricorn': 0.6, 'Aquarius': 0.7, 'Pisces': 0.6,
    },
    'Virgo': {
      'Aries': 0.6, 'Taurus': 0.9, 'Gemini': 0.6, 'Cancer': 0.7,
      'Leo': 0.5, 'Virgo': 0.8, 'Libra': 0.6, 'Scorpio': 0.7,
      'Sagittarius': 0.6, 'Capricorn': 0.9, 'Aquarius': 0.6, 'Pisces': 0.7,
    },
    'Libra': {
      'Aries': 0.7, 'Taurus': 0.8, 'Gemini': 0.9, 'Cancer': 0.6,
      'Leo': 0.8, 'Virgo': 0.6, 'Libra': 0.8, 'Scorpio': 0.6,
      'Sagittarius': 0.7, 'Capricorn': 0.6, 'Aquarius': 0.8, 'Pisces': 0.7,
    },
    'Scorpio': {
      'Aries': 0.6, 'Taurus': 0.7, 'Gemini': 0.5, 'Cancer': 0.8,
      'Leo': 0.7, 'Virgo': 0.7, 'Libra': 0.6, 'Scorpio': 0.8,
      'Sagittarius': 0.6, 'Capricorn': 0.7, 'Aquarius': 0.6, 'Pisces': 0.8,
    },
    'Sagittarius': {
      'Aries': 0.8, 'Taurus': 0.5, 'Gemini': 0.8, 'Cancer': 0.5,
      'Leo': 0.9, 'Virgo': 0.6, 'Libra': 0.7, 'Scorpio': 0.6,
      'Sagittarius': 0.8, 'Capricorn': 0.6, 'Aquarius': 0.8, 'Pisces': 0.6,
    },
    'Capricorn': {
      'Aries': 0.5, 'Taurus': 0.8, 'Gemini': 0.6, 'Cancer': 0.7,
      'Leo': 0.6, 'Virgo': 0.9, 'Libra': 0.6, 'Scorpio': 0.7,
      'Sagittarius': 0.6, 'Capricorn': 0.8, 'Aquarius': 0.6, 'Pisces': 0.7,
    },
    'Aquarius': {
      'Aries': 0.7, 'Taurus': 0.6, 'Gemini': 0.9, 'Cancer': 0.6,
      'Leo': 0.7, 'Virgo': 0.6, 'Libra': 0.8, 'Scorpio': 0.6,
      'Sagittarius': 0.8, 'Capricorn': 0.6, 'Aquarius': 0.8, 'Pisces': 0.7,
    },
    'Pisces': {
      'Aries': 0.6, 'Taurus': 0.7, 'Gemini': 0.6, 'Cancer': 0.9,
      'Leo': 0.6, 'Virgo': 0.7, 'Libra': 0.7, 'Scorpio': 0.8,
      'Sagittarius': 0.6, 'Capricorn': 0.7, 'Aquarius': 0.7, 'Pisces': 0.8,
    },
  };

  // Removed HowMet weights - now asking once in the form

  static CompatibilityResult calculateCompatibility(Person personA, Person personB) {
    // Name similarity using Jaccard index
    final nameSim = _jaccardSimilarity(
      personA.name.toLowerCase().split('').toSet(),
      personB.name.toLowerCase().split('').toSet(),
    );

    // Age difference penalty
    final ageDiff = (personA.age - personB.age).abs();
    final ageDiffPenalty = ageDiff > 10 ? 0.1 : 0.0;

    // Zodiac compatibility
    final zodiacCompat = _zodiacCompatibility[personA.zodiacSign]?[personB.zodiacSign] ?? 0.7;

    // BMI compatibility (using weight and height)
    final bmiA = personA.weightKg / ((personA.heightCm / 100) * (personA.heightCm / 100));
    final bmiB = personB.weightKg / ((personB.heightCm / 100) * (personB.heightCm / 100));
    final bmiCompatibility = 1.0 - ((bmiA - bmiB).abs() / 10).clamp(0.0, 1.0);

    // Personality similarity (using trait compatibility)
    final personalitySim = _calculatePersonalityCompatibility(personA.personality, personB.personality);

    // Gender compatibility (opposite genders get slight boost)
    final genderCompatibility = personA.gender != personB.gender ? 1.1 : 1.0;

    // Preferences overlap
    final prefsOverlap = _jaccardSimilarity(
      personA.favoriteActivities.toSet(),
      personB.favoriteActivities.toSet(),
    );

    // Priority match
    final priorityMatch = personA.relationshipPriority == personB.relationshipPriority ? 1.0 : 0.5;

    // Calculate scores
    final loveScore = (0.3 * (nameSim + bmiCompatibility) + 
                      0.5 * zodiacCompat + 
                      0.2 * prefsOverlap - 
                      ageDiffPenalty).clamp(0.0, 1.0) * genderCompatibility;

    final communicationScore = (0.7 * personalitySim + 
                               0.3 * prefsOverlap).clamp(0.0, 1.0);

    final trustScore = (0.6 * priorityMatch + 
                        0.4 * personalitySim).clamp(0.0, 1.0);

    final overallScore = (loveScore + communicationScore + trustScore) / 3;

    // Add slight randomness for replay value
    final random = Random(42);
    final noise = (random.nextDouble() * 0.06 - 0.03); // ±3%

    final finalLoveScore = ((loveScore * 100) + noise).clamp(0, 100).toDouble();
    final finalCommScore = ((communicationScore * 100) + noise).clamp(0, 100).toDouble();
    final finalTrustScore = ((trustScore * 100) + noise).clamp(0, 100).toDouble();
    final finalOverallScore = ((overallScore * 100) + noise).clamp(0, 100).toDouble();

    return CompatibilityResult(
      loveScore: finalLoveScore,
      communicationScore: finalCommScore,
      trustScore: finalTrustScore,
      overallScore: finalOverallScore,
      explanation: _generateExplanation(
        finalLoveScore, 
        finalCommScore, 
        finalTrustScore, 
        zodiacCompat, 
        priorityMatch,
      ),
      personA: personA,
      personB: personB,
    );
  }

  static double _jaccardSimilarity(Set<String> setA, Set<String> setB) {
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return union > 0 ? intersection / union : 0.0;
  }

  static double _calculatePersonalityCompatibility(PersonalityTraits traitsA, PersonalityTraits traitsB) {
    // Calculate compatibility for each trait
    final socialCompatibility = _calculateTraitCompatibility(traitsA.socialEnergy, traitsB.socialEnergy);
    final emotionalCompatibility = _calculateTraitCompatibility(traitsA.emotionalStability, traitsB.emotionalStability);
    final opennessCompatibility = _calculateTraitCompatibility(traitsA.openness, traitsB.openness);
    final conscientiousnessCompatibility = _calculateTraitCompatibility(traitsA.conscientiousness, traitsB.conscientiousness);
    
    // Weighted average (social energy is most important for communication)
    return (socialCompatibility * 0.4 + 
            emotionalCompatibility * 0.3 + 
            opennessCompatibility * 0.2 + 
            conscientiousnessCompatibility * 0.1);
  }

  static double _calculateTraitCompatibility(int traitA, int traitB) {
    // Similar traits get higher compatibility, but some difference is good
    final difference = (traitA - traitB).abs();
    
    if (difference <= 10) return 0.9; // Very similar
    if (difference <= 30) return 0.8; // Somewhat similar
    if (difference <= 50) return 0.6; // Moderate difference
    if (difference <= 70) return 0.4; // Quite different
    return 0.2; // Very different
  }

  // Removed physique calculation - now using BMI compatibility

  static String _generateExplanation(
    double loveScore, 
    double commScore, 
    double trustScore, 
    double zodiacCompat, 
    double priorityMatch,
  ) {
    if (zodiacCompat > 0.8) {
      return "Your zodiac signs create amazing cosmic chemistry! 🌟";
    }
    if (priorityMatch > 0.8) {
      return "You share the same relationship priorities - that's relationship gold! 💎";
    }
    if (loveScore > 85) {
      return "The love vibes between you two are absolutely electric! ⚡";
    }
    if (trustScore > 85) {
      return "Your trust foundation is rock solid - that's the secret to lasting love! 🏗️";
    }
    if (commScore > 85) {
      return "Your communication styles mesh perfectly - you just get each other! 💬";
    }
    return "You have a unique connection that's worth exploring! ✨";
  }
}
