import 'package:study_flow/l10n/ui_labels.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../common/providers/study_flow_state_provider.dart';
import '../models/ai_assistant_models.dart';
import '../providers/ai_assistant_provider.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmit([String? customText]) {
    final text = customText ?? _textController.text;
    if (text.trim().isEmpty) return;
    AppHaptics.light();
    ref.read(aiAssistantProvider.notifier).sendUserPrompt(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _showCustomPlanDialog(BuildContext context) {
    final subjectController = TextEditingController(text: 'الرياضيات');
    int hours = 3;

    showAppSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('توليد خطة دراسية ذكية'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('اسم المادة أو الموضوع:'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'مثال: فيزياء الحركة الموجية، كيمياء عضوية...',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.messagea5a66bd9f3(context.display(hours)),
                    style: theme.textTheme.bodyMedium,
                  ),
                  Slider(
                    value: hours.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: '$hours ساعات',
                    onChanged: (val) {
                      setSheetState(() => hours = val.round());
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'إنشاء الخطة بالذكاء الاصطناعي',
                          icon: Icons.auto_awesome_rounded,
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(aiAssistantProvider.notifier)
                                .requestStudyPlan(
                                  subject: subjectController.text.trim().isEmpty
                                      ? 'المادة الدراسية'
                                      : subjectController.text.trim(),
                                  hours: hours,
                                );
                            _scrollToBottom();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCustomQuizDialog(BuildContext context) {
    final subjectController = TextEditingController(text: 'الفيزياء');
    String difficulty = 'متوسط';
    int questionsCount = 3;

    showAppSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.quiz_rounded,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('إنشاء كويز تدريبي تفاعلي'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('المادة الدراسية:'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(
                      hintText: context.tr(
                        'مثال: رياضيات، أحياء، نحو، لغة إنجليزية...',
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('مستوى الصعوبة:'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'سهل',
                        label: Text(context.tr('سهل')),
                      ),
                      ButtonSegment(
                        value: 'متوسط',
                        label: Text(context.tr('متوسط')),
                      ),
                      ButtonSegment(
                        value: 'صعب',
                        label: Text(context.tr('صعب')),
                      ),
                    ],
                    selected: {difficulty},
                    onSelectionChanged: (set) {
                      setSheetState(() => difficulty = set.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.message6731cf5a72(
                      context.display(questionsCount),
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  Slider(
                    value: questionsCount.toDouble(),
                    min: 1,
                    max: 3,
                    divisions: 2,
                    label: '$questionsCount',
                    onChanged: (val) {
                      setSheetState(() => questionsCount = val.round());
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'توليد الكويز الآن',
                          icon: Icons.psychology_rounded,
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(aiAssistantProvider.notifier)
                                .requestQuiz(
                                  subject: subjectController.text.trim().isEmpty
                                      ? 'عام'
                                      : subjectController.text.trim(),
                                  difficulty: difficulty,
                                  count: questionsCount,
                                );
                            _scrollToBottom();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNotePickerSheet(BuildContext context) {
    final notes = ref.read(notesProvider);

    showAppSheet(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.note_alt_rounded,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.tr('اختر ملاحظة لتلخيصها بالذكاء الاصطناعي'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (notes.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('لا توجد ملاحظات محفوظة بعد في دفترك.'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'تجربة تلخيص نموذج تعليمي',
                          icon: Icons.auto_awesome,
                          variant: AppButtonVariant.outline,
                          onPressed: () {
                            Navigator.pop(ctx);
                            ref
                                .read(aiAssistantProvider.notifier)
                                .requestNoteSummary(
                                  content: '''
الذاكرة البشرية تنقسم إلى ذاكرة قصيرة المدى وذاكرة طويلة المدى.
تقنية التكرار المتباعد (Spaced Repetition) تقاوم منحنى النسيان لإبنجهاوس عبر مراجعة المعلومة قبل أن تتلاشى مباشرة.
الاسترجاع النشط (Active Recall) يجبر خلايا الدماغ على إعادة تشكيل الروابط العصبية مما يرفع معدل التذكر لأكثر من 80% في الامتحانات.
تطبيق فاينمان يعتمد على تبسيط الشرح وكأنك تشرح لزميل أو طفل صغير لتحديد نقاط الضعف والفجوات.
''',
                                  title: 'أساسيات الذاكرة والتعلم الفائق',
                                );
                            _scrollToBottom();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (c, i) {
                      final note = notes[i];
                      return ListTile(
                        leading: const Icon(Icons.bookmark_border_rounded),
                        title: Text(
                          note.title.isEmpty ? 'ملاحظة بدون عنوان' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_left_rounded),
                        onTap: () {
                          Navigator.pop(ctx);
                          ref
                              .read(aiAssistantProvider.notifier)
                              .requestNoteSummary(
                                content: note.content,
                                title: note.title,
                              );
                          _scrollToBottom();
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final suggestedPrompts = [
      {'icon': '📅', 'text': 'ضع لي خطة لمذاكرة مادة الرياضيات في 4 ساعات'},
      {'icon': '📝', 'text': 'اختبرني في مادة الفيزياء بأسئلة اختيار من متعدد'},
      {'icon': '💡', 'text': 'كيف أطبق تقنية فاينمان لشرح درس صعب؟'},
      {'icon': '⏱️', 'text': 'كيف أنظم جلسات بومودورو مع المواد الدسمة؟'},
      {'icon': '🌿', 'text': 'نصائح عملية للتغلب على قلق وتوتر الامتحانات'},
    ];

    // Filter messages based on category
    final filteredMessages = aiState.messages.where((msg) {
      if (aiState.selectedCategory == 'all') return true;
      if (aiState.selectedCategory == 'studyPlan') {
        return msg.type == AiMessageType.studyPlan ||
            msg.sender == AiSender.user;
      }
      if (aiState.selectedCategory == 'quiz') {
        return msg.type == AiMessageType.quiz || msg.sender == AiSender.user;
      }
      if (aiState.selectedCategory == 'summary') {
        return msg.type == AiMessageType.summary || msg.sender == AiSender.user;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('المساعد الدراسي الذكي'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? 'قوالب دراسية محلية • بدون اتصال بنموذج AI'
                        : 'Local study templates • no AI model connection',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.tr('خطة جديدة'),
            icon: const Icon(Icons.add_chart_rounded),
            onPressed: () => _showCustomPlanDialog(context),
          ),
          IconButton(
            tooltip: context.tr('كويز تفاعلي'),
            icon: const Icon(Icons.quiz_outlined),
            onPressed: () => _showCustomQuizDialog(context),
          ),
          IconButton(
            tooltip: context.tr('بدء محادثة جديدة'),
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(aiAssistantProvider.notifier).clearChat();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Pills
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'الكل',
                      icon: Icons.chat_bubble_outline_rounded,
                      isSelected: aiState.selectedCategory == 'all',
                      onTap: () {
                        AppHaptics.selection();
                        ref
                            .read(aiAssistantProvider.notifier)
                            .setCategory('all');
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'خطط دراسية',
                      icon: Icons.calendar_month_outlined,
                      isSelected: aiState.selectedCategory == 'studyPlan',
                      onTap: () {
                        AppHaptics.selection();
                        ref
                            .read(aiAssistantProvider.notifier)
                            .setCategory('studyPlan');
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'كويز واختبارات',
                      icon: Icons.psychology_outlined,
                      isSelected: aiState.selectedCategory == 'quiz',
                      onTap: () {
                        AppHaptics.selection();
                        ref
                            .read(aiAssistantProvider.notifier)
                            .setCategory('quiz');
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'تلخيص ملاحظات',
                      icon: Icons.lightbulb_outline_rounded,
                      isSelected: aiState.selectedCategory == 'summary',
                      onTap: () {
                        AppHaptics.selection();
                        ref
                            .read(aiAssistantProvider.notifier)
                            .setCategory('summary');
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Messages & Conversation Feed
            Expanded(
              child: filteredMessages.isEmpty
                  ? AppEmptyState.filtered(
                      title: 'لا توجد محادثات في هذا القسم',
                      description: 'جرّب كتابة استفسار جديد أو العودة لعرض كافة الرسائل.',
                      onClearFilter: () {
                        AppHaptics.selection();
                        ref
                            .read(aiAssistantProvider.notifier)
                            .setCategory('all');
                      },
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount:
                          filteredMessages.length + (aiState.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredMessages.length &&
                            aiState.isTyping) {
                          return const _TypingBubble();
                        }

                        final message = filteredMessages[index];
                        return _ChatMessageTile(
                          message: message,
                          onAnswerQuiz: (msgId, qIndex, optIndex) {
                            ref
                                .read(aiAssistantProvider.notifier)
                                .answerQuizQuestion(
                                  messageId: msgId,
                                  questionIndex: qIndex,
                                  selectedOptionIndex: optIndex,
                                );
                          },
                        );
                      },
                    ),
            ),

            // Quick Prompt Suggestions (Horizonally scrollable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: suggestedPrompts.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ActionChip(
                        avatar: Text(p['icon']!),
                        label: Text(
                          p['text']!,
                          style: AppTextStyles.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: isDark
                            ? AppColors.cardDark
                            : AppColors.cardLight,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                        onPressed: () => _handleSubmit(p['text']),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Bottom Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.tr('تلخيص ملاحظة محفوظة'),
                    icon: const Icon(Icons.note_alt_outlined),
                    color: AppColors.primary,
                    onPressed: () => _showNotePickerSheet(context),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: AppTextStyles.cairo(fontSize: 14),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSubmit(),
                      decoration: InputDecoration(
                        hintText: context.tr(
                          'اسأل المساعد الذكي عن أي مادة أو خطة أو كويز...',
                        ),
                        hintStyle: AppTextStyles.cairo(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => _handleSubmit(),
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
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.cairo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  final AiChatMessage message;
  final void Function(String messageId, int questionIndex, int optionIndex)
  onAnswerQuiz;

  const _ChatMessageTile({required this.message, required this.onAnswerQuiz});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == AiSender.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isUser) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  context.tr('المساعد الدراسي'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ] else ...[
                Text(
                  context.tr('أنت'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          // Message Bubble
          Container(
            constraints: const BoxConstraints(maxWidth: 820),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.10)
                  : (isDark ? AppColors.cardDark : Colors.white),
              borderRadius: BorderRadius.only(
                topRight: const Radius.circular(16),
                topLeft: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 16 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 16),
              ),
              border: Border.all(
                color: isUser
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  message.content,
                  style: AppTextStyles.cairo(
                    fontSize: 14,
                    height: 1.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),

                // Attached Study Plan Card
                if (message.studyPlan != null) ...[
                  const SizedBox(height: 14),
                  _StudyPlanView(plan: message.studyPlan!),
                ],

                // Attached Quiz Card
                if (message.quiz != null) ...[
                  const SizedBox(height: 14),
                  _QuizView(
                    messageId: message.id,
                    quiz: message.quiz!,
                    onAnswer: (qIndex, optIndex) =>
                        onAnswerQuiz(message.id, qIndex, optIndex),
                  ),
                ],

                // Attached Note Summary Card
                if (message.noteInsight != null) ...[
                  const SizedBox(height: 14),
                  _NoteInsightView(insight: message.noteInsight!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.tr('المساعد يفكر ويعد الإجابة...'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Attached Study Plan View
// -------------------------------------------------------------
class _StudyPlanView extends StatelessWidget {
  final AiStudyPlan plan;

  const _StudyPlanView({required this.plan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.6)
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.subject,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.message44326941d7(
                        context.display(plan.availableHours),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.l10n.minutes(plan.totalMinutes),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            plan.overview,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const Divider(height: 24),

          // Phases
          Text(
            context.tr('مراحل وجلسات المذاكرة المقترحة:'),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ...plan.phases.asMap().entries.map((entry) {
            final idx = entry.key;
            final phase = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phase.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        context.l10n.minutes(phase.durationMinutes),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(phase.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          phase.energyBadge,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          phase.cognitiveLevel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (phase.subtasks.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...phase.subtasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                task,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Smart Tips
          if (plan.smartTips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.tr('نصائح تفوق لهذه المادة:'),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...plan.smartTips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        tip,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),
          // Action button to start pomodoro
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'بدء جلسة تركيز لهذه الخطة',
                  icon: Icons.timer_outlined,
                  onPressed: () {
                    context.go('/pomodoro');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Attached Quiz View
// -------------------------------------------------------------
class _QuizView extends StatelessWidget {
  final String messageId;
  final AiQuiz quiz;
  final void Function(int questionIndex, int optionIndex) onAnswer;

  const _QuizView({
    required this.messageId,
    required this.quiz,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.6)
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.message16e923f5ae(
                        context.display(quiz.subject),
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.message4178437921(
                        context.display(quiz.difficulty),
                        context.display(quiz.questions.length),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (quiz.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: quiz.score == quiz.questions.length
                        ? AppColors.success
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.messageed951c324b(
                      context.display(quiz.score),
                      context.display(quiz.questions.length),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),

          // Questions
          ...quiz.questions.asMap().entries.map((entry) {
            final qIndex = entry.key;
            final question = entry.value;
            final userAnswer = quiz.userAnswers[qIndex];
            final hasAnswered = userAnswer != null;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          context.l10n.messageb8d204704d(
                            context.display(qIndex + 1),
                          ),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          question.question,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Option tiles
                  ...question.options.asMap().entries.map((optEntry) {
                    final optIndex = optEntry.key;
                    final optionText = optEntry.value;

                    Color tileColor = isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight;
                    Color borderColor = isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight;
                    IconData? statusIcon;
                    Color? textColor;

                    if (hasAnswered) {
                      if (optIndex == question.correctIndex) {
                        tileColor = AppColors.success.withValues(alpha: 0.15);
                        borderColor = AppColors.success;
                        statusIcon = Icons.check_circle_rounded;
                        textColor = AppColors.success;
                      } else if (optIndex == userAnswer) {
                        tileColor = AppColors.danger.withValues(alpha: 0.15);
                        borderColor = AppColors.danger;
                        statusIcon = Icons.cancel_rounded;
                        textColor = AppColors.danger;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: hasAnswered
                            ? null
                            : () {
                                if (optIndex == question.correctIndex) {
                                  AppHaptics.medium();
                                } else {
                                  AppHaptics.rejection();
                                }
                                onAnswer(qIndex, optIndex);
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${['أ', 'ب', 'ج', 'د'][optIndex.clamp(0, 3)]}) ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      textColor ??
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        textColor ??
                                        theme.colorScheme.onSurface,
                                    fontWeight: optIndex == userAnswer
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                              if (statusIcon != null)
                                Icon(statusIcon, size: 18, color: textColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // Explanation after answer
                  if (hasAnswered) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 16,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.tr('التفسير والشرح العلمي:'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question.explanation,
                            style: theme.textTheme.bodySmall?.copyWith(
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Final Score Announcement
          if (quiz.isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.secondary.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.message2c49b1d2f5(
                            context.display(quiz.percentage),
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quiz.percentage >= 80
                              ? 'ممتاز جداً! استيعابك للمفاهيم في قمة مستواه.'
                              : 'أداء رائع! راجع تفسير الأسئلة التي تعثرت فيها لترسيخ الفهم.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Attached Note Summary View
// -------------------------------------------------------------
class _NoteInsightView extends StatelessWidget {
  final AiNoteInsight insight;

  const _NoteInsightView({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withValues(alpha: 0.6)
            : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      context.l10n.message5c10ff4a67(
                        context.display(insight.estimatedReadMinutes),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: context.tr('نسخ الملخص'),
                icon: const Icon(Icons.copy_rounded, size: 18),
                onPressed: () {
                  final textToCopy =
                      '${insight.title}\n\n${insight.summary}\n\nأهم النقاط:\n${insight.keyTakeaways.map((t) => '• $t').join('\n')}';
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('تم نسخ الملخص إلى الحافظة!')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.summary,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const Divider(height: 20),

          // Key takeaways
          Text(
            context.tr('نقاط المراجعة السريعة (High-Yield):'),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...insight.keyTakeaways.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐ ', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (insight.actionItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              context.tr('مهام للمتابعة وتطبيق الفهم:'),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            ...insight.actionItems.map(
              (act) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_box_outlined,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        act,
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (insight.keywords.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: insight.keywords.map((kw) {
                return Chip(
                  label: Text(kw, style: const TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: isDark
                      ? AppColors.cardDark
                      : AppColors.backgroundLight,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
