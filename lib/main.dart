// @dart=2.9
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onivert/model/person.dart';
import 'package:onivert/people_grid.dart';
import 'package:onivert/widget_form.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';




Map<Person,List<ValueNotifier<String>>> map = {};
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
  int sdk = androidInfo.version.sdkInt;
  if(sdk>=31){
    while(!(await _requestPermission(Permission.storage) &&
        await _requestPermission(Permission.manageExternalStorage))){
    }
  }
  else{
    while(!await _requestPermission(Permission.storage)){}
  }

  await Firebase.initializeApp();

  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  await Hive.openBox<Person>("people");



  DefaultCacheManager dcm = DefaultCacheManager();
  final list = Hive.box<Person>("people").values.toList();
  for(int i =0;i<list.length;i++){
    Person person = list[i];
    map.putIfAbsent(person, () => [ValueNotifier(person.cacheImagePath),ValueNotifier(person.cacheDocPath)]);

    if(person.cacheImagePath!=null){
      final cacheImage = await dcm.getFileFromCache(person.cacheImagePath);
      if(cacheImage == null){
        person.cacheImagePath = (await dcm.getSingleFile(person.downloadImagePathUrl)).path;
        map[person][0].value = person.cacheImagePath;
        map[person][0].notifyListeners();
        person.save();
      }

    }
    if(person.cacheDocPath!=null){
      final cacheDoc = await dcm.getFileFromCache(person.cacheDocPath);
      if(cacheDoc == null){
        person.cacheDocPath = (await dcm.getSingleFile(person.downloadDocPathUrl)).path;
        map[person][1].value = person.cacheDocPath;
        map[person][1].notifyListeners();
        person.save();
      }
    }

  }
  
  
  runApp(const MyApp());
}

Future<bool> _requestPermission(Permission permission) async{
  if(await permission.isGranted)return true;
  if(await permission.request() == PermissionStatus.granted)return true;

  return false;
}

class MyApp extends StatelessWidget {

  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onivert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Onivert'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final appBarActionsList = ["delete_all"];


  Future<void> _addPerson(String fn, String ln, String mob, String add, String gen, String downloadImagePathUrl ,String cacheImagePath,String downloadDocPathUrl, String cacheDocPath,String imageName, String docName) async{
    Person person = Person(firstName: fn,lastName: ln,mobile: mob,address: add,gender: gen,downloadImagePathUrl: downloadImagePathUrl , cacheImagePath: cacheImagePath,downloadDocPathUrl: downloadDocPathUrl,cacheDocPath:cacheDocPath,imageName: imageName, docName: docName);
    Hive.box<Person>("people").add(person);
    map.putIfAbsent(person, () => [ValueNotifier(cacheImagePath),ValueNotifier(cacheDocPath)]);
    map[person][0].value = cacheImagePath;
    map[person][1].value= cacheDocPath;
    map[person][0].notifyListeners();
    map[person][1].notifyListeners();

  }

  void _deletePerson(Person person) async {
    try {
      File file = File(person.downloadImagePathUrl);
      if(await file.exists()){
        await file.delete(recursive: true);
      }
      file = File(person.downloadDocPathUrl);
      if(await file.exists()){
        await file.delete(recursive: true);
      }
      person.delete();
    } on Exception catch (e) {
      print(e);
    }

  }

  void deleteAll() async{
    final list = Hive.box<Person>("people").values.toList();
    for(Person p in list){
      if(p.imageName!=null){
        await FirebaseStorage.instance.ref('files/${p.imageName}').delete();
      }
      if(p.docName!=null){
        await FirebaseStorage.instance.ref('files/${p.docName}').delete();
      }
      p.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
              itemBuilder: (cxt){
                return appBarActionsList.map((e){
                  return PopupMenuItem(child: Text(e),value: e,);
                }).toList();
              },
            icon: const Icon(Icons.more_vert),
            onSelected: (val){
                switch(val){
                  case "delete_all":
                    deleteAll();
                    break;
                }
            },

          )
        ],
      ),
      body: Container(
          height: size.height*0.9,
          width: size.width,
          child: PeopleGrid(listen: map)
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showDialog(context: context, builder: (cxt)=>WidgetForm(addTransaction: _addPerson,));
        },
        tooltip: 'Add Person',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
