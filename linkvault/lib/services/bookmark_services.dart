import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/services/api_services.dart';

class BookmarkServices {
  final ApiServices _apiServices = ApiServices();

  // get all bookmarks with pagination
  Future<Map<String, dynamic>> getBookmarks(
      {int page = 1, int limit = 10}) async {
    try {
      final response =
          await _apiServices.get('/api/bookmarks?page=$page&limit=$limit');
      final List<Bookmark> bookmarks =
          (response as List).map((item) => Bookmark.fromJson(item)).toList();
      return {
        'bookmarks': bookmarks,
        'page': page,
        'limit': limit,
      };
    } catch (e) {
      rethrow;
    }
  }

// get bookmarks by id
  Future<Bookmark> getBookmarksById(String id) async {
    try {
      final response = await _apiServices.get('/api/bookmarks/$id');
      return Bookmark.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // create bookmarks
  Future<Bookmark> createBookmark(Bookmark bookmark) async {
    try {
      final response =
          await _apiServices.post('/api/bookmarks', bookmark.toJson());
      return Bookmark.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // update bookmarks
  Future<Bookmark> updateBookmark(String id, Bookmark bookmark) async {
    try {
      final response =
          await _apiServices.put('/api/bookmarks/$id', bookmark.toJson());
      return Bookmark.fromJson(response['updatedBookmark']);
    } catch (e) {
      rethrow;
    }
  }

// delete bookmark

  Future<bool> deleteBookmarks(String id) async {
    try {
      await _apiServices.delete('/api/bookmarks/$id');
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchBookmarks({
    String? query,
    String? category,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String endpoint = '/api/bookmarks/search?page=$page&limit=$limit';
      if (query != null && query.isNotEmpty) {
        endpoint += '&q=$query';
      }
      if (category != null && category.isNotEmpty) {
        endpoint += '&category=$category';
      }
      final response = await _apiServices.get(endpoint);
      final List<Bookmark> bookmarks = (response['bookmarks'] as List)
          .map((item) => Bookmark.fromJson(item))
          .toList();

      return {
        'bookmarks': bookmarks,
        'page': response['page'],
        'totalPages': response['totalPages'],
        'total': response['total'],
        'limit': response['limit'],
      };
    } catch (e) {
      rethrow;
    }
  }
}
