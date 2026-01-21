import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/constrains/env/env.dart';
import 'package:movie_app/constrains/string/endpoint_tmdb.dart';
import 'package:movie_app/modules/account/account_detail/cubit/account_state.dart';

class AccountDetailCubit extends Cubit<AccountState> {
  final Dio _dio;

  AccountDetailCubit(this._dio) : super(AccountInitial());
  Future<void> getAccountDetail({
    required int accountId,
    String? seasionId,
  }) async {
    emit(AccountLoading());
    try {
      final response = await _dio.get(
        EndpointTmdb.getAccountDetails(accountId),
        queryParameters: {'session_id': seasionId},
        options: Options(
          headers: {'Authorization': 'Bearer ${Env.apiAccessToken}'},
        ),
      );
      emit(AccountLoaded(response.data));
    } on DioException catch (e) {
      String errorMessage = 'Đã xảy ra lỗi không xác định';
      if (e.response != null) {
        errorMessage =
            e.response?.data['status_message'] ??
            'Lỗi server: ${e.response?.statusCode}';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Hết thời gian kết nối';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Hết thời gian nhận dữ liệu';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Không có kết nối internet';
      }

      emit(AccountError(errorMessage));
    } catch (e) {
      emit(AccountError('Lỗi khác: ${e.toString()}'));
    }
  }
}
