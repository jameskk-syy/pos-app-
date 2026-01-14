import 'dart:convert';

class InvoiceRequest {
  final String customer;
  final String company;
  final String warehouse;
  final bool updateStock;
  final List<InvoiceItem> items;
  final String postingDate;
  final String posProfile;
  final List<InvoicePayment> payments;
  final bool doNotSubmit;
  final int isPos;
  final String invoiceType;

  InvoiceRequest({
    required this.customer,
    required this.company,
    required this.warehouse,
    required this.updateStock,
    required this.items,
    required this.postingDate,
    required this.posProfile,
    required this.payments,
    required this.doNotSubmit,
    required this.isPos,
    required this.invoiceType,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer': customer,
      'company': company,
      'warehouse': warehouse,
      'update_stock': updateStock,
      'items': items.map((item) => item.toJson()).toList(),
      'posting_date': postingDate,
      'pos_profile': posProfile,
      'payments': payments.map((payment) => payment.toJson()).toList(),
      'do_not_submit': doNotSubmit,
      'is_pos': isPos,
      'invoice_type': invoiceType,
    };
  }

  factory InvoiceRequest.fromJson(Map<String, dynamic> json) {
    return InvoiceRequest(
      customer: json['customer'],
      company: json['company'],
      warehouse: json['warehouse'],
      updateStock: json['update_stock'],
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      postingDate: json['posting_date'],
      posProfile: json['pos_profile'],
      payments: (json['payments'] as List)
          .map((payment) => InvoicePayment.fromJson(payment))
          .toList(),
      doNotSubmit: json['do_not_submit'],
      isPos: json['is_pos'],
      invoiceType: json['invoice_type'],
    );
  }
}

class InvoiceItem {
  final String itemCode;
  final int qty;
  final double rate;
  final String uom;
  final String warehouse;

  InvoiceItem({
    required this.itemCode,
    required this.qty,
    required this.rate,
    required this.uom,
    required this.warehouse,
  });

  Map<String, dynamic> toJson() {
    return {
      'item_code': itemCode,
      'qty': qty,
      'rate': rate,
      'uom': uom,
      'warehouse': warehouse,
    };
  }

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemCode: json['item_code'],
      qty: json['qty'],
      rate: (json['rate'] as num).toDouble(),
      uom: json['uom'],
      warehouse: json['warehouse'],
    );
  }
}

class InvoicePayment {
  final String modeOfPayment;
  final double amount;
  final double baseAmount;

  InvoicePayment({
    required this.modeOfPayment,
    required this.amount,
    required this.baseAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode_of_payment': modeOfPayment,
      'amount': amount,
      'base_amount': baseAmount,
    };
  }

  factory InvoicePayment.fromJson(Map<String, dynamic> json) {
    return InvoicePayment(
      modeOfPayment: json['mode_of_payment'],
      amount: (json['amount'] as num).toDouble(),
      baseAmount: (json['base_amount'] as num).toDouble(),
    );
  }
}

class InvoiceResponse {
  final String name;
  final String customer;
  final String company;
  final String postingDate;
  final double grandTotal;
  final double roundedTotal;
  final double outstandingAmount;
  final int docstatus;

  InvoiceResponse({
    required this.name,
    required this.customer,
    required this.company,
    required this.postingDate,
    required this.grandTotal,
    required this.roundedTotal,
    required this.outstandingAmount,
    required this.docstatus,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    return InvoiceResponse(
      name: json['name'] ?? '',
      customer: json['customer'] ?? '',
      company: json['company'] ?? '',
      postingDate: json['posting_date'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      roundedTotal: (json['rounded_total'] as num?)?.toDouble() ?? 0.0,
      outstandingAmount:
          (json['outstanding_amount'] as num?)?.toDouble() ?? 0.0,
      docstatus: (json['docstatus'] as num?)?.toInt() ?? 0,
    );
  }
}

class CreateInvoiceResponse {
  final bool success;
  final String message;
  final InvoiceResponse? data;
  final List<String>? serverMessages;

  CreateInvoiceResponse({
    required this.success,
    required this.message,
    this.data,
    this.serverMessages,
  });

  factory CreateInvoiceResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>? ?? {};
    final serverMessages = json['_server_messages'] as String?;

    List<String> parsedServerMessages = [];
    if (serverMessages != null) {
      try {
        final decoded = jsonDecode(serverMessages) as List;
        parsedServerMessages = decoded.map((msg) {
          if (msg is String) {
            try {
              final msgJson = jsonDecode(msg) as Map<String, dynamic>;
              return msgJson['message']?.toString() ?? msg;
            } catch (_) {
              return msg;
            }
          }
          return msg.toString();
        }).toList();
      } catch (e) {
        parsedServerMessages = [serverMessages];
      }
    }

    return CreateInvoiceResponse(
      success: messageData['success'] as bool? ?? false,
      message: messageData['message'] as String? ?? '',
      data: messageData['data'] != null
          ? InvoiceResponse.fromJson(
              messageData['data'] as Map<String, dynamic>,
            )
          : null,
      serverMessages: parsedServerMessages.isNotEmpty
          ? parsedServerMessages
          : null,
    );
  }
}
