
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late Box _usersBox;
  String _currentUserEmail = '';
  final _auth = FirebaseAuth.instance;

  final _nameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _residenceController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _usersBox = Hive.box('users');
    _loadUserData();
  }

  void _loadUserData() {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUserEmail = firebaseUser.email ?? '';

      // Load user data from Hive
      final userData = _usersBox.get(_currentUserEmail);
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _fullNameController.text = userData['full_name'] ?? '';
          _residenceController.text = userData['residence'] ?? '';

          if (userData['date_of_birth'] != null) {
            _selectedDate = DateTime.parse(userData['date_of_birth']);
          }
        });
      }
    }
  }

  Future<void> _selectDate() async {
    if (!_isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select your date of birth',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Get existing user data
        final userData = _usersBox.get(_currentUserEmail);
        if (userData != null) {
          // Update user data
          userData['name'] = _nameController.text.trim();
          userData['full_name'] = _fullNameController.text.trim();
          userData['residence'] = _residenceController.text.trim();
          userData['date_of_birth'] = _selectedDate?.toIso8601String();

          // Save back to Hive
          await _usersBox.put(_currentUserEmail, userData);

          // Update Firebase display name
          final firebaseUser = _auth.currentUser;
          if (firebaseUser != null) {
            await firebaseUser.updateDisplayName(_nameController.text.trim());
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Profile updated successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              _isEditMode = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditMode) {
        // Cancel editing - reload original data
        _loadUserData();
      }
      _isEditMode = !_isEditMode;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _residenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Profile' : 'Profile'),
        centerTitle: true,
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text[0].toUpperCase()
                            : _currentUserEmail.isNotEmpty
                            ? _currentUserEmail[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentUserEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Email (Always read-only)
              TextFormField(
                initialValue: _currentUserEmail,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Choose a username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: !_isEditMode,
                  fillColor: !_isEditMode ? Colors.grey[100] : null,
                ),
                enabled: _isEditMode,
                validator: (value) {
                  if (_isEditMode && (value == null || value.isEmpty)) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Full Name
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: !_isEditMode,
                  fillColor: !_isEditMode ? Colors.grey[100] : null,
                ),
                enabled: _isEditMode,
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: _isEditMode ? _selectDate : null,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'Select your date of birth',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: !_isEditMode,
                    fillColor: !_isEditMode ? Colors.grey[100] : null,
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('MMMM dd, yyyy').format(_selectedDate!)
                        : 'Tap to select',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null
                          ? (_isEditMode ? Colors.black : Colors.grey[700])
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Place of Residence
              TextFormField(
                controller: _residenceController,
                decoration: InputDecoration(
                  labelText: 'Place of Residence',
                  hintText: 'City, Country',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: !_isEditMode,
                  fillColor: !_isEditMode ? Colors.grey[100] : null,
                ),
                enabled: _isEditMode,
              ),
              const SizedBox(height: 32),

              // Info Card (only show in edit mode)
              if (_isEditMode)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This information will be visible to other users when messaging.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_isEditMode) const SizedBox(height: 16),

              // Edit Account / Cancel Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleEditMode,
                  icon: Icon(_isEditMode ? Icons.close : Icons.edit),
                  label: Text(_isEditMode ? 'Cancel' : 'Edit Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEditMode ? Colors.grey : Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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