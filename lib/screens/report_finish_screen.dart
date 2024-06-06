import 'package:flutter/material.dart';


class ReportFinishScreen extends StatelessWidget {
  static const String routeName = 'report_finish';

  const ReportFinishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF08df9a),
                    size: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Gracias por denunciar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Revisaremos tu denuncia y tomaremos las medidas necesarias si existiese una infracción de las Normas de la comunidad.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              _BtnReport(),
            ],
          ),
        ),
      ),
    );
  }
}

class _BtnReport extends StatelessWidget {
  const _BtnReport();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            width: width * 0.95,
            height: 40,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: const Color.fromRGBO(2, 79, 49, 1),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              //icono de aleta de emergencia
              child: const Text(
                'Listo',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
