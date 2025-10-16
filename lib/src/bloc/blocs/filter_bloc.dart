import 'package:emovieapp/src/imports/imports.dart';

part '../events/filter_event.dart';
part '../states/filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  final ConfigService _configService;

  FilterBloc({required ConfigService configService}) 
    : _configService = configService,
      super(FilterInitial()) {
    
    on<LoadFilterData>((event, emit) async {
      emit(FilterLoading());
      try {
        final languages = await _configService.getPrimaryLanguages();
        final years = FilterData.generateYears();
        
        emit(FilterLoaded(
          filterData: FilterData(
            languages: languages,
            years: years,
            selectedLanguage: 'es-ES', // Default español
            selectedYear: null,        // Sin año por defecto
            selectedPeriod: 'day',    // día por defecto
          ),
        ));
      } catch (e) {
        emit(FilterError(message: e.toString()));
      }
    });

    on<UpdateLanguageFilter>((event, emit) {
      if (state is FilterLoaded) {
        final currentState = state as FilterLoaded;
        emit(FilterLoaded(
          filterData: currentState.filterData.copyWith(
            selectedLanguage: event.languageCode,
          ),
        ));
      }
    });

    on<UpdateYearFilter>((event, emit) {
      if (state is FilterLoaded) {
        final currentState = state as FilterLoaded;
        emit(FilterLoaded(
          filterData: currentState.filterData.copyWith(
            selectedYear: event.year,
          ),
        ));
      }
    });

    on<UpdatePeriodFilter>((event, emit) {
      if (state is FilterLoaded) {
        final currentState = state as FilterLoaded;
        emit(FilterLoaded(
          filterData: currentState.filterData.copyWith(
            selectedPeriod: event.period,
          ),
        ));
      }
    });

    on<ClearFilters>((event, emit) {
      if (state is FilterLoaded) {
        final currentState = state as FilterLoaded;
        emit(FilterLoaded(
          filterData: currentState.filterData.copyWithNullable(
            selectedPeriod: 'day',
            clearLanguage: true,  // LIMPIAR idioma
            clearYear: true,      // LIMPIAR año
          ),
        ));
      }
    });

    on<ClearLanguageFilter>((event, emit) {
      if (state is FilterLoaded) {
        final currentState = state as FilterLoaded;
        emit(FilterLoaded(
          filterData: currentState.filterData.copyWithNullable(
            clearLanguage: true,
          ),
        ));
      }
    });

    on<ClearYearFilter>((event, emit) {
      if (state is FilterLoaded) {
        final currentState = state as FilterLoaded;
        emit(FilterLoaded(
          filterData: currentState.filterData.copyWithNullable(
            clearYear: true,
          ),
        ));
      }
    });
  }
}