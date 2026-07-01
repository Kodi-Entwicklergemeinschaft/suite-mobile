import 'package:template_c/feat/fav/presentation/fav_screen.dart';
import 'package:template_c/feat/home/presentation/home_screen.dart';
import 'package:template_c/feat/open_street_map/presentation/map_with_radius.dart';
import 'package:template_c/feat/search/presentation/search_screen.dart';
import 'package:template_c/router/route_constant.dart';

Map<String, dynamic> appRouteRgistry = {
  RouteConstant.home.name: HomeScreen(),
  RouteConstant.search.name: SearchScreen(),
  RouteConstant.fav.name: FavScreen(),
  
};
