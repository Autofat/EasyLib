import 'package:easy_lib/config/appConfig.dart';
import 'package:easy_lib/services/peminjaman_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_bridge.dart';
import 'dart:io' show Platform;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _profilePageState();
}

class _profilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> borrowedBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final isAuth = await AuthBridge.isAuthenticated();
    if (!isAuth) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
      return;
    }

    try {
      final user = await AuthBridge.getCurrentUser();
      final books = await PeminjamanService.getBorrowedBooks();

      if (mounted) {
        setState(() {
          userData = user;
          borrowedBooks = books;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      isLoading = true;
    });

    final result = await AuthBridge.logout();

    if (mounted) {
      if (result['success']) {
        // Navigate to login page after successful logout
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        // Show error if logout failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Logout failed')),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushNamed('/main');
          },
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SafeArea(
                  child: Column(children: [
                    Center(
                      child: Header(userData: userData),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: ListView(
                            padding: EdgeInsets.only(bottom: 90),
                            children: [
                              if (borrowedBooks.isEmpty)
                                Center(
                                  child: Text(
                                    'Kamu belum meminjam buku',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              else
                                ...borrowedBooks
                                    .map((book) => Column(
                                          children: [
                                            BookCard(book: book),
                                            SizedBox(height: 10),
                                          ],
                                        ))
                                    .toList(),
                            ],
                          )),
                    )
                  ]),
                ),
                Positioned(
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
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        minimumSize: Size(double.infinity, 50),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Sign Out'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class Header extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const Header({super.key, this.userData});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    final name = widget.userData?['name'] ?? 'User';

    // Calculate membership duration
    String memberSince = 'Member Sejak ';
    if (widget.userData != null && widget.userData!.containsKey('created_at')) {
      try {
        final createdAt = DateTime.parse(widget.userData!['created_at']);
        final year = createdAt.year.toString();
        memberSince += year;
      } catch (e) {
        memberSince += '2025'; // Fallback to the original default
      }
    } else {
      memberSince += '2025'; // Fallback to the original default
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: Column(children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    Image.asset('assets/images/profile/Profile.png').image,
              ),
              SizedBox(height: 10),
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                memberSince,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/editprofile');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(25, 118, 210, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ubah Profil',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark,
                    color: Color.fromRGBO(25, 118, 210, 1),
                  ),
                  Text(
                    'Buku Terpinjam',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ]),
          )
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookCard({super.key, required this.book});

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  Widget _buildBookCover(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Image.asset(
        'assets/images/books/missing_cover.jpeg',
        width: 105,
        height: 150,
        fit: BoxFit.cover,
      );
    }

    try {
      if (imagePath.startsWith('http')) {
        print('Loading network image: $imagePath');
        return Image.network(
          imagePath,
          width: 105,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return Image.asset(
              'assets/images/books/missing_cover.jpeg',
              width: 105,
              height: 150,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        // If not a URL, construct the server URL
        final baseUrl = AppConfig.baseUrl;

        // Platform.isAndroid
        //     ? 'http://10.0.2.2:8000'
        //     : 'http://localhost:8000';

        final imageUrl = '$baseUrl/$imagePath';
        print('Loading constructed URL image: $imageUrl');
        return Image.network(
          imageUrl,
          width: 105,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return Image.asset(
              'assets/images/books/missing_cover.jpeg',
              width: 105,
              height: 150,
              fit: BoxFit.cover,
            );
          },
        );
      }
    } catch (e) {
      print('General error loading image: $e');
      return Image.asset(
        'assets/images/books/missing_cover.jpeg',
        width: 105,
        height: 150,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookData = book['buku'] ?? {};
    final tanggalPinjam = DateTime.parse(book['tanggal_pinjam']);
    // PENGEMBALIAN MAX 90 HARI (3 BULAN)
    final batasPengembalian = tanggalPinjam.add(Duration(days: 90));
    final isLate = DateTime.now().isAfter(batasPengembalian);

    return InkWell(
      onTap: () {
        print("isi Data: $bookData");
        Navigator.of(context)
            .pushNamed('/bookdetails', arguments: bookData['id']);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildBookCover(bookData['cover']),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookData['judul'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    bookData['pengarang'] ?? 'Unknown',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Tahun Terbit: ${_formatDate(bookData['tahun_terbit'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batas Pengembalian ',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isLate ? Colors.red[400] : Colors.green[400],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${batasPengembalian.day}/${batasPengembalian.month}/${batasPengembalian.year}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
