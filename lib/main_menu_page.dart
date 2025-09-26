import 'package:flutter/material.dart';
import 'pages/info_page.dart';
import 'pages/invoice_page.dart';
import 'pages/bank_movement_page.dart';
import 'main.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  String _selectedPage = 'Info';
  int _counter = 0; // Example state

  void _selectPage(String page) {
    setState(() {
      _selectedPage = page;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirm == true) {
      _counter = 0; // Clear state
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  Widget _getPageContent() {
    switch (_selectedPage) {
      case 'Info':
        return InfoPage(counter: _counter, onCounterChanged: (newCount) => setState(() => _counter = newCount));
      case 'Invoice':
        return const InvoicePage();
      case 'Bank Movement':
        return const BankMovementPage();
      default:
        return const Center(child: Text('Page not found.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Web App'),
        actions: [
          NavButton(title: 'Info', selected: _selectedPage == 'Info', onTap: () => _selectPage('Info')),
          NavButton(title: 'Invoice', selected: _selectedPage == 'Invoice', onTap: () => _selectPage('Invoice')),
          NavButton(title: 'Bank Movement', selected: _selectedPage == 'Bank Movement', onTap: () => _selectPage('Bank Movement')),
          const SizedBox(width: 20),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _getPageContent(),
    );
  }
}

class NavButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const NavButton({required this.title, required this.selected, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: selected ? const Color(0xFFFFD700) : Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Text(title),
    );
  }
}
