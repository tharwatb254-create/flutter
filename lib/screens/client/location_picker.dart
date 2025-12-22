import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(30.0444, 31.2357); // Cairo default
  bool _isLoading = true;
  String _selectedAddress = 'جاري تحديد الموقع...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _selectedAddress = 'القاهرة، مصر';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _selectedAddress = 'القاهرة، مصر';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _selectedAddress = 'القاهرة، مصر';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
        _selectedAddress = 'الموقع الحالي';
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLoading = false;
        _selectedAddress = 'القاهرة، مصر';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _currentPosition = position.target;
  }

  void _onCameraIdle() {
    // In a real app, you would use Geocoding API here to get the address
    // from coordinates. For now, we'll use a simple format
    setState(() {
      _selectedAddress = 
          'الموقع: ${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}';
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'latitude': _currentPosition.latitude,
      'longitude': _currentPosition.longitude,
      'address': _selectedAddress,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حدد الموقع'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'جاري تحديد موقعك...',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 15.0,
                  ),
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  mapToolbarEnabled: false,
                ),

                // Center Marker
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_pin,
                        size: 50,
                        color: Colors.red,
                      ),
                      Container(
                        height: 2,
                        width: 2,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Address Card at Bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'الموقع المحدد',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedAddress,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _confirmLocation,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'تأكيد الموقع',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Instructions at Top
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'حرك الخريطة لاختيار الموقع المطلوب',
                            style: GoogleFonts.cairo(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
