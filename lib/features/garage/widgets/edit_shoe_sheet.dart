import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/unit_formatter.dart';
import '../../../data/database/database.dart';
import '../../../data/providers.dart';
import 'photo_source_sheet.dart';

class EditShoeSheet extends ConsumerStatefulWidget {
  final Shoe shoe;

  const EditShoeSheet({super.key, required this.shoe});

  @override
  ConsumerState<EditShoeSheet> createState() => _EditShoeSheetState();
}

class _EditShoeSheetState extends ConsumerState<EditShoeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _targetMilesController;
  late final TextEditingController _currentMilesController;
  late final TextEditingController _priceController;
  late String _selectedCategory;
  String? _currentPhotoPath;
  bool _photoChanged = false;
  bool _initializedUnitValues = false;

  final List<String> _categories = ['road', 'trail', 'racing', 'walking'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shoe.name);
    _brandController = TextEditingController(text: widget.shoe.brand ?? '');
    _modelController = TextEditingController(text: widget.shoe.model ?? '');
    _targetMilesController = TextEditingController();
    _currentMilesController = TextEditingController();
    _priceController = TextEditingController(
      text: widget.shoe.price != null
          ? widget.shoe.price!.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')
          : '',
    );
    _selectedCategory = widget.shoe.category ?? 'road';
    if (!_categories.contains(_selectedCategory)) {
      _selectedCategory = 'road';
    }
    _currentPhotoPath = widget.shoe.photoUri;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedUnitValues) {
      final unit = ref.read(unitPreferenceProvider);
      final displayTarget = UnitFormatter.toDisplayDistance(widget.shoe.targetDistance, unit);
      final displayCurrent = UnitFormatter.toDisplayDistance(widget.shoe.currentDistance, unit);
      _targetMilesController.text = displayTarget.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      _currentMilesController.text = displayCurrent.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      _initializedUnitValues = true;
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
    final action = await showPhotoActionSheet(context, canRemove: _currentPhotoPath != null);
    if (!mounted || action == null) return;

    if (action == PhotoAction.remove) {
      setState(() {
        _currentPhotoPath = null;
        _photoChanged = true;
      });
      return;
    }

    final source = action == PhotoAction.camera ? ImageSource.camera : ImageSource.gallery;
    final picked = await ref.read(shoePhotoServiceProvider).pickImage(source: source);
    if (picked != null && mounted) {
      setState(() {
        _currentPhotoPath = picked;
        _photoChanged = true;
      });
    }
  }

  Future<void> _updateShoe() async {
    if (!_formKey.currentState!.validate()) return;

    final unit = ref.read(unitPreferenceProvider);
    final targetEntered = double.tryParse(_targetMilesController.text);
    final currentEntered = double.tryParse(_currentMilesController.text);

    final target = targetEntered != null
        ? UnitFormatter.toCanonicalMiles(targetEntered, unit)
        : widget.shoe.targetDistance;
    final current = currentEntered != null
        ? UnitFormatter.toCanonicalMiles(currentEntered, unit)
        : widget.shoe.currentDistance;

    final price = double.tryParse(_priceController.text.trim());
    final db = ref.read(databaseProvider);
    final photoService = ref.read(shoePhotoServiceProvider);

    drift.Value<String?> photoValue = const drift.Value.absent();

    if (_photoChanged) {
      if (_currentPhotoPath == null) {
        await photoService.deleteShoePhoto(widget.shoe.photoUri);
        photoValue = const drift.Value(null);
      } else if (_currentPhotoPath != widget.shoe.photoUri) {
        final savedUri = await photoService.saveShoePhoto(
          sourcePath: _currentPhotoPath!,
          shoeId: widget.shoe.id,
        );
        if (widget.shoe.photoUri != null && widget.shoe.photoUri != savedUri) {
          await photoService.deleteShoePhoto(widget.shoe.photoUri);
        }
        photoValue = drift.Value(savedUri);
      }
    }

    await db.updateShoeDetails(
      shoeId: widget.shoe.id,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      category: _selectedCategory,
      targetDistance: target,
      currentDistance: current,
      photoUri: photoValue,
      price: price,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${_nameController.text.trim()}')),
      );
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
                    'Edit Shoe',
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
                        child: _currentPhotoPath != null && File(_currentPhotoPath!).existsSync()
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.file(
                                  File(_currentPhotoPath!),
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
                    if (_currentPhotoPath != null)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _currentPhotoPath = null;
                            _photoChanged = true;
                          }),
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
                  hintText: 'e.g. Hoka - Daily Trainer',
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
                      validator: (val) {
                        final parsed = double.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter valid target';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _currentMilesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Current ${UnitFormatter.unitFullLabel(unit)}',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) {
                        final parsed = double.tryParse(val ?? '');
                        if (parsed == null || parsed < 0) {
                          return 'Enter valid distance';
                        }
                        return null;
                      },
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
                icon: const Icon(Icons.check),
                label: const Text('Save Changes'),
                onPressed: _updateShoe,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
