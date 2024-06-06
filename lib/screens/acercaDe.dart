import 'package:flutter/material.dart';

class AcercaDeScreen extends StatelessWidget {
  static const String routeAcercaDe = 'acercaDe';

  const AcercaDeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
                  'Acerca de',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/Logo_iniciodesesion.png",
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width * 0.6,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Bienvenido a Community Safe",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "La aplicación de seguridad desarrollada por la Universidad De Las Fuerzas Armadas 'ESPE' para proteger y servir a nuestra comunidad.",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Sobre Community Safe",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Con Community Safe, la prioridad es la seguridad y bienestar en todo momento. Puedes estar tranquilo/a sabiendo que tienes acceso rápido a servicios de emergencia y asistencia del 911 en cualquier situación. Ya sea para reportar una emergencia, solicitar ayuda o simplemente mantenerte conectado, Community Safe está aquí. El sistema de publicaciones permite reportar situaciones de manera segura y anónima. Además, la función de chat permite mantener conversaciones seguras y protegidas con otros usuarios, para compartir información importante y coordinar acciones de manera eficiente. En Community Safe, nos comprometemos a crear un entorno seguro y solidario para todos. Únete en el esfuerzo por promover la seguridad y el bienestar en la comunidad. Juntos, podemos construir un futuro más seguro para todos.",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
