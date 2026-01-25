import 'package:flutter/material.dart';

enum EntryType { income, expense }

class DemoEntry {
  final String id;
  final EntryType type;
  final double amount;
  final String category;
  final String categoryIcon;
  final Color color;
  final DateTime date;
  final String addedBy;

  DemoEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.categoryIcon,
    required this.color,
    required this.date,
    required this.addedBy,
  });
}

final List<DemoEntry> demoEntries = [
  // ---------- JAN ----------
  DemoEntry(
    id: '1',
    type: EntryType.income,
    amount: 18000,
    category: 'Salary',
    categoryIcon: '💰',
    color: Colors.greenAccent,
    date: DateTime.now().subtract(const Duration(days: 1)),
    addedBy: 'Company',
  ),
  DemoEntry(
    id: '2',
    type: EntryType.expense,
    amount: 5000,
    category: 'Rent',
    categoryIcon: '🏠',
    color: Colors.purpleAccent,
    date: DateTime.now().subtract(const Duration(days: 2)),
    addedBy: 'Waize',
  ),
  DemoEntry(
    id: '3',
    type: EntryType.expense,
    amount: 250,
    category: 'Food',
    categoryIcon: '🍔',
    color: Colors.redAccent,
    date: DateTime.now(),
    addedBy: 'Armaan',
  ),

  // ---------- DEC ----------
  DemoEntry(
    id: '4',
    type: EntryType.income,
    amount: 25000,
    category: 'Freelance',
    categoryIcon: '💻',
    color: Colors.blueAccent,
    date: DateTime.now().subtract(const Duration(days: 35)),
    addedBy: 'Armaan',
  ),
  DemoEntry(
    id: '5',
    type: EntryType.expense,
    amount: 12000,
    category: 'Travel',
    categoryIcon: '✈️',
    color: Colors.lightBlue,
    date: DateTime.now().subtract(const Duration(days: 40)),
    addedBy: 'Sam',
  ),

  // ---------- NOV ----------
  DemoEntry(
    id: '6',
    type: EntryType.expense,
    amount: 7000,
    category: 'Food',
    categoryIcon: '🍔',
    color: Colors.redAccent,
    date: DateTime.now().subtract(const Duration(days: 65)),
    addedBy: 'Waize',
  ),
];
