import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/study_flow_repository.dart';
import '../../common/providers/study_flow_state_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/material_item_model.dart';

final materialsProvider =
    StateNotifierProvider<MaterialsNotifier, MaterialsState>((ref) {
      return MaterialsNotifier(ref.watch(studyFlowRepositoryProvider));
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
  final IStudyFlowRepository _repository;
  late final Future<void> _ready;
  Future<void> _writes = Future.value();
  MaterialsNotifier(this._repository)
    : super(const MaterialsState(folders: [], items: [])) {
    _ready = _load();
    unawaited(_ready.catchError(_report));
  }
  void _report(Object error, StackTrace stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'ENote library',
      ),
    );
  }

  Future<void> _load() async {
    final json = await _repository.getFeatureState('materials');
    if (mounted && json != null) {
      state = MaterialsState(
        folders: (json['folders'] as List)
            .map(
              (x) =>
                  MaterialFolder.fromJson(Map<String, dynamic>.from(x as Map)),
            )
            .toList(),
        items: (json['items'] as List)
            .map(
              (x) => MaterialItem.fromJson(Map<String, dynamic>.from(x as Map)),
            )
            .toList(),
      );
    }
  }

  Future<void> flush() => _writes;
  void _commit(MaterialsState Function(MaterialsState) change) {
    final write = _writes.then((_) async {
      await _ready;
      if (!mounted) return;
      final next = change(state);
      await _repository.saveFeatureState('materials', {
        'folders': next.folders.map((x) => x.toJson()).toList(),
        'items': next.items.map((x) => x.toJson()).toList(),
      });
      if (mounted) state = next;
    });
    _writes = write.catchError(_report);
  }

  void addFolder(String name, String color) {
    if (name.trim().isEmpty) return;
    _commit(
      (current) => current.copyWith(
        folders: [
          ...current.folders,
          MaterialFolder(
            id: 'f_${DateTime.now().microsecondsSinceEpoch}',
            name: name.trim(),
            color: color,
          ),
        ],
      ),
    );
  }

  void addMaterialItem(MaterialItem item) {
    _commit(
      (current) => _withCounts(current.folders, [
        ...current.items.where((x) => x.id != item.id),
        item,
      ]),
    );
  }

  void updateReadingProgress(String id, int pages) {
    _commit(
      (current) => current.copyWith(
        items: current.items
            .map(
              (i) => i.id == id
                  ? i.copyWith(readPages: pages.clamp(0, i.totalPages))
                  : i,
            )
            .toList(),
      ),
    );
  }

  void deleteItem(String id) {
    _commit(
      (current) => _withCounts(
        current.folders,
        current.items.where((i) => i.id != id).toList(),
      ),
    );
  }

  MaterialsState _withCounts(
    List<MaterialFolder> folders,
    List<MaterialItem> items,
  ) => MaterialsState(
    folders: folders
        .map(
          (f) => f.copyWith(
            filesCount: items.where((i) => i.folderId == f.id).length,
          ),
        )
        .toList(),
    items: items,
  );
}
