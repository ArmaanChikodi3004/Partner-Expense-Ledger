import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/demo_categories.dart';
import '../../constants/active_partner.dart';
import '../../services/expense_service.dart';

class AddEntrySheet extends StatefulWidget {
  const AddEntrySheet({super.key});

  @override
  State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
  EntryType selectedType = EntryType.expense;
  String? selectedCategory;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now(); // ✅ NEW

  bool isSaving = false;

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Color get _submitColor =>
      selectedType == EntryType.expense
          ? const Color(0xFFEF4444)
          : const Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final categories =
        demoCategories.where((c) => c.type == selectedType).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dragHandle(),
              const SizedBox(height: 20),
              _header(context),
              const SizedBox(height: 24),

              _typeToggle(),
              const SizedBox(height: 24),

              _datePickerChip(), // ✅ NEW DATE PICKER
              const SizedBox(height: 24),

              _sectionLabel('Amount'),
              _amountField(),
              const SizedBox(height: 24),

              _sectionLabel('Category'),
              const SizedBox(height: 12),
              _categoryGrid(categories),
              const SizedBox(height: 24),

              _sectionLabel('Description (optional)'),
              _descriptionField(),
              const SizedBox(height: 32),

              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────── DATE PICKER CHIP ─────────

  Widget _datePickerChip() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // ───────── TYPE TOGGLE ─────────

  Widget _typeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _typeButton('Expense', EntryType.expense, const Color(0xFFEF4444)),
          _typeButton('Income', EntryType.income, const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _typeButton(String label, EntryType type, Color color) {
    final active = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = type;
            selectedCategory = null;
          });
        },
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.25) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? color : Colors.transparent),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? color : Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ───────── AMOUNT ─────────

  Widget _amountField() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Text(
            '₹',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────── CATEGORY GRID ─────────

  Widget _categoryGrid(List<DemoCategory> categories) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: categories.map((cat) {
        final selected = selectedCategory == cat.id;
        return GestureDetector(
          onTap: () => setState(() => selectedCategory = cat.id),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? _submitColor.withOpacity(0.25)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? _submitColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(cat.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 6),
                Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? _submitColor : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _descriptionField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: descriptionController,
        maxLines: 2,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Add a note...',
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _submitButton() {
    final enabled =
        selectedCategory != null &&
        amountController.text.isNotEmpty &&
        !isSaving;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? _handleSubmit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _submitColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.white.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          isSaving
              ? 'Saving...'
              : selectedType == EntryType.income
                  ? 'Add Income'
                  : 'Add Expense',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

 Future<void> _handleSubmit() async {
  try {
    setState(() => isSaving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ✅ Get category object
    final category = demoCategories.firstWhere(
      (c) => c.id == selectedCategory,
    );

    // ✅ If description empty → use category name (Food, Travel, etc.)
    final String finalTitle =
        descriptionController.text.trim().isEmpty
            ? category.name
            : descriptionController.text.trim();

    await ExpenseService.addExpense(
      partnerId: activePartnerId,
      title: finalTitle, // ✅ FIXED HERE
      amount: double.parse(amountController.text.trim()),
      type: selectedType == EntryType.expense ? 'expense' : 'income',
      category: selectedCategory!,
      paidBy: user.uid,
      createdAt: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      ),
    );

    if (mounted) {
      Navigator.pop(context);
    }
  } finally {
    if (mounted) setState(() => isSaving = false);
  }
}


  Widget _dragHandle() => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );

  Widget _header(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Entry',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.close,
                  color: Colors.white70, size: 18),
            ),
          ),
        ],
      );

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
}
