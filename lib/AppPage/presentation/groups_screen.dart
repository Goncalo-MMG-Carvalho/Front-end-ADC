import 'package:adc_handson_session/AppPage/application/auth.dart';
import 'package:adc_handson_session/login/domain/GroupInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'appPage_screen.dart';

// Define a model class for a Group
class Group {
  final String groupName;
  final String companyName;
  final Color color;

  Group(this.groupName, this.companyName, this.color);
}

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  String PERSONAL_ROLE = "USER_PERSONAL";

  String userRole = "";

  Authentication auth = Authentication();

  bool _showAddForm = false;
  TextEditingController _groupNameController = TextEditingController();


  Color _selectedColor = Colors.blue;

  bool isPublic = true;

  bool isBusiness = false;

  bool isLoading = true;


  List<GroupInfo> _groups = [];

  void getUserRole() async {
    String role = (await auth.getUserRole())!;
    setState(() {
      userRole = role;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserRole();
    addGroupsInfo();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
    });
  }

  Future<void> addGroupsInfo() async {
    _groups = (await auth.getGroups())!;

    setState(() {
      isLoading = false;
    });
    print(_groups);
  }



  Future<void> createGroupButtonPressed(String groupName, Color color) async {
    String colorString = color.value.toRadixString(16).padLeft(8, '0');


    //VERIFICAR SE È TRUE OR FALSE
    bool verfication = await auth.createGroup(groupName, isPublic, isBusiness, colorString);

    if(verfication) {
      setState(() {
        isLoading = true;
      });
      addGroupsInfo();
    }

    //setState(() {
    //  _groups.add(Group(groupName, colorString));
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromRGBO(248, 237, 227, 1), // Change color as desired
      body: isLoading
          ? const Center(
    // Display a loading indicator or message while loading
          child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                        contentPadding:
                        const EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color.fromRGBO(121, 135, 119, 1),
                        ),
                        hintText: "Search groups",
                        hintStyle: const TextStyle(
                            fontSize: 20.0,
                            color: Color.fromRGBO(121, 135, 119, 1)),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(121, 135, 119, 1),
                              width: 32.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color.fromRGBO(121, 135, 119, 1),
                              width: 2.0),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_box_outlined,
                      size: 30.0,
                      color: Color.fromRGBO(121, 135, 119, 1),
                    ),
                    onPressed: () {
                      // Handle button press
                      print("Button pressed");
                      _toggleAddForm(); // Toggle form visibility
                    },
                  ),
                ),
              ],
            ),
            if (_showAddForm)
              _buildAddGroupForm(), // Show form if _showAddForm is true
            const SizedBox(height: 20.0),
            // Display added groups using Wrap instead of Row
            Column(

              children: _groups.map((group) => _buildGroupSquare(group)).toList(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAddGroupForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(189,210,182,1), // Background color for the form
        border: Border.all(
          color: const Color.fromRGBO(121, 135, 119, 1),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow:[
          BoxShadow(
            color: const Color.fromRGBO(121, 135, 119, 1).withOpacity(0.5), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 7, // Blur radius
            offset: const Offset(0, 3), // Offset
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create Group',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10.0),
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
          ),
        const SizedBox(height: 20.0),
        Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Privacy:",
                  style: TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
              child: RadioListTile<bool>(
                title: const Text('Public'),
                value: true,
                groupValue: isPublic,
                activeColor: const Color.fromRGBO(121, 135, 119, 1),
                onChanged: (value) {
                  setState(() {
                    isPublic = value!;
                  });
                },
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
              child: RadioListTile<bool>(
                  title: const Text('Private'),
                  value: false,
                  groupValue: isPublic,
                  activeColor: const Color.fromRGBO(121, 135, 119, 1),
                  onChanged: (value) {
                    setState(() {
                      isPublic = value!;
                    });
              },

              ),
            )
          ],
          ),

          if( userRole != PERSONAL_ROLE)
            groupTypeChoice(),

          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Select Color:',
                style: TextStyle(fontSize: 16.0),
              ),
            //  const SizedBox(width: 10.0),
              // Color picker
              ElevatedButton(
                onPressed: () => _showColorPicker(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  shape: const CircleBorder(),
                ),
                child: const Text(""),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Handle form submission
              String groupName = _groupNameController.text;
              createGroupButtonPressed(groupName, _selectedColor);
              _toggleAddForm(); // Hide the form after submission
              _groupNameController.clear(); // Clear text fields
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:  const Color.fromRGBO(248, 237, 227, 1),
            ),
            child: const Text(
                'Create group',
              style: TextStyle(
                color:  Color.fromRGBO(121, 135, 119, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget groupTypeChoice() {
    return Column(
      children: <Widget>[
        const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Group type:",
              style: TextStyle(
                fontFamily: 'Arial',
                fontSize: 16,
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: RadioListTile<bool>(
            title: const Text('Personal'),
            value: false,
            groupValue: isBusiness,
            activeColor: const Color.fromRGBO(121, 135, 119, 1),
            onChanged: (value) {
              setState(() {
                isBusiness = value!;
              });
            },
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: RadioListTile<bool>(
            title: const Text('Business'),
            value: true,
            groupValue: isBusiness,
            activeColor: const Color.fromRGBO(121, 135, 119, 1),
            onChanged: (value) {
              setState(() {
                isBusiness = value!;
              });
            },

          ),
        )
      ],
    );
  }

  // Method to show color picker dialog

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
          title: const Text(
              'Choose a color',
              style: TextStyle(
                color: Color.fromRGBO(121, 135, 119, 1),
              ),
          ),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(121, 135, 119, 1)
              ),
              child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color.fromRGBO(248, 237, 227, 1),
                  ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildGroupSquare(GroupInfo group) {

  Color getGroupColor(String color) {
    int colorValue = int.parse(color, radix: 16);
    return Color(colorValue);
  }

  return Container(
    padding: const EdgeInsets.all(12.0),
    width: 200.0, // Fixed width for each group square
    decoration: BoxDecoration(
      color: getGroupColor(group.color),
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 2), // changes position of shadow
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Name: ${group.groupName}',
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 8.0),
      ],
    ),
  );
}
