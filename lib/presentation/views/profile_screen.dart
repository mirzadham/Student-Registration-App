import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../../core/utils/validators.dart';

/// Profile screen for viewing and editing student info
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _icNumberController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _programController;

  @override
  void initState() {
    super.initState();
    final student = context.read<RegistrationViewModel>().student;
    _nameController = TextEditingController(text: student?.name ?? '');
    _icNumberController = TextEditingController(text: student?.icNumber ?? '');
    _phoneController = TextEditingController(text: student?.phoneNumber ?? '');
    _addressController = TextEditingController(text: student?.address ?? '');
    _emergencyContactController = TextEditingController(
      text: student?.emergencyContact ?? '',
    );
    _programController = TextEditingController(text: student?.program ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _icNumberController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _programController.dispose();
    super.dispose();
  }

  void _resetForm() {
    final student = context.read<RegistrationViewModel>().student;
    _nameController.text = student?.name ?? '';
    _icNumberController.text = student?.icNumber ?? '';
    _phoneController.text = student?.phoneNumber ?? '';
    _addressController.text = student?.address ?? '';
    _emergencyContactController.text = student?.emergencyContact ?? '';
    _programController.text = student?.program ?? '';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final registrationViewModel = context.read<RegistrationViewModel>();

    final success = await registrationViewModel.updateStudentProfile(
      studentId: authViewModel.userId!,
      name: _nameController.text.trim(),
      icNumber: _icNumberController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim(),
      program: _programController.text.trim(),
    );

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile updated successfully'
                : registrationViewModel.errorMessage ??
                      'Failed to update profile',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _resetForm();
                setState(() => _isEditing = false);
              },
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: Consumer<RegistrationViewModel>(
        builder: (context, reg, _) {
          if (reg.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = reg.student;
          if (student == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Profile not found',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          student.email,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (student.program != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              student.program!,
                              style: TextStyle(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form fields
                  _buildSectionHeader(theme, 'Personal Information'),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    enabled: _isEditing,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _icNumberController,
                    labelText: 'IC Number',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    enabled: _isEditing,
                    validator: _isEditing ? Validators.validateIcNumber : null,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    enabled: _isEditing,
                    validator: _isEditing
                        ? Validators.validatePhoneNumber
                        : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader(theme, 'Additional Information'),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _addressController,
                    labelText: 'Address',
                    prefixIcon: const Icon(Icons.home_outlined),
                    maxLines: 2,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _emergencyContactController,
                    labelText: 'Emergency Contact',
                    prefixIcon: const Icon(Icons.emergency_outlined),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _programController,
                    labelText: 'Program/Major',
                    prefixIcon: const Icon(Icons.school_outlined),
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (reg.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reg.errorMessage!,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Save button
                  if (_isEditing)
                    LoadingButton(
                      text: 'Save Changes',
                      isLoading: reg.isLoading,
                      onPressed: _handleSave,
                    ),

                  const SizedBox(height: 24),

                  // Security notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer.withOpacity(
                        0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.tertiaryContainer,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Protected',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                              Text(
                                'Your sensitive data is encrypted with AES-256',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onTertiaryContainer
                                      .withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }
}
