import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final String text;

  const Logo({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 1, bottom: 10),
      child: Column(
        children: [
          SizedBox(
            width: 210,
            height: 230,
            child: Image.asset(
              'assets/Logo_iniciodesesion.png',
              // Ajusta el fit según sea necesario
              fit: BoxFit.contain,
            ),
          ),
          Text(text,
              style: const TextStyle(
                  color: Color.fromRGBO(2, 79, 49, 1),
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
