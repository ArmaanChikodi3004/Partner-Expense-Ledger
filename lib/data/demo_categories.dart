import 'package:flutter/material.dart';

enum EntryType { income, expense }

class DemoCategory {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final EntryType type;

  DemoCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

final List<DemoCategory> demoCategories = [
  // -------- EXPENSE --------
  DemoCategory(
    id: 'food',
    name: 'Food',
    icon: '🍔',
    color: const Color(0xFFF97316),
    type: EntryType.expense,
  ),
  DemoCategory(
    id: 'travel',
    name: 'Travel',
    icon: '✈️',
    color: const Color(0xFF38BDF8),
    type: EntryType.expense,
  ),
  DemoCategory(
    id: 'shopping',
    name: 'Shopping',
    icon: '🛍️',
    color: const Color(0xFFEC4899),
    type: EntryType.expense,
  ),
  DemoCategory(
    id: 'other_expense',
    name: 'Others',
    icon: '📦',
    color: const Color(0xFF9CA3AF),
    type: EntryType.expense,
  ),

  // -------- INCOME --------
  DemoCategory(
    id: 'salary',
    name: 'Salary',
    icon: '💼',
    color: const Color(0xFF22C55E),
    type: EntryType.income,
  ),
  DemoCategory(
    id: 'freelance',
    name: 'Freelance',
    icon: '💻',
    color: const Color(0xFF6366F1),
    type: EntryType.income,
  ),
  DemoCategory(
    id: 'other_income',
    name: 'Others',
    icon: '📦',
    color: const Color(0xFF9CA3AF),
    type: EntryType.income,
  ),
];
