import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_first_app/features/todos/domain/models/todo.dart';
import 'package:my_first_app/features/todos/domain/models/todo_image.dart';

class TodoEditorPage extends StatefulWidget {
  const TodoEditorPage({super.key, this.todo, required this.onSave});

  final Todo? todo;
  final Future<void> Function(
    String title,
    String description,
    TodoImageUpload? newImage,
    bool removeImage,
  ) onSave;

  @override
  State<TodoEditorPage> createState() => _TodoEditorPageState();
}

class _TodoEditorPageState extends State<TodoEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;
  TodoImageUpload? _selectedImage;
  bool _removeImage = false;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入待辦標題')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        _titleController.text,
        _descriptionController.text,
        _selectedImage,
        _removeImage,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗：$error')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _selectImage() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('圖片大小不可超過 5 MB。')),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _selectedImage = TodoImageUpload(
        bytes: bytes,
        contentType: _contentTypeFromName(file.name),
      );
      _selectedImageBytes = bytes;
      _removeImage = false;
    });
  }

  String _contentTypeFromName(String fileName) {
    final lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) return 'image/png';
    if (lowerName.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final isNewTodo = widget.todo == null;
    return Scaffold(
      appBar: AppBar(title: Text(isNewTodo ? '新增待辦' : '編輯待辦')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: '標題',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ImageSection(
                    existingImageUrl: _removeImage ? null : widget.todo?.imageUrl,
                    selectedImageBytes: _selectedImageBytes,
                    onSelect: _isSaving ? null : () => unawaited(_selectImage()),
                    onRemove: _isSaving
                        ? null
                        : () => setState(() {
                            _selectedImage = null;
                            _selectedImageBytes = null;
                            _removeImage = widget.todo?.imageUrl != null;
                          }),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _descriptionController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        labelText: '詳細描述（選填）',
                        hintText: '寫下需要記得的事情…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : () => unawaited(_save()),
                      child: Text(_isSaving ? '儲存中…' : '儲存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({
    required this.existingImageUrl,
    required this.selectedImageBytes,
    required this.onSelect,
    required this.onRemove,
  });

  final String? existingImageUrl;
  final Uint8List? selectedImageBytes;
  final VoidCallback? onSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final image = selectedImageBytes != null
        ? Image.memory(selectedImageBytes!, fit: BoxFit.cover)
        : existingImageUrl != null
        ? Image.network(
            existingImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Center(
              child: Text('圖片載入失敗'),
            ),
          )
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('圖片（選填）', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (image != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: image,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  tooltip: '移除圖片',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          )
        else
          OutlinedButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('選擇圖片'),
          ),
        if (image != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('更換圖片'),
          ),
        ],
      ],
    );
  }
}
