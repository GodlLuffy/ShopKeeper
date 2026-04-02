import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shop_keeper_project/core/theme/app_theme.dart';
import 'package:shop_keeper_project/core/widgets/primary_button.dart';

class ConflictResolutionScreen extends StatefulWidget {
  const ConflictResolutionScreen({super.key});

  @override
  State<ConflictResolutionScreen> createState() => _ConflictResolutionScreenState();
}

class _ConflictResolutionScreenState extends State<ConflictResolutionScreen> {
  final Box pendingOpsBox = Hive.box('pending_operations');

  List<Map<String, dynamic>> _getConflicts() {
    return pendingOpsBox.values
        .where((e) => e['type'] == 'conflict' && e['status'] == 'pending')
        .cast<Map<String, dynamic>>()
        .toList();
  }

  void _resolveConflict(String conflictId, Map<String, dynamic> keptData) {
    // Determine how we are resolving it
    // If keptData is local, we need to push it back
    // If keptData is remote, we need to update our Hive box based on collection type

    final conflict = pendingOpsBox.get(conflictId);
    if (conflict != null) {
      // Update status so it doesn't show up again
      pendingOpsBox.put(conflictId, {
        ...Map<String, dynamic>.from(conflict as Map),
        'status': 'resolved',
      });
      // In a broader context, we should cue a push or pull operation here
      // depending on whether 'local' or 'remote' was selected.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final conflicts = _getConflicts();

    return Scaffold(
      backgroundColor: AppTheme.darkBackgroundMain,
      appBar: AppBar(
        title: const Text('⚠️ Sync Conflicts', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.darkBackgroundLayer,
        elevation: 0,
      ),
      body: conflicts.isEmpty
          ? const Center(
              child: Text(
                'No pending sync conflicts',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conflicts.length,
              itemBuilder: (context, index) {
                final conflict = conflicts[index];
                final localData = conflict['localData'] as Map<dynamic, dynamic>;
                final remoteData = conflict['remoteData'] as Map<dynamic, dynamic>;
                
                return Card(
                  color: AppTheme.darkBackgroundLayer,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${conflict['collection'].toString().toUpperCase()} - ${conflict['documentId']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBackgroundMain,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('This Device', style: TextStyle(color: AppTheme.accentTeal)),
                                    const SizedBox(height: 8),
                                    Text(_summarizeData(localData), style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkBackgroundMain,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Cloud', style: TextStyle(color: AppTheme.primaryIndigo)),
                                    const SizedBox(height: 8),
                                    Text(_summarizeData(remoteData), style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: PrimaryButton(
                                text: 'Keep Local',
                                onPressed: () {
                                  _resolveConflict(conflict['id'], Map<String, dynamic>.from(localData));
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.darkBackgroundMain,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  _resolveConflict(conflict['id'], Map<String, dynamic>.from(remoteData));
                                },
                                child: const Text('Keep Remote', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _summarizeData(Map<dynamic, dynamic> data) {
    if (data.containsKey('name')) return 'Name: ${data['name']}\nStock: ${data['stockQuantity']}\nPrice: ₹${data['sellPrice']}';
    if (data.containsKey('quantitySold')) return 'Qty: ${data['quantitySold']}\nTotal: ₹${data['totalAmount']}';
    return data.entries.take(3).map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
