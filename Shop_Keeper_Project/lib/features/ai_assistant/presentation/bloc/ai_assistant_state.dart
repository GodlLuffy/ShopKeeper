import 'package:equatable/equatable.dart';

abstract class AIAssistantState extends Equatable {
  const AIAssistantState();

  @override
  List<Object> get props => [];
}

class AIAssistantInitial extends AIAssistantState {}

class AIAssistantLoading extends AIAssistantState {}

class AIAssistantMessageReceived extends AIAssistantState {
  final List<Map<String, String>> messages;

  const AIAssistantMessageReceived(this.messages);

  @override
  List<Object> get props => [messages];
}

class AIAssistantError extends AIAssistantState {
  final String message;

  const AIAssistantError(this.message);

  @override
  List<Object> get props => [message];
}
