import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:marvel_heroes/entities.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart' as crypto;

// TODO Should be moved to some security place
String _baseUrl = "https://gateway.marvel.com:443/v1/public";
String _publicKey = "8b73058dfc8fd2dcf0a11a355f2b7197";
String _privateKey = "60191d7af4cfeb521f81845f955f10488ddff082";

int _limit = 20;

Future<List<MarvelHero>> fetchHeroes(int page) async {
  return fetchHeroesWithFilters(page, Order.NAME_ASK, "");
}

Future<List<MarvelHero>> fetchHeroesWithFilters(int page, Order order,
    String search) async {
  final ts = DateTime
      .now()
      .millisecondsSinceEpoch;
  final hash = generateMd5("$ts$_privateKey$_publicKey");
  final queryParameters = "ts=$ts&apikey=$_publicKey&hash=$hash";
  final limitAndOffset = "limit=$_limit&offset=${_limit * page}";

  final orderByVal = getOrderValueString(order);
  final orderQuery = "orderBy=$orderByVal";

  final response = await http.get(
      "$_baseUrl/characters?$queryParameters&$limitAndOffset&$orderQuery");

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON

    var wholeJson = json.decode(response.body);
    var dataJson = wholeJson["data"];
    List<MarvelHero> heroes = List<MarvelHero>();
    for (var heroJson in dataJson["results"]) {
      heroes.add(MarvelHero.fromJson(heroJson));
    }
    return heroes;
  } else {
    // If that response was not OK, throw an error.
    throw Exception(response.body);
  }
}

String getOrderValueString(Order order) {
  switch (order) {
    case Order.NAME_ASK:
      return "name";
    case Order.NAME_DESC:
      return "-name";
    case Order.MODIFIED_ASK:
      return "modified";
    case Order.MODIFIED_DESC:
      return "-modified";
  }
}

///Generate MD5 hash
generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var md5 = crypto.md5;
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}

enum Order { NAME_ASK, NAME_DESC, MODIFIED_ASK, MODIFIED_DESC }
