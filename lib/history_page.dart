import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.operations});

  final List<String> operations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC),
      appBar: AppBar(
        title: const Text('Histórico'),
        centerTitle: true,
        backgroundColor: const Color(0xFFA8C4FA),
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
      ),
      body: operations.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma operação realizada.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: operations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.zero,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      operations[index],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
