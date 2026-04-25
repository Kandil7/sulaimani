import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double todaySales;
  final int todayInvoicesCount;
  final int totalProductsCount;
  final int alertsCount;
  final double totalDebt;
  final List<DailySales> last7DaysSales;
  final List<RecentSale> recentSales;
  final List<AlertItem> urgentAlerts;

  const DashboardLoaded({
    required this.todaySales,
    required this.todayInvoicesCount,
    required this.totalProductsCount,
    required this.alertsCount,
    required this.totalDebt,
    required this.last7DaysSales,
    required this.recentSales,
    required this.urgentAlerts,
  });

  @override
  List<Object?> get props => [
        todaySales,
        todayInvoicesCount,
        totalProductsCount,
        alertsCount,
        totalDebt,
        last7DaysSales,
        recentSales,
        urgentAlerts,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class DailySales extends Equatable {
  final DateTime date;
  final double amount;
  final int count;

  const DailySales({
    required this.date,
    required this.amount,
    required this.count,
  });

  @override
  List<Object?> get props => [date, amount, count];
}

class RecentSale extends Equatable {
  final int id;
  final String invoiceNumber;
  final String? customerName;
  final double amount;
  final String paymentType;
  final DateTime createdAt;

  const RecentSale({
    required this.id,
    required this.invoiceNumber,
    this.customerName,
    required this.amount,
    required this.paymentType,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, invoiceNumber, customerName, amount, paymentType, createdAt];
}

class AlertItem extends Equatable {
  final int productId;
  final String productName;
  final String type;
  final String message;

  const AlertItem({
    required this.productId,
    required this.productName,
    required this.type,
    required this.message,
  });

  @override
  List<Object?> get props => [productId, productName, type, message];
}
