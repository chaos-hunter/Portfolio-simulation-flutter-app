import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioItem {
  final String symbol;
  final double price;
  final double amount;
  final String name;

  PortfolioItem({required this.symbol, required this.price, required this.amount, required this.name});

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'price': price,
    'amount': amount,
    'name': name,
  };

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      symbol: json['symbol'],
      price: json['price'],
      amount: json['amount'],
      name: json['name'] ?? json['symbol'],
    );
  }
}

class PortfolioProvider extends ChangeNotifier {
  double _cash = 0.0;
  List<PortfolioItem> _portfolio = [];

  double get cash => _cash;
  List<PortfolioItem> get portfolio => _portfolio;

  PortfolioProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _cash = prefs.getDouble('sim_cash') ?? 0.0;
    final portfolioStr = prefs.getString('sim_portfolio');
    if (portfolioStr != null) {
      final List<dynamic> decoded = jsonDecode(portfolioStr);
      _portfolio = decoded.map((e) => PortfolioItem.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sim_cash', _cash);
    await prefs.setString('sim_portfolio', jsonEncode(_portfolio.map((e) => e.toJson()).toList()));
  }

  void deposit(double amount) {
    if (amount <= 0) return;
    _cash += amount;
    _saveToPrefs();
    notifyListeners();
  }

  bool buy(String symbol, double price, double amount, String name) {
    double cost = price * amount;
    if (cost > _cash) {
      return false; // Insufficient funds
    }

    _cash -= cost;
    int index = _portfolio.indexWhere((item) => item.symbol == symbol);
    if (index >= 0) {
      var existing = _portfolio[index];
      _portfolio[index] = PortfolioItem(
        symbol: symbol, 
        price: price, 
        amount: existing.amount + amount, 
        name: name
      );
    } else {
      _portfolio.add(PortfolioItem(symbol: symbol, price: price, amount: amount, name: name));
    }

    _saveToPrefs();
    notifyListeners();
    return true;
  }

  void sell(String symbol, double amountToSell) {
    int index = _portfolio.indexWhere((item) => item.symbol == symbol);
    if (index < 0) return;

    var item = _portfolio[index];
    double actualSellAmount = amountToSell < item.amount ? amountToSell : item.amount;
    double cashToAdd = item.price * actualSellAmount;

    if (actualSellAmount >= item.amount) {
      _portfolio.removeAt(index);
    } else {
      _portfolio[index] = PortfolioItem(
        symbol: symbol,
        price: item.price,
        amount: item.amount - actualSellAmount,
        name: item.name
      );
    }

    _cash += cashToAdd;
    _saveToPrefs();
    notifyListeners();
  }
}
