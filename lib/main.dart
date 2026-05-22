import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const ExpenseSplitterApp());
}

class ExpenseSplitterApp extends StatelessWidget {
  const ExpenseSplitterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF21D4A3),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Splitter',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: baseColorScheme.copyWith(
          primary: const Color(0xFF21D4A3),
          secondary: const Color(0xFF5A8CFF),
          surface: const Color(0xFF131A24),
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1118),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF131A24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF17202B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF21D4A3), width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      home: const ExpenseSplitterHomePage(),
    );
  }
}

class ExpenseSplitterHomePage extends StatefulWidget {
  const ExpenseSplitterHomePage({super.key});

  @override
  State<ExpenseSplitterHomePage> createState() =>
      _ExpenseSplitterHomePageState();
}

class _ExpenseSplitterHomePageState extends State<ExpenseSplitterHomePage> {
  final List<ExpenseEntry> _expenses = <ExpenseEntry>[];
  final Map<String, double> _balances = <String, double>{};
  int _selectedIndex = 0;

  List<String> get _knownPeople {
    final names = _balances.keys.toList()..sort();
    return names;
  }

  void _showAddExpenseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AddExpenseSheet(
          knownPeople: _knownPeople,
          onAddExpense: _addExpense,
        );
      },
    );
  }

  void _addExpense(ExpenseEntry expense) {
    final participantSet = expense.participants.map(_normalizeName).toSet();
    final splitCount = math.max(1, participantSet.length);
    final splitAmount = expense.amount / splitCount;

    setState(() {
      _expenses.insert(0, expense);

      _balances.putIfAbsent(expense.payer, () => 0);
      _balances[expense.payer] = _balances[expense.payer]! + expense.amount;

      for (final participant in participantSet) {
        _balances.putIfAbsent(participant, () => 0);
        _balances[participant] = _balances[participant]! - splitAmount;
      }
    });
  }

  void _resetDemoData() {
    setState(() {
      _expenses.clear();
      _balances.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ExpensesView(
        expenses: _expenses,
        balances: _balances,
        onQuickAdd: _showAddExpenseSheet,
        onReset: _resetDemoData,
      ),
      SummaryView(balances: _balances),
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text(
          'Expense Splitter',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _resetDemoData,
            tooltip: 'Clear session',
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        child: pages[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}

class ExpensesView extends StatelessWidget {
  const ExpensesView({
    super.key,
    required this.expenses,
    required this.balances,
    required this.onQuickAdd,
    required this.onReset,
  });

  final List<ExpenseEntry> expenses;
  final Map<String, double> balances;
  final VoidCallback onQuickAdd;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        const _HeroHeader(
          title: 'Track shared spending in seconds.',
          subtitle:
              'Add expenses, split them evenly, and see balances update live.',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Expenses',
                value: '${expenses.length}',
                icon: Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Session only',
                value: 'Live',
                icon: Icons.bolt_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (expenses.isEmpty)
          _EmptyState(onAddExpense: onQuickAdd, onReset: onReset)
        else
          ...expenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpenseCard(expense: expense),
            ),
          ),
        const SizedBox(height: 16),
        _SettlementsSection(balances: balances),
      ],
    );
  }
}

class _SettlementsSection extends StatelessWidget {
  const _SettlementsSection({super.key, required this.balances});

  final Map<String, double> balances;

  @override
  Widget build(BuildContext context) {
    final transfers = computeSettlements(balances);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Suggested Settlements',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        if (transfers.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'All balances are settled for this session.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
          )
        else
          ...transfers.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(t.from.substring(0, 1).toUpperCase()),
                  ),
                  title: Text('${t.from} → ${t.to}'),
                  trailing: Text(
                    '\$${t.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class SummaryView extends StatelessWidget {
  const SummaryView({super.key, required this.balances});

  final Map<String, double> balances;

  @override
  Widget build(BuildContext context) {
    final entries = balances.entries.toList()
      ..sort((a, b) {
        final diff = b.value.abs().compareTo(a.value.abs());
        if (diff != 0) {
          return diff;
        }
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        const _HeroHeader(
          title: 'Who owes whom?',
          subtitle:
              'Positive balances mean a person is owed money. Negative balances mean they owe money.',
        ),
        const SizedBox(height: 16),
        if (entries.isEmpty)
          const _EmptySummary()
        else
          ...entries.map((entry) {
            final value = entry.value;
            final isOwed = value >= 0;
            final color = isOwed
                ? const Color(0xFF32D583)
                : const Color(0xFFFF6B6B);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isOwed
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOwed ? 'is owed money' : 'owes money',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isOwed ? '+' : '-'}\$${value.abs().toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({
    super.key,
    required this.knownPeople,
    required this.onAddExpense,
  });

  final List<String> knownPeople;
  final ValueChanged<ExpenseEntry> onAddExpense;

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payerController = TextEditingController();
  final TextEditingController _participantsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _payerController.dispose();
    _participantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final payer = _normalizeName(_payerController.text);
    final participants = _parseNames(_participantsController.text);
    final description = _descriptionController.text.trim();

    widget.onAddExpense(
      ExpenseEntry(
        amount: amount,
        payer: payer,
        participants: participants,
        description: description.isEmpty ? null : description,
        createdAt: DateTime.now(),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1620),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add Expense',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the payer and everyone who shared the cost.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _payerController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Payer',
                    hintText: 'Alice',
                  ),
                  validator: (value) {
                    if (_normalizeName(value).isEmpty) {
                      return 'Add the name of the person who paid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _participantsController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Participants',
                    hintText: 'Alice, Bob, Charlie',
                  ),
                  validator: (value) {
                    if (_parseNames(value).isEmpty) {
                      return 'Add at least one participant';
                    }
                    return null;
                  },
                ),
                if (widget.knownPeople.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.knownPeople
                        .map(
                          (name) => ActionChip(
                            label: Text(name),
                            onPressed: () {
                              final current = _participantsController.text
                                  .trim();
                              if (current.isEmpty) {
                                _participantsController.text = name;
                              } else if (!_parseNames(current).contains(name)) {
                                _participantsController.text =
                                    '$current, $name';
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Groceries, dinner, taxi...',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense});

  final ExpenseEntry expense;

  @override
  Widget build(BuildContext context) {
    final participantCount = expense.participants.length;
    final share = expense.amount / math.max(1, participantCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.description ?? 'Expense',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Paid by ${expense.payer}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF21D4A3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expense.participants
                  .map(
                    (name) => Chip(
                      label: Text(name),
                      side: BorderSide.none,
                      backgroundColor: const Color(0xFF17202B),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calculate_rounded,
                    size: 18,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${expense.participants.length} people split it equally at \$${share.toStringAsFixed(2)} each',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17202B), Color(0xFF0F1620)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131A24),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF21D4A3).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF21D4A3), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddExpense, required this.onReset});

  final VoidCallback onAddExpense;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: Color(0xFF21D4A3),
            ),
            const SizedBox(height: 14),
            Text(
              'No expenses yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an expense to start tracking who paid and how much each person owes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onAddExpense,
                    child: const Text('Add Expense'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onReset,
                  child: const Text('Clear session'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: Color(0xFF21D4A3),
            ),
            const SizedBox(height: 14),
            Text(
              'Nothing to settle yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Balances appear here as soon as you add shared expenses.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseEntry {
  ExpenseEntry({
    required this.amount,
    required this.payer,
    required this.participants,
    required this.createdAt,
    this.description,
  });

  final double amount;
  final String payer;
  final List<String> participants;
  final String? description;
  final DateTime createdAt;
}

String _normalizeName(String? value) {
  return value?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
}

List<String> _parseNames(String? value) {
  final parts = (value ?? '')
      .split(',')
      .map(_normalizeName)
      .where((part) => part.isNotEmpty);
  final seen = <String>{};
  final result = <String>[];

  for (final part in parts) {
    if (seen.add(part.toLowerCase())) {
      result.add(part);
    }
  }

  return result;
}

class Transfer {
  Transfer({required this.from, required this.to, required this.amount});

  final String from;
  final String to;
  final double amount;
}

List<Transfer> computeSettlements(Map<String, double> balances) {
  final creditors = <MapEntry<String, double>>[];
  final debtors = <MapEntry<String, double>>[];

  balances.forEach((name, value) {
    if (value.abs() < 0.005) return; // ignore tiny residues
    if (value > 0) {
      creditors.add(MapEntry(name, (value * 100).round() / 100));
    } else if (value < 0) {
      debtors.add(MapEntry(name, ((-value) * 100).round() / 100));
    }
  });

  creditors.sort((a, b) => b.value.compareTo(a.value));
  debtors.sort((a, b) => b.value.compareTo(a.value));

  var i = 0;
  var j = 0;
  final transfers = <Transfer>[];

  while (i < debtors.length && j < creditors.length) {
    final debtor = debtors[i];
    final creditor = creditors[j];
    final amount = math.min(debtor.value, creditor.value);

    if (amount > 0) {
      transfers.add(
        Transfer(
          from: debtor.key,
          to: creditor.key,
          amount: (amount * 100).round() / 100,
        ),
      );
    }

    final remainingDebtor = (debtor.value - amount);
    final remainingCreditor = (creditor.value - amount);

    if (remainingDebtor <= 0.0049) {
      i++;
    } else {
      debtors[i] = MapEntry(debtor.key, remainingDebtor);
    }

    if (remainingCreditor <= 0.0049) {
      j++;
    } else {
      creditors[j] = MapEntry(creditor.key, remainingCreditor);
    }
  }

  return transfers;
}
