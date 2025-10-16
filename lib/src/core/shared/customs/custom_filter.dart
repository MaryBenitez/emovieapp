import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

class CustomFilter extends StatelessWidget {
  const CustomFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FilterBloc, FilterState>(
      listener: (context, state) {
        // Forzar rebuild
      },
      child: BlocBuilder<FilterBloc, FilterState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header compacto con título y botón de filtro
              _buildFilterHeader(context),
              
              // Chips de filtros activos (siempre visibles)
              _buildCurrentFilters(state),
              const SizedBox(height: 10)
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        children: [
          Text(
            'Recomendadas para ti',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              FilterBottomSheet.show(context);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.redColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.redColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune,
                    color: AppColors.whiteColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentFilters(FilterState state) {
    if (state is! FilterLoaded) return const SizedBox.shrink();

  final filterData = state.filterData;
  final List<Map<String, dynamic>> chips = [];
  
  chips.add({
    'text': filterData.periodDisplayName,
    'isActive': true,
  });
  
  if (filterData.selectedLanguage != null) {
    chips.add({
      'text': filterData.languageDisplayText,
      'isActive': true,
    });
  }
  
  if (filterData.selectedYear != null) {
    chips.add({
      'text': filterData.yearDisplayText,
      'isActive': true,
    });
  }

    // Filtrar chips que tengan texto válido
    final validChips = chips.where((chip) {
      final text = chip['text'] as String;
      return text.isNotEmpty && text.trim().isNotEmpty;
    }).toList();

    // Si no hay chips válidos, no mostrar nada
    if (validChips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: validChips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final chip = validChips[index];
            final isActive = chip['isActive'] as bool;
            
             return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive 
                    ? AppColors.whiteColor  // Fondo blanco si está activo
                    : Colors.transparent,   // Transparente si no está activo
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive 
                      ? AppColors.secondColor  // Borde secondary si está activo
                      : AppColors.whiteColor.withOpacity(0.6), // Borde blanco si no está activo
                  width: 2,
                ),
              ),
              child: Text(
                chip['text'] as String,
                style: TextStyle(
                  color: isActive 
                      ? AppColors.secondColor  // Texto secondary si está activo
                      : AppColors.whiteColor,  // Texto blanco si no está activo
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}