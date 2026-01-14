class GetLoyaltyProgramsRequest {
  final bool? activeOnly;

  GetLoyaltyProgramsRequest({this.activeOnly});

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (activeOnly != null) {
      params['active_only'] = activeOnly.toString();
    }
    return params;
  }
}