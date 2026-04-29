import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../providers/portfolio_provider.dart';

class ProjectionData {
  final int year;
  final double value;

  ProjectionData(this.year, this.value);
}

class ProjectionCalculator extends StatefulWidget {
  final Map<String, dynamic>? currentStock;
  final List<PortfolioItem> portfolio;

  const ProjectionCalculator({
    Key? key,
    this.currentStock,
    required this.portfolio,
  }) : super(key: key);

  @override
  State<ProjectionCalculator> createState() => _ProjectionCalculatorState();
}

class _ProjectionCalculatorState extends State<ProjectionCalculator> {
  final TextEditingController _investmentController = TextEditingController(text: '1000');
  final TextEditingController _yearsController = TextEditingController(text: '10');
  final TextEditingController _rateController = TextEditingController(text: '10');

  List<ProjectionData> _projectionData = [];

  @override
  void initState() {
    super.initState();
    _syncWithStock();
  }

  @override
  void didUpdateWidget(ProjectionCalculator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentStock?['symbol'] != oldWidget.currentStock?['symbol'] || 
        widget.portfolio != oldWidget.portfolio) {
      _syncWithStock();
    }
  }

  void _syncWithStock() {
    if (widget.currentStock == null) return;
    
    // Auto-fill Rate
    double rate = widget.currentStock!['fiftyTwoWeekChangePercent'] ?? 10.0;
    _rateController.text = rate.toStringAsFixed(2);
    
    // Reactively sync Initial Investment
    final symbol = widget.currentStock!['symbol'];
    final holdingIndex = widget.portfolio.indexWhere((p) => p.symbol == symbol);
    
    if (holdingIndex >= 0) {
      final holding = widget.portfolio[holdingIndex];
      final totalValue = holding.price * holding.amount;
      _investmentController.text = totalValue.toStringAsFixed(2);
    } else {
      _investmentController.text = '1000.00';
    }

    // Clear previous projection
    setState(() {
      _projectionData = [];
    });
  }

  void _handleSimulate() {
    if (widget.currentStock == null) return;

    final double investment = double.tryParse(_investmentController.text) ?? 1000.0;
    final int years = int.tryParse(_yearsController.text) ?? 10;
    final double rate = double.tryParse(_rateController.text) ?? 10.0;

    List<ProjectionData> data = [];
    for (int i = 0; i <= years; i++) {
      double value = investment * pow(1 + (rate / 100), i);
      data.add(ProjectionData(i, value));
    }

    setState(() {
      _projectionData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Investment Simulator',
            style: TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Project the value of your investment in ${widget.currentStock?['symbol'] ?? 'this stock'} over time.',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildInput('Initial Investment (\$)', _investmentController),
              _buildInput('Duration (Years)', _yearsController),
              _buildInput('Expected Annual Return (%)', _rateController),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.currentStock == null ? null : _handleSimulate,
              child: Text(widget.currentStock != null ? 'Run Simulation' : 'Select a Stock First'),
            ),
          ),
          if (_projectionData.isNotEmpty) ...[
            const SizedBox(height: 32),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.glassBorder, strokeWidth: 1, dashArray: [3, 3]),
                    getDrawingVerticalLine: (value) => FlLine(color: AppTheme.glassBorder, strokeWidth: 1, dashArray: [3, 3]),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: const TextStyle(color: AppTheme.textSecondary));
                        },
                      ),
                      axisNameWidget: const Text('Years', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max || value == meta.min) return const SizedBox.shrink();
                          return Text('\$${value.toInt()}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _projectionData.map((d) => FlSpot(d.year.toDouble(), d.value)).toList(),
                      isCurved: true,
                      color: AppTheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Final Value: \$${_projectionData.last.value.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}
