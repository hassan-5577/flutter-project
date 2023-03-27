import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';




class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _items = [];
  late List _x;
  bool loading = true;
  late File levelFile;

  Future<File> _createLevelFile() async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    File file = File('$appDocPath/data.json');
    await file.exists().then((value) async => {
      print(value),
      if(value){
        readJson(file)
      }else{
           await file.create()
      }
    });
    return file;
  }
   void initState(){
     _createLevelFile();
   }
  // Fetch content from the json file
  // Future<void> readJson() async {
  //   print("read");
  //   final String response = await rootBundle.loadString('levels/data.json');
  //   final data = await json.decode(response) ;
  //   print(data);
  //   setState(() {
  //     _items = data;
  //     print("..number of items ${_items.length}");
  //   });
  //
  // }

 Future<void> readJson(File file) async {

    print(file);
    String contents = await file.readAsString();
    print(contents);
    try {
      var jsonResponse = jsonDecode(contents);
      print(jsonResponse);
      setState(() {
        loading = false;
        _items = jsonResponse;
        print("..number of items ${_items.length}");
      });
    }catch (e){
      print(e);
      setState(() {
        _items = [];
        loading = false;
      });
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }


  Future<void> delJson(int i) async {
    final file = await _localFile;
    setState(() {
      _items.removeAt(i);
      file.writeAsStringSync(json.encode(_items));
    });

  }

  Future editJson() async {

  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int index, String? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      _items.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['id'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(index, _titleController.text, _descriptionController.text);
                  }

                  // Clear the text fields
                  _titleController.text = '';
                  _descriptionController.text = '';

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

  Future<void> _addItem() async {
    final file = await _localFile;
    setState(() {
      _items.add({'id': _titleController.text, 'description': _descriptionController.text });
      file.writeAsStringSync(json.encode(_items));
    });

  }

  Future<void> _updateItem(int index, String id, content) async {
    final file = await _localFile;
    setState(() {
     _items[index] = {'id': id, 'description': content };
     file.writeAsStringSync(json.encode(_items));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'CRUD APP',
        ),
      ),
      body:Column(
        children: [
          loading ==false ?Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Card(
                    color: Colors.orange[200],
                    key: ValueKey(index),
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(_items[index]["id"]),
                      subtitle: Text(_items[index]["description"]),
                      trailing: SizedBox(
                        width: 100,
                        child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(index, _items[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                delJson(index),
                          ),
                        ],
                      ),
                    )
                ));
              },
            ),
          ): Container(
              alignment: Alignment.center,
              child: const Text('Loading...')
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(0,null),
      ),
    );
  }
}
