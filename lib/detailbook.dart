import 'package:easy_lib/models/book.dart';
import 'package:easy_lib/services/books_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_lib/services/peminjaman_handler.dart';

class BookDetailsPage extends StatefulWidget {
  const BookDetailsPage({super.key});

  @override
  State<BookDetailsPage> createState() => _BookDetailsPageState();
}

class _BookDetailsPageState extends State<BookDetailsPage> {
  Book? book;
  bool isLoading = false;
  bool isProcessing = false;
  String? errorMessage;
  bool isBookNotFound = false;

  bool isBorrowed = false;
  int? borrowId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBookDetails();
  }

  void _showLoadingOverlay() {
    if (!isLoading) {
      setState(() => isLoading = true);
    }
  }

  void _hideLoadingOverlay() {
    if (isLoading) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadBookDetails() async {
    final dynamic bookIdArg = ModalRoute.of(context)?.settings.arguments;

    if (bookIdArg == null) {
      setState(() {
        errorMessage = 'Tidak ada buku yang dipilih';
        isLoading = false;
      });
      return;
    }

    int bookId;
    if (bookIdArg is int) {
      bookId = bookIdArg;
    } else if (bookIdArg is String && int.tryParse(bookIdArg) != null) {
      bookId = int.parse(bookIdArg);
    } else {
      setState(() {
        errorMessage = 'ID buku tidak valid';
        isLoading = false;
      });
      return;
    }

    try {
      final result = await BookService.getBookDetail(bookId);

      if (result['success'] == false && result['error'] == 'not_found') {
        if (mounted) {
          setState(() {
            isBookNotFound = true;
            isLoading = false;
          });
        }
        return;
      }

      final bookDetails = result['data'] as Book;
      if (mounted) {
        setState(() {
          book = bookDetails;
          isLoading = false;
        });
        await _checkIfBookIsBorrowed();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _checkIfBookIsBorrowed() async {
    final borrowedBooks = await PeminjamanService.getBorrowedBooks();
    for (final b in borrowedBooks) {
      if (b['buku']['id'] == book!.id && b['returned'] == 0) {
        setState(() {
          isBorrowed = true;
          borrowId = b['id'];
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text('Detail Buku',
            style:
                GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : isBookNotFound
              ? _buildBookNotFoundView()
              : errorMessage != null
                  ? Center(
                      child: Text(errorMessage!,
                          style: GoogleFonts.poppins(color: Colors.red)))
                  : _buildBookDetailsContent(),
    );
  }

  Widget _buildBookNotFoundView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/books/not_found.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, _) =>
                Icon(Icons.error_outline, size: 80, color: Colors.grey),
          ),
          SizedBox(height: 24),
          Text(
            'Buku Tidak Ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Buku yang Anda cari tidak tersedia dalam database',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Kembali', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildBookDetailsContent() {
    if (book == null) return Center(child: Text('Data buku tidak tersedia'));

    return Stack(
      children: [
        SafeArea(
          child: ListView(
            padding: EdgeInsets.only(bottom: 80),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildBookCoverImage(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book!.kategori?['nama_kategori'] ?? 'Umum',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      book!.judul,
                      style: GoogleFonts.poppins(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      book!.pengarang,
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.shelves, color: Colors.black, size: 20),
                      SizedBox(width: 6),
                      Text(
                        book!.kodeBuku,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ]),
                    SizedBox(height: 20),
                    _buildBookDetailsSection(),
                    _buildSynopsisSection(),
                  ],
                ),
              )
            ],
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  Widget _buildBookCoverImage() {
    final imageUrl = book!.getImageUrl();

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 180,
        height: 250,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: 180,
            height: 250,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (ctx, error, _) {
          print('Error loading book cover: $error');
          return Image.asset(
            'assets/images/books/missing_cover.jpeg',
            width: 180,
            height: 250,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        width: 180,
        height: 250,
        fit: BoxFit.cover,
        errorBuilder: (ctx, error, _) {
          print('Error loading asset book cover: $error');
          return Image.asset(
            'assets/images/books/missing_cover.jpeg',
            width: 180,
            height: 250,
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  Widget _buildBookDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentang Buku',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blue[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              // Changed from Row to Wrap// Add spacing between items
              children: [
                SizedBox(
                  width: 100, // Fixed width for each item
                  child: _buildDetailItem('Kode', book!.kodeBuku),
                ),
                SizedBox(
                  width: 100,
                  child: _buildDetailItem('Stok', '${book!.stokBuku}'),
                ),
                SizedBox(
                  width: 100,
                  child: _buildDetailItem('Penerbit', book!.penerbit),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15, // Reduced font size
            fontWeight: FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis, // Add ellipsis for long text
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14, // Reduced font size
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // Allow up to 2 lines for the value
        ),
      ],
    );
  }

  Widget _buildSynopsisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 25),
        Text(
          'Sinopsis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          book!.deskripsi,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: book != null && (book!.stokBuku > 0 || isBorrowed)
              ? () => _handleBorrowOrReturn(context)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: book != null && (book!.stokBuku > 0 || isBorrowed)
                ? Colors.blue[700]
                : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            minimumSize: Size(double.infinity, 50),
            textStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            foregroundColor: Colors.white,
          ),
          child: Text(isBorrowed
              ? 'Kembalikan'
              : (book!.stokBuku > 0 ? 'Pinjam' : 'Tidak Tersedia')),
        ),
      ),
    );
  }

  void _handleBorrowOrReturn(BuildContext context) {
    if (isBorrowed) {
      _showReturnConfirmationDialog(context);
    } else {
      _showConfirmationDialog(context);
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    if (isProcessing) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('Konfirmasi Peminjaman'),
        content: Text('Apakah Anda yakin?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () => _handleBorrowing(dialogContext),
            child: Text('Ya'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBorrowing(BuildContext dialogContext) async {
    if (isProcessing) return;

    setState(() => isProcessing = true);
    Navigator.pop(dialogContext);

    try {
      final result = await PeminjamanService.borrowBook(book!.id);

      if (!mounted) return;

      if (result['success']) {
        setState(() {
          isBorrowed = true;
          borrowId = result['data']['id'];
          isProcessing = false;
        });
        _showSuccessDialog(context, result['message']);
      } else {
        _showErrorDialog(context, result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  void _showReturnConfirmationDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Konfirmasi Pengembalian'),
        content: Text('Apakah Anda yakin ingin mengembalikan buku ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Ya'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed ?? false) {
        _handleReturnBook(context);
      }
    });
  }

  Future<void> _handleReturnBook(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );

      final result = await PeminjamanService.returnBook(borrowId!);

      if (!mounted) return;
      Navigator.pop(context); // Remove loading dialog

      if (result['success']) {
        setState(() {
          isBorrowed = false;
          borrowId = null;
        });
        _showSuccessDialog(context, result['message']);
      } else {
        _showErrorDialog(context, result['message']);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Remove loading dialog
      _showErrorDialog(context, 'Terjadi kesalahan: $e');
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Gagal'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
