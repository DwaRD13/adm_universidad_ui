import 'package:flutter/material.dart';

class ChipFiltro extends StatelessWidget {
  final String etiqueta;
  final bool seleccionado;
  final VoidCallback alPulsar;

  const ChipFiltro({
    required this.etiqueta,
    required this.seleccionado,
    required this.alPulsar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(etiqueta),
      selected: seleccionado,
      onSelected: (_) => alPulsar(),
    );
  }
}
