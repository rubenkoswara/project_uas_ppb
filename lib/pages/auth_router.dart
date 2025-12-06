import 'package:flutter/material.dart';
import 'admin_dashboard.dart';
import 'customer_pages/customer_dashboard.dart';

/// Navigate to appropriate dashboard based on user role
Widget getAuthDestination(String userRole) {
  if (userRole == 'admin') {
    return const AdminDashboard();
  } else {
    return CustomerDashboard();
  }
}
