import 'package:flutter/material.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';
import '../theme.dart';

class StockSearch extends StatefulWidget {
  final Function(Map<String, dynamic>?) onSelect;

  const StockSearch({Key? key, required this.onSelect}) : super(key: key);

  @override
  State<StockSearch> createState() => _StockSearchState();
}

class _StockSearchState extends State<StockSearch> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _error = '';

  Future<void> _handleSearch() async {
    final symbol = _controller.text.trim().toUpperCase();
    if (symbol.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final yahooFinance = const YahooFinanceDailyReader();
      YahooFinanceResponse response = await yahooFinance.getDailyDTOs(symbol);
      final data = response.candlesData;

      if (data.isNotEmpty) {
        final latest = data.last;
        
        final stockData = {
          'symbol': symbol,
          'shortName': symbol, 
          'regularMarketPrice': latest.close,
          'regularMarketChangePercent': 0.0,
          'fiftyTwoWeekChangePercent': 10.0, // default
        };
        
        if (data.length > 1) {
           final prev = data[data.length - 2];
           final change = latest.close - prev.close;
           stockData['regularMarketChangePercent'] = (change / prev.close) * 100;
        }

        widget.onSelect(stockData);
      } else {
        setState(() {
          _error = 'No data found for symbol $symbol';
        });
        widget.onSelect(null);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _error = 'Network error fetching data. Try again.';
      });
      widget.onSelect(null);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter Stock Symbol (e.g., AAPL)',
                  ),
                  onSubmitted: (_) => _handleSearch(),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSearch,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Search'),
              ),
            ],
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              _error,
              style: const TextStyle(color: AppTheme.danger),
            ),
          ]
        ],
      ),
    );
  }
}
