import 'package:flutter/material.dart';
import 'app_state.dart';

class AllRecordsPage extends StatelessWidget {
  const AllRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2340),
        title: const Text('Все записи', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A2F6B), Color(0xFF0D1B3E), Color(0xFF0A0A1A)],
          ),
        ),
        child: ListenableBuilder(
          listenable: AppState.instance,
          builder: (context, _) {
            final records = AppState.instance.records.reversed.toList();
            if (records.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list_alt_outlined, color: Colors.white12, size: 64),
                    SizedBox(height: 16),
                    Text('Нет данных', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2340),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4C6EF5).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4C6EF5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.monitor_weight_outlined,
                            color: Color(0xFF4C6EF5), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fmtDate(r.date),
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmtTime(r.date),
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${r.weight.toStringAsFixed(2)} кг',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
