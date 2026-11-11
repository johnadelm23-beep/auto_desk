class DashboardStatistics {
  final int totalCars;
  final int receivedToday;
  final int inProgress;
  final int ready;
  final int delivered;
  final int overdue;
  final int upcomingDeliveries;

  const DashboardStatistics({
    this.totalCars = 0,
    this.receivedToday = 0,
    this.inProgress = 0,
    this.ready = 0,
    this.delivered = 0,
    this.overdue = 0,
    this.upcomingDeliveries = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardStatistics &&
          runtimeType == other.runtimeType &&
          totalCars == other.totalCars &&
          receivedToday == other.receivedToday &&
          inProgress == other.inProgress &&
          ready == other.ready &&
          delivered == other.delivered &&
          overdue == other.overdue &&
          upcomingDeliveries == other.upcomingDeliveries;

  @override
  int get hashCode => Object.hash(
        totalCars,
        receivedToday,
        inProgress,
        ready,
        delivered,
        overdue,
        upcomingDeliveries,
      );

  @override
  String toString() {
    return 'DashboardStatistics(total: $totalCars, today: $receivedToday, inProgress: $inProgress, ready: $ready, delivered: $delivered, overdue: $overdue, upcoming: $upcomingDeliveries)';
  }
}

