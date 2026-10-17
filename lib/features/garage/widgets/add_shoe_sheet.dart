import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import 'photo_source_sheet.dart';

class AddShoeSheet extends ConsumerStatefulWidget {
  const AddShoeSheet({super.key});

  @override
  ConsumerState<AddShoeSheet> createState() => _AddShoeSheetState();
}

class _AddShoeSheetState extends ConsumerState<AddShoeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _targetMilesController = TextEditingController();
  final _currentMilesController = TextEditingController(text: '0');
  final _priceController = TextEditingController();
  String _selectedCategory = 'road';
  String? _photoPath;
  bool _initializedDefaults = false;

  final List<String> _categories = ['road', 'trail', 'racing', 'walking'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedDefaults) {
      final unit = ref.read(unitPreferenceProvider);
      _targetMilesController.text = unit == DistanceUnit.miles ? '400' : '650';
      _initializedDefaults = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _targetMilesController.dispose();
    _currentMilesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final action = await showPhotoActionSheet(context, canRemove: _photoPath != null);
    if (!mounted || action == null) return;

    if (action == PhotoAction.remove) {
      setState(() => _photoPath = null);
      return;
    }

    final source = action == PhotoAction.camera ? ImageSource.camera : ImageSource.gallery;
    final picked = await ref.read(shoePhotoServiceProvider).pickImage(source: source);
    if (picked != null && mounted) {
      setState(() => _photoPath = picked);
    }
  }

  Future<void> _saveShoe() async {
    if (!_formKey.currentState!.validate()) return;

    final unit = ref.read(unitPreferenceProvider);
    final targetInput = double.tryParse(_targetMilesController.text) ?? (unit == DistanceUnit.miles ? 400.0 : 650.0);
    final currentInput = double.tryParse(_currentMilesController.text) ?? 0.0;
    final target = UnitFormatter.toCanonicalMiles(targetInput, unit);
    final current = UnitFormatter.toCanonicalMiles(currentInput, unit);
    final price = double.tryParse(_priceController.text.trim());
    final db = ref.read(databaseProvider);

    final newShoeId = const Uuid().v4();
    String? permanentPhotoUri;
    if (_photoPath != null) {
      permanentPhotoUri = await ref.read(shoePhotoServiceProvider).saveShoePhoto(
            sourcePath: _photoPath!,
            shoeId: newShoeId,
          );
    }

    await db.insertShoe(
      ShoesCompanion.insert(
        id: newShoeId,
        name: _nameController.text.trim(),
        brand: drift.Value(_brandController.text.trim().isEmpty ? null : _brandController.text.trim()),
        model: drift.Value(_modelController.text.trim().isEmpty ? null : _modelController.text.trim()),
        category: drift.Value(_selectedCategory),
        currentDistance: drift.Value(current),
        targetDistance: drift.Value(target),
        price: drift.Value(price),
        photoUri: drift.Value(permanentPhotoUri),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = ref.watch(unitPreferenceProvider);
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add New Shoe',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Shoe Photo Picker
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: _pickPhoto,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant,
                            width: 1.5,
                          ),
                        ),
                        child: _photoPath != null && File(_photoPath!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(_photoPath!),
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 28,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Add Photo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_photoPath != null)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photoPath = null),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Shoe Nickname / Title *',
                  hintText: 'e.g. Hoka - Race Day, Daily Trainer',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a name for the shoe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        hintText: 'e.g. Hoka, Nike',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _modelController,
                      decoration: const InputDecoration(
                        labelText: 'Model',
                        hintText: 'e.g. Clifton 9',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.toUpperCase()),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetMilesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Target Lifespan (${UnitFormatter.unitLabel(unit)})',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _currentMilesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Starting ${UnitFormatter.unitFullLabel(unit)}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Purchase Price (optional)',
                  hintText: 'e.g. 160.00',
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                  helperText: 'Used to calculate your real-time cost per ${UnitFormatter.unitPerLabel(unit)}',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add to Garage'),
                onPressed: _saveShoe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
