class Favorite {
  final int churchId;

  Favorite({required this.churchId});

  Map<String, dynamic> toMap() {
    return {
      'tid': churchId,
    };
  }
}
