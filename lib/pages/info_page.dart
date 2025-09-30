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
  final TextEditingController _nifController = TextEditingController();
  final TextEditingController _nissController = TextEditingController();

  String? _message;
  bool _loading = false;
  bool _loadingDefaults = true;
  bool _isEditable = false;

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
            _nifController.text = data['nif'] ?? '';
            _nissController.text = data['niss'] ?? '';
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
    final nif = _nifController.text.trim();
    final niss = _nissController.text.trim();

    if (name.isEmpty || address.isEmpty || nif.isEmpty || niss.isEmpty) {
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
        body: {'name': name, 'address': address, 'nif': nif, 'niss': niss},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() => _message = "Company info submitted successfully!");

          // Clear message after 2 seconds
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

  Future<void> _generateField(String field) async {
    final script = field == "nif" ? "generate_nif.php" : "generate_niss.php";
    try {
      final url = Uri.parse('backend/$script');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // expect PHP to return {"value":"..."} or {"nif":"..."} etc.
          final val = data['value'] ?? data['nif'] ?? data['niss'] ?? '';
          if (field == "nif") {
            _nifController.text = val;
          } else {
            _nissController.text = val;
          }
        });
      } else {
        setState(() => _message = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _message = "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingDefaults) {
      return const Center(child: CircularProgressIndicator());
    }

    const green = Color(0xFF04AA6D);
    const lightGreenTrack = Color(0xFFBEEEDA);

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
              // header row: title + custom switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Company Information",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: green,
                    ),
                  ),
                  Row(
                    children: [
                      const Text("Edit"),
                      const SizedBox(width: 8),
                      // CustomSwitch avoids deprecated MaterialState APIs
                      CustomSwitch(
                        value: _isEditable,
                        activeColor: green,
                        activeTrackColor: lightGreenTrack,
                        onChanged: (v) => setState(() => _isEditable = v),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Company Name
              TextField(
                controller: _nameController,
                enabled: _isEditable,
                decoration: const InputDecoration(
                  labelText: "Company Name",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Address
              TextField(
                controller: _addressController,
                enabled: _isEditable,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // NIF row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nifController,
                      enabled: _isEditable,
                      decoration: const InputDecoration(
                        labelText: "NIF",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: green, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: green),
                    onPressed: _isEditable ? () => _generateField("nif") : null,
                    child: const Text("Generate"),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // NISS row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nissController,
                      enabled: _isEditable,
                      decoration: const InputDecoration(
                        labelText: "NISS",
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: green, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: green),
                    onPressed: _isEditable
                        ? () => _generateField("niss")
                        : null,
                    child: const Text("Generate"),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: (_loading || !_isEditable) ? null : _submitForm,
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

/// Simple custom toggle switch widget (no deprecated APIs)
/// - value: current boolean state
/// - onChanged: callback
/// - activeColor: color for the knob when ON
/// - activeTrackColor: background track color when ON
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color activeTrackColor;
  final double width;
  final double height;

  const CustomSwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.activeTrackColor,
    this.width = 52,
    this.height = 32,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    final knobSize = height - 8; // some padding
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? activeTrackColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: knobSize,
            height: knobSize,
            decoration: BoxDecoration(
              color: value ? activeColor : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.alphaBlend(
                    Colors.black.withAlpha((0.12 * 255).round()),
                    Colors.transparent,
                  ),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
