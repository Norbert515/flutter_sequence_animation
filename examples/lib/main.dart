import 'package:examples/same_variable_multiple_animations.dart';
import 'package:examples/sequence_page.dart';
import 'package:examples/staggered_animation_replication.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
      routes: {
        'sequence': (_)=> new SequencePage(),
        'StaggeredAnimationReplication': (_)=> new StaggeredAnimationReplication(),
        'SameVariableAnimationPage': (_)=> new SameVariableAnimationPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Examples"),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(onPressed: (){Navigator.pushNamed(context, 'sequence');}, child: new Text("Sequence"),),
            new RaisedButton(onPressed: (){Navigator.pushNamed(context, 'StaggeredAnimationReplication');}, child: new Text("StaggeredAnimationReplication"),),
            new RaisedButton(onPressed: (){Navigator.pushNamed(context, 'SameVariableAnimationPage');}, child: new Text("SameVariableAnimationPage"),),
          ],
        ),
      )
    );
  }
}
