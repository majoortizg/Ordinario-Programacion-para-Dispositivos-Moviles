class Recuerdo {
  late String Nombre, Descripcion, FotoPath;
  late double Latitud, Longitud;
  late int Id, Sincronizado;

  bool Favorito = false;
  DateTime? fechaRecuerdo;
  String? categoria;

  Recuerdo.init() {
    Id = 0;
    Nombre = "";
    Descripcion = "";
    FotoPath = "";
    Latitud = 0;
    Longitud = 0;
    Sincronizado = 0;
    Favorito = false;
    fechaRecuerdo = null;
    categoria = null;
  }

  Recuerdo({
    required this.Id,
    required this.Nombre,
    required this.Descripcion,
    required this.FotoPath,
    required this.Latitud,
    required this.Longitud,
    required this.Sincronizado,
    this.Favorito = false,
    this.fechaRecuerdo,
    this.categoria,
  });

  Recuerdo.fromJson(Map<String, dynamic> json) {
    Id = json['Id'] as int? ?? 0;
    Nombre = json['Nombre'] ?? '';
    Descripcion = json['Descripcion'] ?? '';
    FotoPath = json['FotoPath'] ?? '';
    Latitud = json['Latitud'] as double? ?? 0.0;
    Longitud = json['Longitud'] as double? ?? 0.0;
    if (json.containsKey('Sincronizado')) {
      Sincronizado = json['Sincronizado'] as int? ?? 0;
    } else {
      Sincronizado = 1;
    }
    Favorito = false;
    fechaRecuerdo = null;
    categoria = null;
  }

  Map<String, dynamic> toJson() => {
    'Id': Id,
    'Nombre': Nombre,
    'Descripcion': Descripcion,
    'FotoPath': FotoPath,
    'Latitud': Latitud,
    'Longitud': Longitud,
    'Sincronizado': Sincronizado,
  };
}
