import 'package:flutter/material.dart';
import 'package:breez/bloc/marketplace/vendor_model.dart';
import 'package:breez/widgets/route.dart';
import 'package:breez/routes/user/marketplace/vendor_webview.dart';
import 'package:breez/theme_data.dart' as theme;

class VendorRow extends StatelessWidget {
  final VendorModel _vendor;

  VendorRow(this._vendor);

  @override
  Widget build(BuildContext context) {
    final _vendorLogo = _vendor.logo != null
        ? Image(
            image: AssetImage(_vendor.logo),
            height: 55.0,
            width: 55.0,
          )
        : Container();

    final _vendorCard = new GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              FadeInRoute(
                builder: (_) =>
                    new VendorWebViewPage(_vendor.url, _vendor.name),
              ));
        },
        child: Container(
          margin: EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              color: _vendor.bgColor,
              border: Border.all(
                  color: Colors.white, style: BorderStyle.solid, width: 1.0),
              borderRadius: BorderRadius.circular(14.0)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _vendorLogo,
              Text(_vendor.name, style: theme.vendorTitleStyle),
            ],
          ),
        ));

    return _vendorCard;
  }
}
