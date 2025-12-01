import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

const _bg = Color.fromARGB(246, 220, 220, 221);

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  Future<Map<String, int>> _loadCounts() async {
    final col = FirebaseFirestore.instance.collection('items');

    final totalSnap = await col.get();

    final lostSnap = await col.where('status', isEqualTo: 'lost').get();
    final foundSnap = await col.where('status', isEqualTo: 'found').get();
    final returnedSnap = await col.where('status', isEqualTo: 'returned').get();
    final archivedSnap = await col.where('status', isEqualTo: 'archived').get();

    return {
      'total': totalSnap.size,
      'lost': lostSnap.size,
      'found': foundSnap.size,
      'returned': returnedSnap.size,
      'archived': archivedSnap.size,
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
                                value: counts['lost'] ?? 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Total Items',
                                value: counts['total'] ?? 0,
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
                                value: counts['returned'] ?? 0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: 'Archived',
                                value: counts['archived'] ?? 0,
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
                            if (items.isEmpty) {
                              return Container(
                                height: 200,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    'No items in the database yet.\nAdd lost items to see trends over time.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              );
                            }

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

  Map<DateTime, Map<String, int>> _groupByDateAndStatus() {
    final data = <DateTime, Map<String, int>>{};

    for (final item in items) {
      final ts = item['createdAt'];
      if (ts == null) continue;

      final dt = ts.toDate() as DateTime;
      final date = DateTime(dt.year, dt.month, dt.day);
      final status = (item['status'] ?? '').toString();

      data.putIfAbsent(date, () => {'lost': 0, 'returned': 0});

      if (status == 'lost') {
        data[date]!['lost'] = data[date]!['lost']! + 1;
      } else if (status == 'returned') {
        data[date]!['returned'] = data[date]!['returned']! + 1;
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDateAndStatus();
    final dates = grouped.keys.toList()..sort();

    final lostSpots = <FlSpot>[];
    final returnedSpots = <FlSpot>[];
    final labels = <String>[];

    for (int i = 0; i < dates.length; i++) {
      final d = dates[i];
      final counts = grouped[d]!;
      final lost = counts['lost']!.toDouble();
      final returned = counts['returned']!.toDouble();

      lostSpots.add(FlSpot(i.toDouble(), lost));
      returnedSpots.add(FlSpot(i.toDouble(), returned));
      labels.add('${d.month}/${d.day}');
    }

    final hasData = lostSpots.isNotEmpty || returnedSpots.isNotEmpty;
    if (!hasData) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            'No chart data yet.\nItems will appear here as they are created.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    double maxY = 0;
    for (final s in [...lostSpots, ...returnedSpots]) {
      if (s.y > maxY) maxY = s.y;
    }
    if (maxY < 1) {
      maxY = 1;
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Items over time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Row(
            children: const [
              _LegendDot(color: Color(0xFF2563EB), label: 'Lost'),
              SizedBox(width: 18),
              _LegendDot(color: Color(0xFFDC2626), label: 'Returned'),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'Count',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY + 0.5,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= labels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  labels[index],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              if (value % 1 != 0) {
                                return const SizedBox.shrink();
                              }
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: lostSpots,
                          isCurved: true,
                          color: const Color(0xFF2563EB),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color.fromARGB(40, 37, 99, 235),
                          ),
                        ),
                        LineChartBarData(
                          spots: returnedSpots,
                          isCurved: true,
                          color: const Color(0xFFDC2626),
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color.fromARGB(40, 220, 38, 38),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Date',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
