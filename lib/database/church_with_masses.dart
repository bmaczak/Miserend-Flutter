
import 'package:miserend/database/church.dart';
import 'package:miserend/database/mass.dart';

class ChurchWithMasses {

  final Church church;
  final List<Mass> masses;

  ChurchWithMasses(this.church, this.masses);
}