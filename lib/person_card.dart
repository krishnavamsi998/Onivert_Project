import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:onivert/person_detailed_page.dart';

import 'model/person.dart';

class PersonCard extends StatefulWidget {
  final Person? person;

  final Map<Person,List<ValueNotifier<String?>>> listen;
  const PersonCard({Key? key, required this.person,required this.listen}) : super(key: key);

  @override
  _PersonCardState createState() => _PersonCardState();
}

class _PersonCardState extends State<PersonCard> {
  List<State> parents = [];
  DefaultCacheManager dcm = DefaultCacheManager();
  @override
  void initState(){
    super.initState();
    parents.add(this);
  }
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    //print(size.height);
    return widget.person == null
        ? Container()
        : InkWell(
            // onTap: (){
            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.person!.cacheImagePath!)));
            // },
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (Context) =>
                          PersonDetails(person: widget.person!,parents: parents, listen: widget.listen,)));
            },
            child: Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(2),
                color: Theme.of(context).primaryColorDark,
                //decoration: BoxDecoration(color: Theme.of(context).primaryColorDark),
                child: Stack(
                  children: [
                    Positioned(
                        top: size.height * 0.08,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30)),
                              color: Colors.white),
                        )),
                    Positioned(
                        top: size.height * 0.04,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              cardImage(),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                widget.person!.firstName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(widget.person!.mobile)
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
  }

  Widget cardImage(){
    return ValueListenableBuilder<String?>(
      valueListenable: widget.listen[widget.person]![0],
      builder: (context,val,_){
        if(val == null){
          return ClipOval(
            child:Image.asset(
              "assets/images/default.jpg",
              width: 80,
              height: 80,
            )
          );
        }
        return ClipOval(
          child:Image.file(
            File(val),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
          )
        );
      },
    );

  }
}
