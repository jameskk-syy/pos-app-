import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateStaffForm extends StatelessWidget {
  final Widget header;
  final Widget body;

  const CreateStaffForm({super.key, required this.header, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 16),
        Expanded(child: SingleChildScrollView(child: body)),
      ],
    );
  }
}

class StaffFormLayout extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool isObscure;
  final VoidCallback onObscureTap;
  final List<String> selectedRoles;
  final List<String> selectedBillers;
  final VoidCallback onRolesTap;
  final VoidCallback onBillersTap;
  final Widget toggles;
  final Widget actions;

  const StaffFormLayout({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.isObscure,
    required this.onObscureTap,
    required this.selectedRoles,
    required this.selectedBillers,
    required this.onRolesTap,
    required this.onBillersTap,
    required this.toggles,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        if (isTablet) return _buildTabletLayout();
        return _buildMobileLayout();
      },
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Expanded(child: _field('First Name', firstNameController)),
          const SizedBox(width: 12),
          Expanded(child: _field('Last Name', lastNameController)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _field('Email', emailController, keyboardType: TextInputType.emailAddress)),
          const SizedBox(width: 12),
          Expanded(child: _field('Phone Number', phoneController, keyboardType: TextInputType.number, digitsOnly: true)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _passwordField()),
          const SizedBox(width: 12),
          Expanded(child: _pickerField('Roles', selectedRoles.isEmpty ? 'Choose roles' : selectedRoles.join(', '), onRolesTap, isEmpty: selectedRoles.isEmpty)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _pickerField('Assigned Branches', selectedBillers.isEmpty ? 'Choose branches' : selectedBillers.join(', '), onBillersTap, isEmpty: selectedBillers.isEmpty)),
          const SizedBox(width: 12),
          const Expanded(child: SizedBox()),
        ]),
        const SizedBox(height: 16),
        toggles,
        const SizedBox(height: 24),
        actions,
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field('First Name', firstNameController),
        const SizedBox(height: 12),
        _field('Last Name', lastNameController),
        const SizedBox(height: 12),
        _field('Email', emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field('Phone Number', phoneController, keyboardType: TextInputType.number, digitsOnly: true),
        const SizedBox(height: 12),
        _passwordField(),
        const SizedBox(height: 12),
        _pickerField('Roles', selectedRoles.isEmpty ? 'Choose roles' : selectedRoles.join(', '), onRolesTap, isEmpty: selectedRoles.isEmpty),
        const SizedBox(height: 12),
        _pickerField('Assigned Branches', selectedBillers.isEmpty ? 'Choose branches' : selectedBillers.join(', '), onBillersTap, isEmpty: selectedBillers.isEmpty),
        const SizedBox(height: 16),
        toggles,
        const SizedBox(height: 24),
        actions,
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, {TextInputType? keyboardType, bool digitsOnly = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      keyboardType: keyboardType,
      inputFormatters: digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: passwordController,
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off), onPressed: onObscureTap),
      ),
    );
  }

  Widget _pickerField(String label, String value, VoidCallback onTap, {bool isEmpty = false}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
        child: Text(value, style: TextStyle(color: isEmpty ? Colors.grey.shade600 : Colors.black)),
      ),
    );
  }
}

class StaffTogglesSection extends StatelessWidget {
  final bool isEnabled;
  final bool sendWelcomeEmail;
  final Function(bool) onEnabledChanged;
  final Function(bool) onEmailChanged;

  const StaffTogglesSection({
    super.key,
    required this.isEnabled,
    required this.sendWelcomeEmail,
    required this.onEnabledChanged,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Switch(value: isEnabled, onChanged: onEnabledChanged, activeThumbColor: Colors.white, activeTrackColor: Colors.blueAccent),
            const Text('Enabled'),
          ]),
          const SizedBox(width: 24),
          Row(children: [
            Switch(value: sendWelcomeEmail, onChanged: onEmailChanged, activeThumbColor: Colors.white, activeTrackColor: Colors.blueAccent),
            const Text('Send Welcome Email'),
          ]),
        ],
      ),
    );
  }
}

class StaffFormActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onCreate;
  final bool isLoading;

  const StaffFormActions({super.key, required this.onCancel, required this.onCreate, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onCreate,
            icon: const Icon(Icons.add, color: Colors.white),
            label: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
          ),
        ),
      ],
    );
  }
}
