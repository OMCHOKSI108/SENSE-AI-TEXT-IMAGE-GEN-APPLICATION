import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sense/feature/prompt/repos/prompt_repo.dart';

part 'prompt_event.dart';
part 'prompt_state.dart';

class PromptBloc extends Bloc<PromptEvent, PromptState> {
  PromptBloc() : super(PromptInitial()) {
    on<PromptInitialEvent>(promptInitialEvent);
    on<PromptEnteredEvent>(promptEnteredEvent);
  }

  FutureOr<void> promptEnteredEvent(
    PromptEnteredEvent event,
    Emitter<PromptState> emit,
  ) async {
    try {
      emit(PromptGeneratingImageLoadState());
      Uint8List? bytes = await TextToImageService.generateImage(event.prompt);
      if (bytes != null) {
        emit(PromptGeneratingImageSuccessState(bytes));
      } else {
        emit(PromptGeneratingImageErrorState());
      }
    } catch (e) {
      print('Error in promptEnteredEvent: $e');
      emit(PromptGeneratingImageErrorState());
    }
  }

  FutureOr<void> promptInitialEvent(
    PromptInitialEvent event,
    Emitter<PromptState> emit,
  ) async {
    // Start with initial state, no default image
    emit(PromptInitial());
  }
}
