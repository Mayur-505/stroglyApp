import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
import '../models/progress_models.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/steps_gauge_card.dart';
import '../widgets/weekly_bar_chart_card.dart';
import '../widgets/weekly_calendar_card.dart';
import 'progress_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProgressScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ProgressScreen> createState() => ProgressScreenState();
}

class ProgressScreenState extends State<ProgressScreen> {
  List<DayStatusItem> _weekDays = [];
  ProgressStatItem? _workoutStat;
  ProgressStatItem? _caloriesStat;
  ProgressStatItem? _weightStat;
  int _currentSteps = 0;
  int _targetSteps = 6000;
  WeeklyActivityChartData? _workoutChart;
  WeeklyActivityChartData? _calorieChart;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchDashboard();
    }
  }

  /// Public method — HomeScreen calls this via GlobalKey when Progress tab is tapped
  Future<void> fetchDashboard() => _fetchDashboard();

  Future<void> _fetchDashboard() async {
    try {
      final res = await ApiClient.instance.get('/progress/dashboard');
      final Map<String, dynamic> data =
          (res.isOk && res.data is Map<String, dynamic>)
              ? res.data as Map<String, dynamic>
              : <String, dynamic>{};

      final rawDays = data['weekDays'] as List<dynamic>? ?? [];
      final stats = data['stats'] as Map<String, dynamic>? ?? {};
      final charts = data['charts'] as Map<String, dynamic>? ?? {};

      if (mounted) {
        setState(() {
          _weekDays = rawDays.isNotEmpty
              ? rawDays
                  .map((e) => DayStatusItem.fromJson(Map<String, dynamic>.from(e as Map)))
                  .toList()
              : _buildDefaultWeekDays();

          _workoutStat = stats['workout'] != null
              ? ProgressStatItem.fromJson(Map<String, dynamic>.from(stats['workout'] as Map))
              : ProgressStatItem(
                  title: 'Workout', unit: 'min', totalValue: '0', weekValue: '0');

          _caloriesStat = stats['calories'] != null
              ? ProgressStatItem.fromJson(Map<String, dynamic>.from(stats['calories'] as Map))
              : ProgressStatItem(
                  title: 'Calories', unit: 'cal', totalValue: '0', weekValue: '0');

          _weightStat = stats['weight'] != null
              ? ProgressStatItem.fromJson(Map<String, dynamic>.from(stats['weight'] as Map))
              : ProgressStatItem(
                  title: 'Weight', unit: 'lbs', totalValue: '0', weekValue: '0');

          if (stats['steps'] != null) {
            final s = stats['steps'] as Map<String, dynamic>;
            _currentSteps = (s['currentSteps'] is int)
                ? s['currentSteps'] as int
                : int.tryParse(s['currentSteps']?.toString() ?? '0') ?? 0;
            _targetSteps = (s['targetSteps'] is int)
                ? s['targetSteps'] as int
                : int.tryParse(s['targetSteps']?.toString() ?? '6000') ?? 6000;
          } else {
            _currentSteps = 0;
            _targetSteps = 6000;
          }

          _workoutChart = charts['workoutChart'] != null
              ? WeeklyActivityChartData.fromJson(
                  Map<String, dynamic>.from(charts['workoutChart'] as Map))
              : _buildDefaultChart('Workout', '0 min');

          _calorieChart = charts['calorieChart'] != null
              ? WeeklyActivityChartData.fromJson(
                  Map<String, dynamic>.from(charts['calorieChart'] as Map))
              : _buildDefaultChart('Calories', '0 Calories');
        });
      }
    } catch (e) {
      debugPrint('[ProgressScreen] Error fetching dashboard: $e');
      if (mounted) {
        setState(() {
          _weekDays = _buildDefaultWeekDays();
          _workoutStat = ProgressStatItem(title: 'Workout', unit: 'min', totalValue: '0', weekValue: '0');
          _caloriesStat = ProgressStatItem(title: 'Calories', unit: 'cal', totalValue: '0', weekValue: '0');
          _weightStat = ProgressStatItem(title: 'Weight', unit: 'lbs', totalValue: '0', weekValue: '0');
          _currentSteps = 0;
          _targetSteps = 6000;
          _workoutChart = _buildDefaultChart('Workout', '0 min');
          _calorieChart = _buildDefaultChart('Calories', '0 Calories');
        });
      }
    }
  }

  List<DayStatusItem> _buildDefaultWeekDays() {
    final today = DateTime.now();
    final dayOfWeek = today.weekday % 7; // 0 = Sunday
    final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final sunday = today.subtract(Duration(days: dayOfWeek));
    return List.generate(7, (i) {
      final d = sunday.add(Duration(days: i));
      return DayStatusItem(
        dayName: dayNames[i],
        dateText: '${d.day}',
        isCompleted: false,
        isToday: d.day == today.day && d.month == today.month,
      );
    });
  }

  WeeklyActivityChartData _buildDefaultChart(String title, String avg) {
    final dayNames = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return WeeklyActivityChartData(
      metricTitle: title,
      weeklyAverageText: avg,
      mainValueText: avg,
      days: List.generate(
        7,
        (i) => WeeklyChartDayData(dayLabel: dayNames[i], value: 0.0, hasActivity: false, isHighlighted: false),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, ProgressTabType tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProgressDetailScreen(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFCEFF00),
      backgroundColor: const Color(0xFF161619),
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 10.0,
          bottom: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Back Arrow + "Progress" Title
            Row(
              children: [
                GestureDetector(
                  key: const ValueKey('progress_back_button'),
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  LanguageService.tr('progress_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Weekly Day Calendar Card (Tapping opens History Tab)
            WeeklyCalendarCard(
              days: _weekDays.isNotEmpty ? _weekDays : _buildDefaultWeekDays(),
              onTap: () => _navigateToDetail(context, ProgressTabType.history),
            ),

            const SizedBox(height: 14),

            // 2. 2x2 Stats Grid
            Row(
              children: [
                Expanded(
                  child: ProgressStatCard(
                    stat: _workoutStat ?? ProgressStatItem(title: 'Workout', unit: 'min', totalValue: '0', weekValue: '0'),
                    onTap: () => _navigateToDetail(context, ProgressTabType.summary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ProgressStatCard(
                    stat: _caloriesStat ?? ProgressStatItem(title: 'Calories', unit: 'cal', totalValue: '0', weekValue: '0'),
                    onTap: () => _navigateToDetail(context, ProgressTabType.summary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Weight & Steps
            Row(
              children: [
                Expanded(
                  child: ProgressStatCard(
                    stat: _weightStat ?? ProgressStatItem(title: 'Weight', unit: 'lbs', totalValue: '0', weekValue: '0'),
                    onTap: () => _navigateToDetail(context, ProgressTabType.summary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StepsGaugeCard(
                    currentSteps: _currentSteps,
                    targetSteps: _targetSteps,
                    onTap: () => _navigateToDetail(context, ProgressTabType.summary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 3. Workout Weekly Chart Card
            WeeklyBarChartCard(
              chartData: _workoutChart ?? _buildDefaultChart('Workout', '0 min'),
              onTap: () => _navigateToDetail(context, ProgressTabType.summary),
            ),

            const SizedBox(height: 14),

            // 4. Calorie Weekly Chart Card
            WeeklyBarChartCard(
              chartData: _calorieChart ?? _buildDefaultChart('Calories', '0 Calories'),
              onTap: () => _navigateToDetail(context, ProgressTabType.summary),
            ),
          ],
        ),
      ),
    );
  }
}

