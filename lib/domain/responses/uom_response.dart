class UOMResponse {
  final List<UOM> uoms;
  final int count;

  UOMResponse({required this.uoms, required this.count});

  factory UOMResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested "message" structure
    final messageData = json['message'] ?? json;

    final uomsList = messageData['uoms'] as List? ?? [];

    return UOMResponse(
      uoms: uomsList.map((item) {
        return UOM(
          name: item['name']?.toString() ?? '',
          uomName:
              item['uom_name']?.toString() ?? item['name']?.toString() ?? '',
          mustBeWholeNumber: item['must_be_whole_number'] == 1,
        );
      }).toList(),
      count: messageData['count'] ?? uomsList.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': {
        'uoms': uoms
            .map((uom) => {'name': uom.name, 'uom_name': uom.uomName})
            .toList(),
        'count': count,
      },
    };
  }

  @override
  String toString() {
    return 'UOMResponse with $count UOMs: ${uoms.take(3).map((u) => u.name).join(', ')}${count > 3 ? '...' : ''}';
  }
}

// Inner class for UOM items
class UOM {
  final String name;
  final String uomName;
  final bool? mustBeWholeNumber;

  UOM({required this.name, required this.uomName, this.mustBeWholeNumber});

  @override
  String toString() =>
      'UOM(name: $name, uomName: $uomName, mustBeWholeNumber: $mustBeWholeNumber)';
}
