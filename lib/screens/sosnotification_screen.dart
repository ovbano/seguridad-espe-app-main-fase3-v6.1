// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/helpers/show_loading_message.dart';
import 'package:flutter_maps_adv/models/notification.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SosNotificationScreen extends StatelessWidget {
  static const String sosroute = 'sos_notification';
  const SosNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //recupera el argumentos
    final args = ModalRoute.of(context)!.settings.arguments as Notificacione;

    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final counterBloc = BlocProvider.of<NavigatorBloc>(context);
    LatLng? end;
    // const String number = '911';


    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), // Ajusta la altura del AppBar
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(106, 162, 142, 1),
                Color.fromRGBO(2, 79, 49, 1),
              ],
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Color.fromARGB(221, 255, 255, 255)),
            centerTitle: false,
            title: const Text(
              'SOS',
              style: TextStyle(color: Color.fromARGB(221, 255, 255, 255), fontSize: 20),
            ),
            elevation: 0.5,
            backgroundColor: Colors.transparent, // Establece el fondo del AppBar como transparente
          ),
        ),
      ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            //spacebetween
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                children: [],
              ),
              Column(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      "assets/info/advertencia.svg",
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.30,
                      color: const Color.fromRGBO(2, 79, 49, 1),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  args.usuarioRemitente.google == true
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(args.usuarioRemitente.img!),
                        )
                      : const SizedBox(),
                  Text(
                    args.usuarioRemitente.nombre,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    '¡Urgente! Contacto necesita ayuda',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      //centerText

                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        searchBloc.add(const IsActiveNotification(true));
                        final start = locationBloc.state.lastKnownLocation;
                        if (start == null) return;
                        end = LatLng(args.latitud, args.longitud);
                        if (end == null) return;
                        searchBloc.add(OnActivateManualMarkerEvent());
                        showLoadingMessage(context);
                        final destination =
                            await searchBloc.getCoorsStartToEnd(start, end!);
                        await mapBloc.drawRoutePolyline(destination);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        counterBloc.add(const NavigatorIndexEvent(index: 0));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(2, 79, 49, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.mapLocation,
                            color: Colors.white,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Ver mapa',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ));
  }
}
