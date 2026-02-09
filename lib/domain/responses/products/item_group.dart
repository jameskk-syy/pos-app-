// item_group.dart
class ItemGroupMessage { // Renamed from Message
  final List<ItemGroup> itemGroups;
  final int count;

  ItemGroupMessage({
    required this.itemGroups,
    required this.count,
  });

  factory ItemGroupMessage.fromJson(Map<String, dynamic> json) {
    return ItemGroupMessage(
      itemGroups: (json['item_groups'] as List)
          .map((item) => ItemGroup.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_groups': itemGroups.map((item) => item.toJson()).toList(),
      'count': count,
    };
  }
}

class ItemGroupResponse {
  final ItemGroupMessage message; // Use the renamed class

  ItemGroupResponse({
    required this.message,
  });

  factory ItemGroupResponse.fromJson(Map<String, dynamic> json) {
    return ItemGroupResponse(
      message: ItemGroupMessage.fromJson(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.toJson(),
    };
  }
}

class ItemGroup {
  final String name;
  final String itemGroupName;
  final String parentItemGroup;
  final int isGroup;

  ItemGroup({
    required this.name,
    required this.itemGroupName,
    required this.parentItemGroup,
    required this.isGroup,
  });

  factory ItemGroup.fromJson(Map<String, dynamic> json) {
    return ItemGroup(
      name: json['name'] as String,
      itemGroupName: json['item_group_name'] as String,
      parentItemGroup: json['parent_item_group'] as String,
      isGroup: json['is_group'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'item_group_name': itemGroupName,
      'parent_item_group': parentItemGroup,
      'is_group': isGroup,
    };
  }

  bool get isGroupBool => isGroup == 1;
}