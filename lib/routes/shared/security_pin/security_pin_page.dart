import 'package:breez/bloc/account/account_actions.dart';
import 'package:breez/bloc/blocs_provider.dart';
import 'package:breez/bloc/user_profile/breez_user_model.dart';
import 'package:breez/bloc/user_profile/security_model.dart';
import 'package:breez/bloc/user_profile/user_profile_bloc.dart';
import 'package:breez/routes/shared/security_pin/prompt_pin_code.dart';
import 'package:breez/routes/shared/security_pin/security_pin_warning_dialog.dart';
import 'package:breez/theme_data.dart' as theme;
import 'package:breez/widgets/back_button.dart' as backBtn;
import 'package:breez/widgets/route.dart';
import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  SecurityPage({Key key}) : super(key: key);

  @override
  SecurityPageState createState() {
    return SecurityPageState();
  }
}

class SecurityPageState extends State<SecurityPage> {
  UserProfileBloc _userProfileBloc;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _userProfileBloc = AppBlocsProvider.of<UserProfileBloc>(context);
      _isInit = true;
    }
  }

  void _updateSecurityModel(SecurityModel securityModel, {String pinCode, bool secureBackupWithPin, bool delete = false}) {
    UpdateSecurityModel setPinCodeAction = UpdateSecurityModel(
        pinCode: (delete) ? null : (pinCode ?? securityModel.pinCode), secureBackupWithPin: (delete) ? false : (secureBackupWithPin ?? securityModel.secureBackupWithPin));
    _userProfileBloc.userActionsSink.add(setPinCodeAction);
  }

  @override
  Widget build(BuildContext context) {
    String _title = "Security PIN";
    return StreamBuilder<BreezUserModel>(
        stream: _userProfileBloc.userStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            return Scaffold(
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
              body: ListView(
                children: _buildSecurityPINTiles(snapshot.data.securityModel),
              ),
            );
          }
        });
  }

  List<Widget> _buildSecurityPINTiles(SecurityModel securityModel) {
    List<Widget> _tiles = List();
    final _disablePINTile = _buildDisablePINTile(securityModel);
    final _secureBackupWithPinTile = _buildSecureBackupWithPinTile(securityModel);
    final _changePINTile = _buildChangePINTile();
    _tiles..add(_disablePINTile);
    if (securityModel.pinCode != null) _tiles..add(Divider())..add(_secureBackupWithPinTile)..add(Divider())..add(_changePINTile);
    return _tiles;
  }

  ListTile _buildSecureBackupWithPinTile(SecurityModel securityModel) {
    return ListTile(
      title: Text(
        "Use in Backup/Restore",
        style: TextStyle(color: Colors.white),
      ),
      trailing: Switch(
        value: securityModel.secureBackupWithPin,
        activeColor: Colors.white,
        onChanged: (bool value) {
          if (this.mounted) {
            if (value) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return SecurityPINWarningDialog();
                  }).then((approved) {
                _updateSecurityModel(securityModel, secureBackupWithPin: approved);
              });
            } else {
              _updateSecurityModel(securityModel, secureBackupWithPin: value);
            }
          }
        },
      ),
    );
  }

  ListTile _buildChangePINTile() {
    return ListTile(
      title: Text(
        "Change PIN",
        style: TextStyle(color: Colors.white),
      ),
      trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: () {
        Navigator.of(context).push(
          new FadeInRoute(
            builder: (BuildContext context) {
              return LockScreen(
                label: "Enter your current PIN",
                dismissible: true,
                changePassword: true,
              );
            },
          ),
        );
      },
    );
  }

  ListTile _buildDisablePINTile(SecurityModel securityModel) {
    return ListTile(
      title: Text(
        securityModel.pinCode != null ? "Activate PIN" : "Create PIN",
        style: TextStyle(color: Colors.white),
      ),
      trailing: securityModel.pinCode != null
          ? Switch(
              value: securityModel.pinCode != null,
              activeColor: Colors.white,
              onChanged: (bool value) {
                if (this.mounted) {
                  _updateSecurityModel(securityModel, pinCode: null, delete: !value);
                }
              },
            )
          : Icon(Icons.keyboard_arrow_right, color: Colors.white, size: 30.0),
      onTap: securityModel.pinCode != null
          ? null
          : () {
              Navigator.of(context).push(
                new FadeInRoute(
                  builder: (BuildContext context) {
                    return LockScreen(
                      label: "Enter your new PIN",
                      dismissible: true,
                      setPassword: true,
                    );
                  },
                ),
              );
            },
    );
  }
}