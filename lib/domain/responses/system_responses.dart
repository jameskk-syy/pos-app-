class ModuleResponse {
  final bool success;
  final String message;
  final ModuleData data;

  ModuleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ModuleResponse.fromJson(Map<String, dynamic> json) {
    final messageObj = json['message'];
    return ModuleResponse(
      success: messageObj['success'] ?? false,
      message: messageObj['message'] ?? '',
      data: ModuleData.fromJson(messageObj['data']),
    );
  }
}

class ModuleData {
  final List<Module> modules;
  final int total;

  ModuleData({required this.modules, required this.total});

  factory ModuleData.fromJson(Map<String, dynamic> json) {
    return ModuleData(
      modules: (json['modules'] as List)
          .map((i) => Module.fromJson(i))
          .toList(),
      total: json['total'] ?? 0,
    );
  }
}

class Module {
  final String name;
  final String moduleName;
  final String appName;
  final int custom;
  final int doctypeCount;

  Module({
    required this.name,
    required this.moduleName,
    required this.appName,
    required this.custom,
    required this.doctypeCount,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      name: json['name'] ?? '',
      moduleName: json['module_name'] ?? '',
      appName: json['app_name'] ?? '',
      custom: json['custom'] ?? 0,
      doctypeCount: json['doctype_count'] ?? 0,
    );
  }
}

class DoctypeResponse {
  final bool success;
  final String message;
  final DoctypeData data;

  DoctypeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DoctypeResponse.fromJson(Map<String, dynamic> json) {
    final messageObj = json['message'];
    return DoctypeResponse(
      success: messageObj['success'] ?? false,
      message: messageObj['message'] ?? '',
      data: DoctypeData.fromJson(messageObj['data']),
    );
  }
}

class DoctypeData {
  final List<Doctype> doctypes;
  final Pagination? pagination;

  DoctypeData({required this.doctypes, this.pagination});

  factory DoctypeData.fromJson(Map<String, dynamic> json) {
    return DoctypeData(
      doctypes: (json['doctypes'] as List)
          .map((i) => Doctype.fromJson(i))
          .toList(),
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class Doctype {
  final String name;
  final String module;

  Doctype({required this.name, required this.module});

  factory Doctype.fromJson(Map<String, dynamic> json) {
    return Doctype(name: json['name'] ?? '', module: json['module'] ?? '');
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
