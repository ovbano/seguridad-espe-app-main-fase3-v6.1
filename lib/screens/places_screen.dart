// ignore_for_file: unused_local_variable, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/blocs/notification/notification_bloc.dart';
import 'package:flutter_maps_adv/delegates/search_destination_delegate.dart';
import 'package:flutter_maps_adv/models/search_result.dart';
import 'package:flutter_maps_adv/screens/gps_access_screen.dart';
import 'package:flutter_maps_adv/screens/home_screen.dart';
import 'package:flutter_maps_adv/screens/loading_map_screen.dart';
import 'package:flutter_maps_adv/screens/map_screen.dart';
import 'package:flutter_maps_adv/screens/place_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlacesScreen extends StatelessWidget {
  static const String salesroute = 'lugares';
  const PlacesScreen({super.key, Key});

  @override
  Widget build(BuildContext context) {
    final publicationBloc = BlocProvider.of<PublicationBloc>(context);

    void onSearchResults(BuildContext context, SearchResult result) {
      final searchBloc = BlocProvider.of<SearchBloc>(context);

      if (result.manual == true) {
        searchBloc.add(OnActivateManualMarkerEvent());
        return;
      }
    }

    final navigatorBloc = BlocProvider.of<NavigatorBloc>(context);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
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
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: false,
              title: const Text(
                'Mis Direcciones',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    notificationBloc.loadNotification();
                    navigatorBloc.add(const NavigatorIndexEvent(
                        index: 0)); 
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                        
                      ),
                      
                    );
                  },
                  child: const Text(
                    'Ver Mapa',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5, // Ajuste de tamaño
                        child: SvgPicture.asset(
                          "assets/lugares2.svg",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Agrega direcciones para mantenerte informado de lo que sucede alrededor de tu comunidad y recibir alertas de emergencia.",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        final result = await showSearch(
                            context: context,
                            delegate: SearchDestinationDelegate());
                        if (result == null) return;
                        onSearchResults(context, result);
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 20),
                        color: Colors.white,
                        height: 50,
                        child: const Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.plus,
                                    color: Color.fromARGB(255, 13, 168, 99),
                                    size: 20,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    'Agregar dirección',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 13, 168, 99),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return state.ubicaciones.isEmpty
                            ? Container(
                                margin: const EdgeInsets.only(top: 20),
                                child: const Text(
                                  "No tienes direcciones agregadas",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  const Divider(
                                    color: Colors.black12,
                                    thickness: 1,
                                  ),
                                  ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: state.ubicaciones.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: const Icon(Icons.place,
                                            color: Color.fromRGBO(2, 79, 49, 1)),
                                        title: Text(state.ubicaciones[index].barrio),
                                        subtitle: Text(
                                            '${state.ubicaciones[index].ciudad}, ${state.ubicaciones[index].referencia ?? ''} ${state.ubicaciones[index].pais}'),
                                        trailing: const Icon(Icons.arrow_forward_ios),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, PlaceDetailScreen.place,
                                              arguments: {
                                                'ubicacion': state.ubicaciones[index],
                                                'isDelete': true
                                              });
                                        },
                                      );
                                    },
                                  ),
                                  const Divider(
                                    color: Colors.black12,
                                    thickness: 1,
                                  ),
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
