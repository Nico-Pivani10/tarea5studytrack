import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsScreen extends StatefulWidget {
  const GpsScreen({super.key});

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

class _GpsScreenState extends State<GpsScreen> {
  static const Color bordo = Color(0xFF670310);
  static const Color negro = Color(0xFF000000);
  static const Color blanco = Color(0xFFFFFFFF);

  bool permitirUbicacion = true;
  bool detectarProximidad = true;
  bool buscandoUbicacion = false;

  Position? posicionActual;

  String estadoGps = 'SIN COMPROBAR';
  String precisionGps = '--';

  // ============================================================
  // UBICACIONES DEL IFSUL
  // ============================================================

  final List<Map<String, dynamic>> ubicaciones = [
    {
      'nombre': 'Campus Principal',
      'latitud': -30.9008403,
      'longitud': -55.5354775,
    },
    {
      'nombre': 'Biblioteca Central',
      'latitud': -30.9007600,
      'longitud': -55.5353900,
    },
    {
      'nombre': 'Laboratorio de Informática',
      'latitud': -30.9009200,
      'longitud': -55.5355600,
    },
  ];

  // ============================================================
  // OBTENER UBICACIÓN REAL
  // ============================================================

  Future<void> obtenerUbicacion() async {
    if (!permitirUbicacion) {
      mostrarMensaje(
        'Activa "Permitir geolocalización" para utilizar el GPS.',
      );

      return;
    }

    setState(() {
      buscandoUbicacion = true;
      estadoGps = 'BUSCANDO...';
    });

    try {
      final servicioActivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        setState(() {
          buscandoUbicacion = false;
          estadoGps = 'GPS DESACTIVADO';
          precisionGps = '--';
        });

        mostrarMensaje(
          'Activa el servicio de ubicación del dispositivo.',
        );

        return;
      }

      LocationPermission permiso =
          await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        setState(() {
          buscandoUbicacion = false;
          estadoGps = 'PERMISO DENEGADO';
          precisionGps = '--';
        });

        mostrarMensaje(
          'El permiso de ubicación fue denegado.',
        );

        return;
      }

      if (permiso == LocationPermission.deniedForever) {
        setState(() {
          buscandoUbicacion = false;
          estadoGps = 'PERMISO BLOQUEADO';
          precisionGps = '--';
        });

        mostrarMensaje(
          'El permiso de ubicación está bloqueado.',
        );

        return;
      }

      final Position posicion =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        posicionActual = posicion;
        buscandoUbicacion = false;
        estadoGps = 'ACTIVO';

        precisionGps =
            '${posicion.accuracy.toStringAsFixed(1)} m';
      });

      mostrarMensaje(
        'Posición actualizada correctamente.',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        buscandoUbicacion = false;
        estadoGps = 'ERROR';
        precisionGps = '--';
      });

      mostrarMensaje(
        'No fue posible obtener la ubicación.',
      );
    }
  }

  // ============================================================
  // CALCULAR DISTANCIA
  // ============================================================

  double calcularDistancia(
    double latitudDestino,
    double longitudDestino,
  ) {
    if (posicionActual == null) {
      return -1;
    }

    return Geolocator.distanceBetween(
      posicionActual!.latitude,
      posicionActual!.longitude,
      latitudDestino,
      longitudDestino,
    );
  }

  // ============================================================
  // DEFINIR RANGO
  // ============================================================

  bool estaEnRango(double distancia) {
    return distancia >= 0 && distancia <= 200;
  }

  // ============================================================
  // FORMATEAR DISTANCIA
  // ============================================================

  String formatearDistancia(double distancia) {
    if (distancia < 0) {
      return 'Actualiza tu posición';
    }

    if (distancia < 1000) {
      return '${distancia.toStringAsFixed(0)} m de tu posición';
    }

    return '${(distancia / 1000).toStringAsFixed(2)} km de tu posición';
  }

  // ============================================================
  // MENSAJES
  // ============================================================

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // COLOR ESTADO GPS
  // ============================================================

  Color get colorEstadoGps {
    switch (estadoGps) {
      case 'ACTIVO':
        return Colors.green;

      case 'BUSCANDO...':
        return Colors.orange;

      case 'GPS DESACTIVADO':
      case 'PERMISO DENEGADO':
      case 'PERMISO BLOQUEADO':
      case 'ERROR':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: bordo,
        foregroundColor: blanco,
        elevation: 0,

        title: const Text(
          'Ubicación y GPS',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 900,
              ),

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,

                  children: [
                    // ==========================================
                    // BANNER GPS
                    // ==========================================

                    Container(
                      height: 130,

                      decoration: BoxDecoration(
                        color: const Color(0xFF101923),

                        borderRadius:
                            BorderRadius.circular(14),
                      ),

                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.blueAccent,
                            size: 65,
                          ),

                          SizedBox(height: 5),

                          Text(
                            'GPS LOCATION',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==========================================
                    // TÍTULO
                    // ==========================================

                    const Text(
                      'Servicios de Ubicación',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: bordo,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Activa el GPS para detectar tu cercanía a las '
                      'instituciones y registrar tu asistencia automáticamente.',

                      textAlign: TextAlign.center,

                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ==========================================
                    // PERMISOS
                    // ==========================================

                    const Text(
                      '⚙ CONFIGURACIÓN DE PERMISOS',

                      style: TextStyle(
                        color: bordo,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      decoration: BoxDecoration(
                        color: blanco,

                        borderRadius:
                            BorderRadius.circular(14),

                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),

                      child: Column(
                        children: [
                          SwitchListTile(
                            activeThumbColor: bordo,

                            title: const Text(
                              'Permitir geolocalización',

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            subtitle: const Text(
                              'Permite que StudyTrack acceda a tu ubicación.',
                            ),

                            value: permitirUbicacion,

                            onChanged: (value) {
                              setState(() {
                                permitirUbicacion =
                                    value;

                                if (!value) {
                                  posicionActual = null;

                                  estadoGps =
                                      'DESACTIVADO';

                                  precisionGps = '--';
                                }
                              });
                            },
                          ),

                          const Divider(height: 1),

                          SwitchListTile(
                            activeThumbColor: bordo,

                            title: const Text(
                              'Detección de proximidad',

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            subtitle: const Text(
                              'Detecta automáticamente cuando estás cerca '
                              'de una institución.',
                            ),

                            value:
                                detectarProximidad,

                            onChanged: (value) {
                              setState(() {
                                detectarProximidad =
                                    value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // ESTADO GPS
                    // ==========================================

                    Container(
                      padding:
                          const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: blanco,

                        borderRadius:
                            BorderRadius.circular(14),

                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons.gps_fixed,
                            color: bordo,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                const Text(
                                  'Estado del GPS',

                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                Text(
                                  estadoGps,

                                  style: TextStyle(
                                    color:
                                        colorEstadoGps,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,

                            children: [
                              const Text(
                                'Precisión',

                                style: TextStyle(
                                  color:
                                      Colors.black54,
                                ),
                              ),

                              Text(
                                precisionGps,

                                style:
                                    const TextStyle(
                                  color: bordo,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ==========================================
                    // POSICIÓN ACTUAL
                    // ==========================================

                    if (posicionActual != null) ...[
                      const SizedBox(height: 12),

                      Container(
                        padding:
                            const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: blanco,

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),

                          border: Border.all(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.my_location,
                                  color: bordo,
                                ),

                                SizedBox(width: 8),

                                Text(
                                  'Tu posición actual',

                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              'Latitud: '
                              '${posicionActual!.latitude.toStringAsFixed(6)}',
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            Text(
                              'Longitud: '
                              '${posicionActual!.longitude.toStringAsFixed(6)}',
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),

                    // ==========================================
                    // UBICACIONES
                    // ==========================================

                    const Text(
                      'UBICACIONES RECIENTES',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...ubicaciones.map((lugar) {
                      final double distancia =
                          calcularDistancia(
                        lugar['latitud'],
                        lugar['longitud'],
                      );

                      final bool enRango =
                          estaEnRango(distancia);

                      String estado;

                      Color color;

                      if (distancia < 0) {
                        estado = 'SIN DATOS';
                        color = Colors.grey;
                      } else if (!detectarProximidad) {
                        estado = 'DESACTIVADO';
                        color = Colors.grey;
                      } else if (enRango) {
                        estado = 'EN RANGO';
                        color = Colors.green;
                      } else {
                        estado =
                            'FUERA DE RANGO';

                        color = Colors.orange;
                      }

                      return tarjetaUbicacion(
                        lugar['nombre'],
                        formatearDistancia(
                          distancia,
                        ),
                        estado,
                        color,
                      );
                    }),

                    const SizedBox(height: 20),

                    // ==========================================
                    // BOTÓN
                    // ==========================================

                    SizedBox(
                      height: 50,

                      child: ElevatedButton.icon(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor: bordo,
                          foregroundColor: blanco,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        onPressed:
                            buscandoUbicacion
                                ? null
                                : obtenerUbicacion,

                        icon: buscandoUbicacion
                            ? const SizedBox(
                                width: 20,
                                height: 20,

                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.navigation,
                              ),

                        label: Text(
                          buscandoUbicacion
                              ? 'OBTENIENDO POSICIÓN...'
                              : 'ACTUALIZAR POSICIÓN',

                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons
                              .check_circle_outline,

                          color: Colors.green,

                          size: 17,
                        ),

                        SizedBox(width: 5),

                        Flexible(
                          child: Text(
                            'CONEXIÓN SEGURA DE NETWORK A STUDYTRACK',

                            textAlign:
                                TextAlign.center,

                            style: TextStyle(
                              fontSize: 10,

                              color:
                                  Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // ========================================================
      // MENU INFERIOR
      // ========================================================

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,

        selectedItemColor: bordo,

        unselectedItemColor: negro,

        currentIndex: 0,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            label: 'Inicio',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.menu_book_outlined,
            ),
            label: 'Materias',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_box_outlined,
            ),
            label: 'Tareas',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month_outlined,
            ),
            label: 'Calendario',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA UBICACIÓN
  // ============================================================

  Widget tarjetaUbicacion(
    String nombre,
    String distancia,
    String estado,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),

      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: blanco,

        borderRadius:
            BorderRadius.circular(10),

        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: bordo,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  nombre,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  distancia,

                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius:
                  BorderRadius.circular(20),
            ),

            child: Text(
              estado,

              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}