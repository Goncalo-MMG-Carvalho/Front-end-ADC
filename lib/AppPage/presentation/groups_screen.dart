import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
  bool _showAddForm = false;
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  List<Group> _groups = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
    });
  }

  void _addGroup(String groupName, String companyName, Color color) {
    setState(() {
      _groups.add(Group(groupName, companyName, color));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromRGBO(248, 237, 227, 1), // Change color as desired
      body: SingleChildScrollView(
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(189,210,182,100), // Background color for the form
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add Group',
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
          SizedBox(height: 20.0),
          TextField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Color:',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(width: 10.0),
              // Color picker
              ElevatedButton(
                onPressed: () => _showColorPicker(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                ),
                child: const Text('Pick Color'),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          ElevatedButton(
            onPressed: () {
              // Handle form submission
              String groupName = _groupNameController.text;
              String companyName = _companyNameController.text;
              _addGroup(groupName, companyName, _selectedColor); // Add group to the list
              _toggleAddForm(); // Hide the form after submission
              _groupNameController.clear(); // Clear text fields
              _companyNameController.clear();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSquare(Group group) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      width: 200.0, // Fixed width for each group square
      decoration: BoxDecoration(
        color: group.color,
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
          Text(
            'Company Name: ${group.companyName}',
            style: const TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Method to show color picker dialog
  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
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
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}