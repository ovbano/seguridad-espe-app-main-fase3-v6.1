import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/blocs/notification/notification_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = 'notifications_screen';
  static const String sos = 'sos';
  static const String mensaje = 'mensaje';
  const NotificationsScreen({super.key, Key});

  @override
  Widget build(BuildContext context) {
    final publicationBloc =
        BlocProvider.of<PublicationBloc>(context, listen: false);
    final notificationBloc = BlocProvider.of<NotificationBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: false,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255), fontSize: 20),
        ),
        elevation: 0.5,
        actions: [
          // Icono de eliminar notificaciones
          // Si no hay notificaciones no se muestra el icono
          notificationBloc.state.notificaciones.isEmpty
              ? const SizedBox()
              : Padding(
            padding: const EdgeInsets.only(right: 22),
            child: IconButton(
              onPressed: () {
                // Diálogo si estás seguro de eliminar todas las notificaciones
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Eliminar notificaciones'),
                      content: const Text(
                          '¿Estás seguro que quieres eliminar todas las notificaciones?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'CANCELAR',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            notificationBloc
                                .add(const DeleteAllNotificationsEvent());
                          },
                          child: const Text(
                            'ELIMINAR',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
                // notificationBloc.add(const DeleteAllNotificationsEvent());
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ],
        flexibleSpace: Container(
          padding: const EdgeInsets.all(8),
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
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // No tienes notificaciones
          if (state.notificaciones.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications,
                    color: Colors.black54,
                    size: 100,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'No tienes nada pendiente',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Cuando tengas notificaciones pendientes, las verás aquí.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.notificaciones.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(state.notificaciones[index].uid),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red[900],
                    child: const Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    // Eliminar la notificación aquí
                    notificationBloc.add(DeleteNotificationByIdEvent(
                        state.notificaciones[index].uid));
                  },
                  child: Card(
                    elevation: 4, // Ajusta la elevación para la sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        notificationBloc.add(MarcarNotificacionComoLeidaEvent(
                            state.notificaciones[index].uid));

                        state.notificaciones[index].tipo ==
                            NotificationsScreen.sos
                            ? null
                            : publicationBloc.add(PublicacionSelectEvent(
                            state.notificaciones[index].publicacion!));

                        state.notificaciones[index].tipo ==
                            NotificationsScreen.sos
                            ? Navigator.pushNamed(context, 'sos_notification',
                            arguments: state.notificaciones[index])
                            : Navigator.pushNamed(context, 'detalle',
                            arguments:
                            state.notificaciones[index].publicacion);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar del usuario o icono de tipo de notificación
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: state
                                  .notificaciones[index].tipo ==
                                  NotificationsScreen.sos
                                  ? Colors.white
                                  : Color(int.parse(
                                  "0xFF${state.notificaciones[index].publicacion!.color}")),
                              child: Stack(
                                children: [
                                  state.notificaciones[index].tipo ==
                                      NotificationsScreen.sos
                                      ? Image.asset('assets/sos.png')
                                      : state.notificaciones[index].publicacion!
                                      .imgAlerta
                                      .endsWith('.png')
                                      ? Image.asset(
                                    'assets/alertas/${state.notificaciones[index].publicacion!.imgAlerta}',
                                    color: Colors.white,
                                  )
                                      : SvgPicture.asset(
                                    'assets/alertas/${state.notificaciones[index].publicacion!.imgAlerta}',
                                    width: 25,
                                    color: Colors.white,
                                  ),
                                  if (state.notificaciones[index].tipo ==
                                      NotificationsScreen.mensaje)
                                    const Positioned(
                                      bottom: 0,
                                      right: 0,
                                      height: 10,
                                      left: 25,
                                      child: Center(
                                        child: Icon(
                                          FontAwesomeIcons.solidCommentDots,
                                          color:
                                          Color.fromRGBO(106, 162, 142, 1),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título del reporte o tipo de notificación
                                  Text(
                                    state.notificaciones[index].tipo ==
                                        NotificationsScreen.sos
                                        ? state.notificaciones[index]
                                        .usuarioRemitente.nombre
                                        : state.notificaciones[index].tipo ==
                                        NotificationsScreen.mensaje
                                        ? "Comentaron un reporte"
                                        : state.notificaciones[index]
                                        .publicacion!.titulo,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Descripción del reporte o mensaje de notificación
                                  Text(
                                    state.notificaciones[index].mensaje,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Fecha y hora de la notificación
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat.yMd().add_Hms().format(state.notificaciones[index].createdAt),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                state.notificaciones[index].isLeida
                                    ? const SizedBox()
                                    : const CircleAvatar(
                                  radius: 10,
                                  backgroundColor:
                                  Color.fromRGBO(106, 162, 142, 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
