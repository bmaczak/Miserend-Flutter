import 'package:miserend/database/church.dart';
import 'package:miserend/database/mass.dart';

class MassWithChurch {
  final Church church;
  final Mass mass;

  MassWithChurch(this.church, this.mass);
}