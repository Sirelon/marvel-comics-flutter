parseImage(Map<String, dynamic> json) {
  var imageJson = json['thumbnail'];
  return imageJson['path'] + '.' + imageJson['extension'];
}

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
      image: parseImage(json));
  }

  @override
  String toString() {
    return 'Hero{id: $id, name: $name, image: $image}';
  }
}

class MarvelComics {
  final int id;
  final String title;
  final String description;
  final String image;

  MarvelComics({this.id, this.title, this.image, this.description});

  factory MarvelComics.fromJson(Map<String, dynamic> json) {
    return MarvelComics(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: parseImage(json),
    );
  }

  @override
  String toString() {
    return 'MarvelComics{id: $id, name: $title, image: $image}';
  }
}
