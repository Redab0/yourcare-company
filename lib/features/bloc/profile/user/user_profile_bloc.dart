import 'dart:async';

import 'package:cleaning_service_driver/core/di/dependency_injection.dart';
import 'package:cleaning_service_driver/core/utils/loading_controller.dart';
import 'package:cleaning_service_driver/domain/usecases/profile/user/get_user_profile_usecase.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_event.dart';
import 'package:cleaning_service_driver/features/bloc/profile/user/user_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final getUserUseCase = sl<GetUserProfileUseCase>();
  final _loader = sl<LoadingController>();

  UserProfileBloc() : super(ProfileInitial()) {
    on<GetUserEvent>(_onGetUser);
  }

  FutureOr<void> _onGetUser(
      GetUserEvent event, Emitter<UserProfileState> emit) async {
    try {
      await getUserUseCase.call();
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }
}
