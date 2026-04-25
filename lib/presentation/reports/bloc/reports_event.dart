import 'package:equatable/equatable.dart';
import 'reports_state.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();
  @override
  List<Object?> get props => [];
}

class LoadReport extends ReportsEvent {
  final DateTime from;
  final DateTime to;
  final ReportFilter filter;

  const LoadReport({
    required this.from,
    required this.to,
    this.filter = ReportFilter.custom,
  });

  @override
  List<Object?> get props => [from, to, filter];
}

class ChangeFilter extends ReportsEvent {
  final ReportFilter filter;

  const ChangeFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ExportReport extends ReportsEvent {}

class RefreshReport extends ReportsEvent {}
