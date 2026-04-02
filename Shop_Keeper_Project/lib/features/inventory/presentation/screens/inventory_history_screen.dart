import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_keeper_project/features/inventory/presentation/bloc/inventory_cubit.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class InventoryHistoryScreen extends StatelessWidget {
  const InventoryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory History')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          // This would ideally use a separate InventoryLogsCubit
          // For now, we'll show a placeholder or mock logs based on sync logs if available
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10,
            itemBuilder: (context, index) {
              final isAdd = index % 3 == 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAdd ? AppTheme.successEmerald.withOpacity(0.1) : AppTheme.dangerRose.withOpacity(0.1),
                    child: Icon(
                      isAdd ? Icons.add : Icons.remove,
                      color: isAdd ? AppTheme.successEmerald : AppTheme.dangerRose,
                    ),
                  ),
                  title: Text(isAdd ? 'Stock Added: Kurkure' : 'Sale: Lays'),
                  subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now().subtract(Duration(hours: index * 2)))),
                  trailing: Text(
                    isAdd ? '+50' : '-10',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isAdd ? AppTheme.successEmerald : AppTheme.dangerRose,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
