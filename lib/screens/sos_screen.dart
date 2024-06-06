import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/helpers/show_loading_message.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SosScreen extends StatelessWidget {
  static const String sosroute = 'sos';
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //recupera el argumentos
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String nombre = args['nombre'];
    final String img = args['img'] ?? '';
    final bool google = args['google'] == true ? true : false;
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final counterBloc = BlocProvider.of<NavigatorBloc>(context);
    LatLng? end;
    // const String number = '911';

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black87),
          centerTitle: false,
          title: const Text('SOS',
              style: TextStyle(color: Colors.black, fontSize: 20)),
          elevation: 0.5,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            //spacebetween
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Center(
                    child: SvgPicture.asset(
                      "assets/info/advertencia.svg",
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.30,
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  google == true
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(img),
                        )
                      : const SizedBox(),
                  Text(
                    nombre,
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
                height: 20,
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
                        end = LatLng(args['latitud'], args['longitud']);
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
                        counterBloc.add(const NavigatorIndexEvent(index: 0));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
