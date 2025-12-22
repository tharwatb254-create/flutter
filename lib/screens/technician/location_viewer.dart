import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationViewerScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;

  const LocationViewerScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<LocationViewerScreen> createState() => _LocationViewerScreenState();
}

class _LocationViewerScreenState extends State<LocationViewerScreen> {
  GoogleMapController? _mapController;
  late LatLng _location;
  late Set<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _location = LatLng(widget.latitude, widget.longitude);
    _markers = {
      Marker(
        markerId: const MarkerId('client_location'),
        position: _location,
        infoWindow: InfoWindow(
          title: 'موقع العميل',
          snippet: widget.address,
        ),
      ),
    };
  }

  Future<void> _openInGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح خرائط جوجل')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موقع العميل'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _location,
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
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
                        'عنوان العميل',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.address,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: const Icon(Icons.navigation),
                      label: Text(
                        'فتح في خرائط جوجل',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
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
