import 'package:flutter/material.dart';

class AppProperties {
  //Todo duration
  static const duration200Mill = Duration(
    milliseconds: 200,
  );


  //Todo text style
  static const titleTextStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 18,
      overflow: TextOverflow.ellipsis
  );
  static const normalBlackBoldTextStyle = TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis, color: Colors.black);
  static const tableHeaderStyle = TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis, fontSize: 12);
  static const tableHeaderStyleWhite = TextStyle(fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis, fontSize: 12, color: Colors.white);
  static const normalWhiteBoldTextStyle = TextStyle(overflow: TextOverflow.ellipsis, color: Colors.white, fontSize: 15);
  static const listTileBlackBoldStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black);

  //Todo padding style
  static const symmetric8to5 = EdgeInsets.symmetric(horizontal: 8, vertical: 5);

  //Todo linear gradient
  static final linearGradientPrimary = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xff054750),
        const Color(0xff054750).withOpacity(0.8),
      ]
  );
  static final linearGradientPrimaryLite = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xff1C7B86),
        const Color(0xff1C7B86).withOpacity(0.8),
      ]
  );

  //Todo : box shadow
  static final List<BoxShadow> customBoxShadow = [
    BoxShadow(
        offset: const Offset(0,45),
        blurRadius: 112,
        color: Colors.black.withOpacity(0.06)
    ),
    BoxShadow(
        offset: const Offset(0,22.78),
        blurRadius: 48.83,
        color: Colors.black.withOpacity(0.04)
    ),
    BoxShadow(
        offset: const Offset(0,9),
        blurRadius: 18.2,
        color: Colors.black.withOpacity(0.03)
    ),
    BoxShadow(
        offset: const Offset(0,1.97),
        blurRadius: 6.47,
        color: Colors.black.withOpacity(0.02)
    ),
  ];

  //Todo radius
  static const Radius radius5 = Radius.circular(5);


}