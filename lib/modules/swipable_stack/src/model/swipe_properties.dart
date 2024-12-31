import 'package:flutter/rendering.dart';
import '../swipable_stack.dart';

abstract class SwipeProperties {
  const SwipeProperties({
    required this.index,
    required this.constraints,
    required this.direction,
    required this.swipeProgress,
  });

  ///Index of the current item.
  final int index;

  ///[Constraints] of the whole stack.
  final BoxConstraints constraints;

  ///Direction of the current swipe action.
  final SwipeDirection? direction;

  ///Progress of the current swipe action.
  final double swipeProgress;
}

class OverlaySwipeProperties extends SwipeProperties {
  const OverlaySwipeProperties({
    required super.index,
    required super.constraints,
    required super.direction,
    required super.swipeProgress,
  }) : super();

  ///Direction of the current swipe action.
  @override
  SwipeDirection get direction => super.direction!;
}

class ItemSwipeProperties extends SwipeProperties {
  const ItemSwipeProperties({
    required super.index,
    required this.stackIndex,
    required super.constraints,
    required super.direction,
    required super.swipeProgress,
  }) : super();

  ///Index of the current item in the stack.
  ///The top item of the stack has index 0 and the rewind item has index -1.
  final int stackIndex;
}
