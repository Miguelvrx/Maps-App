import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class UbicacionView extends StatefulWidget {
  @override
  _UbicacionViewState createState() => _UbicacionViewState();
}

class _UbicacionViewState extends State<UbicacionView> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  List<LatLng> _universidadesCercanas = []; // Lista de universidades cercanas

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
          _errorMessage = 'Los servicios de ubicación están deshabilitados. Habilítalos desde la configuración del dispositivo.';
          _isLoading = false;
        });
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Permisos de ubicación denegados';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Permisos de ubicación denegados permanentemente';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      // Aquí puedes llamar a la función que obtiene las universidades cercanas
      await _getUniversidadesCercanas();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener la ubicación: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getUniversidadesCercanas() async {
    // Aquí simulas una lista de universidades cercanas
    // Esta lista se debería poblar con la respuesta de tu API de universidades cercanas
    setState(() {
      _universidadesCercanas = [
        LatLng(_currentPosition!.latitude + 0.01, _currentPosition!.longitude + 0.01),
        LatLng(_currentPosition!.latitude - 0.01, _currentPosition!.longitude - 0.01),
        // Agrega más ubicaciones según las universidades cercanas obtenidas de tu API
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Ubicación Actual'),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Obteniendo ubicación...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      SizedBox(height: 20),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: Text('Reintentar'),
                      )
                    ],
                  ),
                )
              : _currentPosition == null
                  ? Center(child: Text('No se pudo obtener la ubicación'))
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: _currentPosition!,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition!,
                              width: 80.0,
                              height: 80.0,
                              child: Icon(
                                Icons.my_location,
                                color: Colors.blue,
                                size: 40.0,
                              ),
                            ),
                            // Agrega un marcador para cada universidad cercana
                            ..._universidadesCercanas.map(
                              (posicion) => Marker(
                                point: posicion,
                                width: 80.0,
                                height: 80.0,
                                child: Icon(
                                  Icons.school,
                                  color: Colors.red,
                                  size: 40.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
    );
  }
}
