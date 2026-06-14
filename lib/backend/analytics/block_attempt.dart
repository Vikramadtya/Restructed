class BlockAttempt {
  final int id;
  final String domain;
  final DateTime attemptedAt;

  const BlockAttempt({
    required this.id,
    required this.domain,
    required this.attemptedAt,
  });
}
