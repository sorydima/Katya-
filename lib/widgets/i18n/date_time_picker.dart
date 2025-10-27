import 'package:flutter/material.dart';

import '../../services/i18n/regional_settings_service.dart';

/// Виджет для выбора даты с учетом региональных настроек
class RegionalDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateChanged;
  final String? label;
  final String? helperText;
  final bool enabled;

  const RegionalDatePicker({
    super.key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.onDateChanged,
    this.label,
    this.helperText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final currentDate = initialDate ?? DateTime.now();

    return TextFormField(
      decoration: InputDecoration(
        labelText: label ?? 'Select Date',
        helperText: helperText,
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: enabled ? const Icon(Icons.arrow_drop_down) : null,
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(
        text: regionalService.formatDate(currentDate),
      ),
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: Locale(RegionalSettingsService().currentSettings.regionCode),
    );

    if (picked != null && picked != initialDate) {
      onDateChanged(picked);
    }
  }
}

/// Виджет для выбора времени с учетом региональных настроек
class RegionalTimePicker extends StatelessWidget {
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeChanged;
  final String? label;
  final String? helperText;
  final bool enabled;

  const RegionalTimePicker({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
    this.label,
    this.helperText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final currentTime = initialTime ?? TimeOfDay.now();

    return TextFormField(
      decoration: InputDecoration(
        labelText: label ?? 'Select Time',
        helperText: helperText,
        prefixIcon: const Icon(Icons.access_time),
        suffixIcon: enabled ? const Icon(Icons.arrow_drop_down) : null,
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      enabled: enabled,
      controller: TextEditingController(
        text: regionalService.formatTime(
          DateTime(2023, 1, 1, currentTime.hour, currentTime.minute),
        ),
      ),
      onTap: enabled ? () => _selectTime(context) : null,
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              hourMinuteTextStyle: Theme.of(context).textTheme.headlineMedium,
              hourMinuteColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialTime) {
      onTimeChanged(picked);
    }
  }
}

/// Виджет для выбора даты и времени
class RegionalDateTimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime) onDateTimeChanged;
  final String? label;
  final String? helperText;
  final bool enabled;

  const RegionalDateTimePicker({
    super.key,
    this.initialDateTime,
    this.firstDate,
    this.lastDate,
    required this.onDateTimeChanged,
    this.label,
    this.helperText,
    this.enabled = true,
  });

  @override
  State<RegionalDateTimePicker> createState() => _RegionalDateTimePickerState();
}

class _RegionalDateTimePickerState extends State<RegionalDateTimePicker> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: RegionalDatePicker(
                initialDate: _selectedDateTime,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      _selectedDateTime.hour,
                      _selectedDateTime.minute,
                      _selectedDateTime.second,
                    );
                  });
                  widget.onDateTimeChanged(_selectedDateTime);
                },
                enabled: widget.enabled,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RegionalTimePicker(
                initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                onTimeChanged: (time) {
                  setState(() {
                    _selectedDateTime = DateTime(
                      _selectedDateTime.year,
                      _selectedDateTime.month,
                      _selectedDateTime.day,
                      time.hour,
                      time.minute,
                    );
                  });
                  widget.onDateTimeChanged(_selectedDateTime);
                },
                enabled: widget.enabled,
              ),
            ),
          ],
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

/// Виджет для отображения относительного времени
class RelativeTimeWidget extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;
  final bool showTooltip;

  const RelativeTimeWidget({
    super.key,
    required this.dateTime,
    this.style,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final regionalService = RegionalSettingsService();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    String relativeTime;
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      relativeTime = _formatRelativeTime(years, 'year');
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      relativeTime = _formatRelativeTime(months, 'month');
    } else if (difference.inDays > 0) {
      relativeTime = _formatRelativeTime(difference.inDays, 'day');
    } else if (difference.inHours > 0) {
      relativeTime = _formatRelativeTime(difference.inHours, 'hour');
    } else if (difference.inMinutes > 0) {
      relativeTime = _formatRelativeTime(difference.inMinutes, 'minute');
    } else {
      relativeTime = 'Just now';
    }

    final Widget textWidget = Text(
      relativeTime,
      style: style,
    );

    if (showTooltip) {
      return Tooltip(
        message: regionalService.formatDateTime(dateTime),
        child: textWidget,
      );
    }

    return textWidget;
  }

  String _formatRelativeTime(int value, String unit) {
    if (value == 1) {
      return '$value $unit ago';
    }
    return '$value ${unit}s ago';
  }
}

/// Виджет для выбора диапазона дат
class RegionalDateRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTimeRange) onDateRangeChanged;
  final String? label;
  final String? helperText;
  final bool enabled;

  const RegionalDateRangePicker({
    super.key,
    this.initialDateRange,
    this.firstDate,
    this.lastDate,
    required this.onDateRangeChanged,
    this.label,
    this.helperText,
    this.enabled = true,
  });

  @override
  State<RegionalDateRangePicker> createState() => _RegionalDateRangePickerState();
}

class _RegionalDateRangePickerState extends State<RegionalDateRangePicker> {
  DateTimeRange? _selectedDateRange;
  final RegionalSettingsService _regionalService = RegionalSettingsService();

  @override
  void initState() {
    super.initState();
    _selectedDateRange = widget.initialDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Date Range',
            helperText: widget.helperText,
            prefixIcon: const Icon(Icons.date_range),
            suffixIcon: widget.enabled ? const Icon(Icons.arrow_drop_down) : null,
            border: const OutlineInputBorder(),
          ),
          readOnly: true,
          enabled: widget.enabled,
          controller: TextEditingController(
            text: _selectedDateRange != null
                ? '${_regionalService.formatDate(_selectedDateRange!.start)} - ${_regionalService.formatDate(_selectedDateRange!.end)}'
                : 'Select date range',
          ),
          onTap: widget.enabled ? () => _selectDateRange(context) : null,
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      initialDateRange: _selectedDateRange,
      locale: Locale(_regionalService.currentSettings.regionCode),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      widget.onDateRangeChanged(picked);
    }
  }
}
