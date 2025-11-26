import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  String _status = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Machine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Enter machine details',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Machine Name', prefixIcon: Icon(Icons.memory)),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                    labelText: 'Machine Code/ID', prefixIcon: Icon(Icons.tag)),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Code/ID is required'
                    : null,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                    labelText: 'Status', prefixIcon: Icon(Icons.circle)),
                items: const [
                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                  DropdownMenuItem(
                      value: 'Under Maintenance',
                      child: Text('Under Maintenance')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'Active'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    final name = _nameController.text.trim();
                    final code = _codeController.text.trim();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added $name ($code) - $_status')),
                    );
                    Navigator.pop(context, {
                      'name': name,
                      'code': code,
                      'status': _status,
                    });
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Add Machine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
