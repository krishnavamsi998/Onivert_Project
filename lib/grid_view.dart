import 'package:flutter/material.dart';
import 'package:onivert/person_card.dart';

import 'model/person.dart';
class GridViewWidget extends StatefulWidget {
  final List<Person?> list;
  final Map<Person,List<ValueNotifier<String?>>> listen;
  const GridViewWidget({Key? key,required this.list,required this.listen}) : super(key: key);

  @override
  _GridViewWidgetState createState() => _GridViewWidgetState();
}

class _GridViewWidgetState extends State<GridViewWidget> {
  @override
  Widget build(BuildContext context) {
    int len = widget.list.length;
    int carry = 0;
    if (len % 2 != 0) {
      carry = 1;
      widget.list.add(null);
    }
    len = (len / 2).round();

    Size size = MediaQuery
        .of(context)
        .size;
    return ListView.builder(
        itemCount: len,
        itemBuilder: (cxt, index) {
          return Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.0),
                height: 200,
                width: size.width * 0.5,
                child: PersonCard(person: widget.list[2 * index],listen: widget.listen,),
              ),
              Container(
                  padding: EdgeInsets.all(2.0),
                  height: 200,
                  width: size.width * 0.5,
                  child: PersonCard(person: widget.list[2 * index + 1],listen: widget.listen)
              ),

            ],
          );
        });
  }

}
