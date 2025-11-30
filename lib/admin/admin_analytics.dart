import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

const _bg = Color.fromARGB(246, 220, 220, 221);

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  Future<Map<String, int>> _loadCounts() async {
    final col = FirebaseFirestore.instance.collection('items');

    final lost = await col.where('status', isEqualTo: 'lost').get();
    final found = await col.where('status', isEqualTo: 'found').get();
    final returned = await col.where('status', isEqualTo: 'claimed').get();
    final archived = await col.where('status', isEqualTo: 'archived').get();

    return {
      'lost': lost.size,
      'found': found.size,
      'returned': returned.size,
      'archived': archived.size,
    };
  }

  Stream<List<Map<String, dynamic>>> _loadItemsHistory() {
    return FirebaseFirestore.instance
        .collection('items')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
          return snap.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return data;
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TraceIt Analytics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: FutureBuilder<Map<String, int>>(
                future: _loadCounts(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final counts = snap.data!;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Lost Items',
                                value: counts['lost']!,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Found Items',
                                value: counts['found']!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: 'Returned',
                                value: counts['returned']!,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Archived',
                                value: counts['archived']!,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _loadItemsHistory(),
                          builder: (context, snap2) {
                            if (!snap2.hasData) {
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final items = snap2.data!;
                            return _HistoryChart(items: items);
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/adminSearch'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Database Portal'),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _HistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _HistoryChart({required this.items});

  Map<DateTime, Map<String, int>> _group() {
    final data = <DateTime, Map<String, int>>{};

    for (final item in items) {
      final ts = item['createdAt'];
      if (ts == null) continue;

      final date = DateTime(
        ts.toDate().year,
        ts.toDate().month,
        ts.toDate().day,
      );
      final status = item['status'] ?? '';

      data.putIfAbsent(date, () => {'lost': 0, 'found': 0});

      if (status == 'lost') data[date]!['lost'] = data[date]!['lost']! + 1;
      if (status == 'found') data[date]!['found'] = data[date]!['found']! + 1;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _group();
    final dates = grouped.keys.toList()..sort();
    final lostSpots = <FlSpot>[];
    final foundSpots = <FlSpot>[];

    for (int i = 0; i < dates.length; i++) {
      final d = dates[i];
      final lost = grouped[d]!['lost']!.toDouble();
      final found = grouped[d]!['found']!.toDouble();
      lostSpots.add(FlSpot(i.toDouble(), lost));
      foundSpots.add(FlSpot(i.toDouble(), found));
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: lostSpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.15),
              ),
            ),
            LineChartBarData(
              spots: foundSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
