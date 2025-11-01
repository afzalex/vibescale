import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/compatibility_result.dart';
import '../theme/vibescale_theme.dart';
import '../widgets/share_widget.dart';
import '../widgets/compatibility_meters.dart';
import '../services/storage_service.dart';
import '../screens/welcome_screen.dart';

class ResultsScreen extends StatefulWidget {
  final CompatibilityResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ConfettiController _confettiController;
  bool _hasShownConfetti = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _animationController.forward();
    
    // Show confetti for high scores
    if (widget.result.overallScore >= 85) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _confettiController.play();
          _hasShownConfetti = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [VibeScaleTheme.backgroundColor, Colors.white],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Header
                    _buildHeader(),
                    const SizedBox(height: 32),
                    
                    // Score Meters
                    _buildScoreMeters(),
                    const SizedBox(height: 32),
                    
                    // Explanation
                    _buildExplanation(),
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
          
          // Confetti
          if (_hasShownConfetti)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.57, // Downward
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.3,
                shouldLoop: false,
                colors: const [
                  VibeScaleTheme.loveColor,
                  VibeScaleTheme.trustColor,
                  VibeScaleTheme.communicationColor,
                  Colors.pink,
                  Colors.purple,
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: VibeScaleTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.favorite,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Vibe Results',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.result.personA.name} & ${widget.result.personB.name}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreMeters() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CompatibilityResultCard(
          overall: widget.result.overallScore,
          subscores: {
            'Love': widget.result.loveScore,
            'Communication': widget.result.communicationScore,
            'Trust': widget.result.trustScore,
          },
          title: '${widget.result.personA.name} & ${widget.result.personB.name}',
        );
      },
    );
  }


  String _getScoreText(double score) {
    if (score >= 90) return 'Exceptional';
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Great';
    if (score >= 60) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs Work';
  }

  Widget _buildExplanation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: VibeScaleTheme.gradientStart,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'What This Means',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.result.explanation,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VibeScaleTheme.gradientStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: VibeScaleTheme.gradientStart,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Remember: This is just for fun! Real relationships are built on communication, trust, and mutual respect.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showShareDialog(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Your Results'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              // Navigate to welcome screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: VibeScaleTheme.gradientStart),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () async {
              // Clear saved data and go to welcome screen
              await StorageService.clearFormData();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.clear_all),
            label: const Text('Start Fresh'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ShareWidget(result: widget.result),
    );
  }
}
