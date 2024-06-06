import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class BotonForm extends StatelessWidget {
  final String text;
  final Function onPressed;

  const BotonForm({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          MaterialButton(
            onPressed: () => text == "Google" ? _handleGoogleSignIn() : onPressed(),
            elevation: 8,
            highlightElevation: 5,
            color: const Color.fromARGB(255, 0, 68, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(width: 0.5),
            ),
            minWidth: MediaQuery.of(context).size.width * 0.5,
            height: 45,
            child: text == "Google"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        FontAwesomeIcons.google,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  )
                : Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // El usuario canceló el inicio de sesión
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Aquí puedes usar googleAuth.accessToken y googleAuth.idToken
      // para autenticarte con tu backend si es necesario.
      
      print('Google User ID: ${googleUser.id}');
      print('Google Auth Token: ${googleAuth.accessToken}');

      // Llamar a la función onPressed pasada como argumento
      onPressed();
    } catch (error) {
      print('Error en Google Sign-In: $error');
    }
  }
}
