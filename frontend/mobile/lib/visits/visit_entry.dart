import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:mobile/models/visit.dart';

import 'package:intl/intl.dart';

class VisitEntry extends StatelessWidget {
  final Visit visit;

  VisitEntry(this.visit);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
                child: Row(
              children: [
                const Icon(Icons.location_on_outlined),
                Text(visit.gymName),
              ],
            )),
            Expanded(
              child: Container(
                alignment: Alignment.topRight,
                padding: EdgeInsets.all(4),
                child: Text(
                  DateFormat.yMMMd().format(visit.date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
