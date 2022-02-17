import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:onivert/person_card.dart';
import 'package:onivert/grid_view.dart';
import 'model/person.dart';

class PeopleGrid extends StatefulWidget {

  final Map<Person,List<ValueNotifier<String?>>> listen;

  const PeopleGrid({Key? key,required this.listen}) : super(key: key);

  @override
  _PeopleGridState createState() => _PeopleGridState();
}

class _PeopleGridState extends State<PeopleGrid> {
  @override
  Widget build(BuildContext context) {

    final s= ValueListenableBuilder<String>(
      valueListenable: ValueNotifier('va'),
      builder: (context,val,_){
        return Container();
      },
    );
    return ValueListenableBuilder<Box<Person>>(
        valueListenable: Hive.box<Person>("people").listenable(),
        builder: (context, box, _) {
          List<Person> listOfPeople = box.values.toList();
          return listOfPeople.length == 0
              ? const Center(
                  child: Text(
                  "The list is empty",
                  style: TextStyle(fontSize: 40),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                ))
              : GridViewWidget(
                  list: listOfPeople,
                  listen: widget.listen
                );
        });
  }
}
