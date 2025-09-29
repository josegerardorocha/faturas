import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui_web' as ui;
import 'dart:html' as html;

class BankMovementPage extends StatefulWidget {
  const BankMovementPage({super.key});

  @override
  State<BankMovementPage> createState() => _BankMovementPageState();
}

class _BankMovementPageState extends State<BankMovementPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'deposit';
  final _amountController = TextEditingController();

  bool _showTable = true; // table is always visible
  String _tableUrl = "backend/bank_movement.php";

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse("backend/bank_movement.php");
      final response = await http.post(uri, body: {
        'type': _type,
        'amount': _amountController.text,
      });

      if (response.statusCode == 200) {
        setState(() {
          // reload iframe after form submit
          final iframe = html.IFrameElement()
            ..src = _tableUrl + "?t=${DateTime.now().millisecondsSinceEpoch}"
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';

          ui.platformViewRegistry.registerViewFactory(
            'movements-view',
            (int viewId) => iframe,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Movement submitted")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error submitting movement")),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // initial table load
    final iframe = html.IFrameElement()
      ..src = _tableUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';

    ui.platformViewRegistry.registerViewFactory(
      'movements-view',
      (int viewId) => iframe,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bank Movements")),
      body: Row(
        children: [
          // LEFT SIDE (form)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text("Choose type:"),
                    RadioListTile(
                      title: const Text("Deposit"),
                      value: 'deposit',
                      groupValue: _type,
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                    RadioListTile(
                      title: const Text("Withdraw"),
                      value: 'withdraw',
                      groupValue: _type,
                      onChanged: (val) => setState(() => _type = val!),
                    ),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // RIGHT SIDE (movements table)
          Expanded(
            child: _showTable
                ? HtmlElementView(viewType: 'movements-view')
                : const Center(child: Text("No movements to display")),
          ),
        ],
      ),
    );
  }
}
