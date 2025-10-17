# eMovieApp 🎬

Aplicación Flutter que consume **TMDb** para mostrar:
- **Próximos estrenos**
- **Tendencia**
- **Recomendados para ti** (filtros locales)
- **Detalle** con tráiler

Incluye **animaciones (Splash)**, **caché offline-first** (JSON+TTL via `SharedPreferences`), **BLoC**, y UI **responsive**.

---

## 1) Requisitos

- Flutter 3.29.2 (Dart `^3.7.2`) en adelante
- Claves de TMDb:
  - **v4 Read Access Token** (preferido, tipo Bearer)
  - **v3 API Key** (alternativa)

---

## 2) Configuración (simple con `env.dart`)

Edita `lib/src/core/env.dart`:

```dart
class Env {
  static const String tmdbApiKey  = "TU_API_KEY_V3";   // v3 (query param api_key)
  static const String tmdbV4Token = "TU_TOKEN_V4";     // v4 (Authorization: Bearer ...)
}
```

---

## 3) Ejecutar

- **VS Code → F5** (no se necesita `--dart-define`).
- O CLI:

```bash
flutter pub get
flutter run
```

---

## 4) Endpoints TMDb (v3)

Todas las rutas y queries están centralizadas y editables en lib/src/services/endpoints.dart.
Este archivo expone métodos como API.upcoming(), API.popular(), API.trending(), API.detailsMovie(), y API.primaryTranslations(), evitando hardcodear URLs en el código.

**Auth**
- Si `Env.tmdbV4Token` ≠ vacío → `Authorization: Bearer <token>`.
- Si no, y `Env.tmdbApiKey` ≠ vacío → `api_key=<v3>` como query param.

---

## 5) Arquitectura / Decisiones

- **State management:** `bloc` / `flutter_bloc`  
- **HTTP:** `dio` con interceptor (auth + `accept-language`)  
- **Caché offline-first:** `SharedPreferences` (JSON + timestamp + TTL por clave)  
- **UI responsive:** `flutter_screenutil`  
- **i18n:** `easy_localization` (assets en `assets/translations/`)  
- **Video:** `youtube_player_flutter` / `video_player`  
- **Errores:** toasts **solo** cuando no hay datos ni caché

**Estrategia de caché:**
1. Intento red → si OK: guardo caché y retorno.  
2. Si falla red → leo caché válido por TTL y **no muestro toast**.  
3. Si no hay caché → muestro toast y retorno vacío/fallback.

---

## 6) Estructura (archivos clave)

> Mapa compacto para evaluación. Los detalles finos están comentados en el código.

| Ruta | Propósito |
|---|---|
| `src/utils/env.dart` | **Tus credenciales** (v3/v4). Flujo simple para correr. |
| `src/services/api_service.dart` | Cliente `Dio` + interceptor (Bearer v4 / api_key v3, `accept-language`), timeouts y manejo de errores. |
| `src/services/movie_service.dart` | Repositorio de películas (upcoming, popular, trending, details, videos) con **caché offline-first** y TTL por endpoint. |
| `src/services/config_service.dart` | `primary_translations` con caché (TTL largo) y fallback local si no hay red ni caché. |
| `src/services/connectivity_service.dart` | (Opcional) Helpers de conectividad. |
| `src/services/endpoints.dart` | Builders de endpoints/queries TMDb (e.g. `API.upcoming()`, `API.trending(period)`, etc.). |
| `src/cache/cache_entry.dart` | Serialización de entradas de caché (JSON + timestamp). Se usa desde `CacheService` (si lo agregas como `services/cache_service.dart`). |
| `src/models/res/movie_model.dart` | Modelo de película (mapea snake_case TMDb ↔ camelCase). Helpers `posterUrl/backdropUrl`. |
| `src/models/res/movie_detail_model.dart` | Detalle de película (géneros, compañías, países, runtime, spoken languages…). |
| `src/models/res/video_model.dart` | Modelo de videos (YouTube key, tipo Trailer, etc.). |
| `src/models/res/general_model.dart` | Wrapper genérico (`success`, `status_message`, `results`). |
| `src/bloc/blocs/movie_bloc.dart` (+ events/states) | Orquesta llamadas de `MovieService` y estados para Home/Detalle. |
| `src/bloc/blocs/language_bloc.dart` (+ events/states) | Idioma actual; lo usa `ApiService` en cabeceras. |
| `src/bloc/blocs/filter_bloc.dart` (+ events/states) | Filtros locales de “Recomendados” (chips idioma/año). |
| `src/bloc/blocs/navigation_bloc.dart` | Navegación/bottom-bar simple si aplica. |
| `src/bloc/blocs/splash_bloc.dart` | Control del tiempo/estado del Splash. |
| `src/shared/animations/animated_background.dart` | Fondo animado reusable. |
| `src/shared/animations/icon_painter.dart` | `CustomPainter` para **íconos flotantes** del Splash. |
| `src/core/constants/colors_palette.dart` | Paleta (`primaryColor`, `secondColor`) para gradientes/tema. |
| `src/customs/custom_app_safe_scaffold.dart` | `Scaffold` + `SafeArea` + estilos base. |
| `src/customs/custom_filter.dart` | Chips/controles para filtros de recomendados. |
| `src/ui/screens/splash_screen.dart` | **Splash**: gradiente, texto animado “eMovie” (opacity/scale/tracking/glow) e iconos flotantes. |
| `src/ui/screens/home_screen.dart` | Home: **Upcoming** (horizontal), **Tendencia** (horizontal), **Recomendados** (grilla 2xN con filtros). |
| `src/ui/screens/movie_details_screen.dart` | Detalle de película + botón **“Ver tráiler”**. |
| `src/ui/widgets/h_poster_list.dart` | Lista horizontal de pósters (cards). |
| `src/ui/widgets/recommended_grid.dart` | Grilla 2xN para recomendados (máx. 6). |
| `src/ui/widgets/section_title.dart` | Título de sección consistente. |
| `src/ui/widgets/filter_bottom_sheet.dart` | Bottom sheet para elegir filtros. |
| `assets/images/` | Imágenes estáticas. |
| `assets/translations/` | Archivos de traducción (`.json`). |

---

## 7) Notas funcionales

- **Responsive:** `ScreenUtil` para tamaños/paddings; listas horizontales y grilla con ratios consistentes.  
- **Accesibilidad:** alto contraste en “eMovie”, sombras y gradiente; tamaños escalables.  
- **Caché:** TTLs sugeridos — Upcoming 120’, Trending 60’, Popular 90’, Details/Videos 180’, Translations 7 días.  
- **Errores:** no se muestra toast si hay datos cacheados; solo si no hay red **y** no hay datos.

---

## 8) Pruebas (unitarias y de widgets)

Los tests viven en `test/`:

- `test/movie_model_test.dart`
  - Mapea **TMDb → MovieModel** (`fromMap`) con datos reales.
  - Manejo de tipos mixtos (string ⇄ num), `nulls` y campos faltantes.
  - `toMap()` en **snake_case** removiendo `nulls`.
  - Helpers de imágenes `posterUrl/backdropUrl`.
  - `copyWith()` preservando/actualizando campos.

- `test/home_screen_test.dart`
  - Render del **logo eMovie** con estilos correctos.
  - Títulos de secciones (`SectionTitle`).
  - Estructura de `CustomScrollView` + `RefreshIndicator` + `BouncingScrollPhysics`.
  - Estados de **loading** y **error**.
  - Simulación de **navegación** (callback).
  - Estructura de **grilla recomendados** (2xN).
  - **Escalado responsivo** del logo según `shortestSide`.

### Ejecutar tests
```bash
flutter test
```

### Ejecutar archivo específico
```bash
flutter test test/home_screen_test.dart
```

---

## 9) Build

Android:
```bash
flutter build apk
```

iOS:
```bash
flutter build ios
```

> Si se cambia claves, se debe actualizar `env.dart` y rebuild.

---

## 10) Créditos / Licencia de datos

Esta app usa la API de **The Movie Database (TMDb)** pero **no está afiliada ni certificada por TMDb**. Respeta sus términos de uso.
