// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, duplicate_ignore

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/auth/auth_bloc.dart';
import 'package:flutter_maps_adv/blocs/publication/publication_bloc.dart';
import 'package:flutter_maps_adv/models/reporte.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AlertScreen extends StatefulWidget {
  static const String routeName = 'reporte';

  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  bool isIconicActivated = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    super.initState();
    isButtonDisabled = false;

    Future.delayed(Duration.zero, () {
      _focusNode.requestFocus();
    });
    _getCurrentLocation();
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
    final Reporte reporte =
        ModalRoute.of(context)!.settings.arguments as Reporte;

    final size = MediaQuery.of(context).size;
    final publicaciones = BlocProvider.of<PublicationBloc>(context);
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
              child: reporte.isSvg == true
                  ? SvgPicture.asset(
                      'assets/alertas/${reporte.icon}',
                      width: 30,
                      color: Colors.white,
                    )
                  : Image.asset(
                      'assets/alertas/${reporte.icon}',
                      width: 30,
                      color: Colors.white,
                    ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: size.width * 0.6,
              child: Text(
                reporte.tipo,
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
                        SizedBox(
                          height: 50,
                          // color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 15),
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width * 0.1,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 49, 67, 78),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  alignment: Alignment.center,
                                  icon: const Icon(
                                    FontAwesomeIcons.image,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    openImages();
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 15),
                                alignment: Alignment.center,
                                // width: MediaQuery.of(context).size.width * 0.1,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 49, 67, 78),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  alignment: Alignment.center,
                                  icon: const Icon(
                                    FontAwesomeIcons.camera,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () async {
                                    
                                    var image = await imgpicker.pickImage(
                                        source: ImageSource.camera,
                                        imageQuality: 5);

                                    if (image != null) {
                                      setState(() {
                                        //agergar imagen a la lista pero que no pase de 3
                                        if (imagefiles.length < 3) {
                                          imagefiles.addAll([image]);
                                          imagePaths.add(image.path);
                                        } else {
                                          _showDialog();
                                        }
                                      });
                                    }
                                    // openImages();
                                  },
                                ),
                              ),
                              Expanded(
                                  child: Row(
                                children: [
                                  //icono de ubicacion
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF202c33),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      margin: const EdgeInsets.only(
                                          left: 20, right: 20),
                                      child: Row(
                                        children: [
                                          Container(
                                              // color: Color.fromARGB(255, 49, 67, 78),
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 49, 67, 78),
                                                borderRadius: BorderRadius.only(
                                                    //bordes redondeados
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10)),
                                              ),
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.white,
                                              )),
                                          //icono con texto de ubicacion
                                          Container(
                                            // color: Color.fromARGB(255, 0, 93, 164),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            padding:
                                                const EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${name.isNotEmpty ? name : 'Ubicación'} - ${ciudad.isNotEmpty ? ciudad : 'Ciudad'}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),

                        //Lista de imagenes selccinoadas de la galeria

                        imagefiles.isNotEmpty
                            ? SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: imagefiles.length,
                                  itemBuilder: (context, index) {
                                    return Stack(children: [
                                      //Una x para eliminar la imagen
                                      Container(
                                        //bordes redondeados
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        margin: const EdgeInsets.all(5),
                                        width: 100,
                                        height: 100,
                                        child: Image.file(
                                          File(imagefiles[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              imagefiles.removeAt(index);
                                              imagePaths.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 17,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]);
                                  },
                                ),
                              )
                            : Container(
                                alignment: Alignment.centerLeft,
                                margin: const EdgeInsets.only(top: 10),
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                child: const Text(
                                  'Máximo 3 fotos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
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
                                      'Modo incógnito ${isIconicActivated ? 'activado' : 'desactivado'}',
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
                                    ? 'Modo incógnito activado'
                                    : 'Modo incógnito desactivado',
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
                                                    color: Color.fromRGBO(2, 79, 49, 1),
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
                                                            Color.fromRGBO(2, 79, 49, 1),
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
                                            await publicaciones
                                                .createPublication(
                                              reporte.tipo,
                                              text,
                                              reporte.color,
                                              reporte.icon,
                                              !isIconicActivated,
                                              true,
                                              authService.state.usuario!.uid,
                                              authService.state.usuario!.nombre,
                                              imagePaths,
                                            );
                                            Fluttertoast.showToast(
                                              msg:
                                                  'Reporte publicado en noticias',
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 2,
                                              backgroundColor:
                                                  const Color.fromRGBO(2, 79, 49, 1),
                                              textColor: Colors.white,
                                              fontSize: 16.0,
                                            );

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
                                    Icon(
                                      FontAwesomeIcons.bullhorn,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Reportar',
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 255, 255, 1),
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
