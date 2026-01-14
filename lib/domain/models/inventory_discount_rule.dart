import 'package:flutter/material.dart';
import 'package:pos/domain/responses/get_inventory_discount_rules_response.dart' as api;

class InventoryDiscountRule {
  final String name;
  final String ruleType;
  final String itemCode;
  final String? batchNo;
  final String? itemGroup;
  final String warehouse;
  final String company;
  final String discountType;
  final double discountValue;
  final int priority;
  final int isActive;
  final String? validFrom;
  final String? validUpto;
  final String? description;

  InventoryDiscountRule({
    required this.name,
    required this.ruleType,
    required this.itemCode,
    required this.batchNo,
    required this.itemGroup,
    required this.warehouse,
    required this.company,
    required this.discountType,
    required this.discountValue,
    required this.priority,
    required this.isActive,
    required this.validFrom,
    required this.validUpto,
    required this.description,
  });

  String get status => isActive == 1 ? 'Active' : 'Inactive';
  Color get statusColor => isActive == 1 ? Colors.green : Colors.red;

  factory InventoryDiscountRule.fromApiModel(
    api.InventoryDiscountRule apiModel,
  ) {
    return InventoryDiscountRule(
      name: apiModel.name,
      ruleType: apiModel.ruleType,
      itemCode: apiModel.itemCode,
      batchNo: apiModel.batchNo,
      itemGroup: apiModel.itemGroup,
      warehouse: apiModel.warehouse,
      company: apiModel.company,
      discountType: apiModel.discountType,
      discountValue: apiModel.discountValue,
      priority: apiModel.priority,
      isActive: apiModel.isActive,
      validFrom: apiModel.validFrom,
      validUpto: apiModel.validUpto,
      description: apiModel.description,
    );
  }
}