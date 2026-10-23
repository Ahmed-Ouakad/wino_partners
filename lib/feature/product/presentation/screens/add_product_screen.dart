import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/add_product_bloc.dart';
import '../bloc/add_product_event.dart';
import '../bloc/add_product_state.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  final FocusNode _subCategoryFocusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    context.read<AddProductBloc>().add(const LoadSubCategoriesEvent());

    _subCategoryFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _subCategoryFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _subCategoryController.dispose();
    _descriptionController.dispose();
    _subCategoryFocusNode.dispose();
    super.dispose();
  }

  void _showImageSourceModal(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sélectionner une photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Prendre une photo (Appareil photo)'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    context.read<AddProductBloc>().add(const PickImageEvent(ImageSource.camera));
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library_outlined, color: theme.colorScheme.secondary),
                  ),
                  title: const Text('Choisir depuis la galerie'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    context.read<AddProductBloc>().add(const PickImageEvent(ImageSource.gallery));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nouveau Produit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: BlocConsumer<AddProductBloc, AddProductState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state.isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produit ajouté avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _showSuggestions = false;
              });
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Picker Section
                  _buildImagePicker(theme, state),

                  const SizedBox(height: 24),

                  // 2. Sub-Category Input with dynamic suggestions
                  _buildSubCategoryInput(theme, isDark, state),

                  const SizedBox(height: 20),

                  // 3. Product Title
                  _buildTextField(
                    label: 'Titre du produit',
                    controller: _titleController,
                    hint: 'ex: Boisson gazeuse 1.5L',
                    icon: Icons.label_outline_rounded,
                    theme: theme,
                  ),

                  const SizedBox(height: 20),

                  // 4. Price Field
                  _buildTextField(
                    label: 'Prix (DT)',
                    controller: _priceController,
                    hint: 'ex: 2.750',
                    icon: Icons.monetization_on_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    theme: theme,
                  ),

                  const SizedBox(height: 20),

                  // 5. Description Field
                  _buildTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    hint: 'Détails, ingrédients ou informations utiles...',
                    icon: Icons.description_outlined,
                    maxLines: 4,
                    theme: theme,
                  ),

                  const SizedBox(height: 36),

                  // 6. Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              context.read<AddProductBloc>().add(
                                    SubmitProductEvent(
                                      title: _titleController.text,
                                      price: _priceController.text,
                                      subCategoryInput: _subCategoryController.text,
                                      description: _descriptionController.text,
                                    ),
                                  );
                            },
                      child: state.isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  state.submissionStatus ?? 'Enregistrement...',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Ajouter le produit',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker(ThemeData theme, AddProductState state) {
    if (state.pickedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              state.pickedImage!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: () => context.read<AddProductBloc>().add(const RemoveImageEvent()),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: InkWell(
              onTap: () => _showImageSourceModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Modifier',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: () => _showImageSourceModal(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ajouter une photo du produit',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Format JPG, PNG ou WebP',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryInput(ThemeData theme, bool isDark, AddProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Catégorie / Rayon',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (state.isLoadingCategories)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _subCategoryController,
          focusNode: _subCategoryFocusNode,
          onChanged: (value) {
            context.read<AddProductBloc>().add(SubCategoryInputChangedEvent(value));
            setState(() {
              _showSuggestions = true;
            });
          },
          decoration: InputDecoration(
            hintText: 'ex: Boissons & Épicerie',
            prefixIcon: Icon(Icons.category_outlined, color: theme.colorScheme.primary),
            suffixIcon: _subCategoryController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _subCategoryController.clear();
                      context.read<AddProductBloc>().add(const SubCategoryInputChangedEvent(''));
                    },
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),

        // Suggestions Dropdown
        if (_showSuggestions && state.filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.filteredSuggestions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final suggestion = state.filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(
                    suggestion.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  trailing: const Icon(Icons.north_west, size: 14, color: Colors.grey),
                  onTap: () {
                    _subCategoryController.text = suggestion.title;
                    context.read<AddProductBloc>().add(SelectSubCategoryEvent(suggestion));
                    _subCategoryFocusNode.unfocus();
                    setState(() {
                      _showSuggestions = false;
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: maxLines > 1 ? 48.0 : 0),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            filled: true,
            fillColor: isDark ? Colors.white10 : Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
