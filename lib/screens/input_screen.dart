import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../models/person.dart';
import '../screens/results_screen.dart';
import '../services/compatibility_service.dart';
import '../services/storage_service.dart';
import '../theme/vibescale_theme.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  // Common data
  HowMet? _howMet;
  
  // Person A data
  final _personANameController = TextEditingController();
  DateTime? _personABirthDate;
  Gender? _personAGender;
  int _personAWeight = 70;
  int _personAHeight = 170;
  PersonalityTraits _personAPersonality = PersonalityTraits(
    socialEnergy: 50,
    emotionalStability: 50,
    openness: 50,
    conscientiousness: 50,
  );
  final List<String> _personAActivities = [];
  RelationshipPriority? _personAPriority;

  // Person B data
  final _personBNameController = TextEditingController();
  DateTime? _personBBirthDate;
  Gender? _personBGender;
  int _personBWeight = 70;
  int _personBHeight = 170;
  PersonalityTraits _personBPersonality = PersonalityTraits(
    socialEnergy: 50,
    emotionalStability: 50,
    openness: 50,
    conscientiousness: 50,
  );
  final List<String> _personBActivities = [];
  RelationshipPriority? _personBPriority;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _personANameController.dispose();
    _personBNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final savedData = await StorageService.loadFormData();
    if (savedData != null) {
      setState(() {
        _personANameController.text = savedData['personAName'] ?? '';
        _personBNameController.text = savedData['personBName'] ?? '';
        _personABirthDate = savedData['personABirthDate'];
        _personBBirthDate = savedData['personBBirthDate'];
        _personAGender = savedData['personAGender'] ?? Gender.male;
        _personBGender = savedData['personBGender'] ?? Gender.male;
        _personAWeight = savedData['personAWeight']?.toInt() ?? 70;
        _personBWeight = savedData['personBWeight']?.toInt() ?? 70;
        _personAHeight = savedData['personAHeight']?.toInt() ?? 170;
        _personBHeight = savedData['personBHeight']?.toInt() ?? 170;
        _personAPersonality = savedData['personAPersonality'] ?? PersonalityTraits(socialEnergy: 50, emotionalStability: 50, openness: 50, conscientiousness: 50);
        _personBPersonality = savedData['personBPersonality'] ?? PersonalityTraits(socialEnergy: 50, emotionalStability: 50, openness: 50, conscientiousness: 50);
        _howMet = savedData['howMet'] ?? HowMet.friends;
        _personAActivities.clear();
        _personAActivities.addAll((savedData['personAFavoriteActivities'] as List<FavoriteActivity>?)?.map((e) => e.displayName).toList() ?? []);
        _personBActivities.clear();
        _personBActivities.addAll((savedData['personBFavoriteActivities'] as List<FavoriteActivity>?)?.map((e) => e.displayName).toList() ?? []);
        _personAPriority = savedData['personARelationshipPriority'] ?? RelationshipPriority.trust;
        _personBPriority = savedData['personBRelationshipPriority'] ?? RelationshipPriority.trust;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _calculateCompatibility() async {
    if (_formKey.currentState!.validate()) {
      // Save form data before calculating
      await StorageService.saveFormData(
        personAName: _personANameController.text.trim(),
        personBName: _personBNameController.text.trim(),
        personABirthDate: _personABirthDate!,
        personBBirthDate: _personBBirthDate!,
        personAGender: _personAGender!,
        personBGender: _personBGender!,
        personAWeight: _personAWeight.toDouble(),
        personBWeight: _personBWeight.toDouble(),
        personAHeight: _personAHeight.toDouble(),
        personBHeight: _personBHeight.toDouble(),
        personAPersonality: _personAPersonality,
        personBPersonality: _personBPersonality,
        howMet: _howMet ?? HowMet.friends,
        personAFavoriteActivities: _personAActivities.map((e) => FavoriteActivity.values.firstWhere((fa) => fa.displayName == e, orElse: () => FavoriteActivity.travel)).toList(),
        personBFavoriteActivities: _personBActivities.map((e) => FavoriteActivity.values.firstWhere((fa) => fa.displayName == e, orElse: () => FavoriteActivity.travel)).toList(),
        personARelationshipPriority: _personAPriority!,
        personBRelationshipPriority: _personBPriority!,
      );

      final personA = Person(
        name: _personANameController.text.trim(),
        birthDate: _personABirthDate!,
        gender: _personAGender!,
        weightKg: _personAWeight,
        heightCm: _personAHeight,
        personality: _personAPersonality,
        favoriteActivities: _personAActivities,
        relationshipPriority: _personAPriority!,
      );

      final personB = Person(
        name: _personBNameController.text.trim(),
        birthDate: _personBBirthDate!,
        gender: _personBGender!,
        weightKg: _personBWeight,
        heightCm: _personBHeight,
        personality: _personBPersonality,
        favoriteActivities: _personBActivities,
        relationshipPriority: _personBPriority!,
      );

      final result = CompatibilityService.calculateCompatibility(personA, personB);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResultsScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeScale Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [VibeScaleTheme.backgroundColor, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / _totalPages,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        VibeScaleTheme.gradientStart,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${_currentPage + 1}/$_totalPages',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildBasicInfoPage(),
                    _buildPersonalityPage(),
                    _buildPreferencesPage(),
                  ],
                ),
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: VibeScaleTheme.gradientStart),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage == _totalPages - 1
                          ? _calculateCompatibility
                          : _nextPage,
                      child: Text(
                        _currentPage == _totalPages - 1 ? 'Calculate Vibe' : 'Next',
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

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about you and your partner',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: VibeScaleTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // How you met (common question)
          _buildHowMetSection(),
          const SizedBox(height: 24),
          
          // Person A Section
          _buildPersonSection('Partner A', true),
          const SizedBox(height: 24),
          
          // Person B Section
          _buildPersonSection('Partner B', false),
        ],
      ),
    );
  }

  Widget _buildHowMetSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How did you meet?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<HowMet>(
              value: _howMet,
              decoration: const InputDecoration(
                labelText: 'How did you meet?',
              ),
              items: HowMet.values.map((howMet) {
                return DropdownMenuItem(
                  value: howMet,
                  child: Text(howMet.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _howMet = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select how you met';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonSection(String title, bool isPersonA) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Name
            TextFormField(
              controller: isPersonA ? _personANameController : _personBNameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter first name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Birth Date - Syncfusion DatePicker
            InkWell(
              onTap: () async {
                final date = await _showSyncfusionDatePicker(
                  context,
                  initialDate: isPersonA ? _personABirthDate : _personBBirthDate,
                  title: 'Select ${isPersonA ? "Person A" : "Person B"} Birth Date',
                );
                if (date != null) {
                  setState(() {
                    if (isPersonA) {
                      _personABirthDate = date;
                    } else {
                      _personBBirthDate = date;
                    }
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Birth Date',
                  hintText: 'Tap to select birth date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  isPersonA
                      ? (_personABirthDate != null
                          ? DateFormat('MMM dd, yyyy').format(_personABirthDate!)
                          : 'Select date')
                      : (_personBBirthDate != null
                          ? DateFormat('MMM dd, yyyy').format(_personBBirthDate!)
                          : 'Select date'),
                  style: TextStyle(
                    color: (isPersonA ? _personABirthDate : _personBBirthDate) != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gender - Toggle Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: Gender.values.map((gender) {
                    final isSelected = (isPersonA ? _personAGender : _personBGender) == gender;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isPersonA) {
                                _personAGender = gender;
                              } else {
                                _personBGender = gender;
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? VibeScaleTheme.gradientStart 
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? VibeScaleTheme.gradientStart 
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              gender.displayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Weight and Height
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight: ${isPersonA ? _personAWeight : _personBWeight} kg',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Slider(
                        value: (isPersonA ? _personAWeight : _personBWeight).toDouble(),
                        min: 40,
                        max: 150,
                        divisions: 110,
                        onChanged: (value) {
                          setState(() {
                            if (isPersonA) {
                              _personAWeight = value.round();
                            } else {
                              _personBWeight = value.round();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Height: ${isPersonA ? _personAHeight : _personBHeight} cm',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Slider(
                        value: (isPersonA ? _personAHeight : _personBHeight).toDouble(),
                        min: 140,
                        max: 220,
                        divisions: 80,
                        onChanged: (value) {
                          setState(() {
                            if (isPersonA) {
                              _personAHeight = value.round();
                            } else {
                              _personBHeight = value.round();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personality & Physique',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your personalities',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: VibeScaleTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // Person A Personality
          _buildPersonalitySection('Partner A', true),
          const SizedBox(height: 24),
          
          // Person B Personality
          _buildPersonalitySection('Partner B', false),
        ],
      ),
    );
  }

  Widget _buildPersonalitySection(String title, bool isPersonA) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Personality - Simple Questions
            Text(
              'Personality',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            // Social Energy - Simple Options
            _buildPersonalityQuestion(
              'How do you recharge your energy?',
              [
                'I love being around people and socializing',
                'I prefer quiet time alone or with close friends',
                'I enjoy both, depending on my mood',
              ],
              isPersonA ? _personAPersonality.socialEnergy : _personBPersonality.socialEnergy,
              (value) {
                setState(() {
                  if (isPersonA) {
                    _personAPersonality = PersonalityTraits(
                      socialEnergy: value,
                      emotionalStability: _personAPersonality.emotionalStability,
                      openness: _personAPersonality.openness,
                      conscientiousness: _personAPersonality.conscientiousness,
                    );
                  } else {
                    _personBPersonality = PersonalityTraits(
                      socialEnergy: value,
                      emotionalStability: _personBPersonality.emotionalStability,
                      openness: _personBPersonality.openness,
                      conscientiousness: _personBPersonality.conscientiousness,
                    );
                  }
                });
              },
            ),
            
            // Emotional Stability
            _buildPersonalityQuestion(
              'How do you handle stress?',
              [
                'I stay calm and think logically',
                'I feel emotions deeply and need support',
                'I handle it differently depending on the situation',
              ],
              isPersonA ? _personAPersonality.emotionalStability : _personBPersonality.emotionalStability,
              (value) {
                setState(() {
                  if (isPersonA) {
                    _personAPersonality = PersonalityTraits(
                      socialEnergy: _personAPersonality.socialEnergy,
                      emotionalStability: value,
                      openness: _personAPersonality.openness,
                      conscientiousness: _personAPersonality.conscientiousness,
                    );
                  } else {
                    _personBPersonality = PersonalityTraits(
                      socialEnergy: _personBPersonality.socialEnergy,
                      emotionalStability: value,
                      openness: _personBPersonality.openness,
                      conscientiousness: _personBPersonality.conscientiousness,
                    );
                  }
                });
              },
            ),
            
            // Openness
            _buildPersonalityQuestion(
              'How do you approach new experiences?',
              [
                'I love trying new things and exploring',
                'I prefer familiar and traditional approaches',
                'I\'m open to new things but like some routine',
              ],
              isPersonA ? _personAPersonality.openness : _personBPersonality.openness,
              (value) {
                setState(() {
                  if (isPersonA) {
                    _personAPersonality = PersonalityTraits(
                      socialEnergy: _personAPersonality.socialEnergy,
                      emotionalStability: _personAPersonality.emotionalStability,
                      openness: value,
                      conscientiousness: _personAPersonality.conscientiousness,
                    );
                  } else {
                    _personBPersonality = PersonalityTraits(
                      socialEnergy: _personBPersonality.socialEnergy,
                      emotionalStability: _personBPersonality.emotionalStability,
                      openness: value,
                      conscientiousness: _personBPersonality.conscientiousness,
                    );
                  }
                });
              },
            ),
            
            // Conscientiousness
            _buildPersonalityQuestion(
              'How do you organize your life?',
              [
                'I plan everything and stick to schedules',
                'I prefer to go with the flow and be spontaneous',
                'I plan important things but stay flexible',
              ],
              isPersonA ? _personAPersonality.conscientiousness : _personBPersonality.conscientiousness,
              (value) {
                setState(() {
                  if (isPersonA) {
                    _personAPersonality = PersonalityTraits(
                      socialEnergy: _personAPersonality.socialEnergy,
                      emotionalStability: _personAPersonality.emotionalStability,
                      openness: _personAPersonality.openness,
                      conscientiousness: value,
                    );
                  } else {
                    _personBPersonality = PersonalityTraits(
                      socialEnergy: _personBPersonality.socialEnergy,
                      emotionalStability: _personBPersonality.emotionalStability,
                      openness: _personBPersonality.openness,
                      conscientiousness: value,
                    );
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences & Priorities',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'What matters most to you in a relationship?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: VibeScaleTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // Person A Preferences
          _buildPreferencesSection('Partner A', true),
          const SizedBox(height: 24),
          
          // Person B Preferences
          _buildPreferencesSection('Partner B', false),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(String title, bool isPersonA) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Favorite Activities
            Text(
              'Favorite Activities (select up to 2)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            ...FavoriteActivity.values.map((activity) {
              return CheckboxListTile(
                title: Text(activity.displayName),
                value: (isPersonA ? _personAActivities : _personBActivities)
                    .contains(activity.displayName),
                onChanged: (value) {
                  setState(() {
                    final activities = isPersonA ? _personAActivities : _personBActivities;
                    if (value == true) {
                      if (activities.length < 2) {
                        activities.add(activity.displayName);
                      }
                    } else {
                      activities.remove(activity.displayName);
                    }
                  });
                },
              );
            }),
            
            const SizedBox(height: 16),
            
            // Relationship Priority
            Text(
              'What\'s most important in a relationship?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            ...RelationshipPriority.values.map((priority) {
              return RadioListTile<RelationshipPriority>(
                title: Text(priority.displayName),
                value: priority,
                groupValue: isPersonA ? _personAPriority : _personBPriority,
                onChanged: (value) {
                  setState(() {
                    if (isPersonA) {
                      _personAPriority = value;
                    } else {
                      _personBPriority = value;
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityQuestion(String question, List<String> options, int currentValue, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isSelected = currentValue == (index * 50); // 0, 50, 100
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => onChanged(index * 50),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? VibeScaleTheme.gradientStart.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? VibeScaleTheme.gradientStart 
                        : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected 
                            ? VibeScaleTheme.gradientStart 
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                              ? VibeScaleTheme.gradientStart 
                              : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? VibeScaleTheme.gradientStart : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<DateTime?> _showSyncfusionDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    required String title,
  }) async {
    DateTime selectedDate;
    
    if (initialDate != null) {
      // If date is already filled, start from that year
      selectedDate = initialDate;
    } else {
      // If no date is set, start from 25 years back
      selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));
    }
    
    return showDialog<DateTime?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300,
          height: 350,
          child: SfDateRangePicker(
            initialSelectedDate: selectedDate,
            initialDisplayDate: selectedDate,
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            selectionMode: DateRangePickerSelectionMode.single,
            view: DateRangePickerView.decade,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is DateTime) {
                selectedDate = args.value as DateTime;
              }
            },
            headerStyle: const DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
            ),
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 1,
            ),
            yearCellStyle: const DateRangePickerYearCellStyle(
              textStyle: TextStyle(fontSize: 16),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(selectedDate),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
