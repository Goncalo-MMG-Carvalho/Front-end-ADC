
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child:Center(
      child: Column(
        children: <Widget>[
          Container(
            height: 300,
          ),
          Container(
            height: 1.0, // Adjust height as needed
            width: 350.0, // Adjust width as needed
            color:  const Color.fromRGBO(162, 178, 159, 1), // Change color as desired
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: const Text(
              'New values',
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 26,
                color: Color.fromRGBO(121, 135, 119, 1),
              ),
            ),
          ),
          Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(10,40,10,5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Mobility',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontFamily: 'Arial',
                  )
                  ,),
                onPressed: () {

                }
              )),
          Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(10,40,10,5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Informatics systems use',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontFamily: 'Arial',
                  )
                  ,),
                onPressed: (

                ) {}
              )),
          Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(10,40,10,5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Applications use',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontFamily: 'Arial',
                  )
                  ,),
                onPressed: () {},
              )),
          Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(10,40,10,5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Food',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontFamily: 'Arial',
                  )
                  ,),
                onPressed: () {},
              )),
          Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(10,40,10,5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                ),
                child: const Text('Electricity and gas',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontFamily: 'Arial',
                  )
                  ,),
                onPressed: () {},
              )),
          Container(
              height: 90,
              padding: const EdgeInsets.fromLTRB(10,40,10,5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(121, 135, 119, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                  ),
                ),
                child: const Text('water consume',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                    fontSize: 20,
                    fontFamily: 'Arial',
                  )
                  ,),
                onPressed: () {},
              )),
          Container(
            height: 30,
          )
        ],
      ),
      ),
    );
  }
}
