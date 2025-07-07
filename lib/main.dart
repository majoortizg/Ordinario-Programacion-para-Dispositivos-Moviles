
import 'package:camera/camera.dart';
import 'package:recuerdos_ordinario3/recuerdo_dba.dart';
import 'package:recuerdos_ordinario3/file_mgr.dart';
import 'package:recuerdos_ordinario3/sync.dart';
import 'package:recuerdos_ordinario3/take_photo.dart';
import 'package:flutter/material.dart';
import 'package:recuerdos_ordinario3/sync.dart';
import 'dart:convert';

import 'recuerdo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recuerdos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: 'Mis Recuerdos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RecuerdoDA _recuerdoDA = RecuerdoDA();

  List<Recuerdo> _recuerdos = [];
  String data = "";

  @override
  void initState() {
    super.initState();
    _readData();
  }

  Future<void> _readData() async {
    print('Leyendo datos');
    _recuerdos = await _recuerdoDA.getAllItems();
    setState(() {});
  }

  List<Widget> _buildGrid() {
    List<Widget> ls = [];
    Widget w;

    for (Recuerdo r in _recuerdos) {
      w = Card(
        color: Colors.blueGrey.shade50,
        elevation: 8,
        margin: const EdgeInsets.all(6.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PreviewPhoto(r)),
            ).then((value) async {
              if (value != null) {
                r = value;
                if (r.Sincronizado == 1) {
                  r.Sincronizado = 2;
                }
                await _recuerdoDA.update(r);
                setState(() {});
              }
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen/Foto
              r.FotoPath.isNotEmpty
                  ? Container(
                height: 120,
                width: double.infinity,
                child: Image.asset(
                  r.FotoPath,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 120,
                width: double.infinity,
                color: Colors.blueGrey.shade50,
                child: const Icon(Icons.image, size: 40),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                child: Text(
                  r.Nombre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  r.Descripcion,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Latitud y Longitud (puedes ponerlo donde prefieras)
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0),
                child: Text(
                  "Latitud: ${r.Latitud}, Longitud: ${r.Longitud}",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () async {
                      SincRecuerdos s = SincRecuerdos();
                      await s.delete(r.Id);
                      await _recuerdoDA.deleteDog(r.Id);
                      setState(() {
                        _recuerdos.remove(r);
                      });
                    },
                    icon: const Icon(Icons.delete, size: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        r.Favorito = !r.Favorito;
                      });
                    },
                    icon: Icon(
                      Icons.favorite,
                      size: 18,
                      color: r.Favorito ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      ls.add(w);
    }
    return ls;
  }


  Widget _showPage() {
    if (_recuerdos.length > 0) {
      return ListView(children: _buildGrid());
    } else {
      return Center(child: Text(this.data));
    }
  }

  Future<void> _saveRecuerdos() async {
    String data = "";
    for (Recuerdo r in _recuerdos) {
      if (data.length > 0) data += ",";
      data += jsonEncode(r.toJson());
    }
    data = "[ " + data + "]";
    print(data);
  }

  /*Future<void> _uploadRecuerdos() async {
    SincRecuerdos s = SincRecuerdos();
    for (Recuerdo r in _recuerdos) {
      if (r.Sincronizado == 0) {
        try {
          r = await s.insert(r);
          await _recuerdoDA.update(r);
        } catch (ex) {
          print("ERROR: ${ex.toString()} para ${r.toJson()}");
        }
      } else if (r.Sincronizado == 2) {
        try {
          r = await s.update(r);
          r.Sincronizado = 1;
          await _recuerdoDA.update(r);
        } catch (ex) {
          print("ERROR: ${ex.toString()} para ${r.toJson()}");
        }
      }
    }
  }*/

  Future<void> _uploadRecuerdos() async {
    SincRecuerdos s = SincRecuerdos();

    List<Recuerdo> noSincronizados = _recuerdos.where((r) => r.Sincronizado == 0 || r.Sincronizado == 2).toList();

    for (Recuerdo r in noSincronizados) {
      try {
        if (r.Sincronizado == 0) {
          Recuerdo actualizado = await s.insert(r);
          await _recuerdoDA.update(actualizado);
        } else if (r.Sincronizado == 2) {
          Recuerdo actualizado = await s.update(r);
          await _recuerdoDA.update(actualizado);
        }
      } catch (ex) {
        debugPrint("ERROR subiendo recuerdo ID=${r.Id}: ${ex.toString()}");
      }
    }
  }

  Future<void> _downloadRecuerdos() async {
    _recuerdos = [];
    SincRecuerdos s = SincRecuerdos();
    Map<String, dynamic> ls = await s.getAll();
    List<dynamic> raiz = ls["Recuerdos"];
    for (var p in raiz) {
      _recuerdos.add(Recuerdo.fromJson(p));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _saveRecuerdos();
              });
            },
            icon: Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _uploadRecuerdos();
              });
            },
            icon: Icon(Icons.upload),
          ),
          IconButton(
              onPressed: () async {
                await _downloadRecuerdos();
                setState(() {});
              },
              icon: Icon(Icons.download_for_offline)),
        ],
      ),
      body: Center(child: _showPage()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Recuerdo r = Recuerdo.init();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PreviewPhoto(r)),
          ).then((value) async {
            if (value != null) {
              await _recuerdoDA.insert(value);
              setState(() {
                _recuerdos.add(value);
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}