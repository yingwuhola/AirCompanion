import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text('MQTT Feeds')), body: MyListView()));
  }
}

class MyListView extends StatefulWidget {
  @override
  ListViewState createState() {
    return ListViewState();
  }
}

class ListViewState extends State<MyListView> {
  late List<String> feeds;

  @override
  void initState() {
    super.initState();
    feeds = [];
    startMQTT(); //调用mqtt
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(feeds[index]),
        );
      },
    );
  }

  updateList(String s) {
    setState(() {
      //feeds.add(s);
      feeds.insert(0,s); //正序出现

    });
  }

  Future<void> startMQTT() async {
    final client = MqttServerClient('test.mosquitto.org', '<my client id>');
    client.port = 1883;
    client.setProtocolV311();
    client.keepAlivePeriod = 30;
    //final String username = 'username';
    //final String password = 'password';
    try {
      //await client.connect(username, password);
      await client.connect();
    } catch (e) {
      print('client exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Mosquitto client connected');
    } else {
      print(
          'ERROR Mosquitto client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
      client.disconnect();
    }
    const topic = 'SCD41-CO2-1'; //订阅主题
    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final receivedMessage = c![0].payload as MqttPublishMessage;
      final messageString = MqttPublishPayload.bytesToStringAsString(
          receivedMessage.payload.message);
      print(
          'Change notification:: topic is <${c[0].topic}>, payload is <-- $messageString -->');
      updateList(messageString);
    });
  }
}
