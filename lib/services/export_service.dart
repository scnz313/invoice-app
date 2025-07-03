import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../utils/currency_helper.dart';

enum ExportFormat { csv, json, pdf, excel }

enum ExportScope { all, filtered, selected }

class ExportOptions {
  final ExportFormat format;
  final ExportScope scope;
  final List<String> includeFields;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<InvoiceStatus>? statusFilter;
  final String? clientFilter;
  final bool includeHeader;
  final String? customFileName;
  final bool compressOutput;
  final String separator; // For CSV
  final bool prettyJson; // For JSON

  const ExportOptions({
    required this.format,
    this.scope = ExportScope.all,
    this.includeFields = const [],
    this.dateFrom,
    this.dateTo,
    this.statusFilter,
    this.clientFilter,
    this.includeHeader = true,
    this.customFileName,
    this.compressOutput = false,
    this.separator = ',',
    this.prettyJson = true,
  });
}

class ExportResult {
  final String filePath;
  final String fileName;
  final ExportFormat format;
  final int recordCount;
  final int fileSizeBytes;
  final DateTime exportedAt;
  final bool success;
  final String? errorMessage;

  const ExportResult({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.recordCount,
    required this.fileSizeBytes,
    required this.exportedAt,
    required this.success,
    this.errorMessage,
  });

  factory ExportResult.error(String errorMessage, ExportFormat format) {
    return ExportResult(
      filePath: '',
      fileName: '',
      format: format,
      recordCount: 0,
      fileSizeBytes: 0,
      exportedAt: DateTime.now(),
      success: false,
      errorMessage: errorMessage,
    );
  }
}

class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  // Available fields for export
  static const Map<String, String> availableFields = {
    'invoiceNumber': 'Invoice Number',
    'clientName': 'Client Name',
    'clientEmail': 'Client Email',
    'clientPhone': 'Client Phone',
    'clientAddress': 'Client Address',
    'createdDate': 'Issue Date',
    'dueDate': 'Due Date',
    'status': 'Status',
    'items': 'Items',
    'itemCount': 'Item Count',
    'subtotal': 'Subtotal',
    'taxPercentage': 'Tax %',
    'taxAmount': 'Tax Amount',
    'discountAmount': 'Discount',
    'total': 'Total Amount',
    'notes': 'Notes',
    'isOverdue': 'Overdue',
    'daysPastDue': 'Days Past Due',
  };

  Future<ExportResult> exportInvoices(
    List<Invoice> invoices,
    ExportOptions options, {
    List<String>? selectedIds,
  }) async {
    try {
      // Filter invoices based on options
      final filteredInvoices = _filterInvoices(invoices, options, selectedIds);
      
      if (filteredInvoices.isEmpty) {
        return ExportResult.error('No invoices match the export criteria', options.format);
      }

      // Generate export data based on format
      final exportData = await _generateExportData(filteredInvoices, options);
      
      // Save to file
      final file = await _saveToFile(exportData, options);
      
      return ExportResult(
        filePath: file.path,
        fileName: file.path.split('/').last,
        format: options.format,
        recordCount: filteredInvoices.length,
        fileSizeBytes: await file.length(),
        exportedAt: DateTime.now(),
        success: true,
      );
    } catch (e) {
      return ExportResult.error('Export failed: $e', options.format);
    }
  }

  List<Invoice> _filterInvoices(
    List<Invoice> invoices,
    ExportOptions options,
    List<String>? selectedIds,
  ) {
    var filtered = invoices;

    // Filter by scope
    switch (options.scope) {
      case ExportScope.selected:
        if (selectedIds != null && selectedIds.isNotEmpty) {
          filtered = filtered.where((invoice) => selectedIds.contains(invoice.id)).toList();
        }
        break;
      case ExportScope.all:
      case ExportScope.filtered:
        // Apply additional filters
        break;
    }

    // Filter by date range
    if (options.dateFrom != null) {
      filtered = filtered.where((invoice) => 
        invoice.createdDate.isAfter(options.dateFrom!.subtract(const Duration(days: 1)))
      ).toList();
    }
    
    if (options.dateTo != null) {
      filtered = filtered.where((invoice) => 
        invoice.createdDate.isBefore(options.dateTo!.add(const Duration(days: 1)))
      ).toList();
    }

    // Filter by status
    if (options.statusFilter != null && options.statusFilter!.isNotEmpty) {
      filtered = filtered.where((invoice) => 
        options.statusFilter!.contains(invoice.status)
      ).toList();
    }

    // Filter by client
    if (options.clientFilter != null && options.clientFilter!.isNotEmpty) {
      final clientFilter = options.clientFilter!.toLowerCase();
      filtered = filtered.where((invoice) => 
        invoice.client.name.toLowerCase().contains(clientFilter) ||
        invoice.client.email.toLowerCase().contains(clientFilter)
      ).toList();
    }

    return filtered;
  }

  // Share exported file
  Future<void> shareExportFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  Future<dynamic> _generateExportData(List<Invoice> invoices, ExportOptions options) async {
    switch (options.format) {
      case ExportFormat.csv:
        return _generateCsvData(invoices, options);
      case ExportFormat.json:
        return _generateJsonData(invoices, options);
      case ExportFormat.excel:
        return _generateExcelData(invoices, options);
      case ExportFormat.pdf:
        return _generatePdfData(invoices, options);
    }
  }

  String _generateCsvData(List<Invoice> invoices, ExportOptions options) {
    final fields = options.includeFields.isNotEmpty 
        ? options.includeFields 
        : availableFields.keys.toList();
    
    final rows = <List<String>>[];
    
    // Add header row
    if (options.includeHeader) {
      rows.add(fields.map((field) => availableFields[field] ?? field).toList());
    }
    
    // Add data rows
    for (final invoice in invoices) {
      final row = fields.map((field) => _getFieldValue(invoice, field)).toList();
      rows.add(row);
    }
    
    return const ListToCsvConverter().convert(
      rows,
      fieldDelimiter: options.separator,
    );
  }

  String _generateJsonData(List<Invoice> invoices, ExportOptions options) {
    final data = {
      'exportInfo': {
        'exportedAt': DateTime.now().toIso8601String(),
        'totalRecords': invoices.length,
        'format': 'JSON',
        'version': '1.0',
      },
      'invoices': invoices.map((invoice) => _invoiceToMap(invoice, options)).toList(),
    };
    
    if (options.prettyJson) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } else {
      return jsonEncode(data);
    }
  }

  Map<String, dynamic> _invoiceToMap(Invoice invoice, ExportOptions options) {
    final fields = options.includeFields.isNotEmpty 
        ? options.includeFields 
        : availableFields.keys.toList();
    
    final map = <String, dynamic>{};
    
    for (final field in fields) {
      map[field] = _getFieldValue(invoice, field);
    }
    
    return map;
  }

  Uint8List _generateExcelData(List<Invoice> invoices, ExportOptions options) {
    // For now, return CSV data as bytes (in a real implementation, use excel package)
    final csvData = _generateCsvData(invoices, options);
    return Uint8List.fromList(utf8.encode(csvData));
  }

  Future<Uint8List> _generatePdfData(List<Invoice> invoices, ExportOptions options) async {
    // This would integrate with the enhanced PDF service
    // For now, return a placeholder
    final jsonData = _generateJsonData(invoices, options);
    return Uint8List.fromList(utf8.encode(jsonData));
  }

  String _getFieldValue(Invoice invoice, String field) {
    switch (field) {
      case 'invoiceNumber':
        return invoice.invoiceNumber;
      case 'clientName':
        return invoice.client.name;
      case 'clientEmail':
        return invoice.client.email;
      case 'clientPhone':
        return invoice.client.phone;
      case 'clientAddress':
        return invoice.client.address;
      case 'createdDate':
        return _formatDate(invoice.createdDate);
      case 'dueDate':
        return _formatDate(invoice.dueDate);
      case 'status':
        return _getStatusText(invoice.status);
      case 'items':
        return invoice.items.map((item) => 
          '${item.description} (${item.quantity} x ${CurrencyHelper.formatAmount(item.price)})'
        ).join('; ');
      case 'itemCount':
        return invoice.items.length.toString();
      case 'subtotal':
        return invoice.subtotal.toStringAsFixed(2);
      case 'taxPercentage':
        return invoice.taxPercentage.toStringAsFixed(2);
      case 'taxAmount':
        return invoice.taxAmount.toStringAsFixed(2);
      case 'discountAmount':
        return invoice.discountAmount.toStringAsFixed(2);
      case 'total':
        return invoice.total.toStringAsFixed(2);
      case 'notes':
        return invoice.notes;
      case 'isOverdue':
        return invoice.isOverdue.toString();
      case 'daysPastDue':
        return invoice.isOverdue 
            ? DateTime.now().difference(invoice.dueDate).inDays.toString()
            : '0';
      default:
        return '';
    }
  }

  Future<File> _saveToFile(dynamic data, ExportOptions options) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = options.customFileName ?? _generateFileName(options);
    final file = File('${directory.path}/$fileName');
    
    if (data is String) {
      await file.writeAsString(data);
    } else if (data is Uint8List) {
      await file.writeAsBytes(data);
    } else {
      throw Exception('Unsupported data type for file writing');
    }
    
    return file;
  }

  String _generateFileName(ExportOptions options) {
    final timestamp = DateTime.now();
    final dateStr = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}';
    final timeStr = '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}';
    
    final extension = _getFileExtension(options.format);
    return 'invoices_export_${dateStr}_$timeStr.$extension';
  }

  String _getFileExtension(ExportFormat format) {
    switch (format) {
      case ExportFormat.csv:
        return 'csv';
      case ExportFormat.json:
        return 'json';
      case ExportFormat.excel:
        return 'xlsx';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.sent:
        return 'Sent';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
    }
  }

  // Share exported file
  Future<void> shareExportedFile(ExportResult result) async {
    if (!result.success) {
      throw Exception(result.errorMessage ?? 'Export failed');
    }

    final xFile = XFile(result.filePath);
    await Share.shareXFiles(
      [xFile],
      subject: 'Invoice Export - ${result.fileName}',
      text: 'Exported ${result.recordCount} invoices on ${_formatDate(result.exportedAt)}',
    );
  }

  // Import data (basic implementation)
  Future<List<Invoice>> importFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      
      final rows = const CsvToListConverter().convert(content);
      if (rows.isEmpty) {
        throw Exception('CSV file is empty');
      }
      
      final header = rows.first.map((e) => e.toString()).toList();
      final dataRows = rows.skip(1);
      
      final invoices = <Invoice>[];
      
      for (final row in dataRows) {
        final rowData = row.map((e) => e.toString()).toList();
        final invoice = _parseInvoiceFromCsv(header, rowData);
        if (invoice != null) {
          invoices.add(invoice);
        }
      }
      
      return invoices;
    } catch (e) {
      throw Exception('Failed to import CSV: $e');
    }
  }

  Invoice? _parseInvoiceFromCsv(List<String> header, List<String> row) {
    try {
      // Find required field indices
      final invoiceNumberIndex = header.indexOf('Invoice Number');
      final clientNameIndex = header.indexOf('Client Name');
      final totalIndex = header.indexOf('Total Amount');
      
      if (invoiceNumberIndex == -1 || clientNameIndex == -1 || totalIndex == -1) {
        return null; // Skip rows with missing required fields
      }
      
      // Create basic client
      final client = Client(
        id: '',
        name: row[clientNameIndex],
        email: _getValueAtIndex(row, header.indexOf('Client Email')) ?? '',
        phone: _getValueAtIndex(row, header.indexOf('Client Phone')) ?? '',
        address: _getValueAtIndex(row, header.indexOf('Client Address')) ?? '',
      );
      
      // Parse dates
      final createdDateStr = _getValueAtIndex(row, header.indexOf('Issue Date'));
      final dueDateStr = _getValueAtIndex(row, header.indexOf('Due Date'));
      
      final createdDate = _parseDate(createdDateStr) ?? DateTime.now();
      final dueDate = _parseDate(dueDateStr) ?? DateTime.now().add(const Duration(days: 30));
      
      // Parse amounts
      // final total = double.tryParse(row[totalIndex]) ?? 0.0;
      final taxPercentage = double.tryParse(_getValueAtIndex(row, header.indexOf('Tax %')) ?? '0') ?? 0.0;
      final discountAmount = double.tryParse(_getValueAtIndex(row, header.indexOf('Discount')) ?? '0') ?? 0.0;
      
      // Parse status
      final statusStr = _getValueAtIndex(row, header.indexOf('Status')) ?? 'Draft';
      final status = _parseStatus(statusStr);
      
      // Create invoice (simplified - would need to parse items properly)
      return Invoice(
        id: '',
        invoiceNumber: row[invoiceNumberIndex],
        client: client,
        items: [], // Would need to parse items from the items field
        createdDate: createdDate,
        dueDate: dueDate,
        taxPercentage: taxPercentage,
        discountAmount: discountAmount,
        status: status,
        notes: _getValueAtIndex(row, header.indexOf('Notes')) ?? '',
      );
    } catch (e) {
      return null; // Skip invalid rows
    }
  }

  String? _getValueAtIndex(List<String> row, int index) {
    if (index == -1 || index >= row.length) return null;
    final value = row[index].trim();
    return value.isEmpty ? null : value;
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    
    try {
      // Try DD/MM/YYYY format
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      // Ignore parse errors
    }
    
    return null;
  }

  InvoiceStatus _parseStatus(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'sent':
        return InvoiceStatus.sent;
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      default:
        return InvoiceStatus.draft;
    }
  }

  // Get export statistics
  Future<ExportStatistics> getExportStatistics(List<Invoice> invoices) async {
    final totalInvoices = invoices.length;
    final totalAmount = invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
    final paidAmount = invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .fold(0.0, (sum, invoice) => sum + invoice.total);
    final pendingAmount = totalAmount - paidAmount;
    
    final statusCounts = <InvoiceStatus, int>{};
    for (final status in InvoiceStatus.values) {
      statusCounts[status] = invoices.where((inv) => inv.status == status).length;
    }
    
    final overdueCount = invoices.where((invoice) => invoice.isOverdue).length;
    
    return ExportStatistics(
      totalInvoices: totalInvoices,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
      statusCounts: statusCounts,
      overdueCount: overdueCount,
    );
  }
}

class ExportStatistics {
  final int totalInvoices;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final Map<InvoiceStatus, int> statusCounts;
  final int overdueCount;

  const ExportStatistics({
    required this.totalInvoices,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.statusCounts,
    required this.overdueCount,
  });
} 