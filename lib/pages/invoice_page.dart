import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui_web' as ui; // Flutter web iframe registration
import 'dart:html' as html;

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'buy';
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _showPreview = false;
  String _pdfUrl = "";

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final uri = Uri.parse("backend/invoice.php");

      // Send POST to verify the backend is reachable
      final response = await http.post(uri, body: {
        'type': _type,
        'name': _nameController.text,
        'address': _addressController.text,
      });

      if (response.statusCode == 200) {
        setState(() {
          _pdfUrl = uri.toString();
          _showPreview = true;

          // Update iframe src dynamically
          final iframe = html.IFrameElement()
            ..src = _pdfUrl
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';

          // Register this iframe for HtmlElementView
          // Each registration key must be unique
          // so we use "pdf-view"
          // ignore: undefined_prefixed_name
          ui.platformViewRegistry.registerViewFactory(
            'pdf-view',
            (int viewId) => iframe,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error generating invoice")),
        );
      }
    }
  }

  void _closePreview() {
    setState(() {
      _showPreview = false;
      _pdfUrl = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoice Generator")),
      body: Row(
        children: [
          // LEFT SIDE - Form
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text("Choose type:"),
                    CheckboxListTile(
                      title: const Text("Buy"),
                      value: _type == 'buy',
                      onChanged: (_) => setState(() => _type = 'buy'),
                    ),
                    CheckboxListTile(
                      title: const Text("Sell"),
                      value: _type == 'sell',
                      onChanged: (_) => setState(() => _type = 'sell'),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Company Name",
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: "Company Address",
                      ),
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

          // RIGHT SIDE - PDF Preview
          if (_showPreview)
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: HtmlElementView(viewType: 'pdf-view'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                        onPressed: () {
                          html.window.open(_pdfUrl, "_blank");
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text("Close"),
                        onPressed: _closePreview,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
