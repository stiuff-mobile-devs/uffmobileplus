import 'package:flutter/material.dart';

class IdCard extends StatelessWidget {
  final String userImageUrl;
  final String username;
  final String iduff;

  const IdCard({
    super.key,
    required this.userImageUrl,
    required this.username,
    required this.iduff,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 162,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          image: DecorationImage(
            image: AssetImage("assets/restaurant/img/studentid_background.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: new BorderRadius.all(Radius.circular(12.0)),
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Image.asset(
                    "assets/restaurant/img/uff_logo.png",
                    color: Colors.white,
                    height: 38,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Universidade",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Federal",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Fluminense",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                height: 60,
                padding: const EdgeInsets.all(2.0), // border width
                decoration: BoxDecoration(
                  color: Colors.white, // border color
                  shape: BoxShape.rectangle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: Image.network(
                    userImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (buildContext, obj, stackTrace) {
                      return Image.asset("assets/images/user_placeholder.jpg");
                    },
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    username,
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(iduff, textAlign: TextAlign.left),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
