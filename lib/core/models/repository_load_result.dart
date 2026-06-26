class RepositoryLoadResult<T> {
  const RepositoryLoadResult({
    required this.data,
    required this.fromCache,
    this.errorMessage,
  });

  final T data;
  final bool fromCache;
  final String? errorMessage;
}
