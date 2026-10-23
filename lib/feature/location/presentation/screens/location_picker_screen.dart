import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../schedule/presentation/screens/schedule_screen.dart';
import '../../domain/entities/location_coordinate.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

import '../../../../core/services/caching_service.dart';
import '../../../../injection_container.dart' as di;

class LocationPickerScreen extends StatefulWidget {
  final bool isUpdating;
  final String? addressId;

  const LocationPickerScreen({
    super.key,
    this.isUpdating = false,
    this.addressId,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String? _effectiveAddressId;

  // Default initial position (Tunis)
  LatLng _currentCenterPosition = const LatLng(36.8065, 10.1815);

  @override
  void initState() {
    super.initState();
    _effectiveAddressId = widget.addressId;
    if (_effectiveAddressId == null || _effectiveAddressId!.isEmpty) {
      final caching = di.sl<CachingService>();
      _effectiveAddressId = caching.getString(addressIdKey);
    }
    final caching = di.sl<CachingService>();
    final savedStreet = caching.getString(addressStreetKey);
    if (savedStreet != null && savedStreet.isNotEmpty) {
      _searchController.text = savedStreet;
    }
    context.read<LocationBloc>().add(GetCurrentLocationEvent());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationLoaded) {
              final newPos = LatLng(
                state.coordinate.latitude,
                state.coordinate.longitude,
              );
              _currentCenterPosition = newPos;
              _mapController.move(newPos, 14.0);
              FocusScope.of(context).unfocus();
            } else if (state is LocationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else if (state is LocationSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isUpdating
                        ? 'Emplacement mis à jour avec succès !'
                        : 'Emplacement enregistré avec succès !',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              if (widget.isUpdating) {
                Navigator.pop(context, true);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => const ScheduleScreen(),
                  ),
                );
              }
            }
          },
          child: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentCenterPosition,
                      initialZoom: 14.0,
                      onTap: (tapPosition, point) =>
                          FocusScope.of(context).unfocus(),
                      onPositionChanged: (MapCamera position, bool hasGesture) {
                        _currentCenterPosition = position.center;
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.yourcompany.wino',
                      ),
                    ],
                  ),

                  // Center Pin
                  IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: Icon(
                        Icons.location_on,
                        size: 52,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  // Top Search Bar & Suggestions
                  Positioned(
                    top: 55,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Card(
                          elevation: 4,
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                if (widget.isUpdating)
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher votre ville...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (_debounce?.isActive ?? false) {
                                        _debounce!.cancel();
                                      }

                                      _debounce = Timer(
                                        const Duration(milliseconds: 500),
                                        () {
                                          context
                                              .read<LocationBloc>()
                                              .add(GetSuggestionsEvent(value));
                                        },
                                      );
                                    },
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        context
                                            .read<LocationBloc>()
                                            .add(SearchCityEvent(value));
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: theme.colorScheme.primary,
                                  ),
                                  onPressed: () {
                                    if (_searchController.text.isNotEmpty) {
                                      context.read<LocationBloc>().add(
                                            SearchCityEvent(
                                              _searchController.text,
                                            ),
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state is LocationSuggestionsLoaded &&
                            state.suggestions.isNotEmpty)
                          Card(
                            elevation: 4,
                            color: theme.colorScheme.surface,
                            margin: const EdgeInsets.only(top: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: state.suggestions.length,
                              itemBuilder: (context, index) {
                                final suggestion = state.suggestions[index];
                                return ListTile(
                                  leading: Icon(
                                    Icons.location_city,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  title: Text(
                                    suggestion.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  onTap: () {
                                    _searchController.text = suggestion.name;
                                    FocusScope.of(context).unfocus();
                                    context.read<LocationBloc>().add(
                                          SelectSuggestionEvent(suggestion),
                                        );
                                  },
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Loading Overlay
                  if (state is LocationLoading)
                    Container(
                      color: Colors.black.withValues(alpha: 0.25),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  // Floating Current Location Button
                  Positioned(
                    bottom: 110,
                    right: 20,
                    child: FloatingActionButton.small(
                      heroTag: 'current_location_fab',
                      backgroundColor: theme.colorScheme.surface,
                      foregroundColor: theme.colorScheme.primary,
                      onPressed: () {
                        context
                            .read<LocationBloc>()
                            .add(GetCurrentLocationEvent());
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ),

                  // Bottom Save & Continue Button
                  Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: state is LocationLoading
                            ? null
                            : () {
                                final coordinateToSave = LocationCoordinate(
                                  latitude: _currentCenterPosition.latitude,
                                  longitude: _currentCenterPosition.longitude,
                                );

                                final streetInput = _searchController.text.trim();

                                if (widget.isUpdating &&
                                    _effectiveAddressId != null &&
                                    _effectiveAddressId!.isNotEmpty) {
                                  context.read<LocationBloc>().add(
                                        UpdateLocationEvent(
                                          coordinateToSave,
                                          street: streetInput.isNotEmpty
                                              ? streetInput
                                              : null,
                                          addressId: _effectiveAddressId!,
                                        ),
                                      );
                                } else {
                                  context.read<LocationBloc>().add(
                                        SaveLocationEvent(
                                          coordinateToSave,
                                          street: streetInput.isNotEmpty ? streetInput : null,
                                        ),
                                      );
                                }
                              },
                        child: Text(
                          widget.isUpdating
                              ? 'Mettre à jour l\'adresse'
                              : 'Confirmer l\'emplacement',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
