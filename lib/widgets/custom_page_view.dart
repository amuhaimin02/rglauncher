import 'package:flutter/material.dart';

class CustomPageView extends StatefulWidget {
  const CustomPageView.builder({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.onPageChanged,
  }) : super(key: key);

  final PageController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final ValueChanged<int>? onPageChanged;

  @override
  State<CustomPageView> createState() => _CustomPageViewState();
}

class _CustomPageViewState extends State<CustomPageView> {
  double currentPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onPageMove);
  }

  @override
  void dispose() {
    widget.controller.removeListener(onPageMove);
    super.dispose();
  }

  void onPageMove() {
    setState(() {
      currentPageValue = widget.controller.page!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget.controller,
      itemCount: widget.itemCount,
      itemBuilder: (context, position) {
        // final animationValue = currentPageValue - position;
        // if (position == currentPageValue.floor()) {
        //   // Page is being swiped from
        //
        //   return Transform(
        //     transform: Matrix4.identity()
        //       ..rotateY(animationValue)
        //       ..rotateZ(animationValue),
        //     child: widget.itemBuilder(context, position),
        //   );
        // } else if (position == currentPageValue.floor() + 1) {
        //   // Page is being swiped to
        //   return Transform(
        //     transform: Matrix4.identity()
        //       ..rotateY(animationValue)
        //       ..rotateZ(animationValue),
        //     child: widget.itemBuilder(context, position),
        //   );
        // } else {
        // Page is being off screen
        return widget.itemBuilder(context, position);
        // }
      },
      onPageChanged: widget.onPageChanged,
    );
  }
}
