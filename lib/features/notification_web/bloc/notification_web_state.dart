import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationReceivedState extends NotificationState {
  final RemoteMessage message;
  const NotificationReceivedState(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationError extends NotificationState {
  final String error;
  const NotificationError(this.error);
  @override
  List<Object?> get props => [error];
}