import 'package:adc_handson_session/MapPage/presentation/mapPage.dart';
import 'package:flutter/material.dart';

import 'homeUserPage_screen.dart';


class AppPage extends StatefulWidget {
  const AppPage({super.key});


  @override
  State<AppPage> createState() => _AppPage();
}

class _AppPage extends State<AppPage> {



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Green Life',
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(189, 210, 182, 1),
              title: Center(
                child: Image.asset(
                  'assets/logo.png', // Replace with your image path
                  height: 70, // Adjust the height as needed
                ),
              ),
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    color: const Color.fromRGBO(121, 135, 119, 1),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  color: const Color.fromRGBO(121, 135, 119, 1),
                  onPressed: () {
                    //TODO
                  },
                ),
              ],
            ),
            bottomNavigationBar: tapBar(),
            body: TabBarView(
              children: [
                Container(child: const HomePage()),//PAGINAS A FAZER
                Container(child: const Icon(Icons.directions_transit))//PAGINAS A FAZER
              ],
            ),
            backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
            //DRAWER
            drawer:  Drawer(
              backgroundColor: const Color.fromRGBO(248, 237, 227, 1),
              child: menu(),
            )
        )
        )
    );
  }

      Widget tapBar() {
        return Container(
          color: const Color.fromRGBO(121, 135, 119, 1),
          child: const TabBar(
            labelColor: Color.fromRGBO(248, 237, 227, 1),
            unselectedLabelColor: Color.fromRGBO(248, 237, 227, 1),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Color.fromRGBO(248, 237, 227, 1),
            tabs: [
              Tab(
                icon: Icon(Icons.home),
              ),
              Tab(
                icon: Icon(Icons.group),
              ),
            ],
          ),
        );
      }


      Widget menu() {
        return ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
              const SizedBox(
              height: 55.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color:
                  Color.fromRGBO(189, 210, 182, 1)
                ),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(0.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text('Menu',
                        style: TextStyle(
                            fontSize: 26,
                            color: Color.fromRGBO(121, 135, 119, 1)
                        )
                    ),
                )
              ),
            ),
            ListTile(
              title: const Text('Map'),
              onTap: () {
                Navigator.push( //responsavel por passar para a outra pagina (mainScreen), pilha que empilha as paginas acessadas, podendo assim voltar a tras nas paginas
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        );
      }
}