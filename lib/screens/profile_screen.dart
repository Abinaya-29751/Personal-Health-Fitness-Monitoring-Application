import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart' as helpers; // Import with alias

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  String _gender = 'Male';

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _heightController = TextEditingController(text: user?.height.toString());
    _weightController = TextEditingController(text: user?.weight.toString());
    _ageController = TextEditingController(text: user?.age.toString());
    _gender = user?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Helper method for initials since it's not in helpers
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }

  // Helper method for BMR calculation since it's not in helpers
  int _calculateBMR(int heightInCm, double weightInKg, int age, String gender) {
    // Mifflin-St Jeor Equation for BMR
    double bmr = 10 * weightInKg + 6.25 * heightInCm - 5 * age;

    if (gender == 'Male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    return bmr.round();
  }

  // Helper method for BMI calculation (using our helpers or a fallback)
  double _calculateBMI(double weightKg, double heightCm) {
    try {
      // Try to use the imported helper
      return helpers.AppHelpers.calculateBMI(weightKg, heightCm);
    } catch (e) {
      // Fallback implementation
      final heightM = heightCm / 100;
      return weightKg / (heightM * heightM);
    }
  }

  // Helper method for email validation (using our helpers or a fallback)
  bool _isValidEmail(String email) {
    try {
      // Try to use the imported helper
      return helpers.AppHelpers.isValidEmail(email);
    } catch (e) {
      // Fallback implementation
      final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegExp.hasMatch(email);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user!;

      final updatedUser = User(
        id: currentUser.id,
        name: _nameController.text,
        email: _emailController.text,
        profilePicture: currentUser.profilePicture,
        height: int.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        age: int.parse(_ageController.text),
        gender: _gender,
      );

      await DatabaseService().updateUser(updatedUser);
      userProvider.updateUser(updatedUser);

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).primaryColor,
              child: user.profilePicture != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.network(
                  user.profilePicture!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
                  : Text(
                _getInitials(user.name),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isEditing)
              _buildEditForm(user)
            else
              _buildProfileInfo(user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        _buildInfoCard(
          title: 'Physical Info',
          items: [
            InfoItem(
              icon: Icons.height,
              label: 'Height',
              value: '${user.height} cm',
            ),
            InfoItem(
              icon: Icons.fitness_center,
              label: 'Weight',
              value: '${user.weight} kg',
            ),
            InfoItem(
              icon: Icons.cake,
              label: 'Age',
              value: '${user.age} years',
            ),
            InfoItem(
              icon: Icons.person,
              label: 'Gender',
              value: user.gender,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Health Metrics',
          items: [
            InfoItem(
              icon: Icons.monitor_weight,
              label: 'BMI',
              value: _calculateBMI(user.weight.toDouble(), user.height.toDouble()).toStringAsFixed(1),
            ),
            InfoItem(
              icon: Icons.local_fire_department,
              label: 'BMR',
              value: '${_calculateBMR(user.height, user.weight, user.age, user.gender)} kcal',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<InfoItem> items}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => _buildInfoItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(InfoItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            item.icon,
            color: Theme.of(context).primaryColor,
            size: 22,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(User user) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!_isValidEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _heightController,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your height';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your weight';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            value: _gender,
            items: ['Male', 'Female', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _gender = newValue!;
              });
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      // Reset controllers to original values
                      _nameController.text = user.name;
                      _emailController.text = user.email;
                      _heightController.text = user.height.toString();
                      _weightController.text = user.weight.toString();
                      _ageController.text = user.age.toString();
                      _gender = user.gender;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final IconData icon;
  final String label;
  final String value;

  InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}