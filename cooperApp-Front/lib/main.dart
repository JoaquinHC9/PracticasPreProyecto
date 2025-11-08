import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// MODELOS
import 'models/account_model.dart';

// VISTAS
import 'views/login_page.dart';
import 'views/register_page.dart';
import 'views/home_page.dart';
import 'views/create_account_screen.dart';
import 'views/perfil_page.dart';
import 'views/report_account_screen.dart';
import 'views/ai_assistant_screen.dart';
import 'views/solicitar_retiro_screen.dart';
import 'views/join_account_screen.dart';
import 'views/forgot_password_page.dart';
import 'views/account_detail_page.dart';
import 'views/analiza_patrones_screen.dart';
import 'views/predice_abandono_screen.dart';
import 'views/cuenta_dueno_page.dart';
import 'views/cuenta_miembro_page.dart';
import 'views/notificaciones_screen.dart';
import 'views/solcitar_deposito_screen.dart';

// VIEWMODELS
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/register_viewmodel.dart';
import 'viewmodels/join_account_view_model.dart';
import 'viewmodels/forgot_password_viewmodel.dart';
import 'viewmodels/create_account_view_model.dart';
import 'viewmodels/report_viewmodel.dart';
import 'viewmodels/ai_assistant_view_model.dart';
import 'viewmodels/analiza_patrones_view_model.dart';
import 'viewmodels/predice_abandono_view_model.dart';
import 'viewmodels/notificacion_viewmodel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => JoinAccountViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => CreateAccountViewModel()),
        ChangeNotifierProvider(create: (_) => ReportViewModel()),
        ChangeNotifierProvider(create: (_) => AiAssistantViewModel()),
        ChangeNotifierProvider(create: (_) => AnalizaPatronesViewModel()),
        ChangeNotifierProvider(create: (_) => PrediceAbandonoViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: const CooperApp(),
    ),
  );
}

class CooperApp extends StatelessWidget {
  const CooperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CooperApp',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/accountDueno':
            final account = settings.arguments as AccountModel;
            return MaterialPageRoute(
              builder: (_) => CuentaDuenoPage(account: account),
            );
          case '/accountMiembro':
            final account = settings.arguments as AccountModel;
            return MaterialPageRoute(
              builder: (_) => CuentaMiembroPage(account: account),
            );
          case '/notificaciones':
            final cuentaId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => NotificacionesScreen(cuentaId: cuentaId),
            );
          default:
            return null;
        }
      },
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/createAccount': (context) => CreateAccountScreen(),
        '/perfil': (context) => PerfilPage(),
        '/reportAccount': (context) => ReportAccountScreen(),
        '/aiAssistant': (context) => AiAssistantScreen(),
        '/solicitarRetiro': (context) => SolicitarRetiroScreen(),
        '/joinAccount': (context) => JoinAccountScreen(),
        '/forgotPassword': (context) => ForgotPasswordPage(),
        '/accountDetail': (context) => AccountDetailPage(),
        '/analizaPatrones': (context) => AnalizaPatronesScreen(),
        '/prediceAbandono': (context) => PrediceAbandonoScreen(),
        '/solicitarDeposito': (context) => SolicitarDepositoScreen(),
      },
    );
  }
}
