import 'package:flutter/material.dart';

enum EntryType { income, expense }

class DemoCategory {
  final String id;
  final String name;
  final String icon;
  final EntryType type;
  final Color color;
  

  DemoCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.color,
  });
}

final List<DemoCategory> demoCategories = [
  // -------- INCOME --------
  DemoCategory(
    id: 'salary',
    name: 'Salary',
    icon: '💰',
    type: EntryType.income,
    color: Color(0xFF6366F1),
  ),
  DemoCategory(
    id: 'freelance',
    name: 'Freelance',
    icon: '💻',
    type: EntryType.income,
    color: Color(0xFF818CF8),
  ),

  // -------- EXPENSE --------
  DemoCategory(
    id: 'food',
    name: 'Food',
    icon: '🍔',
    type: EntryType.expense,
    color: Color(0xFFEC4899),
  ),
  DemoCategory(
    id: 'travel',
    name: 'Travel',
    icon: '✈️',
    type: EntryType.expense,
    color: Color(0xFFF472B6),
  ),
  DemoCategory(
    id: 'shopping',
    name: 'Shopping',
    icon: '🛍️',
    type: EntryType.expense,
    color: Color(0xFFFB7185),
  ),
];
