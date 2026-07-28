void restoreSnapshotList<T, S>({
  required List<T> target,
  required Iterable<S> snapshots,
  required T Function(S snapshot) restore,
}) {
  target
    ..clear()
    ..addAll(snapshots.map(restore));
}
