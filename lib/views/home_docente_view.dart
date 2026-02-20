import 'package:flutter/material.dart';
import 'cursos_view.dart';

class HomeDocenteView extends StatelessWidget {
  const HomeDocenteView({super.key});

  @override
  Widget build(BuildContext context) {
    // El HomeDocenteView ahora simplemente redirige a la vista de cursos
    // que tiene el drawer y todas las funcionalidades
    return CursosView();
  }
}
