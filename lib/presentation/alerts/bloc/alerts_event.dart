import 'package:equatable/equatable.dart';

abstract class AlertsEvent extends Equatable {
  const AlertsEvent();
  @override
  List<Object?> get props => [];
}

class LoadAlerts extends AlertsEvent {}

class DismissAlert extends AlertsEvent {
  final int productId;
  final String alertType; // 'Expired', 'Expiring Soon', 'Low Stock'

  const DismissAlert({required this.productId, required this.alertType});

  @override
  List<Object?> get props => [productId, alertType];
}
