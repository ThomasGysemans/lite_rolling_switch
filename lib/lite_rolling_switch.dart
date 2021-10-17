library lite_rolling_switch;

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';

/// Customable and attractive Switch button.
/// Currently, you can't change the widget
/// width and height properties.
///
/// As well as the classical Switch Widget
/// from flutter material, the following
/// arguments are required:
///
/// * [value] determines whether this switch is on or off.
/// * [onChanged] is called when the user toggles the switch on or off.
class LiteRollingSwitch extends StatefulWidget {
  /// A required boolean that sets the value of the button.
  /// * "on" = `true`
  /// * "off" = `false`
  final bool value;

  /// A function called every time there is a change in state. (required)
  final Function(bool) onChanged;

  /// Text displayed when the [value] is `false`. By default
  /// * "Off"
  final String textOff;

  /// Text displayed when the [value] is `true`. By default:
  /// * "On"
  final String textOn;

  /// Color shown when the [value] is `true`. By default:
  /// * `Colors.green`
  final Color colorOn;

  /// Color shown when the [value] is `false`. By default:
  /// * `Colors.red`
  final Color colorOff;

  /// The size of the text. By default:
  /// * `14.0`
  final double textSize;

  /// The duration of the animation. By default:
  /// * `Duration(milliseconds: 600)`
  final Duration animationDuration;

  /// Text displayed when the [value] is `true`. By default:
  /// * `Icons.check`
  final IconData iconOn;

  /// Text displayed when the [value] is `false`. By default:
  /// * `Icons.flag`
  final IconData iconOff;

  /// Additional action on tap.
  final Function? onTap;

  /// Additional action on double tap.
  final Function? onDoubleTap;

  /// Additional action on swipe.
  final Function? onSwipe;

  const LiteRollingSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
    this.textOff = "Off",
    this.textOn = "On",
    this.textSize = 14.0,
    this.colorOn = Colors.green,
    this.colorOff = Colors.red,
    this.iconOff = Icons.flag,
    this.iconOn = Icons.check,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onTap,
    this.onDoubleTap,
    this.onSwipe,
  }) : super(key: key);

  @override
  _RollingSwitchState createState() => _RollingSwitchState();
}

class _RollingSwitchState extends State<LiteRollingSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  late bool turnState;

  double value = 0.0;

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: widget.animationDuration,
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    animationController.addListener(() {
      setState(() {
        value = animation.value;
      });
    });
    turnState = widget.value;
    _determine();
  }

  @override
  Widget build(BuildContext context) {
    Color transitionColor = Color.lerp(widget.colorOff, widget.colorOn, value)!;

    return GestureDetector(
      onDoubleTap: () {
        _action();
        if (widget.onDoubleTap != null) widget.onDoubleTap!();
      },
      onTap: () {
        _action();
        if (widget.onTap != null) widget.onTap!();
      },
      onPanEnd: (details) {
        _action();
        if (widget.onSwipe != null) widget.onSwipe!();
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 130,
        decoration: BoxDecoration(
          color: transitionColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          children: <Widget>[
            Transform.translate(
              offset: Offset(10 * value, 0), //original
              child: Opacity(
                opacity: (1 - value).clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(right: 10),
                  alignment: Alignment.centerRight,
                  height: 40,
                  child: Text(
                    widget.textOff,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.textSize,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(10 * (1 - value), 0), // original
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 5),
                  alignment: Alignment.centerLeft,
                  height: 40,
                  child: Text(
                    widget.textOn,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.textSize,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(80 * value, 0),
              child: Transform.rotate(
                angle: lerpDouble(0, 2 * pi, value)!,
                child: Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: Icon(
                            widget.iconOn,
                            size: 21,
                            color: transitionColor,
                          ),
                        ),
                      ),
                      Center(
                        child: Opacity(
                          opacity: (1 - value).clamp(0.0, 1.0),
                          child: Icon(
                            widget.iconOff,
                            size: 21,
                            color: transitionColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _action() {
    _determine(changeState: true);
  }

  /// Handles the animation.
  _determine({bool changeState = false}) {
    setState(() {
      if (changeState) turnState = !turnState;
      (turnState)
          ? animationController.forward()
          : animationController.reverse();

      widget.onChanged(turnState);
    });
  }
}
