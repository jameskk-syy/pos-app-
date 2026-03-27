import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pos/data/datasource/biller_remote_datasource.dart';
import 'package:pos/domain/requests/biller/biller_requests.dart';
import 'package:pos/domain/responses/biller/biller_responses.dart';

class MockInterceptor extends Interceptor {
  Response? responseToReturn;
  DioException? errorToThrow;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (errorToThrow != null) {
      handler.reject(errorToThrow!);
    } else if (responseToReturn != null) {
      // Ensure the response has the requested options
      responseToReturn!.requestOptions = options;
      handler.resolve(responseToReturn!);
    } else {
      handler.next(options);
    }
  }
}

void main() {
  late BillerRemoteDatasource datasource;
  late Dio dio;
  late MockInterceptor mockInterceptor;

  setUp(() {
    dio = Dio();
    mockInterceptor = MockInterceptor();
    dio.interceptors.add(mockInterceptor);
    datasource = BillerRemoteDatasource(dio);
  });

  group('BillerRemoteDatasource.createBiller', () {
    final request = CreateBillerRequest(
      billerName: 'New Biller',
      industry: 'Retail',
      company: 'Test Company',
      isDefault: false,
    );

    test('should return CreateBillerResponse on success', () async {
      final mockData = {
        'message': {
          'success': true,
          'message': 'Biller created successfully',
          'data': {
            'biller_name': 'New Biller',
            'industry': 'Retail',
            'company': 'Test Company',
            'is_default': false,
            'warehouses': [],
            'pos_profiles': [],
          }
        }
      };

      mockInterceptor.responseToReturn = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: mockData,
      );

      final result = await datasource.createBiller(request);

      expect(result, isA<CreateBillerResponse>());
      // You can also assert individual fields based on parsing
      // Note: Make sure CreateBillerResponse.fromJson handles this structure
    });

    test('should throw Exception on non-200/201 status code', () async {
      mockInterceptor.responseToReturn = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 400,
        data: {},
      );

      expect(
        () => datasource.createBiller(request),
        throwsA(isA<Exception>()),
      );
    });

    test('should throw Exception on DioException', () async {
      mockInterceptor.errorToThrow = DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Network Error',
      );

      expect(
        () => datasource.createBiller(request),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('BillerRemoteDatasource.listBillers', () {
    final request = ListBillersRequest(searchTerm: 'Test', limit: 10, offset: 0);

    test('should return ListBillersResponse on success', () async {
      final mockData = {
        'message': {
          'success': true,
          'data': {
            'billers': [
              {
                'name': 'Test Biller',
                'industry': 'Retail',
                'company': 'Test Company',
              }
            ],
            'total_count': 1,
          }
        }
      };

      mockInterceptor.responseToReturn = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: mockData,
      );

      final result = await datasource.listBillers(request);

      expect(result, isA<ListBillersResponse>());
      expect(result.billers.length, 1);
      expect(result.billers.first.name, 'Test Biller');
    });

    test('should throw Exception on invalid response format', () async {
      mockInterceptor.responseToReturn = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: 'Invalid string response instead of map',
      );

      expect(
        () => datasource.listBillers(request),
        throwsA(isA<Exception>()),
      );
    });
  });
}
