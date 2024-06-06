import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/blocs/room/room_bloc.dart';
import 'package:flutter_maps_adv/helpers/mostrar_alerta.dart';
import 'package:flutter_maps_adv/screens/screens.dart';
import 'package:flutter_maps_adv/widgets/boton_login.dart';
import 'package:flutter_maps_adv/widgets/custom_input.dart';
import 'package:flutter_maps_adv/widgets/labels_login.dart';
import 'package:flutter_maps_adv/widgets/logo_login.dart';

class LoginScreen extends StatelessWidget {
  static const String loginroute = 'login';

  const LoginScreen({super.key, Key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(70),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Logo(text: "Community Safe"),
              _From(),
              Labels(
                ruta: 'register',
                text: "¿No tienes cuenta?",
                text2: "Crea una",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _From extends StatefulWidget {
  const _From();

  @override
  State<_From> createState() => __FromState();
}

class __FromState extends State<_From> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final roomBloc = BlocProvider.of<RoomBloc>(context);
    final publicationBloc = BlocProvider.of<PublicationBloc>(context);
    final double buttonWidth = MediaQuery.of(context).size.width * 0.5;

    return Column(
      children: [
        CustonInput(
          icon: Icons.mail_outline,
          placeholder: "Email",
          keyboardType: TextInputType.emailAddress,
          textController: emailController,
        ),
        CustonInput(
          icon: Icons.lock_outline,
          placeholder: "Password",
          textController: passwordController,
          isPassword: true,
        ),
        SizedBox(
          width: buttonWidth,
          height: 45,
          child: BotonForm(
            text: "Ingrese",
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (emailController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                final result = await authBloc.login(
                    emailController.text, passwordController.text);
                if (result) {
                  await roomBloc.salasInitEvent();
                  await publicationBloc.getAllPublicaciones();
                  Navigator.pushReplacementNamed(
                      context, LoadingLoginScreen.loadingroute);
                } else {
                  mostrarAlerta(context, "Login incorrecto",
                      "Revise sus credenciales nuevamente");
                }
              } else {
                mostrarAlerta(context, "Campos vacíos",
                    "Por favor, complete todos los campos");
              }
            },
          ),
        ),
        const SizedBox(height: 15),
        const Text("O continue con"),
        SizedBox(
          width: buttonWidth,
          height: 60,
          child: BotonForm(
            text: "Google",
            onPressed: () async {
              try {
                FocusScope.of(context).unfocus();
                final result = await authBloc.signInWithGoogle();
                if (result) {
                  Navigator.pushReplacementNamed(
                      context, LoadingLoginScreen.loadingroute);
                }
              } catch (e) {
                print(e);
              }
            },
          ),
        ),
      ],
    );
  }
}
