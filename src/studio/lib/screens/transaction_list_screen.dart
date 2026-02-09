import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionListScreen extends StatefulWidget {
  final bool isLoading;
  final List<Transaction>? transactions;

  const TransactionListScreen({
    super.key,
    this.isLoading = false,
    this.transactions,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: widget.transactions?.length ?? 0,
              itemBuilder: (context, index) {
                final transaction = widget.transactions![index];
                return ListTile(
                  title: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                  subtitle: Text('ID: ${transaction.id}'),
                );
              },
            ),
    );
  }
}