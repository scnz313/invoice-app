import 'package:flutter/material.dart';
import '../models/enhanced_invoice.dart';
import '../utils/theme.dart';

class CategoryFieldWidget extends StatefulWidget {
  final CategorySpecificField field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const CategoryFieldWidget({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CategoryFieldWidget> createState() => _CategoryFieldWidgetState();
}

class _CategoryFieldWidgetState extends State<CategoryFieldWidget> {
  late TextEditingController _textController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _boolValue = false;
  double _numberValue = 0.0;
  String? _dropdownValue;

  @override
  void initState() {
    super.initState();
    _initializeValue();
  }

  void _initializeValue() {
    switch (widget.field.fieldType) {
      case 'text':
      case 'textarea':
        _textController = TextEditingController(text: widget.value?.toString() ?? '');
        break;
      case 'number':
        _numberValue = widget.value is num ? (widget.value as num).toDouble() : 0.0;
        break;
      case 'date':
        _selectedDate = widget.value is DateTime ? widget.value as DateTime : DateTime.now();
        break;
      case 'time':
        if (widget.value is TimeOfDay) {
          _selectedTime = widget.value as TimeOfDay;
        } else if (widget.value is String) {
          final parts = (widget.value as String).split(':');
          _selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 0,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        } else {
          _selectedTime = TimeOfDay.now();
        }
        break;
      case 'boolean':
        _boolValue = widget.value is bool ? widget.value as bool : false;
        break;
      case 'dropdown':
        _dropdownValue = widget.value?.toString();
        break;
    }
  }

  @override
  void dispose() {
    if (widget.field.fieldType == 'text' || widget.field.fieldType == 'textarea') {
      _textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.field.label,
              style: AirbnbTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (widget.field.required)
              Text(
                ' *',
                style: AirbnbTheme.bodyStyle.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _buildFieldWidget(),
      ],
    );
  }

  Widget _buildFieldWidget() {
    switch (widget.field.fieldType) {
      case 'text':
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.field.label.toLowerCase()}',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            widget.onChanged(value.isEmpty ? null : value);
          },
          validator: widget.field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.field.label} is required';
                  }
                  return null;
                }
              : null,
        );

      case 'textarea':
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.field.label.toLowerCase()}',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          maxLines: 3,
          onChanged: (value) {
            widget.onChanged(value.isEmpty ? null : value);
          },
          validator: widget.field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.field.label} is required';
                  }
                  return null;
                }
              : null,
        );

      case 'number':
        return TextFormField(
          initialValue: _numberValue.toString(),
          decoration: InputDecoration(
            hintText: 'Enter ${widget.field.label.toLowerCase()}',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final number = double.tryParse(value);
            widget.onChanged(number);
          },
          validator: widget.field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.field.label} is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }
              : null,
        );

      case 'date':
        return InkWell(
          onTap: _selectDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: AirbnbTheme.bodyStyle,
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        );

      case 'time':
        return InkWell(
          onTap: _selectTime,
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime.format(context),
                  style: AirbnbTheme.bodyStyle,
                ),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        );

      case 'boolean':
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CheckboxListTile(
            title: Text(
              widget.field.label,
              style: AirbnbTheme.bodyStyle.copyWith(fontSize: 14),
            ),
            value: _boolValue,
            onChanged: (value) {
              setState(() {
                _boolValue = value ?? false;
              });
              widget.onChanged(_boolValue);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );

      case 'dropdown':
        return DropdownButtonFormField<String>(
          value: _dropdownValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          hint: Text('Select ${widget.field.label.toLowerCase()}'),
          items: widget.field.options?.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList() ?? [],
          onChanged: (value) {
            setState(() {
              _dropdownValue = value;
            });
            widget.onChanged(value);
          },
          validator: widget.field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '${widget.field.label} is required';
                  }
                  return null;
                }
              : null,
        );

      default:
        return TextFormField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Enter ${widget.field.label.toLowerCase()}',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            widget.onChanged(value.isEmpty ? null : value);
          },
        );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onChanged(_selectedDate);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onChanged('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}');
    }
  }
}