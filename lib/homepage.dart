import 'package:easy_lib/booklist.dart';
import 'package:easy_lib/models/book.dart';
import 'package:easy_lib/models/category.dart';
import 'package:easy_lib/services/auth_bridge.dart';
import 'package:easy_lib/services/books_handler.dart';
import 'package:easy_lib/services/catagories_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// <-------- DATA -------->
// We'll replace this with data from the API
final List<RecomendationData> recomendations = [
  RecomendationData('assets/images/books/book1.png', 'Bintang', 'Tere Liye'),
  RecomendationData('assets/images/books/book2.png', 'Bulan', 'Tere Liye'),
  RecomendationData('assets/images/books/book3.png', 'Bumi', 'Tere Liye'),
];

class RecomendationData {
  final String image;
  final String title;
  final String author;

  RecomendationData(this.image, this.title, this.author);
}
// <-------- END DATA -------->

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: ListView(
          children: [
            Column(
              children: [
                Header(),
                CategoriesSection(),
                RecommendationSection(),
                SizedBox(
                  height: 20,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  String userName = '';
  String? profilePicture;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthBridge.getCurrentUser();
      if (userData != null && mounted) {
        setState(() {
          userName = userData['name'] ?? 'User';
          profilePicture = userData['profile_picture'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        userName = 'User';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/profile');
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: profilePicture != null
                      ? NetworkImage(profilePicture!)
                      : AssetImage('assets/images/profile/Profile.png')
                          as ImageProvider,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                  child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed('/search');
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Icon(
                        Icons.search,
                        color: Colors.grey[400],
                      ),
                      SizedBox(width: 8),
                      Text("Baca buku apa hari ini?",
                          style: GoogleFonts.poppins(color: Colors.grey[400])),
                      Spacer(
                        flex: 1,
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
          SizedBox(height: 20),
          // <--- Greetings Card --->
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 40,
                      backgroundImage: profilePicture != null
                          ? NetworkImage(profilePicture!)
                          : AssetImage('assets/images/profile/Profile.png')),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang,",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isLoading ? "Loading . . ." : "$userName!",
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF3F84B6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/kartuanggota');
                  },
                  child: Center(
                    child: Text(
                      "Tunjukan Kartu Anggota",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class CategoriesSection extends StatefulWidget {
  const CategoriesSection({super.key});

  @override
  State<CategoriesSection> createState() => _CategoriesSectionState();
}

class _CategoriesSectionState extends State<CategoriesSection> {
  List<Category> categories = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await CategoryService.getCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CATEGORIES',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/search');
                  },
                  icon: Icon(Icons.more_horiz)),
            ],
          ),
        ),
        // <--- Categories List --->
        SizedBox(
          height: 120,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length, // Add categories list
            separatorBuilder: (context, index) => SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryItem(
                  icon: category.icon, title: category.nama_kategori);
            },
          ),
        )
      ],
    );
  }
}

class CategoryItem extends StatefulWidget {
  final IconData icon;
  final String title;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to BookListPage with category name
        Navigator.of(context).pushNamed('/search'); // Use the category title
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: Offset(0, 1)),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 52,
              color: Colors.black87,
            ),
            SizedBox(height: 8),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendationSection extends StatefulWidget {
  const RecommendationSection({super.key});

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  List<Book> recommendedBooks = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final books = await BookService.getRandomRecommendations(limit: 10);
      if (mounted) {
        setState(() {
          recommendedBooks = books;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MUNGKIN KAMU SUKA',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/search');
                  },
                  icon: Icon(Icons.more_horiz)),
            ],
          ),
        ),
        // <--- Recommendation List --->
        SizedBox(
          height: 170,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : hasError
                  ? Center(
                      child: Text(
                          'Tidak dapat memuat rekomendasi: $errorMessage',
                          style: GoogleFonts.poppins(color: Colors.red)))
                  : recommendedBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.grey[400], size: 50),
                              SizedBox(height: 16),
                              Text('Tidak ada rekomendasi buku tersedia',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendedBooks.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final book = recommendedBooks[index];
                            return BookRecommendationItem(
                              id: book.id,
                              image: book.getImageUrl(),
                              title: book.judul,
                              author: book.pengarang,
                            );
                          },
                        ),
        )
      ],
    );
  }
}

class BookRecommendationItem extends StatelessWidget {
  final int id;
  final String image;
  final String title;
  final String author;

  const BookRecommendationItem({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to book details page with book ID
        Navigator.of(context).pushNamed('/bookdetails', arguments: id);
      },
      child: Container(
        width: 120,
        height: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: _buildImageWidget(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    author,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    // Check if image path is valid and not empty
    if (image.isEmpty) {
      return Image.asset(
        'assets/images/books/missing_cover.jpeg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    try {
      if (image.startsWith('http')) {
        print('Loading network image: $image');
        return Image.network(
          image,
          width: double.infinity,
          height: double.infinity,
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
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            );
          },
        );
      } else {
        print('Loading asset image: $image');
        return Image.asset(
          image,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading asset image: $error');
            return Image.asset(
              'assets/images/books/missing_cover.jpeg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            );
          },
        );
      }
    } catch (e) {
      print('General error loading image: $e');
      return Image.asset(
        'assets/images/books/missing_cover.jpeg',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}
