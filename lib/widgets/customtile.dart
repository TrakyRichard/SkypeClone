import 'package:flutter/material.dart';
import 'package:skype/utils/universal_variable.dart';

class CustomTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget icon;
  final Widget subTitle;
  final EdgeInsets margin;
  final Widget trailing;
  final bool mini;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const CustomTile(
      {Key key,
      @required this.leading,
      @required this.title,
      this.icon,
      @required this.subTitle,
      this.margin = const EdgeInsets.all(0),
      this.trailing,
      this.mini = true,
      this.onTap,
      this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: margin,
        padding: EdgeInsets.symmetric(horizontal: mini ? 10 : 0),
        child: Row(
          children: [
            leading,
            Expanded(
                child: Container(
              margin: EdgeInsets.only(left: mini ? 10 : 15),
              padding: EdgeInsets.symmetric(vertical: mini ? 3 : 20),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1, color: UniversalVariables.separatorColor))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          icon ?? Container(),
                          icon != null ? icon : Container(),
                          subTitle
                        ],
                      )
                    ],
                  ),
                  trailing ?? Container()
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
