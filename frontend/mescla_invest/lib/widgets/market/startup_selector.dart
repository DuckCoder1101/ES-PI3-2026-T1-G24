/*
 * Autor: Vinicius Santuci Virgolino
 * RA: 25000294
 */

import 'package:flutter/material.dart';
import 'package:mescla_invest/constants/colors.dart';
import 'package:mescla_invest/models/startup/startup_model.dart';

class StartupSelector extends StatelessWidget {
  final List<StartupResumeDTO> startups;
  final StartupResumeDTO? selected;
  final bool isLoading;
  final void Function(StartupResumeDTO?) onChanged;

  const StartupSelector({
    super.key,
    required this.startups,
    required this.selected,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Startup', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.campoEscuro,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.verdeMescla,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<StartupResumeDTO>(
                    value: selected,
                    hint: const Text(
                      'Selecione uma startup',
                      style: TextStyle(color: Colors.white38),
                    ),
                    dropdownColor: AppColors.campoEscuro,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.verdeMescla,
                    ),
                    isExpanded: true,
                    items: startups
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }
}
