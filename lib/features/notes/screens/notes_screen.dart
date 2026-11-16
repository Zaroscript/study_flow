import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../data/models/note_model.dart';
import '../../common/providers/study_flow_state_provider.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});
  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  String _query = '';
  String? _folder;
  Future<void> _edit([NoteModel? note]) => showAppSheet<void>(
    context: context,
    builder: (context) => _NoteEditor(note: note),
  );

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final scheme = Theme.of(context).colorScheme;
    final visible = notes
        .where(
          (note) =>
              (_folder == null || note.folder == _folder) &&
              '${note.title} ${note.content}'.toLowerCase().contains(
                _query.trim().toLowerCase(),
              ),
        )
        .toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageHeader(
                  title: 'مكتبة أفكارك',
                  description: 'ملخصات وأفكار تستحق الاحتفاظ بها. افتح أي ملاحظة لقراءتها وتعديلها.',
                  action: AppButton(
                    text: 'ملاحظة جديدة',
                    icon: Icons.add,
                    onPressed: () => _edit(),
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'بحث في الملاحظات',
                    hintText: 'ابحث في العنوان أو المحتوى…',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('الكل'),
                      selected: _folder == null,
                      onSelected: (_) {
                        AppHaptics.selection();
                        setState(() => _folder = null);
                      },
                    ),
                    ...notes
                        .map((note) => note.folder)
                        .toSet()
                        .map(
                          (folder) => FilterChip(
                            label: Text(folder),
                            selected: folder == _folder,
                            onSelected: (_) {
                              AppHaptics.selection();
                              setState(() => _folder = folder);
                            },
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 16),
                if (visible.isEmpty)
                  notes.isEmpty
                      ? AppEmptyState.initial(
                          title: 'مكتبتك تبدأ بفكرة',
                          description:
                              'أضف أول ملخص أو فكرة لتنظيم استذكارك والرجوع إليها لاحقًا.',
                          icon: Icons.note_alt_outlined,
                          actionLabel: 'إضافة ملاحظة جديدة',
                          onAction: () => _edit(),
                        )
                      : AppEmptyState.filtered(
                          title: 'لا توجد نتائج مطابقة للبحث',
                          description:
                              'لم نجد أي ملاحظات تحتوي على "$_query". جرّب كلمة بحث أخرى أو أزل الفلتر.',
                          onClearFilter: () {
                            AppHaptics.selection();
                            setState(() {
                              _query = '';
                              _folder = null;
                            });
                          },
                        ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final note = visible[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AppCard(
                  onTap: () => _edit(note),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.folder,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        note.content,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () => _edit(note),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('فتح وتعديل'),
                          ),
                          IconButton(
                            tooltip: 'حذف الملاحظة',
                            icon: Icon(
                              Icons.delete_outline,
                              color: scheme.error,
                            ),
                            onPressed: () => deleteWithUndo(
                              context,
                              onDelete: () => ref
                                  .read(notesProvider.notifier)
                                  .deleteNote(note.id),
                              onUndo: () => ref
                                  .read(notesProvider.notifier)
                                  .addNote(note),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: visible.length),
          ),
        ),
      ],
    );
  }
}

class _NoteEditor extends ConsumerStatefulWidget {
  final NoteModel? note;
  const _NoteEditor({this.note});
  @override
  ConsumerState<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<_NoteEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title, _folder, _content;
  bool _saving = false;
  bool get _dirty =>
      _title.text != (widget.note?.title ?? '') ||
      _content.text != (widget.note?.content ?? '') ||
      _folder.text != (widget.note?.folder ?? 'عام');
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title);
    _folder = TextEditingController(text: widget.note?.folder ?? 'عام');
    _content = TextEditingController(text: widget.note?.content);
    for (final controller in [_title, _folder, _content]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final controller in [_title, _folder, _content]) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _close() async {
    if (_saving) return;
    if (_dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تجاهل التغييرات؟'),
          content: const Text('توجد تعديلات لم تُحفظ في الملاحظة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('متابعة التعديل'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('تجاهل التغييرات'),
            ),
          ],
        ),
      );
      if (discard != true || !mounted) return;
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final note = NoteModel(
        id: widget.note?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        folder: _folder.text.trim().isEmpty ? 'عام' : _folder.text.trim(),
        content: _content.text.trim(),
        date: DateTime.now().toIso8601String(),
      );
      if (widget.note == null) {
        await ref.read(notesProvider.notifier).addNote(note);
      } else {
        await ref.read(notesProvider.notifier).updateNote(note);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر الحفظ. حاول مرة أخرى.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty && !_saving,
    onPopInvoked: (didPop) {
      if (!didPop) _close();
    },
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.note == null ? 'ملاحظة جديدة' : 'تعديل الملاحظة',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'إغلاق',
                  onPressed: _saving ? null : _close,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'العنوان',
              controller: _title,
              validator: AppValidators.required,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'المجلد / المادة', controller: _folder),
            const SizedBox(height: 16),
            AppTextField(
              label: 'المحتوى',
              controller: _content,
              maxLines: 8,
              validator: AppValidators.required,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'حفظ الملاحظة',
              icon: Icons.check,
              isFullWidth: true,
              isLoading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    ),
  );
}
