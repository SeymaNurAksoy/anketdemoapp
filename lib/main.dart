
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Anket"),
        ),
        body: SurveyList(),
      ),
    );
  }
}
final sahteSnapshot = [
  {"isim":"C","oy":3},
  {"isim":"Java","oy":3},
  {"isim":"Python","oy":3},
  {"isim":"Dart","oy":3},
  {"isim":"Kotlin","oy":3},
];
class SurveyList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }

}

class SurveyListState extends State{

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream : Firestore.instance.collection("anket").snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return LinearProgressIndicator();
        }else{
          return buildBody(context, snapshot.data!.documents);
        }
      },
      );
  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 20.0),
      children: snapshot.map<Widget>((data) => buildListItem(context,data)).toList(),

    );
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row= Anket.fromSnapshot(data);
    return Padding(padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
    child: Container(
      child:ListTile(
        title: Text(row.isim),
        trailing: Text(row.oy.toString()),
        onTap: ()=>Firestore.instance.runTransaction((transaction)async{
          final freshSnapshot = await transaction.get(row.reference);
          final fresh = Anket.fromSnapshot(freshSnapshot);
          await transaction.update((row.reference),{'oy':fresh.oy+1});
        },),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(5.0),

      ),

    ),);
  }
}
class Anket{
  String isim;
  int oy;
  DocumentReference? reference ;
  Anket.fromMap(Map<String,dynamic> map ,{this.reference})
      :assert(map["dil"]!=null) ,assert(map["oy"]!=null),
  isim = map["dil"], oy=map["oy"];

  Anket.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data,reference:snapshot.reference);
}


