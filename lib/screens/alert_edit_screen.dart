// ignore_for_file: use_build_context_synchronously, unused_local_variable, deprecated_member_use, duplicate_ignore, avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/auth/auth_bloc.dart';
import 'package:flutter_maps_adv/blocs/publication/publication_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlerEdittScreen extends StatefulWidget {
  static const String routeName = 'reporte_edit_screen';

  const AlerEdittScreen({super.key});

  @override
  State<AlerEdittScreen> createState() => _AlerEdittScreenState();
}

class _AlerEdittScreenState extends State<AlerEdittScreen> {
  bool isIconicActivated = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PublicationBloc publicacionBloc = PublicationBloc();
  List<String> images = [];
  List<XFile> imagefiles =
      []; // Lista para almacenar las imágenes seleccionadas
  List<String> imagePaths =
      []; // Lista para almacenar las rutas de las imágenes

  Position? currentPosition;
  String name = '';
  String ciudad = '';
  final _textController = TextEditingController();
  final ImagePicker imgpicker = ImagePicker();

  bool isPressed = false;
  bool isButtonDisabled = false;
  bool isLoading = false;
  final FocusNode _focusNode = FocusNode();

  bool isErrorMessageShown = false; // New flag to track error dialog

  @override
  void initState() {
    isButtonDisabled = false;
    publicacionBloc = BlocProvider.of<PublicationBloc>(context);
    _textController.text = publicacionBloc.state.currentPublicacion!.contenido;
    images = publicacionBloc.state.currentPublicacion!.imagenes!;
    Future.delayed(Duration.zero, () {
      _focusNode.requestFocus();
    });
    _getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    imagefiles.clear();
    imagePaths.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reporte = publicacionBloc.state.currentPublicacion!;

    final size = MediaQuery.of(context).size;

    final authService = BlocProvider.of<AuthBloc>(context, listen: false);

    //controlar que reporte no sea null

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF111b21),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(int.parse('0xFF${reporte.color}')),
              //endsWith('.png')
              child: reporte.imgAlerta.endsWith('.svg')
                  ? SvgPicture.asset(
                      'assets/alertas/${reporte.imgAlerta}',
                      width: 30,
                      color: Colors.white,
                    )
                  : Image.asset(
                      'assets/alertas/${reporte.imgAlerta}',
                      width: 30,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: size.width * 0.6,
              child: Text(
                reporte.titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFF111b21),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: const Color(0xFF111b21),
                          child: TextField(
                            textCapitalization: TextCapitalization.sentences,
                            focusNode: _focusNode,
                            maxLength: 500,
                            controller:
                                _textController, //sirve para limpiar el texto del textfield cuando se envia el mensaje
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            maxLines: null,
                            expands: true,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: '¿Qué está pasando?',
                              border: InputBorder.none,
                              //color del texto blanco
                              labelStyle: TextStyle(color: Colors.white),
                              hintStyle: TextStyle(color: Colors.white),
                              fillColor: Color(0xFF111b21),

                              //size del texto
                              // contentPadding: EdgeInsets.all(20),
                            ),
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Divider(
                          color: Colors.white,
                        ),
                        //repotar o reportar incognito el incidente
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                setState(() {
                                  isIconicActivated = !isIconicActivated;
                                });
                                Fluttertoast.showToast(
                                  msg:
                                      'Modo icónico ${isIconicActivated ? 'activado' : 'desactivado'}',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: const Color.fromRGBO(2, 79, 49, 1),
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              },
                              child: Tooltip(
                                message: isIconicActivated
                                    ? 'Modo icónico activado'
                                    : 'Modo icónico desactivado',
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isIconicActivated
                                        ? const Color.fromARGB(
                                            255, 243, 149, 33)
                                        : Colors.grey,
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.userSecret,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 43,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromRGBO(2, 79, 49, 1),
                              ),
                              child: MaterialButton(
                                onPressed: isButtonDisabled
                                    ? null
                                    : () async {
                                        _focusNode
                                            .unfocus(); // Hide the keyboard
                                        final text =
                                            _textController.text.trim();

                                        if (text.isEmpty &&
                                            !isErrorMessageShown) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                  'Campo vacío',
                                                  style: TextStyle(
                                                    color: Color(0xFF6165FA),
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                content:
                                                    const SingleChildScrollView(
                                                  child: Text(
                                                    'Por favor, escriba qué sucedió.',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: const Text(
                                                      'Aceptar',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF6165FA),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else if (text.isNotEmpty) {
                                          try {
                                            setState(() {
                                              isLoading =
                                                  true; // Mostrar el indicador de progreso
                                              isErrorMessageShown = true;
                                              isButtonDisabled = true;
                                            });
                                            publicacionBloc.add(
                                                UpdatePublicationDescriptionEvent(
                                                    description: text,
                                                    imagePaths: imagePaths,
                                                    uid: reporte.uid!));
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            setState(() {
                                              isLoading =
                                                  false; // Ocultar el indicador de progreso
                                            });
                                          } catch (e) {
                                            setState(() {
                                              isLoading =
                                                  false; // Ocultar el indicador de progreso en caso de error
                                            });
                                            print('Error: $e');
                                            return;
                                          }
                                        }
                                      },
                                child: const Row(
                                  children: [
                                    //iCONO DE ACTUALIZAR informacion
                                    // Icon(
                                    //   FontAwesomeIcons.check,
                                    //   color: Colors.white,
                                    //   size: 18,
                                    // ),
                                    // SizedBox(width: 10),
                                    Text(
                                      'Actualizar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  //Circular Progress Indicator dialog

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final Placemark place = placemarks[0];
      // print(place);
      setState(() {
        currentPosition = position;
        name = place.street ?? '';
        ciudad = place.subAdministrativeArea ?? '';
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  openImages() async {
    try {
      var pickedFiles = await ImagePicker().pickMultiImage(imageQuality: 5);

      if (pickedFiles.length <= 3 && imagefiles.length <= 3) {
        imagefiles.addAll(
            pickedFiles); // Agregar las nuevas imágenes a la lista existente
        imagePaths.addAll(pickedFiles
            .map((e) => e.path)); // Agregar las rutas de las nuevas imágenes

        setState(
            () {}); // Actualizar el widget para mostrar las imágenes seleccionadas
      } else {
        _showDialog();
      }

      setState(() {});
        } catch (e) {
      print("Error while picking file.");
    }
  }

  //showDailog de superaste el limite de imagenes
  Future<void> _showDialog() async {
    if (Platform.isIOS) {
      // ignore: use_build_context_synchronously
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Máximo 3 fotos'),
            content: const Text(
              'Por favor, seleccione máximo 3 fotos para su reporte.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Máximo 3 fotos'),
            content: const Text(
              'Por favor, seleccione máximo 3 fotos para su reporte.',
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Aceptar',
                  style: TextStyle(color: Color(0xFF6165FA)),
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
}
