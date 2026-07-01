import 'package:go_router/go_router.dart';
import 'package:template_b/feat/linkhub_service/data/model/linkhub_service_model.dart';
import 'package:template_b/feat/linkhub_service/presentation/linkhub_screen.dart';

enum LinkhubServiceRoutes {
  screen('linkhub-screen', '/linkhub/screen');

  final String name;
  final String path;

  const LinkhubServiceRoutes(this.name, this.path);
}

final linkhubServiceRoutes = <GoRoute>[
  GoRoute(
    path: LinkhubServiceRoutes.screen.path,
    name: LinkhubServiceRoutes.screen.name,
    builder: (context, state) {
      final service = state.extra as LinkhubServiceModel;
      return LinkhubScreen(service: service);
    },
  ),
];
