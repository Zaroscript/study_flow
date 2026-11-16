import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/material_item_model.dart';

final materialsProvider =
    StateNotifierProvider<MaterialsNotifier, MaterialsState>((ref) {
      return MaterialsNotifier();
    });

class MaterialsState {
  final List<MaterialFolder> folders;
  final List<MaterialItem> items;

  const MaterialsState({required this.folders, required this.items});

  MaterialsState copyWith({
    List<MaterialFolder>? folders,
    List<MaterialItem>? items,
  }) {
    return MaterialsState(
      folders: folders ?? this.folders,
      items: items ?? this.items,
    );
  }

  List<MaterialItem> getItemsForFolder(String folderId) {
    return items.where((i) => i.folderId == folderId).toList();
  }

  int get totalBooksCount => items.length;
  int get totalCompletedReadings =>
      items.where((i) => i.readingProgress >= 1.0).length;
}

class MaterialsNotifier extends StateNotifier<MaterialsState> {
  MaterialsNotifier()
    : super(
        const MaterialsState(
          folders: [
            MaterialFolder(
              id: 'f1',
              name: 'الرياضيات',
              color: 'indigo',
              icon: 'calculate',
              filesCount: 3,
            ),
            MaterialFolder(
              id: 'f2',
              name: 'الفيزياء',
              color: 'blue',
              icon: 'science',
              filesCount: 2,
            ),
            MaterialFolder(
              id: 'f3',
              name: 'الكيمياء',
              color: 'purple',
              icon: 'biotech',
              filesCount: 2,
            ),
            MaterialFolder(
              id: 'f4',
              name: 'اللغة العربية',
              color: 'green',
              icon: 'menu_book',
              filesCount: 2,
            ),
            MaterialFolder(
              id: 'f5',
              name: 'اللغة الإنجليزية',
              color: 'pink',
              icon: 'language',
              filesCount: 1,
            ),
          ],
          items: [
            MaterialItem(
              id: 'm1',
              folderId: 'f1',
              subject: 'الرياضيات',
              title: 'كتاب التفاضل والتكامل الرسمي',
              type: MaterialType.book,
              totalPages: 160,
              readPages: 65,
              description: 'كتاب الوزارة المعتمد وشرح المسائل المحلولة',
              dateAdded: '2026-11-10',
            ),
            MaterialItem(
              id: 'm2',
              folderId: 'f1',
              subject: 'الرياضيات',
              title: 'ملخص قوانين الجبر والهندسة الفراغية',
              type: MaterialType.summary,
              totalPages: 35,
              readPages: 35,
              description: 'ملخص سريع لجميع القوانين الهامة للامتحان',
              dateAdded: '2026-11-12',
            ),
            MaterialItem(
              id: 'm3',
              folderId: 'f2',
              subject: 'الفيزياء',
              title: 'مذكرة بنك أسئلة الكهربية والمغناطيسية',
              type: MaterialType.examBank,
              totalPages: 80,
              readPages: 25,
              description: 'تدريبات مكثفة على مسائل كيرشوف وقانون أوم',
              dateAdded: '2026-11-13',
            ),
            MaterialItem(
              id: 'm4',
              folderId: 'f3',
              subject: 'الكيمياء',
              title: 'دليل الكيمياء العضوية والتفاعلات',
              type: MaterialType.pdf,
              totalPages: 110,
              readPages: 40,
              description: 'تجميعة معادلات الألكانات والألكينات وطرق التحضير',
              dateAdded: '2026-11-14',
            ),
            MaterialItem(
              id: 'm5',
              folderId: 'f4',
              subject: 'اللغة العربية',
              title: 'كتاب القواعد النحوية الشامل',
              type: MaterialType.book,
              totalPages: 90,
              readPages: 30,
              description: 'شرح مفصل للمشتقات وإعراب الجمل',
              dateAdded: '2026-11-14',
            ),
          ],
        ),
      );

  void addFolder(String name, String color) {
    final newFolder = MaterialFolder(
      id: 'f_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      color: color,
      filesCount: 0,
    );
    state = state.copyWith(folders: [...state.folders, newFolder]);
  }

  void addMaterialItem(MaterialItem item) {
    final updatedItems = [...state.items, item];
    final updatedFolders = state.folders.map((f) {
      if (f.id == item.folderId) {
        return f.copyWith(filesCount: f.filesCount + 1);
      }
      return f;
    }).toList();

    state = state.copyWith(folders: updatedFolders, items: updatedItems);
  }

  void updateReadingProgress(String itemId, int readPages) {
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        final clampedPages = readPages.clamp(0, item.totalPages);
        return item.copyWith(readPages: clampedPages);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void deleteItem(String itemId) {
    final item = state.items.firstWhere(
      (i) => i.id == itemId,
      orElse: () => state.items.first,
    );
    final updatedItems = state.items.where((i) => i.id != itemId).toList();
    final updatedFolders = state.folders.map((f) {
      if (f.id == item.folderId) {
        return f.copyWith(filesCount: (f.filesCount - 1).clamp(0, 999));
      }
      return f;
    }).toList();

    state = state.copyWith(folders: updatedFolders, items: updatedItems);
  }
}
