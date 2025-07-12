import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/invoice.dart';
import '../models/client.dart';
import '../models/invoice_item.dart';
import '../models/company_settings.dart';

class JewelryPdfGenerator {
  static Future<File> generateJewelryInvoice(Invoice invoice, CompanySettings companySettings) async {
    final pdf = pw.Document();
    
    // Add company logo if available
    pw.MemoryImage? logoImage;
    if (companySettings.logoPath != null && companySettings.logoPath!.isNotEmpty) {
      try {
        final logoFile = File(companySettings.logoPath!);
        if (await logoFile.exists()) {
          final logoBytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(logoBytes);
        }
      } catch (e) {
        print('Error loading logo: $e');
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(invoice, companySettings, logoImage),
          pw.SizedBox(height: 20),
          _buildClientSection(invoice.client),
          pw.SizedBox(height: 20),
          _buildInvoiceDetails(invoice),
          pw.SizedBox(height: 20),
          _buildItemsTable(invoice.items),
          pw.SizedBox(height: 20),
          _buildChargesSection(invoice),
          pw.SizedBox(height: 20),
          _buildExchangeSection(invoice),
          pw.SizedBox(height: 20),
          _buildPaymentSection(invoice),
          pw.SizedBox(height: 20),
          _buildTotalSection(invoice),
          pw.SizedBox(height: 20),
          _buildAdditionalDetails(invoice),
          pw.SizedBox(height: 20),
          _buildFooter(companySettings),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/jewelry_invoice_${invoice.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader(Invoice invoice, CompanySettings companySettings, pw.MemoryImage? logoImage) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company Logo and Details
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logoImage != null) ...[
                pw.Image(logoImage, height: 60),
                pw.SizedBox(height: 10),
              ],
              pw.Text(
                companySettings.companyName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                companySettings.address,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Phone: ${companySettings.phone}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Email: ${companySettings.email}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              if (companySettings.gstNumber != null && companySettings.gstNumber!.isNotEmpty)
                pw.Text(
                  'GST: ${companySettings.gstNumber}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
            ],
          ),
        ),
        // Invoice Title and Number
        pw.Expanded(
          flex: 1,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'JEWELRY INVOICE',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      invoice.invoiceNumber,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Date: ${_formatDate(invoice.createdDate)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Due Date: ${_formatDate(invoice.dueDate)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: _getStatusColor(invoice.status),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  invoice.status.name.toUpperCase(),
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildClientSection(Client client) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            client.name,
            style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(client.address, style: const pw.TextStyle(fontSize: 10)),
          if (client.hasCompleteAddress)
            pw.Text(
              '${client.city}, ${client.state} - ${client.pincode}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          pw.Text('Phone: ${client.phone}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Email: ${client.email}', style: const pw.TextStyle(fontSize: 10)),
          if (client.hasBusinessDetails) ...[
            pw.SizedBox(height: 5),
            if (client.gstNumber != null && client.gstNumber!.isNotEmpty)
              pw.Text('GST: ${client.gstNumber}', style: const pw.TextStyle(fontSize: 10)),
            if (client.panNumber != null && client.panNumber!.isNotEmpty)
              pw.Text('PAN: ${client.panNumber}', style: const pw.TextStyle(fontSize: 10)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildInvoiceDetails(Invoice invoice) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INVOICE DETAILS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Invoice #: ${invoice.invoiceNumber}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Date: ${_formatDate(invoice.createdDate)}', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Due Date: ${_formatDate(invoice.dueDate)}', style: const pw.TextStyle(fontSize: 10)),
                if (invoice.salesPerson != null)
                  pw.Text('Sales Person: ${invoice.salesPerson}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT INFO',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green900,
                  ),
                ),
                pw.SizedBox(height: 5),
                if (invoice.paymentMethod != null)
                  pw.Text('Method: ${invoice.paymentMethodDisplay}', style: const pw.TextStyle(fontSize: 10)),
                if (invoice.advanceAmount != null && invoice.advanceAmount! > 0)
                  pw.Text('Advance: ₹${invoice.advanceAmount!.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                if (invoice.isEMI && invoice.emiMonths != null)
                  pw.Text('EMI: ${invoice.emiMonths} months', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Status: ${invoice.paymentStatusText}', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<InvoiceItem> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'JEWELRY ITEMS',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: const {
            0: pw.FlexColumnWidth(3),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
            4: pw.FlexColumnWidth(1),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue50),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Details', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
            // Item rows
            ...items.map((item) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.description, style: const pw.TextStyle(fontSize: 10)),
                      if (item.hasJewelryDetails) ...[
                        pw.SizedBox(height: 2),
                        pw.Text(
                          '${item.jewelryTypeDisplay} • ${item.metalTypeDisplay}',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                        if (item.weight != null)
                          pw.Text(
                            'Weight: ${item.weight}g • Purity: ${item.purity}',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                          ),
                        if (item.size != null)
                          pw.Text(
                            'Size: ${item.size}',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                          ),
                      ],
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(item.quantity.toString(), style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('₹${item.price.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('₹${item.total.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (item.stoneDetails != null) ...[
                        pw.Text(
                          'Stone: ${item.stoneTypeDisplay}',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                        pw.Text(
                          '${item.stoneDetails!.weight}ct • ${item.stoneDetails!.color} • ${item.stoneDetails!.clarity}',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                      if (item.hallmarks != null)
                        pw.Text(
                          'Hallmark: ${item.hallmarks}',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                    ],
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildChargesSection(Invoice invoice) {
    if (invoice.makingCharges == null && invoice.wastageCharges == null) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.orange300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'JEWELRY CHARGES',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Making Charges:', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Text(
                '₹${invoice.totalMakingCharges.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text('Wastage Charges:', style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Text(
                '₹${invoice.totalWastageCharges.toStringAsFixed(2)}',
                style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExchangeSection(Invoice invoice) {
    if (!invoice.isExchange || invoice.exchangeDetails == null) {
      return pw.SizedBox.shrink();
    }

    final exchange = invoice.exchangeDetails!;
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.purple50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.purple300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EXCHANGE DETAILS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.purple900,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Old Item: ${exchange.oldItemDescription}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Old Item Weight: ${exchange.oldItemWeight}g', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Old Item Value: ₹${exchange.oldItemValue.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Exchange Value: ₹${exchange.exchangeValue.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
          if (exchange.exchangeNotes.isNotEmpty)
            pw.Text('Notes: ${exchange.exchangeNotes}', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildPaymentSection(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.green300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PAYMENT DETAILS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 10),
          if (invoice.paymentMethod != null)
            pw.Text('Payment Method: ${invoice.paymentMethodDisplay}', style: const pw.TextStyle(fontSize: 10)),
          if (invoice.advanceAmount != null && invoice.advanceAmount! > 0)
            pw.Text('Advance Amount: ₹${invoice.advanceAmount!.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
          if (invoice.balanceAmount != null)
            pw.Text('Balance Amount: ₹${invoice.balanceAmount!.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
          if (invoice.isEMI && invoice.emiMonths != null)
            pw.Text('EMI Duration: ${invoice.emiMonths} months', style: const pw.TextStyle(fontSize: 10)),
          if (invoice.emiAmount != null)
            pw.Text('Monthly EMI: ₹${invoice.emiAmount!.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 10)),
          if (invoice.paymentDate != null)
            pw.Text('Payment Date: ${_formatDate(invoice.paymentDate!)}', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalSection(Invoice invoice) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.blue300),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 12)),
              pw.Text('₹${invoice.subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
            ],
          ),
          if (invoice.totalMakingCharges > 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Making Charges:', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('₹${invoice.totalMakingCharges.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
          if (invoice.totalWastageCharges > 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Wastage Charges:', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('₹${invoice.totalWastageCharges.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
          if (invoice.totalMakingCharges > 0 || invoice.totalWastageCharges > 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal with Charges:', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('₹${invoice.subtotalWithCharges.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
          if (invoice.taxPercentage > 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tax (${invoice.taxPercentage}%):', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('₹${invoice.taxAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
          if (invoice.discountAmount > 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Discount:', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('-₹${invoice.discountAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ],
          pw.Divider(color: PdfColors.blue300),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.Text('₹${invoice.total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
            ],
          ),
          if (invoice.exchangeValue != null && invoice.exchangeValue! > 0) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Exchange Value:', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('-₹${invoice.exchangeValue!.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.Divider(color: PdfColors.blue300),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Final Amount:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                pw.Text('₹${invoice.finalAmount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildAdditionalDetails(Invoice invoice) {
    if (invoice.warrantyDetails == null && invoice.returnPolicy == null && invoice.notes.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ADDITIONAL DETAILS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey900,
            ),
          ),
          pw.SizedBox(height: 10),
          if (invoice.warrantyDetails != null) ...[
            pw.Text('Warranty: ${invoice.warrantyDetails}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 5),
          ],
          if (invoice.returnPolicy != null) ...[
            pw.Text('Return Policy: ${invoice.returnPolicy}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 5),
          ],
          if (invoice.notes.isNotEmpty)
            pw.Text('Notes: ${invoice.notes}', style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(CompanySettings companySettings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            companySettings.companyName,
            style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            companySettings.address,
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
          pw.Text(
            'Phone: ${companySettings.phone} | Email: ${companySettings.email}',
            style: const pw.TextStyle(fontSize: 8),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static PdfColor _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return PdfColors.grey;
      case InvoiceStatus.sent:
        return PdfColors.blue;
      case InvoiceStatus.paid:
        return PdfColors.green;
      case InvoiceStatus.overdue:
        return PdfColors.red;
      case InvoiceStatus.exchanged:
        return PdfColors.orange;
      case InvoiceStatus.returned:
        return PdfColors.purple;
    }
  }
}