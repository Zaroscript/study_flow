import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/user_profile.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../widgets/animated_pulse_emblem.dart';
import '../widgets/grade_card_selector.dart';
import '../widgets/onboarding_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentPage = 0;
  String? _selectedGrade = 'المرحلة الثانوية';
  int _selectedDailyTargetMinutes = 90;
  String _preferredTime = 'مسائي';
  bool _enableDailyReminder = true;

  String? _nameError;
  String? _gradeError;
  bool _isSubmitting = false;

  static const int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1) {
      final name = _nameController.text.trim();
      bool hasError = false;

      setState(() {
        _nameError = null;
        _gradeError = null;
      });

      if (name.isEmpty) {
        setState(() => _nameError = 'يرجى إدخال اسم الطالب للمتابعة.');
        hasError = true;
      }
      if (_selectedGrade == null || _selectedGrade!.isEmpty) {
        setState(() => _gradeError = 'يرجى اختيار المرحلة الدراسية.');
        hasError = true;
      }

      if (hasError) {
        AppHaptics.lightImpact();
        return;
      }
    }

    if (_currentPage < _totalPages - 1) {
      AppHaptics.selectionClick();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      AppHaptics.selectionClick();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _skipToSetup() {
    AppHaptics.selectionClick();
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _handleFinish() async {
    final name = _nameController.text.trim();
    final grade = _selectedGrade ?? 'المرحلة الثانوية';

    if (name.isEmpty) {
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _nameError = 'يرجى إدخال اسم الطالب.');
      return;
    }

    setState(() => _isSubmitting = true);
    AppHaptics.mediumImpact();

    try {
      final profile = UserProfile(name: name, grade: grade);

      // Persist profile in SQLite database via Riverpod notifier
      await ref.read(profileProvider.notifier).saveProfile(profile);

      // Persist onboarding completed flag in SharedPreferences
      await ref.read(preferencesServiceProvider).setOnboardingCompleted(true);

      AppHaptics.heavyImpact();

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _nameError = 'حدث خطأ أثناء حفظ البيانات، يرجى المحاولة ثانية.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF13111C) : const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button or App Logo
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded), // RTL Back
                          tooltip: 'السابق',
                          onPressed: _previousPage,
                        )
                      else
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [AppColors.primary, AppColors.secondary],
                                ),
                              ),
                              child: const Icon(Icons.school, color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ENote',
                              style: AppTextStyles.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),

                      // Animated Page Dots Indicator
                      OnboardingPageIndicator(
                        count: _totalPages,
                        currentIndex: _currentPage,
                        onDotTapped: (index) {
                          if (index < _currentPage) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                      ),

                      // Skip Button
                      if (_currentPage < _totalPages - 1)
                        TextButton(
                          onPressed: _skipToSetup,
                          child: Text(
                            'تخطي',
                            style: AppTextStyles.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Slide Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildWelcomeSlide(isDark),
                      _buildProfileSetupSlide(isDark),
                      _buildPreferencesSlide(isDark),
                      _buildReadySlide(isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SLIDE 1: WELCOME & HIGHLIGHTS ---
  Widget _buildWelcomeSlide(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const AnimatedPulseEmblem(
            icon: Icons.school_rounded,
            size: 96,
          ),
          const SizedBox(height: 24),
          Text(
            'مرحباً بك في ENote',
            textAlign: TextAlign.center,
            style: AppTextStyles.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'منظومتك الدراسية المتكاملة لإدارة المذاكرة، مؤقت التركيز، والمكتبة بدون تشتت.',
            textAlign: TextAlign.center,
            style: AppTextStyles.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // 3 Feature Cards
          _buildFeatureRow(
            icon: Icons.timer_outlined,
            color: Colors.indigo,
            title: 'مؤقت بومودورو 3D تفاعلي',
            desc: 'ساعة قلابة ميكانيكية تحافظ على تركيزك بجلسات مخصصة.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            icon: Icons.folder_open_rounded,
            color: Colors.blue,
            title: 'مكتبة ملازم ومراجع منظمة',
            desc: 'ملف خاص لكل مادة، تتبع لصفحات القراءة، وروابط محاضرات سريعة.',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildFeatureRow(
            icon: Icons.psychology_rounded,
            color: Colors.purple,
            title: 'مساعد دراسي ذكي ومكافآت',
            desc: 'خطط مذاكرة فورية، تلخيص للمذكرات، ومستويات XP تحفيزية.',
            isDark: isDark,
          ),

          const SizedBox(height: 36),
          AppButton(
            text: 'ابدأ الإعداد المخصص',
            isFullWidth: true,
            height: 52,
            icon: Icons.arrow_back_rounded,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  // --- SLIDE 2: STUDENT PROFILE SETUP ---
  Widget _buildProfileSetupSlide(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'دعنا نتعرف عليك',
            style: AppTextStyles.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اسمك ومرحلتك الدراسية يساعدانا على تهيئة المخطط والمواد المناسبة لك.',
            style: AppTextStyles.cairo(
              fontSize: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 22),

          // Name Validation Alert
          if (_nameError != null) ...[
            _buildAlertBanner(_nameError!),
            const SizedBox(height: 12),
          ],

          AppTextField(
            label: 'اسم الطالب',
            hint: 'مثال: أحمد مصطفى',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 20),

          // Grade Selector Heading
          Text(
            'اختر المرحلة الدراسية',
            style: AppTextStyles.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),

          if (_gradeError != null) ...[
            _buildAlertBanner(_gradeError!),
            const SizedBox(height: 10),
          ],

          GradeCardSelector(
            selectedGrade: _selectedGrade,
            onSelected: (val) {
              setState(() {
                _selectedGrade = val;
                _gradeError = null;
              });
            },
          ),

          const SizedBox(height: 32),
          AppButton(
            text: 'متابعة الخطوة التالية',
            isFullWidth: true,
            height: 52,
            icon: Icons.arrow_back_rounded,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  // --- SLIDE 3: STUDY HABITS & TARGETS ---
  Widget _buildPreferencesSlide(bool isDark) {
    final targets = [45, 90, 120, 180];
    final times = [
      {'id': 'صباحي', 'label': 'صباحي 🌅', 'desc': 'طاقة ونشاط مبكر'},
      {'id': 'مسائي', 'label': 'مسائي 🌙', 'desc': 'هدوء واستيعاب عميق'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عادات وأهداف المذاكرة',
            style: AppTextStyles.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'حدّد وتيرتك اليومية لبناء عادات دراسية مستمرة دون إرهاق.',
            style: AppTextStyles.cairo(
              fontSize: 13,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 24),

          // Daily Target Minutes
          Text(
            'هدف التركيز اليومي المطلوب:',
            style: AppTextStyles.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: targets.map((mins) {
              final isSel = _selectedDailyTargetMinutes == mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() => _selectedDailyTargetMinutes = mins);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary
                            : (isDark ? const Color(0xFF1E1C2A) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel
                              ? AppColors.primary
                              : (isDark ? const Color(0xFF2C2A3C) : const Color(0xFFE5E7EB)),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$mins',
                            style: AppTextStyles.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isSel ? Colors.white : (isDark ? Colors.white : AppColors.textPrimaryLight),
                            ),
                          ),
                          Text(
                            'دقيقة',
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              color: isSel ? Colors.white70 : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Preferred Study Time
          Text(
            'الوقت المفضل للمذاكرة:',
            style: AppTextStyles.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: times.map((t) {
              final isSel = _preferredTime == t['id'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() => _preferredTime = t['id']!);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.primary.withOpacity(0.12)
                            : (isDark ? const Color(0xFF1E1C2A) : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? AppColors.primary : const Color(0xFFE5E7EB),
                          width: isSel ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['label']!,
                            style: AppTextStyles.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSel ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimaryLight),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t['desc']!,
                            style: AppTextStyles.cairo(
                              fontSize: 11,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Daily Notifications Switch
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, color: AppColors.secondary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تذكيرات المذاكرة الذكية',
                        style: AppTextStyles.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'إشعارات مشجعة وتنبيهات لمهام اليوم',
                        style: AppTextStyles.cairo(
                          fontSize: 11,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: _enableDailyReminder,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    AppHaptics.selectionClick();
                    setState(() => _enableDailyReminder = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          AppButton(
            text: 'تأكيد الخطة الدراسية',
            isFullWidth: true,
            height: 52,
            icon: Icons.arrow_back_rounded,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }

  // --- SLIDE 4: CELEBRATION & LAUNCH ---
  Widget _buildReadySlide(bool isDark) {
    final name = _nameController.text.trim();
    final displayName = name.isNotEmpty ? name : 'يا بطل';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Celebratory Emblem
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 54,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'أنت جاهز للانطلاق!',
            textAlign: TextAlign.center,
            style: AppTextStyles.cairo(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تم إعداد وتخصيص مساحتك الأكاديمية بنجاح.',
            textAlign: TextAlign.center,
            style: AppTextStyles.cairo(
              fontSize: 14,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 24),

          // Overview Card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildSummaryLine(
                  label: 'اسم الطالب:',
                  value: displayName,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _buildSummaryLine(
                  label: 'المرحلة الدراسية:',
                  value: _selectedGrade ?? 'المرحلة الثانوية',
                  icon: Icons.school_outlined,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _buildSummaryLine(
                  label: 'هدف التركيز اليومي:',
                  value: '$_selectedDailyTargetMinutes دقيقة / يومياً',
                  icon: Icons.timer_outlined,
                  isDark: isDark,
                ),
                const Divider(height: 20),
                _buildSummaryLine(
                  label: 'التنبيهات اليومية:',
                  value: _enableDailyReminder ? 'مفعلة بانتظام' : 'متوقفة',
                  icon: Icons.notifications_none_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          AppButton(
            text: 'انطلق إلى مساحتك الدراسية ✦',
            isFullWidth: true,
            height: 54,
            isLoading: _isSubmitting,
            icon: Icons.rocket_launch_rounded,
            onPressed: _handleFinish,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.cairo(
            fontSize: 13,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1C2B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2A3C) : const Color(0xFFEFF0F6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTextStyles.cairo(
                    fontSize: 12,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
