import 'package:flutter/cupertino.dart';

class CustomButtonAppBar extends StatelessWidget {
  final void Function()? onPressed;
  final Widget widget;

  const CustomButtonAppBar(
      {Key? key, required this.widget, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF232527),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              offset: Offset(3, 3),
              blurRadius: 20,
              color: Color(0xFF13151A),
            ),
            BoxShadow(
              offset: Offset(-3, -3),
              blurRadius: 20,
              color: Color(0xff5D6167),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff5D6167).withOpacity(0.0),
              const Color(0xff13151A).withOpacity(1),
            ],
          ),
        ),
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF232527),
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xff545659).withOpacity(0.0),
                const Color(0xff232629).withOpacity(1),
              ],
            ),
          ),
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.8,
                color: const Color(0xFF232527),
              ),
              color: const Color(0xff545659),
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xff5D6167).withOpacity(0.0),
                  const Color(0xff13151A).withOpacity(1),
                ],
              ),
            ),
            child: Align(
              alignment: Alignment.center,
              child: widget,
            ),
          ),
        ),
      ),
    );
  }
}
