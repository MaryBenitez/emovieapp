import 'package:flutter/material.dart';
import 'package:emovieapp/src/imports/imports.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border.all(
              color: AppColors.whiteColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Header del modal
              _buildHeader(context),
              
              // Contenido con scroll
              Expanded(
                child: _buildScrollableContent(context, state),
              ),
              
              // Botones de acción
              _buildActionButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.whiteColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Filtrar recomendaciones',
            style: TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.whiteColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, FilterState state) {
    if (state is FilterLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.secondColor),
      );
    }

    if (state is FilterError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.redColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar filtros',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(
                color: AppColors.whiteColor.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is FilterLoaded) {

      // Verificar si hay datos
      if (state.filterData.languages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber,
                color: AppColors.secondColor,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay idiomas disponibles',
                style: TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta recargar la aplicación',
                style: TextStyle(
                  color: AppColors.whiteColor.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de período
            _buildPeriodSelector(context, state.filterData),
            const SizedBox(height: 24),
            
            // Selector de idioma
            _buildLanguageSelector(context, state.filterData),
            const SizedBox(height: 24),
            
            // Selector de año
            _buildYearSelector(context, state.filterData),
            const SizedBox(height: 40), // Espacio extra para botones
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context, FilterState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.whiteColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          //  Botón limpiar
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.read<FilterBloc>().add(const ClearFilters());
                // context.read<MovieBloc>().add(const LoadAllMovies());
                context.read<MovieBloc>().add(
                const LoadRecommendationsWithFilter(
                  language: null,      // Sin idioma
                  year: null,          // Sin año  
                  period: 'day',       // Período por defecto
                ),
              );
              
              Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.whiteColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: AppColors.whiteColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Limpiar',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          //  Botón aplicar
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                if (state is FilterLoaded) {
                  context.read<MovieBloc>().add(
                    LoadRecommendationsWithFilter(
                      language: state.filterData.selectedLanguage,
                      year: state.filterData.selectedYear,
                      period: state.filterData.selectedPeriod,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.secondColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check,
                      color: AppColors.whiteColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Aplicar filtros',
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, FilterData filterData) {
    final periods = [
      {'value': 'day', 'label': '📅 Hoy', 'description': 'Trending de hoy'},
      {'value': 'week', 'label': '📊 Esta semana', 'description': 'Trending semanal'},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Período de tendencia',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: periods.map((period) {
            final isSelected = period['value'] == filterData.selectedPeriod;
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  context.read<FilterBloc>().add(
                    UpdatePeriodFilter(period: period['value'] as String),
                  );
                  context.read<MovieBloc>().add(
                    LoadRecommendationsWithFilter(
                      language: filterData.selectedLanguage,
                      year: filterData.selectedYear,
                      period: period['value'] as String,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.secondColor 
                        : AppColors.whiteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.secondColor 
                          : AppColors.whiteColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        period['label'] as String,
                        style: TextStyle(
                          color: isSelected ? AppColors.whiteColor : AppColors.whiteColor.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        period['description'] as String,
                        style: TextStyle(
                          color: isSelected ? AppColors.whiteColor.withOpacity(0.8) : AppColors.whiteColor.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(BuildContext context, FilterData filterData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Idioma',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            
            // Idiomas existentes
            ...filterData.languages.map((language) {
              final isSelected = language.code == filterData.selectedLanguage;
              
              return GestureDetector(
                onTap: () {
                  context.read<FilterBloc>().add(
                    UpdateLanguageFilter(languageCode: language.code),
                  );
                  context.read<MovieBloc>().add(
                    LoadRecommendationsWithFilter(
                      language: language.code,
                      year: filterData.selectedYear,
                      period: filterData.selectedPeriod,
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.secondColor 
                        : AppColors.whiteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.secondColor 
                          : AppColors.whiteColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(language.flag, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        language.name,
                        style: TextStyle(
                          color: isSelected ? AppColors.whiteColor : AppColors.whiteColor.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildYearSelector(BuildContext context, FilterData filterData) {
    final currentYear = DateTime.now().year;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Año de estreno',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Años por décadas organizados
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Años recientes (2020-actual)
            _buildYearSection(
              context,
              filterData,
              'Recientes',
              List.generate(currentYear - 2019, (index) => currentYear - index),
            ),
            
            const SizedBox(height: 16),
            
            // Años 2010s
            _buildYearSection(
              context,
              filterData,
              '2010s',
              [2019, 2018, 2017, 2016, 2015, 2014, 2013, 2012, 2011, 2010],
            ),
            
            const SizedBox(height: 16),
            
            // Años 2000s
            _buildYearSection(
              context,
              filterData,
              '2000s',
              [2009, 2008, 2007, 2006, 2005, 2004, 2003, 2002, 2001, 2000],
            ),
            
            const SizedBox(height: 16),
            
            // Años clásicos
            _buildYearSection(
              context,
              filterData,
              'Clásicos',
              [1999, 1995, 1990, 1985, 1980, 1975, 1970, 1965, 1960],
            ),
          ],
        ),
      ],
    );
  }

  // Método para construir secciones de años
  Widget _buildYearSection(
    BuildContext context,
    FilterData filterData,
    String title,
    List<int> years,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.whiteColor.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: years.map((year) {
            final isSelected = year == filterData.selectedYear;
            
            return GestureDetector(
              onTap: () {
                context.read<FilterBloc>().add(
                  UpdateYearFilter(year: year),
                );
                context.read<MovieBloc>().add(
                  LoadRecommendationsWithFilter(
                    language: filterData.selectedLanguage,
                    year: year,
                    period: filterData.selectedPeriod,
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.secondColor 
                      : AppColors.whiteColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.secondColor 
                        : AppColors.whiteColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.secondColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  year.toString(),
                  style: TextStyle(
                    color: isSelected 
                        ? AppColors.whiteColor 
                        : AppColors.whiteColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}