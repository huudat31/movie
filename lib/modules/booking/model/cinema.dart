class Cinema {
  final String id;
  final String name;
  final String address;
  final String? imageUrl;
  final List<String> facilities;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    this.imageUrl,
    this.facilities = const [],
  });

  factory Cinema.fromMap(Map<String, dynamic> map, String id) {
    return Cinema(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['imageUrl'],
      facilities: List<String>.from(map['facilities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'imageUrl': imageUrl,
      'facilities': facilities,
    };
  }
}
