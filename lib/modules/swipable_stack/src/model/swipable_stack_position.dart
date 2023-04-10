part of '../swipable_stack.dart';

/// The information to record swiping position for [SwipableStack].
class SwipableStackPosition {
  const SwipableStackPosition({
    required this.start,
    required this.current,
    required this.local,
  });

  factory SwipableStackPosition.notMoving() {
    return const SwipableStackPosition(
      start: Offset.zero,
      current: Offset.zero,
      local: Offset.zero,
    );
  }

  factory SwipableStackPosition.readyToSwipeAnimation({
    required SwipeDirection direction,
    required BoxConstraints areaConstraints,
  }) {
    Offset localPosition() {
      switch (direction) {
        case SwipeDirection.left:
          return Offset(
            areaConstraints.maxWidth * 0.8,
            areaConstraints.maxHeight * 0.4,
          );
        case SwipeDirection.right:
          return Offset(
            areaConstraints.maxWidth * 0.2,
            areaConstraints.maxHeight * 0.4,
          );
        case SwipeDirection.up:
          return Offset(
            areaConstraints.maxWidth / 2,
            areaConstraints.maxHeight,
          );
        case SwipeDirection.down:
          return Offset(
            areaConstraints.maxWidth / 2,
            0,
          );
      }
    }

    return SwipableStackPosition(
      start: Offset.zero,
      current: Offset.zero,
      local: localPosition(),
    );
  }

  /// The start point of swipe action.
  final Offset start;

  /// The current point of swipe action.
  final Offset current;

  /// The point which user is touching in the component.
  final Offset local;

  @override
  bool operator ==(Object other) =>
      other is SwipableStackPosition &&
      start == other.start &&
      current == other.current &&
      local == other.local;

  @override
  int get hashCode =>
      runtimeType.hashCode ^ start.hashCode ^ current.hashCode ^ local.hashCode;

  @override
  String toString() => '$SwipableStackPosition('
      'startPosition:$start,'
      'currentPosition:$current,'
      'localPosition:$local'
      ')';

  SwipableStackPosition copyWith({
    Offset? startPosition,
    Offset? currentPosition,
    Offset? localPosition,
  }) =>
      SwipableStackPosition(
        start: startPosition ?? start,
        current: currentPosition ?? current,
        local: localPosition ?? local,
      );

  /// Difference offset from [start] to [current] .
  Offset get difference {
    return current - start;
  }
}
