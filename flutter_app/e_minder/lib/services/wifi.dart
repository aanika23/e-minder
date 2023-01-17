// Original Template from https://blog.kuzzle.io/communicate-through-ble-using-flutter

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:e_minder/screens/home/home.dart';

// void main() => runApp(const WifiSetup());

class WifiSetup extends StatelessWidget {
  const WifiSetup({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'e-minder Wifi Setup',
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
    home: PageBLE(title: 'e-minder Wifi Setup'),
  );
}

class PageBLE extends StatefulWidget {
  PageBLE({Key? key, required this.title}) : super(key: key);

  final String title;
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  PageBLEState createState() => PageBLEState();
}

class PageBLEState extends State<PageBLE> {
  final _writeController = TextEditingController();
  final _writeControllerPass = TextEditingController();
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name == "e-minder") {
        containers.add(
          SizedBox(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                          device.name == '' ? '(unknown device)' : device.name),
                      Text(device.id.toString()),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple[800],
                  ),
                  child: const Text(
                    'Setup',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    widget.flutterBlue.stopScan();
                    try {
                      await device.connect();
                    } on PlatformException catch (e) {
                      if (e.code != 'already_connected') {
                        rethrow;
                      }
                    } finally {
                      _services = await device.discoverServices();
                    }
                    setState(() {
                      _connectedDevice = device;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = <ButtonTheme>[];

    // if (characteristic.properties.read) {
    //   buttons.add(
    //     ButtonTheme(
    //       minWidth: 10,
    //       height: 20,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 4),
    //         child: TextButton(
    //           child: const Text('READ', style: TextStyle(color: Colors.white)),
    //           onPressed: () async {
    //             var sub = characteristic.value.listen((value) {
    //               setState(() {
    //                 widget.readValues[characteristic.uuid] = value;
    //               });
    //             });
    //             await characteristic.read();
    //             sub.cancel();
    //           },
    //         ),
    //       ),
    //     ),
    //   );
    // }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple[800],
              ),
              child: Text(
                  characteristic.uuid.toString() ==
                      '986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba'
                      ? 'Change Wifi Name (SSID)'
                      : "Change Wifi Password",
                  style: TextStyle(color: Colors.white)),
              // const Text('CHANGE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(characteristic.uuid.toString() ==
                            '986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba'
                            ? 'Input your WiFi Name (SSID).'
                            : "Input your WiFi Password."),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: characteristic.uuid.toString() == '986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba' ? _writeController : _writeControllerPass,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text("Confirm"),
                            onPressed: () {
                              if(characteristic.uuid.toString() == '986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba'){
                                characteristic.write(
                                    utf8.encode(_writeController.value.text));
                              } else {
                                characteristic.write(
                                    utf8.encode(_writeControllerPass.value.text));
                              }

                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: const Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    // if (characteristic.properties.notify) {
    //   buttons.add(
    //     ButtonTheme(
    //       minWidth: 10,
    //       height: 20,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 4),
    //         child: ElevatedButton(
    //           child:
    //               const Text('NOTIFY', style: TextStyle(color: Colors.white)),
    //           onPressed: () async {
    //             characteristic.value.listen((value) {
    //               setState(() {
    //                 widget.readValues[characteristic.uuid] = value;
    //               });
    //             });
    //             await characteristic.setNotifyValue(true);
    //           },
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Widget> containers = <Widget>[];

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = <Widget>[];
      if (service.uuid.toString() == "715200cc-f5df-49cd-9dcc-d232762fae77") {
        for (BluetoothCharacteristic characteristic
        in service.characteristics) {
          characteristicsWidget.add(
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(characteristic.uuid.toString() ==
                          '986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba'
                          ? 'WIFI NAME'
                          : 'WIFI PASSWORD'),
                      // Text(characteristic.uuid.toString(),
                      //     style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      ..._buildReadWriteNotifyButton(characteristic),
                    ],
                  ),
                  // Row(
                  //   children: <Widget>[
                  //     Text(characteristic.uuid.toString() ==
                  //             '986bd3e6-ba7c-4ae2-a2aa-e40d52b4b8ba'
                  //         ? 'WIFI NAME'
                  //         : "PASSWORD"),
                  //     // Text('Value: ${widget.readValues[characteristic.uuid]}'),
                  //   ],
                  // ),
                  const Divider(),
                ],
              ),
            ),
          );
        }
        containers.add(
          ExpansionTile(
              initiallyExpanded: true,
              title: const Text("Network"),
              children: characteristicsWidget),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: Icon(Icons.home_filled, color: Colors.white),
        onPressed: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => Home())),
      ),
      title: Text(widget.title),
      flexibleSpace: Container(
        decoration:
        BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/auth_screen_bg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      foregroundColor: Colors.grey[200],
      elevation: 5.0,
    ),
    body: _buildView(),
  );
}