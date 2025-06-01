import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_lib/models/book.dart';
import 'package:easy_lib/services/books_handler.dart';
import 'package:easy_lib/detailbook.dart'; // Import BookDetailsPage

class BookListPage extends StatefulWidget {
  final String? initialSearch;
  final int? initialCategoryId;
  final String? initialCategoryName;

  const BookListPage({
    super.key,
    this.initialSearch,
    this.initialCategoryId,
    this.initialCategoryName,
  });

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int selectedCategoryId = 0;
  String selectedCategoryName = 'All';
  bool isLoading = true;
  List<Book> books = [];

  @override
  void initState() {
    super.initState();

    // Initialize from passed parameters
    if (widget.initialSearch != null && widget.initialSearch!.isNotEmpty) {
      searchController.text = widget.initialSearch!;
      searchQuery = widget.initialSearch!;
    }

    if (widget.initialCategoryId != null) {
      selectedCategoryId = widget.initialCategoryId!;
    }

    if (widget.initialCategoryName != null &&
        widget.initialCategoryName!.isNotEmpty) {
      selectedCategoryName = widget.initialCategoryName!;
    }

    // Add search listener
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });

    // Initial fetch of books
    _fetchBooks();
  }

  void _fetchBooks() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Book> fetchedBooks = await BookService.getBooks(
        search: searchQuery,
        categoryId: selectedCategoryId > 0 ? selectedCategoryId : null,
        categoryName: selectedCategoryName,
      );

      setState(() {
        books = fetchedBooks;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching books: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  void _handleSearch() {
    _fetchBooks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'List Buku ${selectedCategoryName != 'All' ? '- $selectedCategoryName' : ''}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Telusuri Koleksi',
                hintStyle: GoogleFonts.poppins(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _handleSearch,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
                _handleSearch();
              },
            ),
            SizedBox(height: 16),

            // Status indicator (if searching or filtering)
            if (searchQuery.isNotEmpty || selectedCategoryId > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Wrap(
                  spacing: 8.0,
                  children: [
                    if (searchQuery.isNotEmpty)
                      Chip(
                        label: Text('Search: $searchQuery'),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            searchQuery = '';
                            searchController.clear();
                          });
                          _fetchBooks();
                        },
                      ),
                    if (selectedCategoryId > 0)
                      Chip(
                        label: Text('Category: $selectedCategoryName'),
                        deleteIcon: Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            selectedCategoryId = 0;
                            selectedCategoryName = 'All';
                          });
                          _fetchBooks();
                        },
                      ),
                  ],
                ),
              ),

            // Book List
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : books.isEmpty
                      ? Center(
                          child: Text(
                            'No books found',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        )
                      : ListView.separated(
                          itemCount: books.length,
                          separatorBuilder: (_, __) => Divider(),
                          itemBuilder: (context, index) {
                            return _bookItem(books[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookItem(Book book) {
    return ListTile(
      contentPadding: EdgeInsets.all(8.0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          book.getImageUrl(),
          height: 80,
          width: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 80,
              width: 60,
              color: Colors.grey[300],
              child: Icon(Icons.book, color: Colors.grey[600]),
            );
          },
        ),
      ),
      title: Text(
        book.judul,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.pengarang,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          Text(
            'Tahun Terbit: ${_formatDate(book.tahunTerbit)}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          Text(
            'Stok: ${book.stokBuku}',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ],
      ),
      // Navigate to the book details page when item is tapped
      onTap: () {
        // Navigate to BookDetailsPage and pass the book ID as argument
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailsPage(),
            settings: RouteSettings(
              arguments: book.id, // Passing the book ID to the details page
            ),
          ),
        );
      },
    );
  }
}
