parseImage(Map<String, dynamic> json) {
  var imageJson = json['thumbnail'];
  return imageJson['path'] + '.' + imageJson['extension'];
}

class MarvelHero {
  final int id;
  final String name;
  final String description;
  final String image;
  final UrlHolder urlHolder;

  MarvelHero(
      {this.id, this.name, this.image, this.description, this.urlHolder});

  factory MarvelHero.fromJson(Map<String, dynamic> json) {
    return MarvelHero(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        image: parseImage(json),
        urlHolder: UrlHolder.fromJson(json));
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
  final String url;

  MarvelComics({this.id, this.title, this.image, this.description, this.url});

  factory MarvelComics.fromJson(Map<String, dynamic> json) {
    return MarvelComics(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      url: UrlHolder.fromJson(json).detailUrl,
      image: parseImage(json),
    );
  }

  @override
  String toString() {
    return 'MarvelComics{id: $id, name: $title, image: $image}';
  }
}

class UrlHolder {
  final String detailUrl;
  final String wikiUrl;
  final String comicslUrl;

  UrlHolder({this.detailUrl, this.wikiUrl, this.comicslUrl});

  factory UrlHolder.fromJson(Map<String, dynamic> json) {
    String detailUrl;
    String wikiUrl;
    String comicslUrl;

    var urlsList = json['urls'] as List<dynamic>;
    print(urlsList);
    urlsList.forEach((jsonUrl) {
      final urlStr = jsonUrl['url'];
      var type = jsonUrl['type'];
      switch (type) {
        case 'detail':
          detailUrl = urlStr;
          break;
        case 'wiki':
          wikiUrl = urlStr;
          break;
        case 'comiclink':
          comicslUrl = urlStr;
          break;
      }
    });

    return UrlHolder(
        detailUrl: detailUrl, wikiUrl: wikiUrl, comicslUrl: comicslUrl);
  }
}
