import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/visit.dart';
import 'package:mobile/services/location.dart';
import 'package:mobile/services/visits-service.dart';
import 'package:mobile/storage/visits-storage.dart';
import 'package:mobile/visits/visit_entry.dart';
import 'package:table_calendar/table_calendar.dart';

class VisitsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VisitsState();
}

class _VisitsState extends State<VisitsScreen> {
  var storage = GetIt.instance<VisitsStorage>();
  var service = VisitsService();
  String _currentView = "list";
  late List<Visit> visits;

  void _switchView(String view) => setState(() {
        _currentView = view;
      });

  reload() async {
    setState(() {
      future = _getVisits();
    });
  }

  late Future<List<Visit>> future = _getVisits();

  Future<List<Visit>> _getVisits() {
    var visits = storage.getVisits();
    if (visits != null) {
      return Future.value(visits);
    } else {
      return service.getLastVisits().then((value) {
        if (value.success) {
          return value.result ?? [];
        } else {
          return [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),
        SizedBox(
          height: 50,
          child: VisitsHeading(_switchView),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: FutureBuilder<List<Visit>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;
                return _currentView == "list"
                    ? VisitsList(data)
                    : VisitsCalendar(data, reload);
              } else if (snapshot.hasError) {
                return const Text("There was an error during loading data.");
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }
}

class VisitsList extends StatelessWidget {
  final List<Visit> data;
  var changeViewMethod;

  VisitsList(this.data);

  Widget _buildEntry(Visit visit) {
    return VisitEntry(visit);
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: const Text(
          'There are no recent visits. Start with creating new gym in the map.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 21),
        ),
      );
    }

    return ListView(children: [
      ...data.map((visit) => _buildEntry(visit)).toList(),
    ]);
  }
}

class VisitsCalendar extends StatefulWidget {
  final List<Visit> data;
  final Function reload;

  VisitsCalendar(this.data, this.reload);

  @override
  State<StatefulWidget> createState() => _VisitsCalendarState();
}

class _VisitsCalendarState extends State<VisitsCalendar> {
  late final ValueNotifier<List<Visit>> _currentDayVisits;
  late DateTime _selectedDay;

  bool _isSameDay(DateTime first, DateTime second) {
    var firstTimeStrap = DateTime(first.year, first.month, first.day);
    var secondTimeStrap = DateTime(second.year, second.month, second.day);

    return firstTimeStrap.compareTo(secondTimeStrap) == 0;
  }

  List<Visit> _getVisitsInDay(DateTime forDate) {
    return widget.data
        .where((element) => _isSameDay(forDate, element.date))
        .toList();
  }

  List<dynamic> _visitsLoader(DateTime day) {
    var visitsThisDay = _getVisitsInDay(day);

    return visitsThisDay.map((e) => Text(e.date.toString())).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
      });

      _currentDayVisits.value = _getVisitsInDay(selectedDay);
    }
  }

  Future _removeVisit(String id) async {
    var service = LocationService();

    var result = await service.removeVisit(id);

    if (result) {
      widget.reload();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('There was an error!')));
    }
  }

  Widget buildVisitDescription(Visit visit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(visit.gymName),
        Text(DateFormat(DateFormat.HOUR_MINUTE_SECOND).format(visit.date)),
        IconButton(
            onPressed: () async => await _removeVisit(visit.id),
            icon: const Icon(Icons.delete)),
      ],
    );
  }

  @override
  void initState() {
    _selectedDay = DateTime.now();
    _currentDayVisits = ValueNotifier(_getVisitsInDay(_selectedDay));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: DateTime.now(),
          eventLoader: _visitsLoader,
          onDaySelected: _onDaySelected,
          selectedDayPredicate: (day) => _selectedDay == day,
          calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) => null,
              selectedBuilder: (context, day, focusedDay) => Center(
                      child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.green),
                  ))),
        ),
        Expanded(
            child: ValueListenableBuilder<List<Visit>>(
                valueListenable: _currentDayVisits,
                builder: (context, value, child) {
                  if (value.isEmpty) {
                    return const Center(child: Text('No visits.'));
                  }

                  return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        var item = value[index];
                        return Container(
                          child: ListTile(
                            title: buildVisitDescription(item),
                          ),
                        );
                      });
                }))
      ],
    );
  }
}

typedef StringToVoidFunc = void Function(String);

class VisitsHeading extends StatefulWidget {
  final StringToVoidFunc changeViewMethod;

  const VisitsHeading(
    this.changeViewMethod, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VisitsHeadingState();
}

class _VisitsHeadingState extends State<VisitsHeading> {
  String _currentView = "list";
  _switchToCalendar() {
    setState(() {
      _currentView = "calendar";
    });
    widget.changeViewMethod("calendar");
  }

  _switchToList() {
    setState(() {
      _currentView = "list";
    });
    widget.changeViewMethod("list");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              "Recent visits",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Expanded(
              child: Container(
            alignment: Alignment.centerRight,
            child: _currentView == "list"
                ? IconButton(
                    icon: const Icon(Icons.calendar_today_rounded),
                    onPressed: () => _switchToCalendar(),
                  )
                : IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () => _switchToList(),
                  ),
          ))
        ],
      ),
    );
  }
}
