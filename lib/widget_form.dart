import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'model/person.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:progress_dialog/progress_dialog.dart';

class WidgetForm extends StatefulWidget {
  final Function? addTransaction;
  final List<State>? parents;
  final Person? person;
  final Map<Person,List<ValueNotifier?>> listen;
  const WidgetForm({Key? key,this.addTransaction,this.person,this.parents,required this.listen}) : super(key: key);

  @override
  _WidgetFormState createState() => _WidgetFormState();
}

class _WidgetFormState extends State<WidgetForm> {
  final _FormKey = GlobalKey<FormState>();
  late String firstName;
  late String lastName;
  late String mobile;
  late String address;
  late int genderVal = 1;


  late File? selectedImagePath = null;
  late String? imageBaseName = null;
  late String? _downloadImagePathUrl = null;
  late String? _cacheImagePath = null;

  late File? selectedDocPath = null;
  late String? docBaseName = null;
  String? fileName = null;
  late String? _downloadDocPathUrl = null;
  late String? _cacheDocPath = null;

  @override
  void initState(){
    super.initState();
    if(widget.person !=null){
      firstName = widget.person!.firstName;
      lastName =widget.person!.lastName;
      mobile = widget.person!.mobile;
      address= widget.person!.address;

      if(widget.person!.downloadImagePathUrl!=null){
        _cacheImagePath = widget.person!.cacheImagePath;
        _downloadImagePathUrl = widget.person!.downloadImagePathUrl;
        selectedImagePath = File(_cacheImagePath!);
        imageBaseName = widget.person!.imageName;
      }

      if(widget.person!.downloadDocPathUrl!=null){
        docBaseName = widget.person!.docName;
        fileName = docBaseName!.substring(docBaseName!.indexOf("_")+1);
        _downloadDocPathUrl = widget.person!.downloadDocPathUrl;
        _cacheDocPath = widget.person!.cacheDocPath;
      }


      genderVal = widget.person!.gender == 'male'? 1:2;

    }


  }

  Future<TaskSnapshot?> uploadFile(String destination, File file) async{
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return await ref.putFile(file);
      //final task = await ref.putFile(file);
      //_downloadImagePathUrl = await task.ref.getDownloadURL();
      // print(_downloadImagePathUrl);
      // _cacheImagePath = (await DefaultCacheManager().getSingleFile(_downloadImagePathUrl!)).path;
      // print(_cacheImagePath);

    } on Exception catch (e) {
      print("unable to upload file $e");
    }

  }
  
  Future<void> deleteFile(String destination) async{
    return await FirebaseStorage.instance.ref(destination).delete();
  }
  void _tryModify() async{
    final isValid = _FormKey.currentState!.validate();
    if(isValid){
      final pd = ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: false,);
      pd.style(message: "Uploading content please wait");
      pd.show();
      _FormKey.currentState!.save();

      bool ic = false,dc= false;

      if(imageBaseName != widget.person!.imageName){
        if(widget.person!.imageName !=null)await deleteFile('files/${widget.person!.imageName}');
        if(imageBaseName !=null){
          final task = await uploadFile("files/$imageBaseName",selectedImagePath!);
          if(task!=null){
            _downloadImagePathUrl = await task.ref.getDownloadURL();
            _cacheImagePath = (await DefaultCacheManager().getSingleFile(_downloadImagePathUrl!)).path;
          }
        }
        widget.listen[widget.person]![0]!.value = _cacheImagePath;
        widget.listen[widget.person]![0]!.notifyListeners();
        ic = true;
      }
      if(docBaseName!=widget.person!.docName){
        if(widget.person!.docName !=null)await deleteFile('files/${widget.person!.docName}');
        if(docBaseName !=null){
          final task = await uploadFile("files/$docBaseName", selectedDocPath!);
          if(task!=null){
            _downloadDocPathUrl = await task.ref.getDownloadURL();
            _cacheDocPath = (await DefaultCacheManager().getSingleFile(_downloadDocPathUrl!)).path;
          }
        }
        dc = true;
      }

      for (var element in widget.parents!) {
        if(element.mounted){
          element.setState(() {

            widget.person!.firstName = firstName;
            widget.person!.lastName = lastName;
            widget.person!.mobile = mobile;
            widget.person!.address = address;
            widget.person!.gender = genderVal == 1?"male":"female";
            if(ic){
              widget.person!.imageName = imageBaseName;
              widget.person!.cacheImagePath = _cacheImagePath;
              widget.person!.downloadImagePathUrl = _downloadImagePathUrl;
            }
            if(dc){
              widget.person!.docName = docBaseName;
              widget.person!.cacheDocPath = _cacheDocPath;
              widget.person!.downloadDocPathUrl = _downloadDocPathUrl;
            }
            widget.person!.save();

          });
        }
      }

      pd.hide();
      Navigator.of(context).pop();
      return;

    }
  }
  void _trySubmit() async{
    final isValid = _FormKey.currentState!.validate();
    if(isValid){
      final pd = ProgressDialog(context,type: ProgressDialogType.Normal,isDismissible: false,);
      pd.style(message: "Uploading content please wait");
      pd.show();
      _FormKey.currentState!.save();

      if(selectedImagePath !=null){
        final task = await uploadFile("files/$imageBaseName",selectedImagePath!);
        if(task!=null){
          _downloadImagePathUrl = await task.ref.getDownloadURL();
          _cacheImagePath = (await DefaultCacheManager().getSingleFile(_downloadImagePathUrl!)).path;
        }
      }
      if(selectedDocPath !=null){
        final task = await uploadFile("files/$docBaseName", selectedDocPath!);
        if(task!=null){
          _downloadDocPathUrl = await task.ref.getDownloadURL();
          _cacheDocPath = (await DefaultCacheManager().getSingleFile(_downloadDocPathUrl!)).path;
        }

      }

      widget.addTransaction!(firstName,lastName,mobile,address,genderVal==1?"male":"female",_downloadImagePathUrl,_cacheImagePath,_downloadDocPathUrl,_cacheDocPath,imageBaseName,docBaseName);
      pd.hide();
      Navigator.of(context).pop();
    }


  }


  bool containsNumbers(String s){
    final array = ['1','2','3','4','5','6','7','8','9','0'];
    for(String i in array){
      if(s.contains(i))return true;
    }
    return false;
  }

  Future<void> pickImage(ImageSource source) async {
    try{
      final image = await ImagePicker().pickImage(source: source);
      if(image == null)return;
      setState(() {
        selectedImagePath = File(image.path);
      });
      if(source == ImageSource.camera){
        imageBaseName = selectedImagePath!.path.substring(selectedImagePath!.path.lastIndexOf("/")+1);
      }
      else if(source == ImageSource.gallery){
        imageBaseName = selectedImagePath!.path.substring(selectedImagePath!.path.lastIndexOf("/")+1);
      }
    }catch(e){
      print(e);
    }

  }
  void discardImage(){
    //localImageStoragePath = null;
    setState(() {
      selectedImagePath = null;
      imageBaseName = null;
      _cacheImagePath = null;
      _downloadImagePathUrl = null;
    });
  }


  Future<void> filePicker() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,type:FileType.custom,allowedExtensions: ["pdf"]);
    if(result !=null){
        selectedDocPath =File(result.files.single.path!);
        setState(() {
          fileName = selectedDocPath!.path.substring(selectedDocPath!.path.lastIndexOf('/')+1);
          docBaseName = randomAlphaNumeric(10)+"_"+fileName!;
        });

    }
  }
  discardFile(){
    setState(() {
      selectedDocPath = null;
      fileName = null;
      docBaseName= null;
      _downloadDocPathUrl = null;
      _cacheDocPath = null;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Card(
      child: Form(
        key: _FormKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    selectedImagePath == null?ClipOval(child: Image.asset("assets/images/default.jpg",width: 160,height: 160,))
                        : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipOval(child: Image.file(selectedImagePath!,width: 160,height: 160,fit: BoxFit.cover,)),
                            TextButton(onPressed: (){discardImage();}, child: const Text("Remove photo"))
                          ],
                        ),
                    const SizedBox(width: 30),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(onPressed: (){pickImage(ImageSource.gallery);}, child: const Text("Pick Image")),
                        ElevatedButton(onPressed: (){pickImage(ImageSource.camera);}, child: const Text("Take Image"))
                      ],
                    )
                  ],
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "First Name",),
                  keyboardType: TextInputType.name,
                  validator: (value){
                    if(value == null || value.isEmpty ){
                      return "First name cannot be empty";
                    }
                    else if(containsNumbers(value)){
                      return "This field cannot have numeric characters.";
                    }
                    return null;
                  },
                  onSaved: (value){
                    firstName = value!;
                  },
                  initialValue: widget.person!=null?firstName:"",
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Last Name"),
                  keyboardType: TextInputType.name,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Last name cannot be empty";
                    }
                    else if(containsNumbers(value)){
                      return "This field cannot have numeric characters.";
                    }
                    return null;
                  },
                  onSaved: (value){
                    lastName =value!;
                  },
                  initialValue: widget.person!=null?lastName:"",
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Mobile No."),
                  keyboardType: TextInputType.number,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Mobile number cannot be empty";
                    }
                    else if(value.length!=10){
                      return "Mobile number should be 10 digits";
                    }
                    return null;
                  },
                  onSaved: (value){
                    mobile = value!;
                  },
                  initialValue: widget.person!=null?mobile:"",
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Address"),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return "Country cannot be empty";
                    }
                    return null;
                  },
                  onSaved: (value){
                    address = value!;
                  },
                  initialValue: widget.person!=null?address:"",
                ),

                Row(
                  children: [
                    const Flexible(
                      fit: FlexFit.tight,
                      flex:1,
                      child: Text("Gender :", style: TextStyle(fontSize: 20),),
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                      flex:2,
                      child:Column(
                        children: [
                          RadioListTile(
                            groupValue: genderVal,
                            value: 1,
                            title: const Text("Male"),
                            onChanged: (int? value) {
                              setState(() {
                                genderVal = value!;
                              });
                            },
                          ),
                          RadioListTile(
                            groupValue: genderVal,
                            value: 2,
                            title: const Text("Female"),
                            onChanged: (int? value){
                              setState(() {
                                genderVal = value!;
                              });
                            },
                          )
                        ],
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    if(fileName !=null)Text(fileName!),
                    if(fileName!=null)IconButton(onPressed: (){discardFile();}, icon: const Icon(Icons.delete)),
                    TextButton(onPressed: (){filePicker();}, child: const Text("Upload resume")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: (){Navigator.pop(context);}, child: const Text("Cancel")),
                    ElevatedButton(onPressed: widget.person!=null?_tryModify:_trySubmit, child: Text(widget.person!=null?"Modify":"Submit")),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
