import 'package:flutter/material.dart';
import 'package:charity_project/models/fond_data.dart';

class FondProfileView extends StatelessWidget {
  final FondData? fond;

  const FondProfileView({
    super.key,
    this.fond,
  });

  @override
  Widget build(BuildContext context) {
    var currentFond = fond;
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
            topRight: Radius.circular(68.0),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              offset: const Offset(1.1, 1.1),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 25),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(currentFond!.imageUrl),
                  ),
                  const SizedBox(width: 35),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentFond.fundName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                          letterSpacing: 1,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text(
                        currentFond.tag,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0,
                          color: Colors.green.withOpacity(0.5),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
