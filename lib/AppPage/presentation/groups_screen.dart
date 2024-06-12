
import 'package:flutter/material.dart';


class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Align children to the start (left) of the column
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16.0, 16.0, 10.0, 16.0),
                  child: TextField(
                  cursorColor: const Color.fromRGBO(121, 135, 119, 1),
                  style: const TextStyle(
                  fontSize: 20.0,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                      prefixIcon: const Icon(Icons.search,
                        color: Color.fromRGBO(121, 135, 119, 1),
                      ),
                      hintText: "Search groups",
                      hintStyle: const TextStyle(
                          fontSize: 20.0,
                          color: Color.fromRGBO(121, 135, 119, 1)
                      ),
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color.fromRGBO(121, 135, 119, 1), width: 32.0),
                          borderRadius: BorderRadius.circular(5.0)),

                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color.fromRGBO(121, 135, 119, 1), width: 2.0), // Focused border
                          borderRadius: BorderRadius.circular(5.0),
                    ),

                  )
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                child: IconButton(
                  icon: const Icon(Icons.add_box_outlined,
                    size: 30.0,
                    color:  Color.fromRGBO(121, 135, 119, 1),
                  ),
                  onPressed: () {
                    // Handle button press
                    print("Button pressed");
                  },
                ),
              ),
            ],
          ),
        ],

      ),
    );
  }
}
