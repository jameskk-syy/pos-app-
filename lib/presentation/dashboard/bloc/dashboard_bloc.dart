import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/repository/dashboard_repo.dart';
import 'package:pos/domain/requests/sales/dashboard_request.dart';
import 'package:pos/domain/responses/sales/dashboard_response.dart';
import 'package:pos/domain/models/top_selling_item_model.dart';
import 'package:pos/domain/models/invoice_list_model.dart';
import 'package:pos/domain/responses/purchase/purchase_invoice_response.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepo dashboardRepo;
  DashboardResponse? _cachedData;
  DashboardRequest? _currentFilters;

  DashboardBloc({required this.dashboardRepo}) : super(DashboardInitial()) {
    on<FetchDashboardData>(_fetchDashboardData);
    on<RefreshDashboardData>(_refreshDashboardData);
    on<UpdateDashboardFilters>(_updateDashboardFilters);
    on<ClearDashboardFilters>(_clearDashboardFilters);
    on<LoadCachedDashboardData>(_loadCachedDashboardData);
    on<ClearCachedDashboardData>(_clearCachedDashboardData);
  }

  FutureOr<void> _fetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final req = event.request;
      String company = req.company ?? '';
      if (company.isEmpty) {
        final storage = getIt<StorageService>();
        final userString = await storage.getString('current_user');
        if (userString != null) {
          try {
            final userRes = CurrentUserResponse.fromJson(jsonDecode(userString));
            company = userRes.message.company.name;
          } catch (_) {}
        }
      }
      
      final results = await Future.wait([
        dashboardRepo.getDashboardStats(req),
        if (company.isNotEmpty) dashboardRepo.getTopSellingItems(
          company: company,
          warehouse: req.warehouse,
          period: req.period,
        ).then<TopSellingItemResponse?>((v) => v).catchError((_) => null) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getLatestOrders(
          company: company,
          orderBy: 'creation desc',
        ).then<InvoiceListResponse?>((v) => v).catchError((_) => null) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getRecentPurchases(
          company: company,
        ).then<PurchaseInvoiceResponse?>((v) => v).catchError((_) => null) else Future.value(null),
      ]);

      final response = results[0] as DashboardResponse;
      final topSellingItemsRes = results[1] as TopSellingItemResponse?;
      final latestOrdersRes = results[2] as InvoiceListResponse?;
      final recentPurchasesRes = results[3] as PurchaseInvoiceResponse?;

      _cachedData = response;
      _currentFilters = req;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: req,
          topSellingItems: topSellingItemsRes?.data ?? [],
          latestOrders: latestOrdersRes?.data,
          recentPurchases: recentPurchasesRes?.data,
        ),
      );
    } catch (e) {
      //debugPrint('Dashboard fetch error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: event.request,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _refreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    // Use current filters or create default request
    final request = _currentFilters ?? DashboardRequest();
    
    try {
      String company = request.company ?? '';
      if (company.isEmpty) {
        final storage = getIt<StorageService>();
        final userString = await storage.getString('current_user');
        if (userString != null) {
          try {
            final userRes = CurrentUserResponse.fromJson(jsonDecode(userString));
            company = userRes.message.company.name;
          } catch (_) {}
        }
      }
      
      final results = await Future.wait([
        dashboardRepo.getDashboardStats(request),
        if (company.isNotEmpty) dashboardRepo.getTopSellingItems(
          company: company,
          warehouse: request.warehouse,
          period: request.period,
        ).then<TopSellingItemResponse?>((v) => v).catchError((_) => null) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getLatestOrders(
          company: company,
          orderBy: 'creation desc',
        ).then<InvoiceListResponse?>((v) => v).catchError((_) => null) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getRecentPurchases(
          company: company,
        ).then<PurchaseInvoiceResponse?>((v) => v).catchError((_) => null) else Future.value(null),
      ]);

      final response = results[0] as DashboardResponse;
      final topSellingItemsRes = results[1] as TopSellingItemResponse?;
      final latestOrdersRes = results[2] as InvoiceListResponse?;
      final recentPurchasesRes = results[3] as PurchaseInvoiceResponse?;

      _cachedData = response;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: request,
          topSellingItems: topSellingItemsRes?.data ?? [],
          latestOrders: latestOrdersRes?.data,
          recentPurchases: recentPurchasesRes?.data,
        ),
      );
    } catch (e) {
      //debugPrint('Dashboard refresh error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: request,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _updateDashboardFilters(
    UpdateDashboardFilters event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final req = event.newFilters;
      String company = req.company ?? '';
      if (company.isEmpty) {
        final storage = getIt<StorageService>();
        final userString = await storage.getString('current_user');
        if (userString != null) {
          try {
            final userRes = CurrentUserResponse.fromJson(jsonDecode(userString));
            company = userRes.message.company.name;
          } catch (_) {}
        }
      }

      final results = await Future.wait([
        dashboardRepo.getDashboardStats(req),
        if (company.isNotEmpty) dashboardRepo.getTopSellingItems(
          company: company,
          warehouse: req.warehouse,
          period: req.period,
        ) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getLatestOrders(
          company: company,
          orderBy: 'creation desc',
        ) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getRecentPurchases(
          company: company,
        ) else Future.value(null),
      ]);

      final response = results[0] as DashboardResponse;
      final topSellingItemsRes = results[1] as TopSellingItemResponse?;
      final latestOrdersRes = results[2] as InvoiceListResponse?;
      final recentPurchasesRes = results[3] as PurchaseInvoiceResponse?;

      _cachedData = response;
      _currentFilters = req;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: req,
          topSellingItems: topSellingItemsRes?.data ?? [],
          latestOrders: latestOrdersRes?.data,
          recentPurchases: recentPurchasesRes?.data,
        ),
      );
    } catch (e) {
      //debugPrint('Dashboard filter update error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: event.newFilters,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _clearDashboardFilters(
    ClearDashboardFilters event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final defaultRequest = DashboardRequest();
    try {
      String company = defaultRequest.company ?? '';
      if (company.isEmpty) {
        final storage = getIt<StorageService>();
        final userString = await storage.getString('current_user');
        if (userString != null) {
          try {
            final userRes = CurrentUserResponse.fromJson(jsonDecode(userString));
            company = userRes.message.company.name;
          } catch (_) {}
        }
      }

      final results = await Future.wait([
        dashboardRepo.getDashboardStats(defaultRequest),
        if (company.isNotEmpty) dashboardRepo.getTopSellingItems(
          company: company,
          warehouse: defaultRequest.warehouse,
          period: defaultRequest.period,
        ).then<TopSellingItemResponse?>((v) => v).catchError((_) => null) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getLatestOrders(
          company: company,
          orderBy: 'creation desc',
        ).then<InvoiceListResponse?>((v) => v).catchError((_) => null) else Future.value(null),
        if (company.isNotEmpty) dashboardRepo.getRecentPurchases(
          company: company,
        ).then<PurchaseInvoiceResponse?>((v) => v).catchError((_) => null) else Future.value(null),
      ]);

      final response = results[0] as DashboardResponse;
      final topSellingItemsRes = results[1] as TopSellingItemResponse?;
      final latestOrdersRes = results[2] as InvoiceListResponse?;
      final recentPurchasesRes = results[3] as PurchaseInvoiceResponse?;

      _cachedData = response;
      _currentFilters = defaultRequest;
      emit(
        DashboardLoaded(
          dashboardData: response,
          currentFilters: defaultRequest,
          topSellingItems: topSellingItemsRes?.data ?? [],
          latestOrders: latestOrdersRes?.data,
          recentPurchases: recentPurchasesRes?.data,
        ),
      );
    } catch (e) {
      //debugPrint('Dashboard clear filters error: ${e.toString()}');
      emit(
        DashboardError(
          message: e.toString(),
          currentFilters: defaultRequest,
          cachedData: _cachedData,
        ),
      );
    }
  }

  FutureOr<void> _loadCachedDashboardData(
    LoadCachedDashboardData event,
    Emitter<DashboardState> emit,
  ) {
    if (_cachedData != null && _currentFilters != null) {
      emit(
        DashboardLoaded(
          dashboardData: _cachedData!,
          currentFilters: _currentFilters!,
          isFromCache: true,
        ),
      );
    } else {
      emit(DashboardInitial());
    }
  }

  FutureOr<void> _clearCachedDashboardData(
    ClearCachedDashboardData event,
    Emitter<DashboardState> emit,
  ) {
    _cachedData = null;
    _currentFilters = null;
    emit(DashboardCacheCleared());
  }
}