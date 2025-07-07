import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'recuerdo.dart';

class PreviewPhoto extends StatefulWidget {
  Recuerdo _recuerdo;

  PreviewPhoto(this._recuerdo, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _PreviewPhotoState(_recuerdo);
  }
}

class _PreviewPhotoState extends State<PreviewPhoto> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  Uint8List? imageBytes;
  XFile? file;
  Recuerdo _recuerdo;

  Future<void> _listCamaras() async {
    await availableCameras().then((cameras) {
      _cameras = cameras;
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      _controller?.initialize().then((_) {
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initUbicacion();
    _listCamaras();
  }

  void _initUbicacion() async {
    try {
      Position position = await _getCurrentPosition();
      setState(() {
        _recuerdo.Latitud = position.latitude;
        _recuerdo.Longitud = position.longitude;
      });
    } catch (e) {
      print("No se pudo obtener la ubicación: $e");
    }
  }

  _PreviewPhotoState(this._recuerdo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              initialValue: _recuerdo.Nombre,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Titulo',
              ),
              onChanged: (value) {
                _recuerdo.Nombre = value;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _recuerdo.Descripcion,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Descripcion',
              ),
              onChanged: (value) {
                _recuerdo.Descripcion = value;
              },
            ),
            const SizedBox(height: 16),
            viewUI(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Fecha del Recuerdo'),
              subtitle: Text(_recuerdo.fechaRecuerdo == null
                  ? 'No seleccionada'
                  : "${_recuerdo.fechaRecuerdo!.day}/${_recuerdo.fechaRecuerdo!.month}/${_recuerdo.fechaRecuerdo!.year}"),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _recuerdo.fechaRecuerdo ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _recuerdo.fechaRecuerdo = picked);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Ubicación GPS'),
              subtitle: Text('Latitud: ${_recuerdo.Latitud}, Longitud: ${_recuerdo.Longitud}'),
            ),
            CheckboxListTile(
              value: _recuerdo.Favorito,
              title: const Text('Favorito'),
              onChanged: (v) => setState(() => _recuerdo.Favorito = v ?? false),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: _recuerdo.categoria,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Categoría',
              ),
              onChanged: (v) => setState(() => _recuerdo.categoria = v!),
              items: [
                "En Pareja",
                "Solo",
                "Amigos",
                "Familia",
                "Viajes",
                "Sin especificar"
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Position position = await _getCurrentPosition();
          _recuerdo.Latitud = position.latitude;
          _recuerdo.Longitud = position.longitude;
          Navigator.pop(context, _recuerdo);
          await _controller?.initialize();
        },
        child: Icon(Icons.save),
      ),
    );
  }

  Future<Position> _getCurrentPosition() async {
    bool locationServiceEnabled;
    LocationPermission permission;

    locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationServiceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Widget viewUI() {
    if (_controller == null) {
      return CircularProgressIndicator();
    } else if (imageBytes == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 100, height: 100, child: CameraPreview(_controller!)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  file = await _controller?.takePicture();
                  imageBytes = await file?.readAsBytes();
                  _recuerdo.FotoPath = file!.path;
                  setState(() {});
                },
                icon: Icon(Icons.camera_alt),
              ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: imageBytes == null
                ? Icon(Icons.photo)
                : Image.memory(imageBytes!),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              imageBytes = null;
              file = null;
              _recuerdo.FotoPath = "";
              await _controller?.initialize();
              setState(() {});
            },
          ),
        ],
      );
    }
  }
}
