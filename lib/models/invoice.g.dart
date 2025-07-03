// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.draft: 'draft',
  InvoiceStatus.sent: 'sent',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
};
