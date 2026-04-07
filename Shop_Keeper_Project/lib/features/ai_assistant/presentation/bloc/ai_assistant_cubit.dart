import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/ai_assistant/presentation/bloc/ai_assistant_state.dart';
import 'package:shop_keeper_project/services/ai_assistant_service.dart';

class AIAssistantCubit extends Cubit<AIAssistantState> {
  final AIAssistantService assistantService;
  final List<Map<String, String>> _messages = [];

  AIAssistantCubit({required this.assistantService}) : super(AIAssistantInitial()) {
    _messages.add({
      'role': 'assistant',
      'content': 'Hello Shopkeeper! How can I help you with your shop today? Ask me about sales, profit, or low stock.'
    });
    emit(AIAssistantMessageReceived(List.from(_messages)));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add({'role': 'user', 'content': text});
    emit(AIAssistantMessageReceived(List.from(_messages)));
    
    emit(AIAssistantLoading());
    // Artificial delay for realism
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final response = await assistantService.processQuery(text);
      _messages.add({'role': 'assistant', 'content': response});
      emit(AIAssistantMessageReceived(List.from(_messages)));
    } catch (e) {
      emit(AIAssistantError("Failed to process request: $e"));
    }
  }

  void clearChat() {
    _messages.clear();
    _messages.add({
      'role': 'assistant',
      'content': 'Chat cleared. How can I help you now?'
    });
    emit(AIAssistantMessageReceived(List.from(_messages)));
  }
}
