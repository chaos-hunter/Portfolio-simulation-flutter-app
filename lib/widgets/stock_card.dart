import 'package:flutter/material.dart';
import '../theme.dart';

class StockCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(String symbol, double price, double amount, String name) onBuy;

  const StockCard({Key? key, required this.data, required this.onBuy}) : super(key: key);

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  final TextEditingController _amountController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    final double price = widget.data['regularMarketPrice'] ?? 0.0;
    final double changePercent = widget.data['regularMarketChangePercent'] ?? 0.0;
    final bool isPositive = changePercent >= 0;

    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data['symbol'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.data['shortName'] ?? widget.data['symbol'],
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? AppTheme.primary : AppTheme.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Shares to Buy',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    if (amount > 0) {
                      widget.onBuy(
                        widget.data['symbol'],
                        price,
                        amount,
                        widget.data['shortName'] ?? widget.data['symbol'],
                      );
                    }
                  },
                  child: const Text('Buy Shares'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
