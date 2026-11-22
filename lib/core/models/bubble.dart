import 'package:flutter/material.dart';
import '../constants/game_colors.dart';

enum BubbleColor {
  cyan,
  pink,
  gold,
  green,
  purple,
  orange,
  blue,
}

extension BubbleColorExtension on BubbleColor {
  Color get color {
    switch (this) {
      case BubbleColor.cyan:
        return GameColors.bubbleCyan;
      case BubbleColor.pink:
        return GameColors.bubblePink;
      case BubbleColor.gold:
        return GameColors.bubbleGold;
      case BubbleColor.green:
        return GameColors.bubbleGreen;
      case BubbleColor.purple:
        return GameColors.bubblePurple;
      case BubbleColor.orange:
        return GameColors.bubbleOrange;
      case BubbleColor.blue:
        return GameColors.bubbleBlue;
    }
  }

  Color get glowColor {
    switch (this) {
      case BubbleColor.cyan:
        return GameColors.neonCyan;
      case BubbleColor.pink:
        return GameColors.neonPink;
      case BubbleColor.gold:
        return GameColors.neonGold;
      case BubbleColor.green:
        return GameColors.neonGreen;
      case BubbleColor.purple:
        return GameColors.neonPurple;
      case BubbleColor.orange:
        return GameColors.neonOrange;
      case BubbleColor.blue:
        return GameColors.neonBlue;
    }
  }

  String get displayName {
    switch (this) {
      case BubbleColor.cyan:
        return 'Cyan';
      case BubbleColor.pink:
        return 'Pink';
      case BubbleColor.gold:
        return 'Gold';
      case BubbleColor.green:
        return 'Green';
      case BubbleColor.purple:
        return 'Purple';
      case BubbleColor.orange:
        return 'Orange';
      case BubbleColor.blue:
        return 'Blue';
    }
  }
}

enum BubbleType {
  normal,
  bomb,
  rainbow,
  lightning,
  fire,
}

class Bubble {
  final String id;
  final int row;
  final int col;
  final BubbleColor? color;
  final BubbleType type;

  // Animation states
  bool isPopping;
  bool isFalling;
  double opacity;
  double scale;
  Offset fallOffset;
  Offset fallVelocity;

  Bubble({
    required this.id,
    required this.row,
    required this.col,
    this.color,
    this.type = BubbleType.normal,
    this.isPopping = false,
    this.isFalling = false,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.fallOffset = Offset.zero,
    this.fallVelocity = Offset.zero,
  });

  bool get isSpecial => type != BubbleType.normal;

  Bubble copyWith({
    String? id,
    int? row,
    int? col,
    BubbleColor? color,
    BubbleType? type,
    bool? isPopping,
    bool? isFalling,
    double? opacity,
    double? scale,
    Offset? fallOffset,
    Offset? fallVelocity,
  }) {
    return Bubble(
      id: id ?? this.id,
      row: row ?? this.row,
      col: col ?? this.col,
      color: color ?? this.color,
      type: type ?? this.type,
      isPopping: isPopping ?? this.isPopping,
      isFalling: isFalling ?? this.isFalling,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      fallOffset: fallOffset ?? this.fallOffset,
      fallVelocity: fallVelocity ?? this.fallVelocity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row': row,
      'col': col,
      'color': color?.name,
      'type': type.name,
    };
  }

  factory Bubble.fromJson(Map<String, dynamic> json) {
    return Bubble(
      id: json['id'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      color: json['color'] != null
          ? BubbleColor.values.firstWhere((e) => e.name == json['color'])
          : null,
      type: BubbleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => BubbleType.normal,
      ),
    );
  }
}
