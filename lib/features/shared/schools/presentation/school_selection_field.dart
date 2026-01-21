import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotosco_v3/features/shared/schools/data/school_model.dart';
import 'package:gotosco_v3/features/shared/schools/data/schools_repository.dart';
import 'package:gotosco_v3/features/shared/schools/presentation/add_school_screen.dart';

class SchoolSelectionField extends ConsumerStatefulWidget {
  final ValueChanged<SchoolModel?> onSchoolSelected;
  final String? initialValue;
  final String? cityId; // NEW

  const SchoolSelectionField({
    super.key,
    required this.onSchoolSelected,
    this.initialValue,
    this.cityId,
  });

  @override
  ConsumerState<SchoolSelectionField> createState() =>
      _SchoolSelectionFieldState();
}

class _SchoolSelectionFieldState extends ConsumerState<SchoolSelectionField> {
  SchoolModel? _selectedSchool;
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<SchoolModel> _options = [];
  bool _isLoading = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchSchools(query);
      } else {
        setState(() => _options = []);
        _removeOverlay();
      }
    });
  }

  Future<void> _searchSchools(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await ref
          .read(schoolsRepositoryProvider)
          .searchSchools(query, cityId: widget.cityId);
      if (mounted) {
        setState(() {
          _options = results;
          _isLoading = false;
        });
        _showOverlay();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  ..._options.map((school) {
                    return ListTile(
                      title: Text(school.name),
                      subtitle: Text(school.address ?? ''),
                      onTap: () {
                        _selectSchool(school);
                      },
                    );
                  }),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: Colors.indigo),
                    title: Text('Add "${_controller.text}" as new school'),
                    onTap: () {
                      _removeOverlay();
                      _addNewSchool(_controller.text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectSchool(SchoolModel school) {
    setState(() {
      _selectedSchool = school;
      _controller.text = school.name;
    });
    widget.onSchoolSelected(school);
    _removeOverlay();
  }

  Future<void> _addNewSchool(String name) async {
    final newSchool = await Navigator.push<SchoolModel>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddSchoolScreen(initialName: name, initialCityId: widget.cityId),
      ),
    );

    if (newSchool != null) {
      _selectSchool(newSchool);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: "School Name",
          hintText: "Start typing to search school...",
          prefixIcon: const Icon(Icons.school_outlined, color: Colors.grey),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add new school',
                  onPressed: () => _addNewSchool(_controller.text),
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        onChanged: _onSearchChanged,
        validator: (v) => v == null || v.isEmpty ? 'School is required' : null,
      ),
    );
  }
}
