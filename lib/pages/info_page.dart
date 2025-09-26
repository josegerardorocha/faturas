import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InfoPage extends StatefulWidget {
  final int counter;
  final ValueChanged<int> onCounterChanged;

  const InfoPage({
    required this.counter,
    required this.onCounterChanged,
    super.key,
  });

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _message;
  bool _loading = false;
  bool _loadingDefaults = true;

  @override
  void initState() {
    super.initState();
    _fetchDefaults();
  }

  Future<void> _fetchDefaults() async {
    try {
      final url = Uri.parse('backend/info.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _nameController.text = data['name'] ?? '';
            _addressController.text = data['address'] ?? '';
            _loadingDefaults = false;
          });
        } else {
          setState(() {
            _message = "Failed to load default data";
            _loadingDefaults = false;
          });
        }
      } else {
        setState(() {
          _message = "Server error: ${response.statusCode}";
          _loadingDefaults = false;
        });
      }
    } catch (e) {
      setState(() {
        _message = "Error: $e";
        _loadingDefaults = false;
      });
    }
  }

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      setState(() => _message = "Please fill in all fields.");
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      final url = Uri.parse('backend/info.php');
      final response = await http.post(
        url,
        body: {'name': name, 'address': address},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => _message = "Company info submitted successfully!");

          // Clear the success message after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() => _message = null);
            }
          });
        } else {
          setState(() => _message = "Submission failed.");
        }
      } else {
        setState(() => _message = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _message = "Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDefaults) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Company Information",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF04AA6D),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Company Name",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF04AA6D), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF04AA6D), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF04AA6D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _loading ? null : _submitForm,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains("success")
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
