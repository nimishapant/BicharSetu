import 'package:flutter/material.dart';

import 'theme/bichar_theme_extension.dart';

/// Local book entry — no backend; [image] is a placeholder key (e.g. `picture1`).
class BookItem {
  const BookItem({
    required this.title,
    required this.author,
    required this.image,
    required this.genre,
    required this.description,
    required this.pages,
    required this.language,
  });

  final String title;
  final String author;
  final String image;
  final String genre;
  final String description;
  final int pages;
  final String language;
}

const List<BookItem> _allBooks = [
  BookItem(
    title: 'Muna Madan',
    author: 'Laxmi Prasad Devkota',
    image: 'picture1',
    genre: 'Epic Poetry',
    description:
        'A timeless Nepali epic poem about love, separation, and the journey of Muna and Madan — one of the most beloved works in Nepali literature.',
    pages: 96,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Ghumne Mechmathi Andho Manche',
    author: 'Bhupi Sherchan',
    image: 'picture2',
    genre: 'Poetry',
    description:
        'A landmark collection of modern Nepali poetry that captures irony, identity, and the restless spirit of a changing society.',
    pages: 128,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Shireeshko Phool',
    author: 'Parijat',
    image: 'picture3',
    genre: 'Novel',
    description:
        'A deeply emotional novel exploring loneliness, longing, and human connection through the life of its unforgettable protagonist.',
    pages: 184,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Jeevan Kada Ki Phool',
    author: 'Jhamak Ghimire',
    image: 'picture4',
    genre: 'Autobiography',
    description:
        'A powerful autobiography written with the feet, celebrating resilience, creativity, and the beauty found amid life\'s thorns.',
    pages: 212,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Palpasa Cafe',
    author: 'Narayan Wagle',
    image: 'picture5',
    genre: 'Novel',
    description:
        'A love story set against the backdrop of Nepal\'s civil conflict — intimate, political, and profoundly moving.',
    pages: 296,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Seto Dharti',
    author: 'Amar Neupane',
    image: 'picture6',
    genre: 'Novel',
    description:
        'A poignant narrative about child widows in Nepal, shedding light on tradition, injustice, and quiet strength.',
    pages: 320,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Karnali Blues',
    author: 'Buddhisagar',
    image: 'picture7',
    genre: 'Novel',
    description:
        'A coming-of-age journey along the Karnali, blending memory, music, and the bittersweet taste of growing up.',
    pages: 268,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Bhikari',
    author: 'Laxmi Prasad Devkota',
    image: 'picture8',
    genre: 'Poetry',
    description:
        'A celebrated poetic work reflecting compassion, social conscience, and the poet\'s mastery of lyrical Nepali verse.',
    pages: 72,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Aamako Sapana',
    author: 'Gopal Prasad Rimal',
    image: 'picture9',
    genre: 'Drama',
    description:
        'A pioneering modern Nepali play that broke from tradition to address social change and the dreams of a nation.',
    pages: 110,
    language: 'Nepali',
  ),
  BookItem(
    title: 'Buddhibinod',
    author: 'Lekhnath Paudyal',
    image: 'picture10',
    genre: 'Poetry',
    description:
        'Classic verses marked by elegance, wit, and philosophical depth — a cornerstone of refined Nepali literary expression.',
    pages: 88,
    language: 'Nepali',
  ),
];

/// Books library screen — fully local, no backend.
class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedGenre = 'All';
  final Set<String> _savedIds = {};

  List<String> get _genres {
    final genres = _allBooks.map((b) => b.genre).toSet().toList()..sort();
    return ['All', ...genres];
  }

  List<BookItem> get _filteredBooks {
    final q = _query.trim().toLowerCase();
    return _allBooks.where((book) {
      final matchesGenre =
          _selectedGenre == 'All' || book.genre == _selectedGenre;
      if (!matchesGenre) return false;
      if (q.isEmpty) return true;
      return book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.genre.toLowerCase().contains(q);
    }).toList();
  }

  String _bookId(BookItem book) => '${book.title}_${book.author}';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBookDetail(BookItem book) {
    final id = _bookId(book);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.bichar.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _BookDetailSheet(
          book: book,
          isSaved: _savedIds.contains(id),
          onSaveToggle: () {
            setState(() {
              if (_savedIds.contains(id)) {
                _savedIds.remove(id);
              } else {
                _savedIds.add(id);
              }
            });
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(
                  _savedIds.contains(id)
                      ? 'Added "${book.title}" to your shelf'
                      : 'Removed "${book.title}" from your shelf',
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBooks;
    final width = MediaQuery.sizeOf(context).width;
    final contentMaxWidth = width >= 1200 ? 1100.0 : width;
    final horizontalPadding = width >= 800 ? 28.0 : 18.0;
    final crossAxisCount = width >= 1100
        ? 4
        : width >= 800
            ? 3
            : width >= 500
                ? 2
                : 1;

    final bichar = context.bichar;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _BooksAppBar(),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            20,
                            horizontalPadding,
                            0,
                          ),
                          child: const _BooksWelcomeHeader(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            18,
                            horizontalPadding,
                            12,
                          ),
                          child: _BooksSearchField(
                            controller: _searchController,
                            onClear: () => _searchController.clear(),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _GenreFilterRow(
                          genres: _genres,
                          selected: _selectedGenre,
                          onSelected: (genre) =>
                              setState(() => _selectedGenre = genre),
                        ),
                      ),
                      if (_allBooks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              20,
                              horizontalPadding,
                              14,
                            ),
                            child: _FeaturedBookCard(
                              book: _allBooks.first,
                              onTap: () => _openBookDetail(_allBooks.first),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            4,
                            horizontalPadding,
                            12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Nepali Classics',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: bichar.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${filtered.length} book${filtered.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: bichar.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (filtered.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _BooksEmptyState(),
                        )
                      else if (crossAxisCount == 1)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            28,
                          ),
                          sliver: SliverList.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final book = filtered[index];
                              return _BookListTile(
                                book: book,
                                isSaved: _savedIds.contains(_bookId(book)),
                                onTap: () => _openBookDetail(book),
                              );
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            28,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.62,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final book = filtered[index];
                                return _BookGridCard(
                                  book: book,
                                  isSaved: _savedIds.contains(_bookId(book)),
                                  onTap: () => _openBookDetail(book),
                                );
                              },
                              childCount: filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BooksAppBar extends StatelessWidget {
  const _BooksAppBar();

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Container(
      color: bichar.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_rounded, color: bichar.textPrimary, size: 26),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              'Books',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: bichar.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Book search is available below'),
                ),
              );
            },
            icon: Icon(Icons.search_rounded, color: bichar.textPrimary, size: 26),
          ),
        ],
      ),
    );
  }
}

class _BooksWelcomeHeader extends StatelessWidget {
  const _BooksWelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bichar.accent, bichar.accentLight],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bichar Setu Library',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: bichar.textPrimary,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover timeless Nepali literature',
                    style: TextStyle(
                      fontSize: 14,
                      color: bichar.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BooksSearchField extends StatelessWidget {
  const _BooksSearchField({
    required this.controller,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search books or authors...',
        hintStyle: TextStyle(
          color: bichar.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(Icons.search_rounded, color: bichar.mutedIcon),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onClear,
            );
          },
        ),
        filled: true,
        fillColor: bichar.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: bichar.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: bichar.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: bichar.accent, width: 1.5),
        ),
      ),
    );
  }
}

class _GenreFilterRow extends StatelessWidget {
  const _GenreFilterRow({
    required this.genres,
    required this.selected,
    required this.onSelected,
  });

  final List<String> genres;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selected;
          return FilterChip(
            label: Text(genre),
            selected: isSelected,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : bichar.textSecondary,
            ),
            selectedColor: bichar.accent,
            backgroundColor: bichar.cardBackground,
            side: BorderSide(
              color: isSelected ? bichar.accent : bichar.border,
            ),
            onSelected: (_) => onSelected(genre),
          );
        },
      ),
    );
  }
}

class _FeaturedBookCard extends StatelessWidget {
  const _FeaturedBookCard({
    required this.book,
    required this.onTap,
  });

  final BookItem book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF5B35D5), bichar.accent, bichar.accentLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: bichar.accent.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 88,
                height: 120,
                child: _BookCoverPlaceholder(
                  image: book.image,
                  borderRadius: 12,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          book.genre,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Renders a styled placeholder from keys like `picture1` … `picture10`.
class _BookCoverPlaceholder extends StatelessWidget {
  const _BookCoverPlaceholder({
    required this.image,
    this.borderRadius = 14,
  });

  final String image;
  final double borderRadius;

  static const List<List<Color>> _palettes = [
    [Color(0xFF6A3DE8), Color(0xFF9B7BFF)],
    [Color(0xFF1565C0), Color(0xFF5C9CE6)],
    [Color(0xFF00897B), Color(0xFF4DB6AC)],
    [Color(0xFFE91E8C), Color(0xFFFF7EB9)],
    [Color(0xFFF57C00), Color(0xFFFFB74D)],
    [Color(0xFF5E35B1), Color(0xFF9575CD)],
    [Color(0xFF00796B), Color(0xFF26A69A)],
    [Color(0xFFC2185B), Color(0xFFF06292)],
    [Color(0xFF3949AB), Color(0xFF7986CB)],
    [Color(0xFF6D4C41), Color(0xFFA1887F)],
  ];

  int get _index {
    final n = int.tryParse(image.replaceAll(RegExp(r'[^0-9]'), ''));
    if (n == null || n < 1) return 0;
    return (n - 1).clamp(0, _palettes.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[_index];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              Icons.menu_book_rounded,
              size: 56,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Center(
            child: Icon(
              Icons.auto_stories_rounded,
              size: 36,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                image,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookGridCard extends StatelessWidget {
  const _BookGridCard({
    required this.book,
    required this.isSaved,
    required this.onTap,
  });

  final BookItem book;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Material(
      color: bichar.cardBackground,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: bichar.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _BookCoverPlaceholder(image: book.image),
                    if (isSaved)
                      const Positioned(
                        top: 10,
                        right: 10,
                        child: Icon(
                          Icons.bookmark_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: bichar.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: bichar.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: bichar.chipBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          book.genre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: bichar.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookListTile extends StatelessWidget {
  const _BookListTile({
    required this.book,
    required this.isSaved,
    required this.onTap,
  });

  final BookItem book;
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Material(
      color: bichar.cardBackground,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: bichar.border),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 96,
                child: _BookCoverPlaceholder(image: book.image),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: bichar.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 13,
                        color: bichar.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _MetaChip(label: book.genre),
                        const SizedBox(width: 6),
                        _MetaChip(label: '${book.pages} pg'),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                isSaved ? Icons.bookmark_rounded : Icons.chevron_right_rounded,
                color: isSaved ? bichar.accent : bichar.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bichar.chipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: bichar.accent,
        ),
      ),
    );
  }
}

class _BookDetailSheet extends StatelessWidget {
  const _BookDetailSheet({
    required this.book,
    required this.isSaved,
    required this.onSaveToggle,
  });

  final BookItem book;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                height: 140,
                child: _BookCoverPlaceholder(image: book.image),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: bichar.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 15,
                        color: bichar.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(label: book.genre),
                        _MetaChip(label: book.language),
                        _MetaChip(label: '${book.pages} pages'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            book.description,
            style: TextStyle(
              fontSize: 14,
              color: bichar.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Opening "${book.title}" — reader coming soon',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Reading'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onSaveToggle,
                icon: Icon(
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                ),
                tooltip: isSaved ? 'Remove from shelf' : 'Save to shelf',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BooksEmptyState extends StatelessWidget {
  const _BooksEmptyState();

  @override
  Widget build(BuildContext context) {
    final bichar = context.bichar;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: bichar.chipBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.menu_book_outlined, size: 34, color: bichar.accent),
          ),
          const SizedBox(height: 16),
          Text(
            'No books found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: bichar.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term or genre filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: bichar.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
