class MarvelHero {
  final int id;
  final String name;
  final String description;
  final String image;

  MarvelHero({this.id, this.name, this.image, this.description});

  factory MarvelHero.fromJson(Map<String, dynamic> json) {
    return MarvelHero(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: parseImage(json),
    );
  }

  static parseImage(Map<String, dynamic> json) {
    var imageJson = json['thumbnail'];
    return imageJson['path'] + '.' + imageJson['extension'];
  }

  @override
  String toString() {
    return 'Hero{id: $id, name: $name, image: $image}';
  }
}
