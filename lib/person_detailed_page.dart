import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:onivert/model/person.dart';
import 'package:onivert/widget_form.dart';
import 'package:open_file/open_file.dart';

class PersonDetails extends StatefulWidget {
  final Person person;
  final List<State>? parents;
  final Map<Person,List<ValueNotifier<String?>>> listen;
  const PersonDetails(
      {Key? key, required this.person,this.parents,required this.listen})
      : super(key: key);

  @override
  _PersonDetailsState createState() => _PersonDetailsState();
}

class _PersonDetailsState extends State<PersonDetails> {
  int addressMaxLines = 3;
  final items = ['Delete', 'Modify'];


  void deletePerson() async{
    if(widget.person.imageName!=null){
      await FirebaseStorage.instance.ref('files/${widget.person.imageName}').delete();
    }
    if(widget.person.docName!=null){
      await FirebaseStorage.instance.ref('files/${widget.person.docName}').delete();
    }
    widget.person.delete();

  }

  void actionSelected(String val) {
    switch (val) {
      case 'Delete':
        //widget.deletePerson(widget.person);
        deletePerson();
        Navigator.pop(context);
        break;
      case 'Modify':
        showDialog(context: context, builder: (cxt)=>WidgetForm(person: widget.person,parents: widget.parents,listen: widget.listen,));
        break;
    }
  }


  @override
  void initState(){
    super.initState();
    widget.parents!.add(this);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.person.firstName),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            PopupMenuButton<String>(
              // icon: Icon(Icons.more_vert),
              itemBuilder: (context) {
                return items.map((e) {
                  return PopupMenuItem(
                    child: Text(e),
                    value: e,
                  );
                }).toList();
              },
              onSelected: (val) {
                actionSelected(val);
              },
            )
          ],
        ),
        body: Container(
          width: size.width,
          height: size.height,
          //decoration: BoxDecoration(border: Border.all(color:Colors.red,width: 5),),
          child: Stack(
            children: [
              Positioned(
                child: Container(
                  width: size.width,
                  height: size.height * 0.2,
                  color: Theme
                      .of(context)
                      .primaryColorDark,
                ),
              ),
              Positioned(
                top: size.height * 0.15,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  //color: Colors.white,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                      color: Colors.white),
                ),
              ),
              Positioned(
                top: size.height * 0.05,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  //decoration: BoxDecoration(border: Border.all(color:Colors.red,width: 5),),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(children: [
                        ClipOval(
                            child: Container(
                              height: size.width / 2 + 20,
                              width: size.width / 2 + 20,
                              color: Colors.white,
                            )),
                        Positioned(
                            top: 10,
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: imageWidget(size)
                        )
                      ]),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        widget.person.firstName + " " + widget.person.lastName,
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Row(
                        children: [
                          const Text(
                            "First Name: ",
                            style: TextStyle(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          Expanded(child: Text(widget.person.firstName,overflow: TextOverflow.ellipsis,)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Last Name: ",
                      style: TextStyle(fontSize: 15),),
                          Expanded(child: Text(widget.person.lastName,overflow: TextOverflow.ellipsis,)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Mobile No: ", style: TextStyle(fontSize: 15),),
                          Expanded(child: Text(widget.person.mobile,overflow: TextOverflow.ellipsis,)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Gender: ", style: TextStyle(fontSize: 15),),
                          Text(widget.person.gender,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            addressMaxLines = 100;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Address: ", style: TextStyle(fontSize: 15),),
                            Flexible(
                                fit: FlexFit.tight,
                                child: Text(
                                  widget.person.address,
                                  maxLines: addressMaxLines,
                                  overflow: TextOverflow.ellipsis,
                                ))
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Text("Resume: ", style: TextStyle(fontSize: 15),),
                          widget.person.downloadDocPathUrl != null ? TextButton(
                              onPressed: () {
                                downloadResume();
                              }, child: Text("Resume")) : Text("No resume uploaded"),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget imageWidget(Size size){
    return ValueListenableBuilder<String?>(
        valueListenable: widget.listen[widget.person]![0],
        builder: (context,val,_){
          if(val == null){
            return ClipOval(
                child: Image.asset(
                  "assets/images/default.jpg",
                  width: size.width / 2,
                  height: size.width / 2,
                )
            );
          }
          return ClipOval(
              child: Image.file(
                File(val),
                width: size.width / 2,
                height: size.width / 2,
                fit: BoxFit.cover,
              )
          );
        }
    );
  }

  void downloadResume() async{
    final dcm = DefaultCacheManager();
    FileInfo? file;
    if(widget.person.cacheDocPath == null || (file = await dcm.getFileFromCache(widget.person.cacheDocPath!)) ==null ){
      widget.person.cacheDocPath = (await dcm.getSingleFile(widget.person.downloadDocPathUrl!)).path;
      setState(() {
        widget.person.save();
      });
      OpenFile.open(widget.person.cacheDocPath);
      return;
    }
    OpenFile.open(widget.person.cacheDocPath);
  }


}
