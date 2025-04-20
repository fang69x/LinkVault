import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkvault/models/bookmark_model.dart';
import 'package:linkvault/services/bookmark_services.dart';

// Bookmark service provider
final bookmarkServiceProvider = Provider<BookmarkServices>((ref) {
  return BookmarkServices();
});

// Bookmark state notifier
class BookmarkNotifier extends StateNotifier<BookmarkState> {
  final BookmarkServices _bookmarkService;

  BookmarkNotifier(this._bookmarkService) : super(BookmarkState.initial());

  // Get all bookmarks
  Future<void> getBookmarks({int page = 1, bool refresh = false}) async {
    if (refresh) {
      state = BookmarkState.initial();
    }

    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _bookmarkService.getBookmarks(
        page: page,
        limit: 10,
      );

      final bookmarks = result['bookmarks'] as List<Bookmark>;
      final currentPage = result['page'] as int;

      state = state.copyWith(
        bookmarks: page == 1 ? bookmarks : [...state.bookmarks, ...bookmarks],
        currentPage: currentPage,
        isLoading: false,
        hasMore: bookmarks.length ==
            10, // If we got less than requested, we've reached the end
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create a new bookmark
  Future<void> createBookmark(Bookmark bookmark) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final newBookmark = await _bookmarkService.createBookmark(bookmark);
      state = state.copyWith(
        bookmarks: [newBookmark, ...state.bookmarks],
        isSubmitting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update a bookmark
  Future<void> updateBookmark(String id, Bookmark bookmark) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final updatedBookmark =
          await _bookmarkService.updateBookmark(id, bookmark);
      final updatedBookmarks = state.bookmarks.map((b) {
        return b.id == id ? updatedBookmark : b;
      }).toList();

      state = state.copyWith(
        bookmarks: updatedBookmarks,
        isSubmitting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Delete a bookmark
  Future<void> deleteBookmark(String id) async {
    try {
      await _bookmarkService.deleteBookmarks(id);
      state = state.copyWith(
        bookmarks: state.bookmarks.where((b) => b.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Search bookmarks
  Future<void> searchBookmarks(
      {String? query,
      String? category,
      int page = 1,
      bool reset = false}) async {
    if (reset) {
      state = state.copyWith(
        searchResults: [],
        searchQuery: query,
        searchCategory: category,
        currentSearchPage: 1,
      );
    }

    if (state.isSearching) return;

    state = state.copyWith(isSearching: true, error: null);
    try {
      final result = await _bookmarkService.searchBookmarks(
        query: query,
        category: category,
        page: page,
      );

      final bookmarks = result['bookmarks'] as List<Bookmark>;
      final totalPages = result['totalPages'] as int;

      state = state.copyWith(
        searchResults:
            page == 1 ? bookmarks : [...state.searchResults, ...bookmarks],
        searchQuery: query,
        searchCategory: category,
        currentSearchPage: page,
        totalSearchPages: totalPages,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  // Get a single bookmark
  Future<void> getBookmarkDetails(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookmark = await _bookmarkService.getBookmarksById(id);
      state = state.copyWith(
        selectedBookmark: bookmark,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear the selected bookmark
  void clearSelectedBookmark() {
    state = state.copyWith(selectedBookmark: null);
  }
}

// Bookmark state provider
final bookmarkNotifierProvider =
    StateNotifierProvider<BookmarkNotifier, BookmarkState>((ref) {
  final bookmarkService = ref.watch(bookmarkServiceProvider);
  return BookmarkNotifier(bookmarkService);
});

// Bookmark state
class BookmarkState {
  final List<Bookmark> bookmarks;
  final List<Bookmark> searchResults;
  final Bookmark? selectedBookmark;
  final bool isLoading;
  final bool isSubmitting;
  final bool isSearching;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final String? searchCategory;
  final int currentSearchPage;
  final int totalSearchPages;

  BookmarkState({
    required this.bookmarks,
    required this.searchResults,
    this.selectedBookmark,
    required this.isLoading,
    required this.isSubmitting,
    required this.isSearching,
    this.error,
    required this.currentPage,
    required this.hasMore,
    this.searchQuery,
    this.searchCategory,
    required this.currentSearchPage,
    required this.totalSearchPages,
  });

  factory BookmarkState.initial() {
    return BookmarkState(
      bookmarks: [],
      searchResults: [],
      selectedBookmark: null,
      isLoading: false,
      isSubmitting: false,
      isSearching: false,
      error: null,
      currentPage: 1,
      hasMore: true,
      currentSearchPage: 1,
      totalSearchPages: 1,
    );
  }

  BookmarkState copyWith({
    List<Bookmark>? bookmarks,
    List<Bookmark>? searchResults,
    Bookmark? selectedBookmark,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSearching,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? searchCategory,
    int? currentSearchPage,
    int? totalSearchPages,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      searchResults: searchResults ?? this.searchResults,
      selectedBookmark: selectedBookmark ?? this.selectedBookmark,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSearching: isSearching ?? this.isSearching,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      searchCategory: searchCategory ?? this.searchCategory,
      currentSearchPage: currentSearchPage ?? this.currentSearchPage,
      totalSearchPages: totalSearchPages ?? this.totalSearchPages,
    );
  }
}
