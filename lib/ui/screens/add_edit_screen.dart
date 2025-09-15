import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../state/app_scope.dart';
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

  String _category = '';            // инициализируем позже, когда будет доступен AppScope
  bool _isIncome = false;
  String? _imagePath;
  late DateTime _selectedDate;

  bool _depsInitialized = false;    // чтобы didChangeDependencies сработал один раз

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _title.text = i.title;
      _amount.text = i.amount.toStringAsFixed(0);
      _category = i.category;       // временно положим из initial (если редактирование)
      _isIncome = i.isIncome;
      _imagePath = i.imagePath;
      _selectedDate = i.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_depsInitialized) return;

    // Читаем категории из состояния только здесь (合法но)
    final s = AppScope.of(context);
    if (widget.initial == null) {
      // для новой записи — дефолтная категория из списка, иначе оставим ту, что была в initial
      _category = (s.categories.isNotEmpty ? s.categories.first : 'Другое');
    } else {
      // если редактирование, убедимся, что категория существует (вдруг была удалена)
      if (!s.categories.contains(_category)) {
        _category = (s.categories.isNotEmpty ? s.categories.first : 'Другое');
      }
    }

    _depsInitialized = true;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Камера: ${e.message}')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      helpText: 'Дата операции',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
      locale: const Locale('ru', 'RU'),
    );
    if (picked != null) {
      setState(() => _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      ));
    }
  }

  Future<void> _addCategoryFromDialog() async {
    final s = AppScope.of(context);
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новая категория'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Например, Здоровье'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Добавить')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final created = await s.addCategory(name);
    if (created != null && mounted) {
      setState(() => _category = created);
    }
  }

  void _save() {
    if (_form.currentState?.validate() != true) return;
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0.0;

    final e = (widget.initial ??
        Expense(
          id: 'e${DateTime.now().microsecondsSinceEpoch}',
          title: '',
          amount: 0.0,
          category: _category,
          date: _selectedDate,
          isIncome: _isIncome,
          imagePath: _imagePath,
        ))
        .copyWith(
      title: _title.text.trim(),
      amount: amount,
      category: _category,
      date: _selectedDate,
      isIncome: _isIncome,
      imagePath: _imagePath,
    );

    Navigator.of(context).pop(e);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context); // читать в build можно
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

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: const Text('Дата'),
                  subtitle: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}',
                  ),
                  trailing: TextButton(onPressed: _pickDate, child: const Text('Изменить')),
                ),
                const SizedBox(height: 8),

                InputDecorator(
                  decoration: const InputDecoration(labelText: 'Категория'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _category.isNotEmpty ? _category : null,
                      items: [
                        for (final c in s.categories) DropdownMenuItem(value: c, child: Text(c)),
                        const DropdownMenuItem(
                          value: '__add__',
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 18),
                              SizedBox(width: 8),
                              Text('Добавить категорию…'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (v) async {
                        if (v == '__add__') {
                          await _addCategoryFromDialog();
                        } else if (v != null) {
                          setState(() => _category = v);
                        }
                      },
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
