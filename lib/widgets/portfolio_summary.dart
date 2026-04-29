import 'package:flutter/material.dart';
import '../theme.dart';
import '../providers/portfolio_provider.dart';

class PortfolioSummary extends StatelessWidget {
  final List<PortfolioItem> portfolio;
  final Function(String symbol, double amount) onSell;

  const PortfolioSummary({
    Key? key,
    required this.portfolio,
    required this.onSell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double totalValue = 0.0;
    for (var item in portfolio) {
      totalValue += item.price * item.amount;
    }

    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Portfolio',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Asset Value',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          if (portfolio.isEmpty)
            const Text(
              'No stocks in portfolio yet.',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: portfolio.length,
              itemBuilder: (context, index) {
                final item = portfolio[index];
                return _buildPortfolioItem(context, item);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(BuildContext context, PortfolioItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${(item.price * item.amount).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.amount.toStringAsFixed(2)} shares @ \$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              TextButton(
                onPressed: () {
                  _showSellDialog(context, item);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Sell'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSellDialog(BuildContext context, PortfolioItem item) {
    final TextEditingController controller = TextEditingController(text: item.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text('Sell ${item.symbol}'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Shares to Sell',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                final amountToSell = double.tryParse(controller.text) ?? 0;
                if (amountToSell > 0) {
                  onSell(item.symbol, amountToSell);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              child: const Text('Confirm Sell'),
            ),
          ],
        );
      },
    );
  }
}
