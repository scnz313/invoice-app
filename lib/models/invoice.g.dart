// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeDetails _$ExchangeDetailsFromJson(Map<String, dynamic> json) =>
    ExchangeDetails(
      oldItemWeight: (json['oldItemWeight'] as num).toDouble(),
      oldItemValue: (json['oldItemValue'] as num).toDouble(),
      oldItemDescription: json['oldItemDescription'] as String,
      exchangeValue: (json['exchangeValue'] as num).toDouble(),
      exchangeNotes: json['exchangeNotes'] as String,
    );

Map<String, dynamic> _$ExchangeDetailsToJson(ExchangeDetails instance) =>
    <String, dynamic>{
      'oldItemWeight': instance.oldItemWeight,
      'oldItemValue': instance.oldItemValue,
      'oldItemDescription': instance.oldItemDescription,
      'exchangeValue': instance.exchangeValue,
      'exchangeNotes': instance.exchangeNotes,
    };

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
  id: json['id'] as String,
  invoiceNumber: json['invoiceNumber'] as String,
  client: Client.fromJson(json['client'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>)
      .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdDate: DateTime.parse(json['createdDate'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  taxPercentage: (json['taxPercentage'] as num?)?.toDouble() ?? 0.0,
  discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
  status:
      $enumDecodeNullable(_$InvoiceStatusEnumMap, json['status']) ??
      InvoiceStatus.draft,
  notes: json['notes'] as String? ?? '',
  makingCharges: (json['makingCharges'] as num?)?.toDouble(),
  wastageCharges: (json['wastageCharges'] as num?)?.toDouble(),
  exchangeValue: (json['exchangeValue'] as num?)?.toDouble(),
  exchangeDetails: json['exchangeDetails'] == null
      ? null
      : ExchangeDetails.fromJson(json['exchangeDetails'] as Map<String, dynamic>),
  paymentMethod: $enumDecodeNullable(_$PaymentMethodEnumMap, json['paymentMethod']),
  paymentReference: json['paymentReference'] as String?,
  paymentDate: json['paymentDate'] == null
      ? null
      : DateTime.parse(json['paymentDate'] as String),
  advanceAmount: (json['advanceAmount'] as num?)?.toDouble(),
  balanceAmount: (json['balanceAmount'] as num?)?.toDouble(),
  salesPerson: json['salesPerson'] as String?,
  warrantyDetails: json['warrantyDetails'] as String?,
  returnPolicy: json['returnPolicy'] as String?,
  isExchange: json['isExchange'] as bool? ?? false,
  isEMI: json['isEMI'] as bool? ?? false,
  emiMonths: (json['emiMonths'] as num?)?.toInt(),
  emiAmount: (json['emiAmount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'invoiceNumber': instance.invoiceNumber,
  'client': instance.client,
  'items': instance.items,
  'createdDate': instance.createdDate.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'taxPercentage': instance.taxPercentage,
  'discountAmount': instance.discountAmount,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'notes': instance.notes,
  'makingCharges': instance.makingCharges,
  'wastageCharges': instance.wastageCharges,
  'exchangeValue': instance.exchangeValue,
  'exchangeDetails': instance.exchangeDetails?.toJson(),
  'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod],
  'paymentReference': instance.paymentReference,
  'paymentDate': instance.paymentDate?.toIso8601String(),
  'advanceAmount': instance.advanceAmount,
  'balanceAmount': instance.balanceAmount,
  'salesPerson': instance.salesPerson,
  'warrantyDetails': instance.warrantyDetails,
  'returnPolicy': instance.returnPolicy,
  'isExchange': instance.isExchange,
  'isEMI': instance.isEMI,
  'emiMonths': instance.emiMonths,
  'emiAmount': instance.emiAmount,
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.exchanged: 'exchanged',
  InvoiceStatus.returned: 'returned',
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.upi: 'upi',
  PaymentMethod.bankTransfer: 'bankTransfer',
  PaymentMethod.cheque: 'cheque',
  PaymentMethod.exchange: 'exchange',
  PaymentMethod.emi: 'emi',
  PaymentMethod.other: 'other',
};
