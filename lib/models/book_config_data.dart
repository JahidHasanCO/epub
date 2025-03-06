import 'package:epub/utils/extension/color.dart';
import 'package:flutter/material.dart';

class BookConfigData {
  BookConfigData({
    required this.name,
    required this.authors,
    required this.wordsPerSpineItem,
    required this.description,
    required this.chapters,
    required this.coverSize,
    required this.coverColor,
    required this.rating,
    required this.progressSpine,
    required this.characterMetadataName,
  });

  BookConfigData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        authors =
        json['authors'].map<String>((name) => name.toString()).toList(),
        wordsPerSpineItem =
        (json['wordsPerSpineItem'] as List).map((e) => e as int).toList(),
        chapters = json['chapters']
            .map<String>((chapter) => chapter.toString())
            .toList(),
        description = json['description'],
        coverSize = Size(json['coverSize'][0], json['coverSize'][1]),
        coverColor = HexColor(json['coverColor'] as String? ?? '#FFFFFF'),
        rating = json['rating'],
        progressSpine = json['progressSpine'] as double,
        characterMetadataName = json['characterMetadataName'];

  String name;
  List<String> authors;
  List<int> wordsPerSpineItem;
  String description;
  List<String> chapters;
  Size coverSize;
  Color coverColor;
  double? rating;
  double progressSpine;
  String? characterMetadataName;

  Map<String, dynamic> toJson() => {
    'name': name,
    'authors': authors,
    'wordsPerSpineItem': wordsPerSpineItem,
    'chapters': chapters,
    'description': description,
    'coverSize': [coverSize.width, coverSize.height],
    'rating': rating,
    'progressSpine': progressSpine,
    'characterMetadataName': characterMetadataName,
  };
}
