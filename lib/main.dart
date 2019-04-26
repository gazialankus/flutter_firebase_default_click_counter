import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool isUpdateInProgress;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future initAsync() async {
    isUpdateInProgress = true;

    DocumentReference docRef = Firestore.instance
      .collection("counters").document("mycounter");

    Stream<DocumentSnapshot> snapshots = docRef.snapshots();

    await for (final snap in snapshots) {
      print("received a value!");
      int counterFromServer = snap.data['counter'];
      print(counterFromServer);

      setState(() {
        _counter = counterFromServer;
        isUpdateInProgress = false;
      });
    }
  }

  Future<void> _incrementCounter() async {
    DocumentReference docRef = Firestore.instance.collection("counters").document("mycounter");

    setState(() {
      isUpdateInProgress = true;
    });

    Firestore.instance.runTransaction((transaction) async {
      DocumentSnapshot documentSnapshot = await transaction.get(docRef);
      int currentCounterValue = documentSnapshot.data["counter"];
      await transaction.update(docRef, {'counter': currentCounterValue + 1});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            isUpdateInProgress == true
              ? CircularProgressIndicator()
              : Text('$_counter', style: Theme.of(context).textTheme.display1,),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
