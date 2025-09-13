import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/categories.dart';
import '../../core/routes.dart';
import '../../domain/models/expense.dart';
import '../widgets/app_bar_title.dart';
import '../widgets/primary_button.dart';
import '../widgets/theme_action.dart';

class AddEditScreen extends StatefulWidget {
  final Expense? initial;
  const AddEditScreen({super.key, this.initial});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  String _category = kCategories.first;
  bool _isIncome = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _title.text = i.title;
      _amount.text = i.amount.toStringAsFixed(0);
      _category = i.category;
      _isIncome = i.isIncome;
      _imagePath = i.imagePath;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final shot = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (shot == null) return;
      setState(() => _imagePath = shot.path);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Камера: ${e.message}')));
    }
  }

  void _save() {
    if (_form.currentState?.validate() != true) return;
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0.0;
    final now = DateTime.now();

    final e = (widget.initial ??
        Expense(
          id: 'e${now.microsecondsSinceEpoch}',
          title: '',
          amount: 0.0,
          category: _category,
          date: now,
          isIncome: _isIncome,
          imagePath: _imagePath,
        ))
        .copyWith(
      title: _title.text.trim(),
      amount: amount,
      category: _category,
      date: now,
      isIncome: _isIncome,
      imagePath: _imagePath,
    );

    Navigator.of(context).pop(e);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: const AppBarTitle(title: 'Запись', canPop: true, actions: [ThemeAction()]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                SwitchListTile(
                  value: _isIncome,
                  onChanged: (v) => setState(() => _isIncome = v),
                  title: const Text('Это доход'),
                  subtitle: const Text('Вычитается из итоговых расходов'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  decoration: const InputDecoration(labelText: 'Сумма', hintText: '0'),
                  validator: (v) {
                    final x = double.tryParse((v ?? '').replaceAll(',', '.'));
                    if (x == null || x <= 0) return 'Введите сумму > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    hintText: 'Например, Продукты',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Введите название' : null,
                ),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Категория'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _category,
                      items: [for (final c in kCategories) DropdownMenuItem(value: c, child: Text(c))],
                      onChanged: (v) => setState(() => _category = v ?? _category),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Прикрепить фото'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_imagePath != null)
                      IconButton(
                        tooltip: 'Просмотреть',
                        onPressed: () =>
                            Navigator.of(context).pushNamed(Routes.photo, arguments: _imagePath!),
                        icon: const Icon(Icons.open_in_new),
                      ),
                  ],
                ),
                if (_imagePath != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(_imagePath!), height: 170, fit: BoxFit.cover),
                  ),
                ],
                const SizedBox(height: 20),
                PrimaryButton(
                  onPressed: _save,
                  label: isEdit ? 'Сохранить изменения' : 'Сохранить',
                  icon: Icons.save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
