import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:pos/domain/models/audit_log.dart';
import 'package:pos/domain/repository/audit_repository.dart';

part 'audit_event.dart';
part 'audit_state.dart';

class AuditBloc extends Bloc<AuditEvent, AuditState> {
  final AuditRepository auditRepository;
  int _currentPage = 1;
  static const int _pageSize = 20;

  AuditBloc({required this.auditRepository}) : super(AuditInitial()) {
    on<FetchAuditLogs>(_onFetchAuditLogs);
    on<LoadMoreAuditLogs>(_onLoadMoreAuditLogs);
    on<FetchAuditStatistics>(_onFetchAuditStatistics);
  }

  Future<void> _onFetchAuditLogs(
    FetchAuditLogs event,
    Emitter<AuditState> emit,
  ) async {
    if (event.isRefresh) {
      _currentPage = 1;
    }
    emit(AuditLoading(isFirstFetch: _currentPage == 1));

    try {
      final response = await auditRepository.getAuditLogs(
        company: event.company,
        page: _currentPage,
        pageSize: _pageSize,
        activityType: event.activityType,
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
        search: event.search,
      );

      final List<AuditLog> currentLogs = event.isRefresh
          ? []
          : (state is AuditLoaded ? (state as AuditLoaded).logs : []);

      final AuditStatistics? currentStats = state is AuditLoaded
          ? (state as AuditLoaded).statistics
          : null;

      final updatedLogs = List<AuditLog>.from(currentLogs)
        ..addAll(response.data);

      emit(
        AuditLoaded(
          logs: updatedLogs,
          hasNext: response.pagination.hasNext,
          currentPage: _currentPage,
          company: event.company,
          activityType: event.activityType,
          status: event.status,
          startDate: event.startDate,
          endDate: event.endDate,
          search: event.search,
          statistics: currentStats,
        ),
      );
    } catch (e) {
      emit(AuditFailure(error: e.toString()));
    }
  }

  Future<void> _onLoadMoreAuditLogs(
    LoadMoreAuditLogs event,
    Emitter<AuditState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuditLoaded && currentState.hasNext) {
      _currentPage++;
      try {
        final response = await auditRepository.getAuditLogs(
          company: currentState.company,
          page: _currentPage,
          pageSize: _pageSize,
          activityType: currentState.activityType,
          status: currentState.status,
          startDate: currentState.startDate,
          endDate: currentState.endDate,
          search: currentState.search,
        );

        final updatedLogs = List<AuditLog>.from(currentState.logs)
          ..addAll(response.data);

        emit(
          AuditLoaded(
            logs: updatedLogs,
            hasNext: response.pagination.hasNext,
            currentPage: _currentPage,
            company: currentState.company,
            activityType: currentState.activityType,
            status: currentState.status,
            startDate: currentState.startDate,
            endDate: currentState.endDate,
            search: currentState.search,
            statistics: currentState.statistics,
          ),
        );
      } catch (e) {
        emit(AuditFailure(error: e.toString()));
      }
    }
  }

  Future<void> _onFetchAuditStatistics(
    FetchAuditStatistics event,
    Emitter<AuditState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuditLoaded) {
      emit(AuditLoading());
    }

    try {
      final response = await auditRepository.getAuditStatistics(
        company: event.company,
      );

      if (state is AuditLoaded) {
        final s = state as AuditLoaded;
        emit(
          AuditLoaded(
            logs: s.logs,
            hasNext: s.hasNext,
            currentPage: s.currentPage,
            company: s.company,
            activityType: s.activityType,
            status: s.status,
            startDate: s.startDate,
            endDate: s.endDate,
            search: s.search,
            statistics: response.data,
          ),
        );
      } else {
        emit(
          AuditLoaded(
            logs: [],
            hasNext: false,
            currentPage: 1,
            statistics: response.data,
          ),
        );
      }
    } catch (e) {
      emit(AuditFailure(error: e.toString()));
    }
  }
}
