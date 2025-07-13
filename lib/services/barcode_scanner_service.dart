import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/grocery_product.dart';
import '../utils/logger.dart';

class BarcodeScannerService {
  static final BarcodeScannerService _instance = BarcodeScannerService._internal();
  factory BarcodeScannerService() => _instance;
  BarcodeScannerService._internal();

  MobileScannerController? _controller;
  bool _isInitialized = false;

  // Product database cache for quick lookup
  final Map<String, GroceryProduct> _productCache = {};

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      _isInitialized = true;
      Logger.info('Barcode scanner initialized', 'BarcodeScannerService');
    } catch (e) {
      Logger.error('Failed to initialize barcode scanner', 'BarcodeScannerService', e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      Logger.info('Barcode scanner disposed', 'BarcodeScannerService');
    } catch (e) {
      Logger.error('Error disposing barcode scanner', 'BarcodeScannerService', e);
    }
  }

  Future<void> startScanning() async {
    try {
      await _controller?.start();
      Logger.info('Barcode scanning started', 'BarcodeScannerService');
    } catch (e) {
      Logger.error('Failed to start barcode scanning', 'BarcodeScannerService', e);
      rethrow;
    }
  }

  Future<void> stopScanning() async {
    try {
      await _controller?.stop();
      Logger.info('Barcode scanning stopped', 'BarcodeScannerService');
    } catch (e) {
      Logger.error('Failed to stop barcode scanning', 'BarcodeScannerService', e);
    }
  }

  Future<void> toggleTorch() async {
    try {
      await _controller?.toggleTorch();
      Logger.info('Torch toggled', 'BarcodeScannerService');
    } catch (e) {
      Logger.error('Failed to toggle torch', 'BarcodeScannerService', e);
    }
  }

  Future<void> switchCamera() async {
    try {
      await _controller?.switchCamera();
      Logger.info('Camera switched', 'BarcodeScannerService');
    } catch (e) {
      Logger.error('Failed to switch camera', 'BarcodeScannerService', e);
    }
  }

  // Product lookup by barcode
  Future<GroceryProduct?> lookupProductByBarcode(String barcode) async {
    try {
      // Check cache first
      if (_productCache.containsKey(barcode)) {
        Logger.info('Product found in cache: $barcode', 'BarcodeScannerService');
        return _productCache[barcode];
      }

      // TODO: Implement actual database lookup
      // For now, return a mock product
      final product = _createMockProduct(barcode);
      if (product != null) {
        _productCache[barcode] = product;
        Logger.info('Product found in database: $barcode', 'BarcodeScannerService');
      } else {
        Logger.warning('Product not found: $barcode', 'BarcodeScannerService');
      }

      return product;
    } catch (e) {
      Logger.error('Error looking up product by barcode', 'BarcodeScannerService', e);
      return null;
    }
  }

  // Manual barcode entry validation
  bool isValidBarcode(String barcode) {
    if (barcode.isEmpty) return false;
    
    // Check for common barcode formats
    // EAN-13: 13 digits
    if (barcode.length == 13 && RegExp(r'^\d{13}$').hasMatch(barcode)) {
      return _validateEAN13(barcode);
    }
    
    // EAN-8: 8 digits
    if (barcode.length == 8 && RegExp(r'^\d{8}$').hasMatch(barcode)) {
      return _validateEAN8(barcode);
    }
    
    // UPC-A: 12 digits
    if (barcode.length == 12 && RegExp(r'^\d{12}$').hasMatch(barcode)) {
      return _validateUPCA(barcode);
    }
    
    // UPC-E: 8 digits
    if (barcode.length == 8 && RegExp(r'^\d{8}$').hasMatch(barcode)) {
      return _validateUPCE(barcode);
    }
    
    // Code 128: Variable length
    if (barcode.length >= 4 && barcode.length <= 20) {
      return true; // Accept any reasonable length for Code 128
    }
    
    return false;
  }

  // EAN-13 validation
  bool _validateEAN13(String barcode) {
    if (barcode.length != 13) return false;
    
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      int digit = int.parse(barcode[i]);
      sum += digit * (i % 2 == 0 ? 1 : 3);
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[12]);
  }

  // EAN-8 validation
  bool _validateEAN8(String barcode) {
    if (barcode.length != 8) return false;
    
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      int digit = int.parse(barcode[i]);
      sum += digit * (i % 2 == 0 ? 3 : 1);
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[7]);
  }

  // UPC-A validation
  bool _validateUPCA(String barcode) {
    if (barcode.length != 12) return false;
    
    int sum = 0;
    for (int i = 0; i < 11; i++) {
      int digit = int.parse(barcode[i]);
      sum += digit * (i % 2 == 0 ? 3 : 1);
    }
    
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[11]);
  }

  // UPC-E validation
  bool _validateUPCE(String barcode) {
    if (barcode.length != 8) return false;
    
    // Convert UPC-E to UPC-A for validation
    String upcA = _convertUPCEToUPCA(barcode);
    return _validateUPCA(upcA);
  }

  // Convert UPC-E to UPC-A
  String _convertUPCEToUPCA(String upcE) {
    String upcA = upcE[0] + upcE.substring(1, 7);
    
    // Add the appropriate number of zeros based on the last digit
    int lastDigit = int.parse(upcE[7]);
    switch (lastDigit) {
      case 0:
        upcA = upcA.substring(0, 3) + '00000' + upcA.substring(3);
        break;
      case 1:
        upcA = upcA.substring(0, 3) + '10000' + upcA.substring(3);
        break;
      case 2:
        upcA = upcA.substring(0, 3) + '20000' + upcA.substring(3);
        break;
      case 3:
        upcA = upcA.substring(0, 4) + '00000' + upcA.substring(4);
        break;
      case 4:
        upcA = upcA.substring(0, 5) + '00000' + upcA.substring(5);
        break;
      case 5:
        upcA = upcA.substring(0, 1) + '00000' + upcA.substring(1);
        break;
      case 6:
        upcA = upcA.substring(0, 1) + '00000' + upcA.substring(1);
        break;
      case 7:
        upcA = upcA.substring(0, 1) + '00000' + upcA.substring(1);
        break;
      case 8:
        upcA = upcA.substring(0, 1) + '00000' + upcA.substring(1);
        break;
      case 9:
        upcA = upcA.substring(0, 1) + '00000' + upcA.substring(1);
        break;
    }
    
    return upcA;
  }

  // Mock product creation for testing
  GroceryProduct? _createMockProduct(String barcode) {
    // Create mock products based on barcode patterns
    if (barcode.startsWith('890')) {
      // Indian products
      return GroceryProduct(
        id: 'mock_${barcode}',
        name: 'Amul Milk',
        barcode: barcode,
        category: GroceryCategory.dairyEggs,
        subcategory: 'Milk',
        brand: 'Amul',
        description: 'Fresh full cream milk',
        unitPrice: 60.0,
        costPrice: 45.0,
        unitType: UnitType.liters,
        currentStock: 50.0,
        reorderPoint: 10.0,
        maxStock: 100.0,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        batchNumber: 'BATCH001',
        supplierName: 'Amul Dairy',
        supplierContact: '+91-1234567890',
        isPerishable: true,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (barcode.startsWith('400')) {
      // German products
      return GroceryProduct(
        id: 'mock_${barcode}',
        name: 'Nestle Maggi',
        barcode: barcode,
        category: GroceryCategory.pantryStaples,
        subcategory: 'Instant Noodles',
        brand: 'Nestle',
        description: '2-minute instant noodles',
        unitPrice: 14.0,
        costPrice: 10.0,
        unitType: UnitType.packs,
        currentStock: 200.0,
        reorderPoint: 50.0,
        maxStock: 500.0,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
        batchNumber: 'BATCH002',
        supplierName: 'Nestle India',
        supplierContact: '+91-9876543210',
        isPerishable: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else if (barcode.startsWith('500')) {
      // UK products
      return GroceryProduct(
        id: 'mock_${barcode}',
        name: 'Cadbury Dairy Milk',
        barcode: barcode,
        category: GroceryCategory.snacksConfectionery,
        subcategory: 'Chocolate',
        brand: 'Cadbury',
        description: 'Milk chocolate bar',
        unitPrice: 55.0,
        costPrice: 40.0,
        unitType: UnitType.pieces,
        currentStock: 100.0,
        reorderPoint: 20.0,
        maxStock: 200.0,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        batchNumber: 'BATCH003',
        supplierName: 'Mondelez India',
        supplierContact: '+91-1122334455',
        isPerishable: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    return null;
  }

  // Batch scanning for multiple items
  Future<List<GroceryProduct>> batchScanProducts(List<String> barcodes) async {
    final products = <GroceryProduct>[];
    
    for (final barcode in barcodes) {
      final product = await lookupProductByBarcode(barcode);
      if (product != null) {
        products.add(product);
      }
    }
    
    return products;
  }

  // Price verification
  Future<bool> verifyPrice(String barcode, double expectedPrice) async {
    final product = await lookupProductByBarcode(barcode);
    if (product == null) return false;
    
    // Allow for small price variations (within 5%)
    final tolerance = expectedPrice * 0.05;
    return (product.unitPrice - expectedPrice).abs() <= tolerance;
  }

  // Stock level checking
  Future<bool> checkStockAvailability(String barcode, double quantity) async {
    final product = await lookupProductByBarcode(barcode);
    if (product == null) return false;
    
    return product.currentStock >= quantity;
  }

  // Clear product cache
  void clearCache() {
    _productCache.clear();
    Logger.info('Product cache cleared', 'BarcodeScannerService');
  }

  // Get cached products count
  int get cachedProductsCount => _productCache.length;

  // Get scanner controller
  MobileScannerController? get controller => _controller;

  // Check if scanner is initialized
  bool get isInitialized => _isInitialized;
}

// Barcode scanning result
class BarcodeScanResult {
  final String barcode;
  final String format;
  final GroceryProduct? product;
  final bool isValid;
  final String? errorMessage;

  const BarcodeScanResult({
    required this.barcode,
    required this.format,
    this.product,
    required this.isValid,
    this.errorMessage,
  });

  factory BarcodeScanResult.success({
    required String barcode,
    required String format,
    GroceryProduct? product,
  }) {
    return BarcodeScanResult(
      barcode: barcode,
      format: format,
      product: product,
      isValid: true,
    );
  }

  factory BarcodeScanResult.error({
    required String barcode,
    required String format,
    required String errorMessage,
  }) {
    return BarcodeScanResult(
      barcode: barcode,
      format: format,
      isValid: false,
      errorMessage: errorMessage,
    );
  }
}

// Barcode scanning widget
class BarcodeScannerWidget extends StatefulWidget {
  final Function(BarcodeScanResult) onBarcodeDetected;
  final bool showTorchButton;
  final bool showCameraSwitchButton;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    this.showTorchButton = true,
    this.showCameraSwitchButton = true,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final BarcodeScannerService _scannerService = BarcodeScannerService();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      await _scannerService.initialize();
      await _scannerService.startScanning();
      setState(() {
        _isScanning = true;
      });
    } catch (e) {
      Logger.error('Failed to initialize scanner widget', 'BarcodeScannerWidget', e);
    }
  }

  @override
  void dispose() {
    _scannerService.stopScanning();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_scannerService.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerService.controller,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                _handleBarcodeDetected(barcode.rawValue!, barcode.format.name);
              }
            }
          },
        ),
        Positioned(
          top: 50,
          left: 20,
          child: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.black54,
            child: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        if (widget.showTorchButton)
          Positioned(
            top: 50,
            right: 20,
            child: FloatingActionButton(
              onPressed: _scannerService.toggleTorch,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.flash_on, color: Colors.white),
            ),
          ),
        if (widget.showCameraSwitchButton)
          Positioned(
            top: 120,
            right: 20,
            child: FloatingActionButton(
              onPressed: _scannerService.switchCamera,
              backgroundColor: Colors.black54,
              child: const Icon(Icons.flip_camera_ios, color: Colors.white),
            ),
          ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Point camera at barcode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleBarcodeDetected(String barcode, String format) async {
    try {
      // Validate barcode
      if (!_scannerService.isValidBarcode(barcode)) {
        final result = BarcodeScanResult.error(
          barcode: barcode,
          format: format,
          errorMessage: 'Invalid barcode format',
        );
        widget.onBarcodeDetected(result);
        return;
      }

      // Lookup product
      final product = await _scannerService.lookupProductByBarcode(barcode);
      
      final result = BarcodeScanResult.success(
        barcode: barcode,
        format: format,
        product: product,
      );
      
      widget.onBarcodeDetected(result);
    } catch (e) {
      Logger.error('Error handling barcode detection', 'BarcodeScannerWidget', e);
      final result = BarcodeScanResult.error(
        barcode: barcode,
        format: format,
        errorMessage: 'Error processing barcode: $e',
      );
      widget.onBarcodeDetected(result);
    }
  }
}