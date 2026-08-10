import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colores con significado propio del dominio académico (aprobado, ausente, pendiente...).
///
/// Van en una extensión del tema en lugar de constantes sueltas para que cambien
/// solos entre claro y oscuro y para que ninguna pantalla escriba un color literal.
@immutable
class ColoresEstado extends ThemeExtension<ColoresEstado> {
  const ColoresEstado({
    required this.exito,
    required this.exitoSuave,
    required this.advertencia,
    required this.advertenciaSuave,
    required this.error,
    required this.errorSuave,
    required this.info,
    required this.infoSuave,
  });

  /// Aprobado, presente, entregado.
  final Color exito;
  final Color exitoSuave;

  /// Pendiente, tardanza, por vencer.
  final Color advertencia;
  final Color advertenciaSuave;

  /// Reprobado, ausente, vencido.
  final Color error;
  final Color errorSuave;

  /// Excusa, informativo.
  ///
  /// Es cian y no azul a propósito: el azul es el color de marca y si `info`
  /// también fuera azul, un chip informativo se confundiría con una acción.
  final Color info;
  final Color infoSuave;

  static const ColoresEstado claro = ColoresEstado(
    exito: Color(0xFF15803D),
    exitoSuave: Color(0xFFDCF4E4),
    advertencia: Color(0xFF9A6207),
    advertenciaSuave: Color(0xFFFBEFD3),
    error: Color(0xFFB3261E),
    errorSuave: Color(0xFFFBE2E0),
    info: Color(0xFF0E7490),
    infoSuave: Color(0xFFD5EDF4),
  );

  static const ColoresEstado oscuro = ColoresEstado(
    exito: Color(0xFF5FD68B),
    exitoSuave: Color(0xFF10361F),
    advertencia: Color(0xFFF0C264),
    advertenciaSuave: Color(0xFF3A2C0C),
    error: Color(0xFFFF8A80),
    errorSuave: Color(0xFF41181A),
    info: Color(0xFF4CC7E5),
    infoSuave: Color(0xFF0B333D),
  );

  @override
  ColoresEstado copyWith({
    Color? exito,
    Color? exitoSuave,
    Color? advertencia,
    Color? advertenciaSuave,
    Color? error,
    Color? errorSuave,
    Color? info,
    Color? infoSuave,
  }) {
    return ColoresEstado(
      exito: exito ?? this.exito,
      exitoSuave: exitoSuave ?? this.exitoSuave,
      advertencia: advertencia ?? this.advertencia,
      advertenciaSuave: advertenciaSuave ?? this.advertenciaSuave,
      error: error ?? this.error,
      errorSuave: errorSuave ?? this.errorSuave,
      info: info ?? this.info,
      infoSuave: infoSuave ?? this.infoSuave,
    );
  }

  @override
  ColoresEstado lerp(ThemeExtension<ColoresEstado>? otro, double t) {
    if (otro is! ColoresEstado) return this;
    return ColoresEstado(
      exito: Color.lerp(exito, otro.exito, t)!,
      exitoSuave: Color.lerp(exitoSuave, otro.exitoSuave, t)!,
      advertencia: Color.lerp(advertencia, otro.advertencia, t)!,
      advertenciaSuave: Color.lerp(advertenciaSuave, otro.advertenciaSuave, t)!,
      error: Color.lerp(error, otro.error, t)!,
      errorSuave: Color.lerp(errorSuave, otro.errorSuave, t)!,
      info: Color.lerp(info, otro.info, t)!,
      infoSuave: Color.lerp(infoSuave, otro.infoSuave, t)!,
    );
  }
}

/// Acentos para distinguir entidades sin significado semántico: una materia de
/// otra, una persona de otra.
///
/// Los siete tonos son deliberadamente fríos y de la misma familia que el azul
/// de marca, para que dos materias contiguas se distingan sin que la pantalla
/// parezca un semáforo. Vive en el tema (y no como constante en un widget) para
/// que exista una única lista y para que cambie en modo oscuro.
@immutable
class PaletaAcademica extends ThemeExtension<PaletaAcademica> {
  const PaletaAcademica({required this.acentos});

  final List<Color> acentos;

  static const PaletaAcademica claro = PaletaAcademica(
    acentos: [
      Color(0xFF1B4DA8), // azul académico
      Color(0xFF0E7490), // cian profundo
      Color(0xFF4338CA), // índigo
      Color(0xFF0F766E), // verde azulado
      Color(0xFF0369A1), // azul cielo oscuro
      Color(0xFF6D28D9), // violeta
      Color(0xFF9A6207), // ámbar oscuro
    ],
  );

  static const PaletaAcademica oscuro = PaletaAcademica(
    acentos: [
      Color(0xFF8FB2F5),
      Color(0xFF4CC7E5),
      Color(0xFF9A9DF5),
      Color(0xFF5ECFC0),
      Color(0xFF6BB8ED),
      Color(0xFFB79BF0),
      Color(0xFFF0C264),
    ],
  );

  /// Acento estable para un nombre: la misma materia recibe siempre el mismo
  /// color en el horario, en las notas y en su avatar, sin guardar nada.
  Color porNombre(String nombre) =>
      acentos[nombre.hashCode.abs() % acentos.length];

  @override
  PaletaAcademica copyWith({List<Color>? acentos}) {
    return PaletaAcademica(acentos: acentos ?? this.acentos);
  }

  @override
  PaletaAcademica lerp(ThemeExtension<PaletaAcademica>? otro, double t) {
    if (otro is! PaletaAcademica) return this;
    return PaletaAcademica(
      acentos: [
        for (var i = 0; i < acentos.length; i++)
          Color.lerp(acentos[i], otro.acentos[i], t)!,
      ],
    );
  }
}

/// Acceso corto a los colores de estado desde cualquier widget.
extension TemaUniConnect on BuildContext {
  ColoresEstado get estados => Theme.of(this).extension<ColoresEstado>()!;
  PaletaAcademica get academica => Theme.of(this).extension<PaletaAcademica>()!;
  ColorScheme get colores => Theme.of(this).colorScheme;
  TextTheme get textos => Theme.of(this).textTheme;
}

/// Sistema de diseño de la aplicación: Material 3 sobre una paleta azul académica.
///
/// Los dos [ColorScheme] se escriben a mano en lugar de derivarse con
/// `ColorScheme.fromSeed`: la semilla genera un `secondary` y un `tertiary`
/// desvaídos y añade un tinte automático a las superficies, y el resultado se
/// parece al de cualquier otra app de Material. Aquí el azul es la identidad.
class TemaApp {
  const TemaApp._();

  /// Azul académico: el color de marca del que sale todo lo demás.
  static const Color semilla = Color(0xFF1B4DA8);

  /// Radio de las tarjetas y contenedores. Un único valor mantiene la coherencia.
  static const double radio = 16;

  /// Radio de los elementos pequeños: campos, botones, chips grandes.
  static const double radioChico = 12;

  /// Unidad base de espaciado; los márgenes son múltiplos de este valor.
  static const double espacio = 8;

  /// Ancho útil máximo del contenido. En tablet y web el contenido se centra en
  /// lugar de estirarse, que es lo que hace ilegible una lista a 1600 px.
  static const double anchoMaximo = 720;

  static const ColorScheme _esquemaClaro = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1B4DA8),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD8E3FF),
    onPrimaryContainer: Color(0xFF0A2A63),
    secondary: Color(0xFF4A6FA5),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFDDE7F6),
    onSecondaryContainer: Color(0xFF17324F),
    tertiary: Color(0xFFB0770B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFBEFD3),
    onTertiaryContainer: Color(0xFF4A3209),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFBE2E0),
    onErrorContainer: Color(0xFF5C1512),
    surface: Color(0xFFFBFCFF),
    onSurface: Color(0xFF12161D),
    onSurfaceVariant: Color(0xFF5A6472),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F6FC),
    surfaceContainer: Color(0xFFEDF1F9),
    surfaceContainerHigh: Color(0xFFE6ECF7),
    surfaceContainerHighest: Color(0xFFDFE6F2),
    inverseSurface: Color(0xFF283040),
    onInverseSurface: Color(0xFFF1F4FA),
    inversePrimary: Color(0xFFAFC6FF),
    outline: Color(0xFF7A8496),
    outlineVariant: Color(0xFFC3CDDF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const ColorScheme _esquemaOscuro = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFAFC6FF),
    onPrimary: Color(0xFF062E6B),
    primaryContainer: Color(0xFF123A82),
    onPrimaryContainer: Color(0xFFD8E3FF),
    secondary: Color(0xFFB4C7E7),
    onSecondary: Color(0xFF1B3350),
    secondaryContainer: Color(0xFF32496B),
    onSecondaryContainer: Color(0xFFDDE7F6),
    tertiary: Color(0xFFF0C264),
    onTertiary: Color(0xFF3F2E00),
    tertiaryContainer: Color(0xFF5A4308),
    onTertiaryContainer: Color(0xFFFBEFD3),
    error: Color(0xFFFF8A80),
    onError: Color(0xFF5C1512),
    errorContainer: Color(0xFF7A2420),
    onErrorContainer: Color(0xFFFBE2E0),
    surface: Color(0xFF0E1116),
    onSurface: Color(0xFFE4E8F0),
    onSurfaceVariant: Color(0xFF9BA6B8),
    surfaceContainerLowest: Color(0xFF090C10),
    surfaceContainerLow: Color(0xFF161A21),
    surfaceContainer: Color(0xFF1A1F27),
    surfaceContainerHigh: Color(0xFF1E242D),
    surfaceContainerHighest: Color(0xFF272E39),
    inverseSurface: Color(0xFFE4E8F0),
    onInverseSurface: Color(0xFF1A1F27),
    inversePrimary: Color(0xFF1B4DA8),
    outline: Color(0xFF6B7787),
    outlineVariant: Color(0xFF38414F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  /// Los dos temas se construyen una sola vez: resolver GoogleFonts y armar
  /// todos los sub-temas en cada cambio de `ThemeMode` es trabajo tirado.
  static final ThemeData _claro = _construir(_esquemaClaro);
  static final ThemeData _oscuro = _construir(_esquemaOscuro);

  static ThemeData claro() => _claro;

  static ThemeData oscuro() => _oscuro;

  /// Escala tipográfica propia.
  ///
  /// La de Material es uniforme y por eso una pantalla llena de texto se lee
  /// plana: aquí los títulos grandes llevan tracking negativo y peso alto, y las
  /// etiquetas pequeñas tracking positivo, que es lo que crea la jerarquía.
  static TextTheme _tipografia(TextTheme base, ColorScheme esquema) {
    final inter = GoogleFonts.interTextTheme(base);

    return inter
        .copyWith(
          displaySmall: GoogleFonts.inter(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            height: 1.15,
          ),
          headlineLarge: GoogleFonts.inter(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.2,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 1.2,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            height: 1.25,
          ),
          titleLarge: GoogleFonts.inter(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.45),
          bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.45),
          bodySmall: GoogleFonts.inter(fontSize: 12.5, height: 1.4),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
          ),
        )
        .apply(bodyColor: esquema.onSurface, displayColor: esquema.onSurface);
  }

  static ThemeData _construir(ColorScheme esquema) {
    final base = ThemeData(colorScheme: esquema, useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: esquema.surface,
      // Sin tinte automático: las superficies mantienen el color que se les da
      // en lugar de teñirse de azul al hacer scroll bajo una barra.
      applyElevationOverlayColor: false,
      textTheme: _tipografia(base.textTheme, esquema),
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.surface,
        foregroundColor: esquema.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: esquema.onSurface,
        ),
      ),
      // Tarjetas planas con borde sutil: se leen mejor que las sombras pesadas.
      cardTheme: CardThemeData(
        color: esquema.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
          side: BorderSide(
            color: esquema.outlineVariant.withValues(alpha: 0.7),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radioChico),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radioChico),
          borderSide: BorderSide(
            color: esquema.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radioChico),
          borderSide: BorderSide(color: esquema.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radioChico),
          borderSide: BorderSide(color: esquema.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radioChico),
          borderSide: BorderSide(color: esquema.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radioChico),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: esquema.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radioChico),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: esquema.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: esquema.primaryContainer,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => GoogleFonts.inter(
            fontSize: 12,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: estados.contains(WidgetState.selected)
                ? esquema.primary
                : esquema.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            size: 24,
            color: estados.contains(WidgetState.selected)
                ? esquema.onPrimaryContainer
                : esquema.onSurfaceVariant,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: esquema.primary,
        unselectedLabelColor: esquema.onSurfaceVariant,
        indicatorColor: esquema.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: esquema.outlineVariant.withValues(alpha: 0.7),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      dividerTheme: DividerThemeData(
        color: esquema.outlineVariant.withValues(alpha: 0.7),
        space: 1,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radioChico),
        ),
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radio),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: esquema.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radio + 4)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: esquema.primary,
        linearTrackColor: esquema.surfaceContainerHighest,
        circularTrackColor: esquema.surfaceContainerHighest,
      ),
      extensions: <ThemeExtension<dynamic>>[
        esquema.brightness == Brightness.light
            ? ColoresEstado.claro
            : ColoresEstado.oscuro,
        esquema.brightness == Brightness.light
            ? PaletaAcademica.claro
            : PaletaAcademica.oscuro,
      ],
    );
  }
}
