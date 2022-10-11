import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data/configs.dart';

class ClickyListView extends StatefulWidget {
  const ClickyListView({
    Key? key,
    required this.itemBuilder,
    required this.itemCount,
    required this.onChanged,
    this.sideGap = 0,
    this.initialIndex = 0,
    required this.listItemSize,
    this.scrollDirection = Axis.vertical,
    this.controller,
  }) : super(key: key);

  final Widget Function(BuildContext context, int index, bool seleced)
      itemBuilder;
  final int itemCount;
  final ValueChanged<int> onChanged;
  final double sideGap;
  final int initialIndex;
  final double listItemSize;
  final Axis scrollDirection;
  final ClickyListScrollController? controller;

  @override
  State<ClickyListView> createState() => _ClickyListViewState();
}

class _ClickyListViewState extends State<ClickyListView> {
  @override
  void initState() {
    super.initState();
    widget.controller?._addState(this);
  }

  late int _currentIndex = widget.initialIndex;

  late final _scrollController = ScrollController(
    initialScrollOffset: widget.initialIndex * widget.listItemSize,
  );

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollUpdateNotification) {
          final computedIndex =
              (scrollInfo.metrics.pixels / widget.listItemSize).round();
          _softSetIndex(computedIndex);
          return true;
        } else if (scrollInfo is UserScrollNotification &&
            scrollInfo.direction == ScrollDirection.idle) {
          final computedIndex =
              (scrollInfo.metrics.pixels / widget.listItemSize).round();
          _hardSetIndex(computedIndex);
          return true;
        }
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: widget.scrollDirection,
                padding: widget.scrollDirection == Axis.vertical
                    ? EdgeInsets.symmetric(
                        horizontal: widget.sideGap,
                        vertical:
                            constraints.maxHeight / 2 - widget.listItemSize / 2,
                      )
                    : EdgeInsets.symmetric(
                        vertical: widget.sideGap,
                        horizontal:
                            constraints.maxWidth / 2 - widget.listItemSize / 2,
                      ),
                itemCount: widget.itemCount,
                itemBuilder: (context, index) => SizedBox(
                  width: widget.scrollDirection == Axis.horizontal
                      ? widget.listItemSize
                      : null,
                  height: widget.scrollDirection == Axis.vertical
                      ? widget.listItemSize
                      : null,
                  child: widget.itemBuilder(
                      context, index, index == _currentIndex),
                ),
              ),
              // Container(
              //   width: constraints.maxWidth / 2 - widget.listItemSize / 2,
              //   color: Colors.yellow.withOpacity(0.2),
              // )
            ],
          );
        },
      ),
    );
  }

  void _softSetIndex(int newIndex, {bool animate = false}) {
    if (_currentIndex == newIndex) return;
    newIndex = newIndex.clamp(0, widget.itemCount - 1);

    if (animate) {
      _scrollController.jumpTo(
        newIndex * widget.listItemSize,
        // duration: Duration(milliseconds: 100),
        // curve: defaultAnimationCurve,
      );
    }
    setState(() {
      _currentIndex = newIndex;
    });
  }

  void _hardSetIndex(int newIndex) {
    newIndex = newIndex.clamp(0, widget.itemCount - 1);
    setState(() {
      _currentIndex = newIndex;
    });
    _reposition(newIndex);
    widget.onChanged(newIndex);
  }

  void _reposition(int newIndex) {
    Future.microtask(() {
      _scrollController.animateTo(
        newIndex * widget.listItemSize,
        duration: defaultAnimationDuration,
        curve: defaultAnimationCurve,
      );
    });
  }

  void jumpToIndex(int newIndex) {
    _scrollController.animateTo(
      newIndex * widget.listItemSize,
      duration: defaultAnimationDuration,
      curve: defaultAnimationCurve,
    );
  }

  void jumpBy(int delta, bool fast) {
    final newIndex = (_currentIndex + delta).clamp(0, widget.itemCount - 1);
    if (fast) {
      _softSetIndex(newIndex, animate: true);
    } else {
      _hardSetIndex(newIndex);
    }
  }
}

class ClickyListScrollController {
  _ClickyListViewState? _state;

  void _addState(_ClickyListViewState state) {
    _state = state;
  }

  void jumpToIndex(int newIndex) {
    _state?.jumpToIndex(newIndex);
  }

  void goPreviousBy(int delta, {bool fast = false}) {
    _state?.jumpBy(-delta, fast);
  }

  void goNextBy(int delta, {bool fast = false}) {
    _state?.jumpBy(delta, fast);
  }
}
