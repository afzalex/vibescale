import 'person.dart';

class CompatibilityResult {
  final double loveScore;
  final double communicationScore;
  final double trustScore;
  final double overallScore;
  final String explanation;
  final Person personA;
  final Person personB;

  CompatibilityResult({
    required this.loveScore,
    required this.communicationScore,
    required this.trustScore,
    required this.overallScore,
    required this.explanation,
    required this.personA,
    required this.personB,
  });

  Map<String, double> get scoresAsMap => {
    'Love': loveScore,
    'Communication': communicationScore,
    'Trust': trustScore,
    'Overall': overallScore,
  };

  String get loveScoreText => _getScoreText(loveScore);
  String get communicationScoreText => _getScoreText(communicationScore);
  String get trustScoreText => _getScoreText(trustScore);
  String get overallScoreText => _getScoreText(overallScore);

  String _getScoreText(double score) {
    if (score >= 90) return 'Exceptional';
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Great';
    if (score >= 60) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Work';
  }
}
