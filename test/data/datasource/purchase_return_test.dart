import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:pos/data/datasource/purchase_remote_datasource.dart';
import 'package:pos/domain/requests/purchase/create_purchase_return_request.dart';
import 'package:pos/domain/responses/purchase/create_purchase_return_response.dart';

class MockInterceptor extends Interceptor {
  Response? responseToReturn;
  DioException? errorToThrow;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (errorToThrow != null) {
      handler.reject(errorToThrow!);
    } else if (responseToReturn != null) {
      responseToReturn!.requestOptions = options;
      handler.resolve(responseToReturn!);
    } else {
      handler.next(options);
    }
  }
}

void main() {
  late PurchaseRemoteDataSource datasource;
  late Dio dio;
  late MockInterceptor mockInterceptor;

  setUp(() {
    dio = Dio();
    mockInterceptor = MockInterceptor();
    dio.interceptors.add(mockInterceptor);
    datasource = PurchaseRemoteDataSource(dio);
  });

  group('PurchaseRemoteDataSource.createPurchaseReturn', () {
    const poName = 'PUR-ORD-2026-00002';
    final request = CreatePurchaseReturnRequest(
      returnAgainst: poName,
      postingDate: '2026-03-28',
      company: 'Tets',
      items: [
        PurchaseReturnItemRequest(
          itemCode: 'ITEM001',
          qty: 10,
          rate: 100,
          warehouse: 'Stock',
        ),
      ],
    );

    test('should return CreatePurchaseReturnResponse on success', () async {
      final mockData = {
        'message': {
          'status': 'success',
          'message': 'Purchase Return created successfully',
        }
      };

      mockInterceptor.responseToReturn = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: mockData,
      );

      final result = await datasource.createPurchaseReturn(request: request);

      expect(result, isA<CreatePurchaseReturnResponse>());
      expect(result.status, 'success');
    });

    test('should throw Exception when status is failed', () async {
      final mockData = {
        'message': {
          'status': 'failed',
          'message': 'Error message',
        }
      };

      mockInterceptor.responseToReturn = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
        data: mockData,
      );

      expect(
        () => datasource.createPurchaseReturn(request: request),
        throwsA(isA<Exception>()),
      );
    });
  });
}
