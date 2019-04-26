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
  Stream<DocumentSnapshot> _counterStream;

  @override
  void initState() {
    super.initState();
    _counterStream = Firestore.instance.collection("counters").document("mycounter").snapshots();
  }

  Future<void> _incrementCounter() async {
    DocumentReference docRef = Firestore.instance.collection("counters").document("mycounter");

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
            buildCounterDisplay(context),
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

  Widget buildCounterDisplay(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _counterStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if(snapshot.hasData) {
          // data
          int currentCounter = snapshot.data.data['counter'];
          return Text('$currentCounter', style: Theme.of(context).textTheme.display1,);
        } else if (snapshot.hasError){
          // error
          return Text("There was an error: ${snapshot.error}");
        } else {
          // progress
          return CircularProgressIndicator();
        }
      },
    );
  }
}
