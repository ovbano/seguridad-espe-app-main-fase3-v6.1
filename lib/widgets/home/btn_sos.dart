import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/blocs/notification/notification_bloc.dart';
import 'package:flutter_maps_adv/helpers/page_route.dart';
import 'package:flutter_maps_adv/screens/notification_screen.dart';
import 'package:flutter_maps_adv/screens/screens.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class BtnSOS extends StatelessWidget {
  const BtnSOS({super.key, Key});

  @override
  Widget build(BuildContext context) {
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final lat = locationBloc.state.lastKnownLocation!.latitude;
    final lng = locationBloc.state.lastKnownLocation!.longitude;
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? state.isActiveNotification
                ? _SOSNumber(
                    authBloc: BlocProvider.of<AuthBloc>(context),
                    lat: lat,
                    lng: lng,
                  )
                : const SizedBox()
            : const PositionedBtnSOS();
      },
    );
  }
}

class PositionedBtnSOS extends StatelessWidget {
  const PositionedBtnSOS({super.key, Key});
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final lat = locationBloc.state.lastKnownLocation!.latitude;
    final lng = locationBloc.state.lastKnownLocation!.longitude;
    return _SOSNotification(
      authBloc: authBloc,
      lat: lat,
      lng: lng,
    );
  }
}

class _SOSNotification extends StatefulWidget {
  const _SOSNotification({
    required this.authBloc,
    required this.lat,
    required this.lng,
  });

  final AuthBloc authBloc;
  final double lat;
  final double lng;

  @override
  State<_SOSNotification> createState() => _SOSNotificationState();
}

class _SOSNotificationState extends State<_SOSNotification> {
  bool isRequesting = false;
  DateTime lastRequestTime = DateTime.now();

  Future<void> _sendNotification(double lat, double lng) async {
    if (isRequesting) {
      return; // Si ya se está realizando una petición, no hacer nada.
    }

    if (DateTime.now().difference(lastRequestTime) <
        const Duration(seconds: 5)) {
      return; // Si el tiempo entre peticiones es menor a 5 segundos, no hacer nada.
    }

    setState(() {
      isRequesting = true;
      lastRequestTime = DateTime.now();
    });

    // Simular un proceso asíncrono, reemplaza esto con tu lógica real

    Fluttertoast.showToast(
      msg:
          "Se ha enviado una notificación a tus contactos\nFecha: ${DateFormat.yMd().format(DateTime.now())}\nHora: ${DateFormat.Hms().format(DateTime.now())}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromRGBO(219, 31, 31, 1),
      textColor: Colors.white,
      fontSize: 16.0,
    );

    await widget.authBloc.notificacion(widget.lat, widget.lng);

    setState(() {
      isRequesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigatorBloc = BlocProvider.of<NavigatorBloc>(context);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, stateauth) {
        return Positioned(
          top: MediaQuery.of(context).size.height * 0.04,
          left: MediaQuery.of(context).size.width *
              0.04, // Posición izquierda para la campana
          right: MediaQuery.of(context).size.width *
              0.04, // Posición derecha para el botón SOS
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Alinea los elementos al inicio y al final del row
            children: [
              GestureDetector(
                onTap: () {
                  notificationBloc.loadNotification();
                  widget.authBloc
                      .add(const MarcarNotificacionesPendienteFalse());
                  navigatorBloc.add(
                      const NavigatorIsNewSelectedEvent(isNewSelected: true));
                  Navigator.of(context).push(
                    CreateRoute.createRoute(const NotificationsScreen()),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.12,
                  height: MediaQuery.of(context).size.width * 0.12,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 21, 75, 175),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Stack(
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        color: Color.fromARGB(255, 255, 254, 254),
                        size: 45,
                      ),
                      Positioned(
                        top: 8,
                        right: 15,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: stateauth.usuario!.isNotificacionesPendiente
                                ? Colors.red
                                : Colors.transparent,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () async {
                  if (!widget.authBloc.hasTelefonos()) {
                    mostrarDialogoIngresarNumero(context);
                    return;
                  }

                  if (!isRequesting) {
                    await _sendNotification(widget.lat, widget.lng);
                  }
                },
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(206, 37, 37, 1),
                        Color.fromRGBO(192, 54, 54, 0.882),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 255, 0, 0)
                            .withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.3 / 2,
                    ),
                    onTap: () async {
                      if (!widget.authBloc.hasTelefonos()) {
                        mostrarDialogoIngresarNumero(context);
                        return;
                      }

                      if (!isRequesting) {
                        await _sendNotification(widget.lat, widget.lng);
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: MediaQuery.of(context).size.width * 0.25,
                      alignment: Alignment.center,
                      child: Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void mostrarDialogoIngresarNumero(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Números de teléfono no encontrados',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1F5545),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Antes de utilizar la función SOS, asegúrate de ingresar al menos un número de teléfono de algún familiar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navegar a la pantalla de agregar números de teléfono
                  Navigator.pushNamed(
                      context, InformationFamily.informationFamily);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F5545),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'Ingresar número',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  color: Color(0xFF1F5545),
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _SOSNumber extends StatelessWidget {
  const _SOSNumber({
    required this.authBloc,
    required this.lat,
    required this.lng,
  });

  final AuthBloc authBloc;
  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.05,
      right: 5.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
          onPressed: () {},
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 30, 29, 29), // Gris más fuerte
                  Color.fromARGB(
                      255, 67, 67, 67), // Gris más fuerte (más transparente)
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF616161)
                      .withOpacity(0.5), // Gris más fuerte (más transparente)
                  spreadRadius: 9,
                  blurRadius: 5,
                  // offset: Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.3 / 2,
              ),
              onTap: () async {
                final Uri smsLaunchUri = Uri(
                  scheme: 'tel',
                  path: '911',
                );

                await canLaunchUrl(smsLaunchUri)
                    ? launchUrl(smsLaunchUri)
                    : throw 'Could not launch $smsLaunchUri';
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.20,
                height: MediaQuery.of(context).size.width * 0.25,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LLAMAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '911',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        //texto en el centro del boton
                      ),
                      //texto en el centro del boton
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
