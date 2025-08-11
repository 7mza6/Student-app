class PendingOperation {
  final int? id;
  final String type;
  final String payload; // JSON string
  final DateTime createdAt;

  PendingOperation({
    this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'type': type,
    'payload': payload,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory PendingOperation.fromMap(Map<String, Object?> map) => PendingOperation(
    id: map['id'] as int?,
    type: map['type'] as String,
    payload: map['payload'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );
}