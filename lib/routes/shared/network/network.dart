import 'dart:async';
import 'dart:io';

import 'package:breez/services/breezlib/breez_bridge.dart';
import 'package:breez/services/breezlib/data/rpc.pb.dart';
import 'package:breez/services/injector.dart';
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/widgets/back_button.dart' as backBtn;
import 'package:breez/widgets/error_dialog.dart';
import 'package:flutter/material.dart';

class NetworkPage extends StatefulWidget {
  NetworkPage({Key key}) : super(key: key);

  @override
  NetworkPageState createState() {
    return NetworkPageState();
  }
}

class NetworkPageState extends State<NetworkPage> {
  final _formKey = GlobalKey<FormState>();
  BreezBridge _breezLib;
  ScrollController _scrollController = new ScrollController();
  final _peerController = TextEditingController();
  _NetworkData _data = new _NetworkData();

  @override
  Widget build(BuildContext context) {
    String _title = "Network";
    return ButtonTheme(
      height: 28.0,
      child: new Scaffold(
        appBar: new AppBar(
            iconTheme: theme.appBarIconTheme,
            textTheme: theme.appBarTextTheme,
            backgroundColor: theme.BreezColors.blue[500],
            automaticallyImplyLeading: false,
            leading: backBtn.BackButton(),
            title: new Text(
              _title,
              style: theme.appBarTextStyle,
            ),
            elevation: 0.0),
        body: new Padding(
            padding: new EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: Form(
                key: _formKey,
                child: new ListView(scrollDirection: Axis.vertical, controller: _scrollController, children: <Widget>[
                  new Column(children: <Widget>[
                    new Container(
                      padding: new EdgeInsets.only(top: 8.0),
                      child: new TextFormField(
                        decoration: new InputDecoration(labelText: "Bitcoin Node (BIP 157)"),
                        style: theme.FieldTextStyle.textStyle,
                        onSaved: (String value) {
                          this._data.peer = value;
                        },
                        validator: (val) => null,
                        controller: _peerController,
                      ),
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        OutlineButton(
                          borderSide: BorderSide(color: Colors.white),
                          child: new Text(
                            "Reset",
                          ),
                          onPressed: () async {
                            await _reset();
                            _promptForRestart();
                          },
                        ),
                        SizedBox(width: 12.0),
                        OutlineButton(
                          borderSide: BorderSide(color: Colors.white),
                          child: new Text(
                            "Save",
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              if (this._data.peer.isNotEmpty) {
                                await _breezLib.setPeers([this._data.peer]);
                              } else {
                                await _reset();
                              }
                              await _promptForRestart();
                            }
                          },
                        )
                      ],
                    )
                  ])
                ]))),
      ),
    );
  }

  @override
  void dispose() {
    _peerController.removeListener(_onChangePeer);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _breezLib = new ServiceInjector().breezBridge;
    _loadData();
    _peerController.addListener(_onChangePeer);
  }

  void _loadData() async {
    await _loadPeer();
  }

  Future _loadPeer() async {
    Peers peers = await _breezLib.getPeers();
    String peer = '';
    if (peers.peer.length > 0) {
      peer = peers.peer[0];
    }
    setState(() {
      _data.peer = peer;
      _data.isDefault = peers.isDefault;
    });
    _peerController.text = peer;
  }

  void _onChangePeer() {
    String peer = _peerController.text;
    setState(() {
      _data.peer = peer;
    });
  }

  Future<bool> _promptForRestart() {
    return promptAreYouSure(
            context, null, Text("Please restart Breez to switch to the new Bitcoin Node configuration.", style: theme.alertStyle),
            cancelText: "Cancel", okText: "Exit Breez")
        .then((shouldExit) {
      if (shouldExit) {
        exit(0);
      }
      return true;
    });
  }

  Future _reset() async {
    await _breezLib.setPeers([]);
    return _loadData();
  }
}

class _NetworkData {
  String peer = '';
  bool isDefault = false;
}
