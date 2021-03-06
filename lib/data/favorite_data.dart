import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:hive/hive.dart';
import 'package:komikcast/bloc/favorite_bloc.dart';
import 'package:komikcast/data/pro_data.dart';

class FavoriteData {
  static saveFavorite({
    String mangaId,
    String currentId,
    String detailChapter,
    String image,
    String title,
    String type,
    BuildContext context,
  }) {
    // Open DB
    // ============================
    var db = Hive.box('komikcast');

    List favs = db.get('favorite', defaultValue: []);

    if (favs.length >= 10 && ProData().isPro() == false) {
      // IF MAX EXCEEDED
      Modular.to.pushNamed('/pro');
    } else {
      // Get Values
      // ============================
      List listFavorite = db.get('favorite') != null ? db.get('favorite') : [];
      listFavorite = listFavorite.cast<Map>();

      // Store Favorite to DB
      // ============================
      var favorite = {
        'image': image,
        'title': title,
        'mangaId': mangaId.substring(mangaId.length - 1) == '/'
            ? mangaId.replaceAll('/', '')
            : mangaId,
        'chapterId': currentId,
        'chapterName': detailChapter,
        'type': type,
      };

      listFavorite.add(favorite);
      db.put('favorite', listFavorite);

      // Store Favorite to Bloc
      // ================================
      Modular.get<FavoriteBloc>().add(listFavorite);

      // Show Snackbar
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Ditambahkan ke Favorit')));
    }
  }

  // ignore: slash_for_doc_comments
  /**
   *  Unsave Favorite
   * 
   *  ==================================
   * 
   */

  static unsaveFavorite({
    String mangaId,
  }) {
    // Open DB
    // ============================
    var db = Hive.box('komikcast');

    // Get Values
    // ============================
    List listFavorite = db.get('favorite') != null ? db.get('favorite') : [];
    listFavorite = listFavorite.cast<Map>();

    // Remove Saved Favorite
    listFavorite = listFavorite
        .where(
          (element) =>
              element['mangaId'] !=
              (mangaId.substring(mangaId.length - 1) == '/'
                  ? mangaId.replaceAll('/', '')
                  : mangaId),
        )
        .toList();
    listFavorite = listFavorite.cast<Map>();

    // Restore to DB
    db.put('favorite', listFavorite);

    // Store Favorite to Bloc
    // ================================
    Modular.get<FavoriteBloc>().add(listFavorite);
  }
}
