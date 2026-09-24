import 'package:flutter/material.dart';
import 'package:wino_partners/feature/auth/presentation/screens/login_screen.dart';

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

  // Fonction de validation commune
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
        child: SingleChildScrollView(
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

                buildLabel('Type'),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  validator: (value) => value == null ? 'Veuillez sélectionner un type' : null,
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
                    });
                  },
                ),
                const SizedBox(height: 20),

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

                // CHAMP: Email
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

                // CHAMP: Mot de passe
                buildLabel('Mot de passe'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
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
                    suffixIcon: Icon(
                      Icons.visibility_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Traiter l'inscription
                        print('Nom: ${_nomCommercialController.text}');
                        print('Type: $_selectedType');
                        print('Téléphone: ${_phoneController.text}');
                        print('Email: ${_emailController.text}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
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
        ),
      ),
    );
  }
}