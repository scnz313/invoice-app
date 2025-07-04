import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/invoice.dart';
import '../models/company_settings.dart';
import '../utils/currency_helper.dart';
import '../utils/logger.dart';
import 'image_service.dart';

class PDFService {
  static final PDFService _instance = PDFService._internal();
  factory PDFService() => _instance;
  PDFService._internal();

  // Font management with Unicode support and caching
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;
  static bool _fontsLoaded = false;
  static bool _fontsLoading = false;

  // Logo image caching
  static pw.ImageProvider? _logoImage;
  static bool _logoLoaded = false;

  // Image service for logo management
  final ImageService _imageService = ImageService();

  // PDF generation settings for optimization
  static const int _maxItemsPerPage = 25;
  static const double _compressionLevel = 0.8;
  static const PdfPageFormat _pageFormat = PdfPageFormat.a4;
  static const pw.EdgeInsets _pageMargins = pw.EdgeInsets.all(16);

  Future<void> _loadFonts() async {
    if (_fontsLoaded || _fontsLoading) return;
    
    _fontsLoading = true;
    try {
      // Use fonts with Unicode support for rupee symbols
      _regularFont = await PdfGoogleFonts.notoSansRegular();
      _boldFont = await PdfGoogleFonts.notoSansBold();
      _fontsLoaded = true;
      Logger.debug('PDF fonts loaded successfully: Noto Sans', 'PDFService');
    } catch (e) {
      Logger.warning('Failed to load Noto fonts, trying Roboto: $e', 'PDFService');
      try {
        // Fallback to other Unicode-supporting fonts
        _regularFont = await PdfGoogleFonts.robotoRegular();
        _boldFont = await PdfGoogleFonts.robotoBold();
        _fontsLoaded = true;
        Logger.debug('PDF fonts loaded successfully: Roboto', 'PDFService');
      } catch (e2) {
        Logger.warning('Failed to load Google fonts, using system defaults: $e2', 'PDFService');
        // Continue with system fonts - they may have limited Unicode support
        _fontsLoaded = true;
      }
    } finally {
      _fontsLoading = false;
    }
  }

  Future<void> _loadDefaultLogo() async {
    if (_logoLoaded) return;
    
    try {
      final logoBytes = await rootBundle.load('assets/images/app_logo.png');
      _logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      _logoLoaded = true;
      Logger.debug('Default app logo loaded successfully for PDF', 'PDFService');
    } catch (e) {
      Logger.warning('Failed to load default app logo: $e', 'PDFService');
      // Logo will fall back to text placeholder
    }
  }

  /// Load company logo from settings, fallback to default logo
  Future<pw.ImageProvider?> _loadCompanyLogo(CompanySettings companySettings) async {
    try {
      Logger.debug('Loading company logo for PDF...', 'PDFService');
      
      // First try to load company logo if available
      if (companySettings.logoPath != null && companySettings.logoPath!.isNotEmpty) {
        Logger.debug('Company logo path found: ${companySettings.logoPath}', 'PDFService');
        final logoBytes = await _imageService.loadImageAsBytes(companySettings.logoPath!);
        if (logoBytes != null) {
          Logger.info('Company logo loaded successfully for PDF (${logoBytes.length} bytes)', 'PDFService');
          return pw.MemoryImage(logoBytes);
        } else {
          Logger.warning('Failed to load company logo bytes from path: ${companySettings.logoPath}', 'PDFService');
        }
      } else {
        Logger.debug('No company logo path set, will use default or placeholder', 'PDFService');
      }
      
      // Fallback to default logo
      await _loadDefaultLogo();
      if (_logoImage != null) {
        Logger.debug('Using default app logo for PDF', 'PDFService');
      } else {
        Logger.debug('No default logo available, will show placeholder', 'PDFService');
      }
      return _logoImage;
    } catch (e) {
      Logger.warning('Failed to load company logo, using default: $e', 'PDFService');
      await _loadDefaultLogo();
      return _logoImage;
    }
  }

  Future<String> generateInvoicePDF({
    required Invoice invoice,
    required CompanySettings companySettings,
    String? outputPath,
  }) async {
    try {
      // Validate input data
      _validateInputData(invoice, companySettings);
      
      await _loadFonts();

      final pdf = pw.Document(
        compress: true,
        title: 'Invoice ${invoice.invoiceNumber}',
        author: companySettings.name.isNotEmpty ? companySettings.name : 'Invoice App',
        creator: 'Invoice App v1.0',
        subject: 'Invoice ${invoice.invoiceNumber}',
        keywords: 'invoice, billing, ${companySettings.name}',
      );

      // Build pages - split into multiple pages if needed
      final pages = await _buildPagesAsync(invoice, companySettings);
      for (final page in pages) {
        pdf.addPage(page);
      }

      // Save PDF with optimized settings
      final fileName = outputPath ?? await _generateFileName(invoice);
      final pdfBytes = await pdf.save();
      
      // Validate PDF size (warn if too large)
      if (pdfBytes.length > 5 * 1024 * 1024) { // 5MB
        Logger.warning('Generated PDF is large (${(pdfBytes.length / 1024 / 1024).toStringAsFixed(1)}MB)', 'PDFService');
      }
      
      final file = File(fileName);
      await file.writeAsBytes(pdfBytes);
      
      Logger.info('PDF generated successfully: $fileName (${(pdfBytes.length / 1024).toStringAsFixed(1)}KB)', 'PDFService');
      return fileName;
    } catch (e, stackTrace) {
      Logger.error('PDF generation error', 'PDFService', e, stackTrace);
      throw Exception('Failed to generate PDF: ${e.toString()}');
    }
  }

  void _validateInputData(Invoice invoice, CompanySettings companySettings) {
    if (invoice.invoiceNumber.isEmpty) {
      throw ArgumentError('Invoice number cannot be empty');
    }
    if (invoice.items.isEmpty) {
      throw ArgumentError('Invoice must have at least one item');
    }
    if (invoice.total <= 0) {
      throw ArgumentError('Invoice total must be greater than zero');
    }
  }

  Future<List<pw.Page>> _buildPagesAsync(Invoice invoice, CompanySettings companySettings) async {
    final pages = <pw.Page>[];
    
    // Load the main page content
    final mainPageContent = await _buildMainPageAsync(invoice, companySettings);
    
    // For now, single page layout
    pages.add(
      pw.Page(
        pageFormat: _pageFormat,
        margin: _pageMargins,
        build: (context) => mainPageContent,
      ),
    );
    
    return pages;
  }

  Future<pw.Widget> _buildMainPageAsync(Invoice invoice, CompanySettings companySettings) async {
    // Load the company logo first
    final companyLogo = await _loadCompanyLogo(companySettings);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header section
        _buildEnhancedHeader(),
        pw.SizedBox(height: 16),
        
        // Company information section
        _buildEnhancedCompanySection(companySettings, companyLogo),
        pw.SizedBox(height: 16),
        
        // Bill To and Invoice details section
        _buildEnhancedBillToSection(invoice),
        pw.SizedBox(height: 16),
        
        // Items table
        _buildEnhancedItemsTable(invoice),
        pw.SizedBox(height: 16),
        
        // Footer with bank details and terms
        pw.Expanded(child: _buildEnhancedFooter(companySettings)),
      ],
    );
  }

  pw.Widget _buildEnhancedHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // INVOICE label with box
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                font: _boldFont,
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          
          // ORIGINAL FOR RECIPIENT label
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey700, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              'ORIGINAL FOR RECIPIENT',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 9,
                color: PdfColors.grey700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEnhancedCompanySection(CompanySettings companySettings, [pw.ImageProvider? logo]) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Row(
        children: [
          // Enhanced logo section with dynamic logo
          _buildLogoSection(logo),
          
          // Enhanced company details
          pw.Expanded(
            child: _buildCompanyDetails(companySettings),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLogoSection([pw.ImageProvider? logo]) {
    // Use provided logo, or fall back to static _logoImage, or show placeholder
    final logoToUse = logo ?? _logoImage;
    
    return pw.Container(
      width: 90,
      height: 70,
      margin: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        boxShadow: [
          pw.BoxShadow(
            color: PdfColors.grey400,
            offset: const PdfPoint(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: logoToUse != null
          ? pw.Container(
              decoration: pw.BoxDecoration(
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Image(
                logoToUse,
                fit: pw.BoxFit.contain,
                width: 90,
                height: 70,
              ),
            )
          : pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [
                    PdfColor.fromHex('#2196F3'),
                    PdfColor.fromHex('#1976D2'),
                  ],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                ),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Center(
                child: pw.Text(
                  'LOGO',
                  style: pw.TextStyle(
                    font: _boldFont,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
    );
  }

  pw.Widget _buildCompanyDetails(CompanySettings companySettings) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            _sanitizeText(companySettings.name.isNotEmpty ? companySettings.name.toUpperCase() : 'YOUR COMPANY NAME'),
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            _sanitizeText(companySettings.address.isNotEmpty ? companySettings.address : 'Your Address, City, State, PIN Code'),
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 11,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
            maxLines: 2,
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Mobile: ${_sanitizeText(companySettings.phone.isNotEmpty ? companySettings.phone : '+1234567890')}',
                style: pw.TextStyle(
                  font: _regularFont,
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Email: ${_sanitizeText(companySettings.email.isNotEmpty ? companySettings.email : 'info@yourcompany.com')}',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEnhancedBillToSection(Invoice invoice) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Row(
        children: [
          // Enhanced Bill To section
          pw.Expanded(
            flex: 5,
            child: _buildBillToDetails(invoice),
          ),
          
          // Vertical separator
          pw.Container(
            width: 1.5,
            height: 90,
            color: PdfColors.black,
          ),
          
          // Enhanced Invoice details section
          pw.Expanded(
            flex: 7,
            child: _buildInvoiceDetails(invoice),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBillToDetails(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _sanitizeText(invoice.client.name.isNotEmpty ? invoice.client.name.toUpperCase() : 'CLIENT NAME'),
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            '3643463', // Client ID - you might want to add this to client model
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _sanitizeText(invoice.client.email.isNotEmpty ? invoice.client.email : 'client@email.com'),
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Phone: ${_sanitizeText(invoice.client.phone.isNotEmpty ? invoice.client.phone : '+1234567890')}',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInvoiceDetails(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Row(
        children: [
          // Invoice Number
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice No.',
                  style: pw.TextStyle(
                    font: _boldFont,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _sanitizeText(invoice.invoiceNumber),
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          
          _buildVerticalDivider(height: 45),
          
          // Invoice Date
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Invoice Date',
                  style: pw.TextStyle(
                    font: _boldFont,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _formatDate(invoice.createdDate),
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
          
          _buildVerticalDivider(height: 45),
          
          // Due Date
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Due Date',
                  style: pw.TextStyle(
                    font: _boldFont,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _formatDate(invoice.dueDate),
                  style: pw.TextStyle(
                    font: _regularFont,
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEnhancedItemsTable(Invoice invoice) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Column(
        children: [
          // Enhanced table header
          _buildTableHeader(),
          
          // Enhanced table rows
          ...invoice.items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            
            return _buildEnhancedTableRow(
              index.toString(),
              _sanitizeText(item.description),
              '${item.quantity.toInt()} PCS',
              CurrencyHelper.formatAmountForPdf(item.price),
              CurrencyHelper.formatAmountForPdf(item.total),
            );
          }),
          
          // Empty rows to fill space (minimum 6 rows total)
          ...List.generate(
            (6 - invoice.items.length).clamp(0, 5),
            (index) => _buildEnhancedTableRow('', '', '', '', ''),
          ),
          
          // Enhanced totals section
          _buildEnhancedTotalsSection(invoice),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.black, width: 1.5),
        ),
      ),
      child: pw.Row(
        children: [
          _buildTableHeaderCell('S.NO.', flex: 1),
          _buildVerticalDivider(),
          _buildTableHeaderCell('ITEMS', flex: 5),
          _buildVerticalDivider(),
          _buildTableHeaderCell('QTY.', flex: 2),
          _buildVerticalDivider(),
          _buildTableHeaderCell('RATE', flex: 2),
          _buildVerticalDivider(),
          _buildTableHeaderCell('AMOUNT', flex: 2),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaderCell(String text, {int flex = 1}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: _boldFont,
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.5,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildVerticalDivider({double height = 20}) {
    return pw.Container(
      width: 1,
      height: height,
      color: PdfColors.black,
      margin: const pw.EdgeInsets.symmetric(horizontal: 2),
    );
  }

  pw.Widget _buildEnhancedTableRow(
    String sno,
    String item,
    String qty,
    String rate,
    String amount,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        children: [
          _buildTableCell(sno, flex: 1, isCenter: true),
          _buildVerticalDivider(),
          _buildTableCell(item, flex: 5, isLeft: true),
          _buildVerticalDivider(),
          _buildTableCell(qty, flex: 2, isCenter: true),
          _buildVerticalDivider(),
          _buildTableCell(rate, flex: 2, isCenter: true),
          _buildVerticalDivider(),
          _buildTableCell(amount, flex: 2, isCenter: true),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    int flex = 1,
    bool isCenter = false,
    bool isLeft = false,
    bool isBold = false,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isBold ? _boldFont : _regularFont,
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isCenter
            ? pw.TextAlign.center
            : isLeft
                ? pw.TextAlign.left
                : pw.TextAlign.right,
        maxLines: 2,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  pw.Widget _buildEnhancedTotalsSection(Invoice invoice) {
    return pw.Column(
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(color: PdfColors.black, width: 1.5),
            ),
          ),
          child: pw.Column(
            children: [
              _buildTotalRow('SUBTOTAL', CurrencyHelper.formatAmountForPdf(invoice.subtotal)),
              _buildTotalRow(
                'TAX (${(invoice.taxAmount / invoice.subtotal * 100).toStringAsFixed(1)}%)',
                CurrencyHelper.formatAmountForPdf(invoice.taxAmount),
              ),
              _buildTotalRow(
                'TOTAL',
                CurrencyHelper.formatAmountForPdf(invoice.total),
                isTotal: true,
                showQuantity: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    String amount, {
    bool isTotal = false,
    bool showQuantity = false,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
        color: isTotal ? PdfColors.grey50 : null,
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 8, child: pw.Container()), // Empty space
          _buildVerticalDivider(),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: isTotal ? _boldFont : _regularFont,
                fontSize: isTotal ? 11 : 10,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          _buildVerticalDivider(),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              showQuantity ? '1' : '',
              style: pw.TextStyle(
                font: _regularFont,
                fontSize: 10,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          _buildVerticalDivider(),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              amount,
              style: pw.TextStyle(
                font: isTotal ? _boldFont : _regularFont,
                fontSize: isTotal ? 11 : 10,
                fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildEnhancedFooter(CompanySettings companySettings) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 16),
        
        // Enhanced Received Amount section
        _buildReceivedAmountSection(),
        
        pw.SizedBox(height: 12),
        
        // Enhanced Bank Details and Terms section
        _buildFooterMainSection(companySettings),
      ],
    );
  }

  pw.Widget _buildReceivedAmountSection() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: PdfColors.grey50,
      ),
      child: pw.Text(
        'Received Amount: Rs. __________',
        style: pw.TextStyle(
          font: _boldFont,
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildFooterMainSection(CompanySettings companySettings) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Enhanced Bank Details
          pw.Expanded(
            flex: 3,
            child: _buildBankDetails(companySettings),
          ),
          
          // Vertical separator
          pw.Container(
            width: 1.5,
            height: 100,
            color: PdfColors.black,
          ),
          
          // Enhanced Terms and Conditions
          pw.Expanded(
            flex: 3,
            child: _buildTermsAndConditions(),
          ),
          
          // Vertical separator
          pw.Container(
            width: 1.5,
            height: 100,
            color: PdfColors.black,
          ),
          
          // Enhanced Signature section
          pw.Expanded(
            child: _buildSignatureSection(),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBankDetails(CompanySettings companySettings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bank Details',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildBankDetailRow('Name:', _sanitizeText(companySettings.name.isNotEmpty ? companySettings.name : 'Your Company Name')),
          _buildBankDetailRow('IFSC Code:', _sanitizeText(companySettings.bankIFSC.isNotEmpty ? companySettings.bankIFSC : 'YOURBANK123')),
          _buildBankDetailRow('Account No:', _sanitizeText(companySettings.bankAccount.isNotEmpty ? companySettings.bankAccount : '1234567890123456')),
          _buildBankDetailRow('Bank:', _sanitizeText(companySettings.bankName.isNotEmpty ? companySettings.bankName : 'Your Bank Name')),
        ],
      ),
    );
  }

  pw.Widget _buildTermsAndConditions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Terms and Conditions',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 8),
          _buildTermsItem('1. Payment due within 30 days'),
          _buildTermsItem('2. Goods once sold will not be taken back'),
          _buildTermsItem('3. All disputes subject to local jurisdiction'),
          pw.SizedBox(height: 8),
          pw.Text(
            'Notes:',
            style: pw.TextStyle(
              font: _boldFont,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '2342',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureSection() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.SizedBox(height: 50),
          pw.Text(
            'Authorised',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
            ),
          ),
          pw.Text(
            'Signatory',
            style: pw.TextStyle(
              font: _regularFont,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBankDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        '$label $value',
        style: pw.TextStyle(
          font: _regularFont,
          fontSize: 10,
        ),
      ),
    );
  }

  pw.Widget _buildTermsItem(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: _regularFont,
          fontSize: 10,
        ),
      ),
    );
  }

  // Utility methods
  String _sanitizeText(String text) {
    // Remove or replace characters that might cause PDF issues
    return text
        .replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\u00FF\u20A8]'), ' ')
        .trim();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<String> _generateFileName(Invoice invoice) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final sanitizedInvoiceNumber = invoice.invoiceNumber.replaceAll(RegExp(r'[^\w\-]'), '_');
      return '${directory.path}/invoice_${sanitizedInvoiceNumber}_$timestamp.pdf';
    } catch (e) {
      // Fallback to temp directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '${directory.path}/invoice_$timestamp.pdf';
    }
  }

  // Public API methods with enhanced error handling
  Future<void> printInvoice(Invoice invoice, CompanySettings settings) async {
    try {
      await _loadFonts();
      
      final pdf = pw.Document(
        compress: true,
        title: 'Invoice ${invoice.invoiceNumber}',
      );
      
      // Load the main page content with logo
      final mainPageContent = await _buildMainPageAsync(invoice, settings);
      
      pdf.addPage(
        pw.Page(
          pageFormat: _pageFormat,
          margin: _pageMargins,
          build: (context) => mainPageContent,
        ),
      );
      
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice ${invoice.invoiceNumber}',
      );
    } catch (e, stackTrace) {
      Logger.error('Print error', 'PDFService', e, stackTrace);
      throw Exception('Failed to print invoice: ${e.toString()}');
    }
  }

  Future<void> shareInvoice(Invoice invoice, CompanySettings settings) async {
    try {
      Logger.debug('Starting PDF sharing process...', 'PDFService');
      
      final fileName = await generateInvoicePDF(
        invoice: invoice, 
        companySettings: settings,
      );
      
      Logger.debug('PDF file generated at: $fileName', 'PDFService');
      
      // Verify file exists and is readable
      final file = File(fileName);
      if (!await file.exists()) {
        throw Exception('Generated PDF file does not exist');
      }
      
      final fileSize = await file.length();
      Logger.debug('PDF file size: ${fileSize} bytes', 'PDFService');
      
      if (fileSize == 0) {
        throw Exception('Generated PDF file is empty');
      }
      
      // Use share_plus package instead of Printing.sharePdf for better cross-platform support
      final xFile = XFile(fileName);
      
      Logger.debug('Sharing PDF using share_plus...', 'PDFService');
      
      await Share.shareXFiles(
        [xFile],
        subject: 'Invoice ${invoice.invoiceNumber}',
        text: 'Please find attached invoice ${invoice.invoiceNumber} from ${settings.name.isNotEmpty ? settings.name : 'Your Company'}.',
      );
      
      Logger.info('PDF sharing completed successfully', 'PDFService');
    } catch (e, stackTrace) {
      Logger.error('Share error', 'PDFService', e, stackTrace);
      throw Exception('Failed to share invoice: ${e.toString()}');
    }
  }

  // Alternative sharing method using Printing.sharePdf as fallback
  Future<void> shareInvoiceUsingPrinting(Invoice invoice, CompanySettings settings) async {
    try {
      Logger.debug('Using Printing.sharePdf as fallback...', 'PDFService');
      
      final fileName = await generateInvoicePDF(
        invoice: invoice, 
        companySettings: settings,
      );
      
      await Printing.sharePdf(
        bytes: await File(fileName).readAsBytes(),
        filename: 'invoice_${invoice.invoiceNumber}.pdf',
        subject: 'Invoice ${invoice.invoiceNumber}',
      );
    } catch (e, stackTrace) {
      Logger.error('Printing share error', 'PDFService', e, stackTrace);
      throw Exception('Failed to share invoice using printing package: ${e.toString()}');
    }
  }

  // Comprehensive sharing method with multiple fallbacks
  Future<void> shareInvoiceRobust(Invoice invoice, CompanySettings settings) async {
    Exception? lastError;
    String? generatedFilePath;
    
    try {
      Logger.debug('Starting PDF sharing process...', 'PDFService');
      
      // Clean up old PDF files first (keep only latest 5 files)
      await _cleanupOldPdfFiles();
      
      // Generate the PDF file once
      generatedFilePath = await generateInvoicePDF(
        invoice: invoice, 
        companySettings: settings,
      );
      
      Logger.debug('PDF file generated at: $generatedFilePath', 'PDFService');
      
      // Verify file exists and is readable
      final file = File(generatedFilePath);
      if (!await file.exists()) {
        throw Exception('Generated PDF file does not exist');
      }
      
      final fileSize = await file.length();
      Logger.debug('PDF file size: ${fileSize} bytes', 'PDFService');
      
      if (fileSize == 0) {
        throw Exception('Generated PDF file is empty');
      }
      
      // Try primary method using share_plus
      try {
        Logger.debug('Sharing PDF using share_plus...', 'PDFService');
        
        final xFile = XFile(generatedFilePath);
        await Share.shareXFiles(
          [xFile],
          subject: 'Invoice ${invoice.invoiceNumber}',
          text: 'Please find attached invoice ${invoice.invoiceNumber} from ${settings.name.isNotEmpty ? settings.name : 'Your Company'}.',
        );
        
        Logger.info('PDF sharing completed successfully', 'PDFService');
        return;
      } catch (e) {
        Logger.warning('Primary share method failed: $e', 'PDFService');
        lastError = Exception('Primary share failed: $e');
      }
      
      // Try fallback method using Printing package with existing file
      try {
        Logger.debug('Using Printing.sharePdf as fallback...', 'PDFService');
        
        await Printing.sharePdf(
          bytes: await file.readAsBytes(),
          filename: 'invoice_${invoice.invoiceNumber}.pdf',
          subject: 'Invoice ${invoice.invoiceNumber}',
        );
        
        Logger.info('PDF sharing completed successfully using fallback', 'PDFService');
        return;
      } catch (e) {
        Logger.warning('Fallback share method failed: $e', 'PDFService');
        lastError = Exception('All share methods failed. Last error: $e');
      }
      
    } catch (e, stackTrace) {
      Logger.error('PDF generation or sharing error', 'PDFService', e, stackTrace);
      lastError = Exception('Failed to generate or share invoice: ${e.toString()}');
    }
    
    throw lastError!;
  }

  // Clean up old PDF files to prevent accumulation
  Future<void> _cleanupOldPdfFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((file) => file.path.contains('invoice_') && file.path.endsWith('.pdf'))
          .map((file) => File(file.path))
          .toList();
      
      if (files.length > 5) {
        // Sort by modification time (newest first)
        files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
        
        // Delete all but the latest 5 files
        final filesToDelete = files.skip(5);
        for (final file in filesToDelete) {
          try {
            await file.delete();
            Logger.debug('Cleaned up old PDF file: ${file.path}', 'PDFService');
          } catch (e) {
            Logger.warning('Failed to delete old PDF file: ${file.path}, error: $e', 'PDFService');
          }
        }
      }
    } catch (e) {
      Logger.warning('Error during PDF cleanup: $e', 'PDFService');
      // Don't throw error, cleanup is not critical
    }
  }

  // Legacy support methods
  static Future<Uint8List> generateInvoicePdf(Invoice invoice, CompanySettings companySettings) async {
    final service = PDFService();
    final fileName = await service.generateInvoicePDF(
      invoice: invoice,
      companySettings: companySettings,
    );
    return await File(fileName).readAsBytes();
  }

  static Future<void> shareInvoicePdf(Invoice invoice, CompanySettings companySettings) async {
    final service = PDFService();
    await service.shareInvoiceRobust(invoice, companySettings);
  }

  static Future<void> printInvoicePdf(Invoice invoice, CompanySettings companySettings) async {
    final service = PDFService();
    await service.printInvoice(invoice, companySettings);
  }
} 