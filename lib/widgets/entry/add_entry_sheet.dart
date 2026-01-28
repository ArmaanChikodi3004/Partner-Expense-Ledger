import 'package:flutter/material.dart';
import '../../data/demo_categories.dart';

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

  final List<String> attachments = [];

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// 🔴 Expense | 🔵 Income
  Color get _submitColor =>
      selectedType == EntryType.expense
          ? const Color(0xFFEF4444)
          : const Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final categories =
        demoCategories.where((c) => c.type == selectedType).toList();

    return Container(
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

            _sectionLabel('Amount'),
            _amountField(),

            const SizedBox(height: 24),

            _sectionLabel('Category'),
            const SizedBox(height: 12),
            _categoryGrid(categories),

            const SizedBox(height: 24),

            _sectionLabel('Description (optional)'),
            _descriptionField(),

            const SizedBox(height: 24),

            _sectionLabel('Attachments'),
            _attachments(),

            const SizedBox(height: 28),

            _submitButton(),
          ],
        ),
      ),
    );
  }

  // ───────────────────── UI PARTS ─────────────────────

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
              child: const Icon(Icons.close, color: Colors.white70, size: 18),
            ),
          ),
        ],
      );

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

  // ───────── CATEGORY GRID (SMALLER) ─────────

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

  // ───────── DESCRIPTION ─────────

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

  // ───────── ATTACHMENTS ─────────

  Widget _attachments() {
    return GestureDetector(
      onTap: () {
        setState(() {
          attachments.add('receipt_${attachments.length + 1}.jpg');
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: const [
            Icon(Icons.upload, color: Colors.white54),
            SizedBox(height: 6),
            Text(
              'Upload receipt or document',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── SUBMIT BUTTON ─────────

  Widget _submitButton() {
    final enabled = selectedCategory != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? () => Navigator.pop(context) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _submitColor,
          disabledBackgroundColor: Colors.white.withOpacity(0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          selectedType == EntryType.income ? 'Add Income' : 'Add Expense',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      );
}
