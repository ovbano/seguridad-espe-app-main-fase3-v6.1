import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/helpers/page_route.dart';
import 'package:flutter_maps_adv/screens/screens.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InformationFamily extends StatefulWidget {
  static const String informationFamily = 'information_family';
  const InformationFamily({super.key});

  @override
  State<InformationFamily> createState() => _InformationFamilyState();
}

class _InformationFamilyState extends State<InformationFamily> {
  final TextEditingController telefonoController =
      TextEditingController(text: '09');
  bool areFieldsEmpty = true;
  // bool routeActive = false;
  List<String> telefonos = [];
  AuthBloc authBloc = AuthBloc();
  NavigatorBloc navigatorBloc = NavigatorBloc();
  late SvgPicture image1;
  final ScrollController _scrollController = ScrollController();
  bool isNumberAdd = false;

  @override
  void initState() {
    super.initState();
    authBloc = BlocProvider.of<AuthBloc>(context);
    navigatorBloc = BlocProvider.of<NavigatorBloc>(context);
    telefonos = authBloc.state.usuario?.telefonos ?? [];
    telefonoController.addListener(updateFieldsState);

    image1 = SvgPicture.asset(
      "assets/info/numberfamily.svg",
      fit: BoxFit.cover,
    );
  }

  @override
  void dispose() {
    telefonoController.removeListener(updateFieldsState);
    telefonoController.dispose();
    super.dispose();
  }

  void updateFieldsState() {
    setState(() {
      areFieldsEmpty = telefonoController.text.trim().isEmpty ||
          !isValidPhoneNumber(telefonoController.text.trim());
    });
  }

  bool isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegex = RegExp(r'^09\d{8}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final authService = BlocProvider.of<AuthBloc>(
      context,
    );

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(221, 255, 255, 255)),
        centerTitle: false,
        flexibleSpace: Container(
          padding: const EdgeInsets.all(20),
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
        // automaticallyImplyLeading: routeActive,
        title: const Text(
          'Mis contactos de emergencia',
          style: TextStyle(color: Color.fromARGB(221, 255, 255, 255)),
        ),
        actions: [
          //boton texto de siguiente
          authService.state.usuario?.telefonos != null && isNumberAdd == false
              ? const SizedBox()
              : TextButton(
                  onPressed: () {
                    navigatorBloc.add(const NavigatorIsPlaceSelectedEvent(
                        isPlaceSelected: true));

                    // ignore: use_build_context_synchronously
                    Navigator.of(context)
                        .push(CreateRoute.createRoute(const PlacesScreen()));
                  },
                  child: const Text(
                    'Siguiente',
                    style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1), fontSize: 16),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                shrinkWrap: true,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.80,
                      height: MediaQuery.of(context).size.height * 0.40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: image1,
                    ),
                  ),
                  const Text(
                    "Agrega los números de teléfono de tus contactos en caso de emergencia, para que puedan recibir alertas de tus seres queridos. Solo los números que hayas añadido serán notificados una vez que presiones el botón de SOS.",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(0, 0, 0, 0.782),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _TextFieldAddTelefono(telefonoController: telefonoController),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: ElevatedButton(
                      onPressed: areFieldsEmpty
                          ? null
                          : () {
                              if (authService.state.usuario?.telefonos.contains(
                                      telefonoController.text.trim()) ??
                                  false) {
                                mostrarAlerta(
                                  context,
                                  'Número ya registrado',
                                  'El número que estás intentando ingresar ya se encuentra registrado.',
                                );
                                return;
                              }

                              if (authService.state.usuario?.telefono ==
                                  telefonoController.text.trim()) {
                                mostrarAlerta(
                                  context,
                                  'Número ya registrado',
                                  'No puedes agregar tu propio número de teléfono.',
                                );
                                return;
                              }

                              authService.addTelefonoFamily(
                                  telefonoController.text.trim());

                              setState(() {
                                isNumberAdd = true;
                              });

                              telefonoController.clear();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(2, 79, 49, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Agregar número', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _ListContact(authService: authService, telefonos: telefonos)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void mostrarAlerta(BuildContext context, String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            titulo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(2, 79, 49, 1), // Un color atractivo
            ),
          ),
          content: Text(
            mensaje,
            style: const TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(2, 79, 49, 1), // Mismo color que el título para coherencia
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

class _TextFieldAddTelefono extends StatelessWidget {
  const _TextFieldAddTelefono({
    required this.telefonoController,
  });

  final TextEditingController telefonoController;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                "assets/ecuador.jpg",
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'EC +593',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 0.782),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: TextField(
            controller: telefonoController,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Teléfono',
              labelStyle: TextStyle(
                color: Color.fromRGBO(2, 79, 49, 1), // Color del texto del label
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color.fromRGBO(2, 79, 49, 1), // Color de la línea de abajo del TextField
                ),
              ),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
          ),
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class _ListContact extends StatelessWidget {
  _ListContact({
    required this.authService,
    required this.telefonos,
  });

  List<String> telefonos;
  final AuthBloc authService;

  @override
  Widget build(BuildContext context) {
    final state = authService.state;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: state.usuario?.telefonos.length ?? 0,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(
              Icons.person,
              color: Color.fromRGBO(2, 79, 49, 1),
            ),
            title: Text(
              state.usuario?.telefonos[index] ?? '',
              style: const TextStyle(
                color: Color.fromRGBO(0, 0, 0, 0.782),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                _showDeleteConfirmationDialog(
                    context, state.usuario?.telefonos[index] ?? '');
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromRGBO(0, 0, 0, 0.782),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String telefono) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este número de teléfono?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo sin eliminar
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //solo que pueda eliminar cuando sea mayor a 1
                if (authService.state.usuario?.telefonos.length == 1) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          'No se puede eliminar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        content: const Text(
                          'No se puede eliminar el número de teléfono, debe tener al menos un número de teléfono.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context); // Cerrar el diálogo sin eliminar
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                            ),
                            child: const Text(
                              'Aceptar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                  return;
                }
                authService.deleteTelefonoFamily(telefono);
                Navigator.pop(context); // Cerrar el diálogo después de eliminar
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color.fromRGBO(2, 79, 49, 1),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
