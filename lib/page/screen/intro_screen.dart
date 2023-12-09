import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  final String title;
  final String description;
  final String assets;
  const IntroScreen({Key? key, required this.description, required this.assets, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assets),
          fit: BoxFit.cover,
        ),
        color: const Color.fromARGB(199, 0, 0, 0)
      ),
      // width: 1000,
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Image.asset(assets,fit: BoxFit.cover,height: double.infinity,width: double.infinity,),
          Text(title,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
          SizedBox(height: 10,),
          Text(description,style: TextStyle(fontSize: 20,color: Colors.white),)
        ],
      ),
    );
  }
}
