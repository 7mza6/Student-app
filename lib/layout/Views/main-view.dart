import 'package:flutter/material.dart';
import '../../courses/Views/homePage.dart';
import 'DrawerView.dart';
import 'navBar.dart';
import 'AppHeader.dart';

class mainView extends StatefulWidget {
  Widget? body;
   mainView({super.key,this.body});

   static _mainViewState? of(BuildContext context) =>
       context.findAncestorStateOfType<_mainViewState>();
  @override
  State<mainView> createState() => _mainViewState();  
}

class _mainViewState extends State<mainView> {
  
  void setBody(Widget body) {
    setState(() {
      widget.body = body;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppHeader(context,this),
        drawer: DrawerView(),
        bottomNavigationBar: BottomNavBar(mainView: this,),
        body: widget.body ?? HomePage(),        
      ),
    );
  }
}

