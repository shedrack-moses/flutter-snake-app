import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake/widgets/firebase_collection.dart';

class ScoreTile extends StatelessWidget {
  final String documentID;

  const ScoreTile({super.key, required this.documentID});

  @override
  Widget build(BuildContext context) {
    var highScoreCollection = FirebaseFirestore.instance.collection(highScores);
    return FutureBuilder<DocumentSnapshot>(
      future: highScoreCollection.doc(documentID).get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data.data() as Map<String, dynamic>;
          return Row(
            spacing: 10,
            children: [
              Text(
                data['score'].toString(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Text(
                data['name'],
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          );
        }
        return Text('waiting ....');
      },
    );
  }
}
