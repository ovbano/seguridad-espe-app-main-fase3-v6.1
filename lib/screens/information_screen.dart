import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/helpers/page_route.dart';
import 'package:flutter_maps_adv/screens/information_family_screen.dart';

class InformationScreen extends StatefulWidget {
  static const String information = 'information';
  const InformationScreen({super.key, Key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final TextEditingController telefonoController =
      TextEditingController(text: '09');
  bool areFieldsEmpty = true;
  NavigatorBloc navigatorBloc = NavigatorBloc();

  @override
  void initState() {
    super.initState();
    telefonoController.addListener(updateFieldsState);
    navigatorBloc = BlocProvider.of<NavigatorBloc>(context);
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final double imageWidth = screenWidth * 0.20;
    final double imageHeight = screenHeight * 0.10;
    final double labelWidth = screenWidth * 0.15;
    final double textFieldWidth = screenWidth * 0.6;

    final double buttonHeight = screenHeight * 0.05;

    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight *
                  0.02, // Ajuste vertical según el tamaño de la pantalla
              horizontal: screenWidth *
                  0.1, // Ajuste horizontal según el tamaño de la pantalla
            ),
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
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(
                    top: screenHeight *
                        0.02), // Ajuste vertical para mover el texto hacia abajo
                child: Text(
                  "Información del contacto",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight *
                        0.03, // Ajuste del tamaño del texto según el tamaño de la pantalla
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Para brindar una respuesta rápida en situaciones de emergencia, le solicitamos que ingrese su número de teléfono.",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(0, 0, 0, 0.782),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: imageWidth,
                          height: imageHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Image.asset(
                            'assets/ecuador.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: labelWidth,
                          height: imageHeight,
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
                      child: SizedBox(
                        width: textFieldWidth,
                        height: imageHeight,
                        child: TextField(
                          controller: telefonoController,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            labelStyle: TextStyle(
                              color: Color.fromRGBO(106, 162, 142, 1),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(106, 162, 142, 1),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: screenWidth * 0.5,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: areFieldsEmpty
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            await authBloc
                                .addTelefono(telefonoController.text.trim());
                            navigatorBloc.add(
                                const NavigatorIsNumberFamilyEvent(
                                    isNumberFamily: true));
                            Navigator.of(context).push(CreateRoute.createRoute(
                                const InformationFamily()));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(2, 79, 49, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text('Guardar',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
