import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'buy';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _nissController = TextEditingController();

  Uint8List? _pdfBytes;

  Future<void> _submitForm() async {
    final uri = Uri.parse('backend/invoice.php');
    final response = await http.post(
      uri,
      body: {
        'type': _type,
        'name': _nameController.text,
        'address': _addressController.text,
        'nif': _nifController.text,
        'niss': _nissController.text,
      },
    );

    if (response.statusCode == 200 &&
        response.headers['content-type'] != null &&
        response.headers['content-type']!.contains('pdf')) {
      setState(() => _pdfBytes = response.bodyBytes);
    } else {
      // helpful debug message if PHP returned HTML (error page) instead of PDF
      final text = response.headers['content-type']?.contains('text') ?? false
          ? response.body
          : 'No PDF returned (status ${response.statusCode})';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to generate PDF: $text')));
    }
  }

  Future<void> _generateField(String field) async {
    final response = await http.post(
      Uri.parse('backend/generate.php'),
      body: {'field': field},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        if (field == 'nif') {
          _nifController.text = data['value'];
        } else if (field == 'niss') {
          _nissController.text = data['value'];
        }
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error generating $field")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left: Form
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Invoice Type"),
                  Row(
                    children: [
                      Checkbox(
                        value: _type == 'buy',
                        onChanged: (val) {
                          setState(() => _type = 'buy');
                        },
                      ),
                      const Text("Buy"),
                      Checkbox(
                        value: _type == 'sell',
                        onChanged: (val) {
                          setState(() => _type = 'sell');
                        },
                      ),
                      const Text("Sell"),
                    ],
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Company Name",
                    ),
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: "Company Address",
                    ),
                    maxLines: 2,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nifController,
                          decoration: const InputDecoration(labelText: "NIF"),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Generate NIF",
                        onPressed: () => _generateField("nif"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nissController,
                          decoration: const InputDecoration(labelText: "NISS"),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: "Generate NISS",
                        onPressed: () => _generateField("niss"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Generate Invoice"),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Right: PDF Viewer
        Expanded(
          flex: 2,
          child: _pdfBytes == null
              ? const Center(child: Text("No invoice generated yet"))
              : Column(
                  children: [
                    Expanded(child: SfPdfViewer.memory(_pdfBytes!)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _pdfBytes = null;
                            });
                          },
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
