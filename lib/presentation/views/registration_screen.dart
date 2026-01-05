import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/registration_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../../core/utils/validators.dart';
import 'dashboard_screen.dart';

/// Registration screen for new students
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _icNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _programController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _icNumberController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final registrationViewModel = context.read<RegistrationViewModel>();

    // Step 1: Create Firebase Auth account
    final authSuccess = await authViewModel.registerWithEmailPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!authSuccess || !mounted) return;

    // Step 2: Create student profile
    final profileSuccess = await registrationViewModel.registerStudentProfile(
      uid: authViewModel.userId!,
      email: _emailController.text.trim(),
      name: _nameController.text.trim(),
      icNumber: _icNumberController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      emergencyContact: _emergencyContactController.text.trim(),
      program: _programController.text.trim(),
      enrollmentYear: DateTime.now().year,
    );

    if (profileSuccess && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _handleRegistration();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.of(context).pop();
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    if (_currentStep < 2)
                      Expanded(
                        child: LoadingButton(
                          text: 'Continue',
                          onPressed: details.onStepContinue,
                        ),
                      )
                    else
                      Expanded(
                        child: Consumer2<AuthViewModel, RegistrationViewModel>(
                          builder: (context, auth, reg, _) {
                            return LoadingButton(
                              text: 'Register',
                              isLoading: auth.isLoading || reg.isLoading,
                              onPressed: details.onStepContinue,
                            );
                          },
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LoadingButton(
                        text: _currentStep == 0 ? 'Cancel' : 'Back',
                        isOutlined: true,
                        onPressed: details.onStepCancel,
                      ),
                    ),
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Account Details
              Step(
                title: const Text('Account'),
                subtitle: const Text('Email & Password'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Create a strong password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          );
                        },
                      ),
                      validator: (value) => Validators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                    ),
                  ],
                ),
              ),

              // Step 2: Personal Information
              Step(
                title: const Text('Personal'),
                subtitle: const Text('Your details'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outlined),
                      textInputAction: TextInputAction.next,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _icNumberController,
                      labelText: 'IC Number',
                      hintText: 'YYMMDD-SS-NNNN',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateIcNumber,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Phone Number',
                      hintText: 'Enter phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhoneNumber,
                    ),
                  ],
                ),
              ),

              // Step 3: Additional Information
              Step(
                title: const Text('Additional'),
                subtitle: const Text('Optional info'),
                isActive: _currentStep >= 2,
                state: _currentStep > 2
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  children: [
                    // Error messages
                    Consumer2<AuthViewModel, RegistrationViewModel>(
                      builder: (context, auth, reg, _) {
                        final error = auth.errorMessage ?? reg.errorMessage;
                        if (error != null) {
                          return Padding(
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
                                      error,
                                      style: TextStyle(
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      prefixIcon: const Icon(Icons.home_outlined),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emergencyContactController,
                      labelText: 'Emergency Contact',
                      hintText: 'Name and phone number',
                      prefixIcon: const Icon(Icons.emergency_outlined),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _programController,
                      labelText: 'Program/Major',
                      hintText: 'e.g., Computer Science',
                      prefixIcon: const Icon(Icons.school_outlined),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
