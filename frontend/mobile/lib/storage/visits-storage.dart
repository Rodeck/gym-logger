import 'package:mobile/models/visit.dart';
import 'package:rxdart/rxdart.dart';

class VisitsStorage {
  BehaviorSubject<List<Visit>?> visitsSubject = BehaviorSubject.seeded(null);

  ValueStream<List<Visit>?> getVisitsStream() => visitsSubject.stream;

  setVisits(List<Visit> visits) => visitsSubject.add(visits);
  List<Visit>? getVisits() => visitsSubject.valueOrNull;
}
