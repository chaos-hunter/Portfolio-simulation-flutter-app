import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/stock_search.dart';
import '../widgets/stock_card.dart';
import '../widgets/portfolio_summary.dart';
import '../widgets/projection_calculator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _currentStock;
  final TextEditingController _depositController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 800) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildMainContent(),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 1,
                              child: _buildSidebar(),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildMainContent(),
                            const SizedBox(height: 32),
                            _buildSidebar(),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'ProInvestor Sim',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Real-time Data & Wealth Projection Engine',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        return Column(
          children: [
            StockSearch(
              onSelect: (stock) {
                setState(() {
                  _currentStock = stock;
                });
              },
            ),
            if (_currentStock != null) ...[
              StockCard(
                data: _currentStock!,
                onBuy: (symbol, price, amount, name) {
                  final success = portfolioProvider.buy(symbol, price, amount, name);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Insufficient funds!'), backgroundColor: AppTheme.danger),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bought $amount shares of $symbol'), backgroundColor: AppTheme.primary),
                    );
                  }
                },
              ),
              ProjectionCalculator(
                currentStock: _currentStock,
                portfolio: portfolioProvider.portfolio,
              ),
            ] else
              Container(
                decoration: AppTheme.glassDecoration,
                padding: const EdgeInsets.all(48),
                alignment: Alignment.center,
                child: const Text(
                  'Search for a stock symbol (e.g., NVDA, TSLA, SPY) to begin.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        return Column(
          children: [
            Container(
              decoration: AppTheme.glassDecoration,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Current Balance', style: TextStyle(color: AppTheme.textSecondary)),
                  Text(
                    '\$${portfolioProvider.cash.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _depositController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(hintText: 'Amount to Add'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final amount = double.tryParse(_depositController.text) ?? 0;
                          if (amount > 0) {
                            portfolioProvider.deposit(amount);
                            _depositController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PortfolioSummary(
              portfolio: portfolioProvider.portfolio,
              onSell: (symbol, amount) {
                portfolioProvider.sell(symbol, amount);
              },
            ),
          ],
        );
      },
    );
  }
}
