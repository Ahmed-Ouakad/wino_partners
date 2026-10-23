import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/register_bloc.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/register_event.dart';
import 'package:wino_partners/feature/auth/presentation/bloc/register_state.dart';
import 'package:wino_partners/feature/auth/presentation/screens/login_screen.dart';
import 'package:wino_partners/feature/home/presentation/screens/main_screen.dart';
import 'package:wino_partners/feature/onboarding/presentation/screens/onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Liste des options pour le menu déroulant
  final List<String> _types = ['Personne Physique', 'entreprise', 'docteur'];
  String? _selectedType;
  String? _selectedSentType;
  bool _obscurePassword = true;

  // Contrôleurs pour récupérer les valeurs
  final TextEditingController _nomCommercialController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nomCommercialController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction de validation pour champ requis
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration buildInputDecoration({required String hint, required IconData icon}) {
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.onSurfaceVariant,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainer,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      );
    }

    // Widget réutilisable pour les labels
    Widget buildLabel(String text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Inscription réussie !'),
                  backgroundColor: Colors.green,
                ),
              );
              if (!state.hasService) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              }
            } else if (state is RegisterFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    Image.asset(
                      'assets/images/logo.png',
                      height: 65,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Renseignez vos informations pour commencer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: theme.colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // CHAMP: Nom commercial (Requis)
                    buildLabel('Nom commercial'),
                    TextFormField(
                      controller: _nomCommercialController,
                      validator: _validateRequired,
                      decoration: buildInputDecoration(
                        hint: 'Votre nom commercial',
                        icon: Icons.business,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CHAMP: Type (Requis)
                    buildLabel('Type'),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez sélectionner un type';
                        }
                        return null;
                      },
                      decoration: buildInputDecoration(
                        hint: 'Sélectionnez un type',
                        icon: Icons.category,
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
                      dropdownColor: theme.colorScheme.surfaceContainer,
                      items: _types.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue;
                          if( newValue == _types[0]) {
                            _selectedSentType = "PERSONAL";
                          }
                          if( newValue == _types[1]) {
                            _selectedSentType = "ORGANISATIONAL";
                          }
                          if( newValue == _types[2]) {
                            _selectedSentType = "Doctor";
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // CHAMP: Numéro de téléphone (Requis)
                    buildLabel('Numéro de téléphone'),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: _validateRequired,
                      decoration: buildInputDecoration(
                        hint: 'Votre numéro de téléphone',
                        icon: Icons.phone,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CHAMP: Email (Requis)
                    buildLabel('Email'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ce champ est requis';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                      decoration: buildInputDecoration(
                        hint: 'votre@email.com',
                        icon: Icons.mail,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CHAMP: Mot de passe (Requis)
                    buildLabel('Mot de passe'),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      obscuringCharacter: '•',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est requis';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                      decoration: buildInputDecoration(
                        hint: '••••••••',
                        icon: Icons.lock,
                      ).copyWith(
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // BOUTON: S'inscrire
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<RegisterBloc>().add(
                                    RegisterVendorSubmitted(
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                      fullname: _nomCommercialController.text.trim(),
                                      phoneNumber: _phoneController.text.trim(),
                                      vendorType: _selectedSentType ?? '',
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // LIEN: Déjà inscrit ?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà inscrit ? ',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}