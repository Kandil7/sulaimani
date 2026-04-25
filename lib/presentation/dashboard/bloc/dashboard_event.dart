import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class RefreshDashboard extends DashboardEvent {}

class ChangeDateRange extends DashboardEvent {
  final DateTime from;
  final DateTime to;

  const ChangeDateRange({required this.from, required this.to});

  @override
  List<Object?> get props => [from, to];
}
