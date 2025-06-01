import 'package:easy_lib/services/auth_bridge.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class KartuanggotaPage extends StatefulWidget {
  const KartuanggotaPage({super.key});

  @override
  _KartuanggotaPageState createState() => _KartuanggotaPageState();
}

class _KartuanggotaPageState extends State<KartuanggotaPage> {
  Map<String, dynamic>? userData;
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

    final user = await AuthBridge.getCurrentUser();
    if (mounted) {
      if (user != null) {
        setState(() {
          userData = user;
          isLoading = false;
        });
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cardWidth = screenWidth * 0.9;
    double cardHeight = cardWidth * 0.6;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF1E78D1),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : userData == null
                ? Center(child: Text('Gagal memuat data pengguna'))
                : Center(
                    // Center the entire content
                    child: Container(
                      height: screenHeight, // Full screen height
                      child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Center vertically
                          children: [
                            Container(
                              width: cardWidth,
                              height: cardHeight,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFF78B7EB),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start, // Align to top
                                children: [
                                  // Left side - Profile picture and ID
                                  SizedBox(
                                    width: cardWidth *
                                        0.3, // Fixed width for left side
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Take minimum space
                                      children: [
                                        CircleAvatar(
                                          radius: 35, // Slightly smaller
                                          backgroundImage: AssetImage(
                                              'assets/images/profile/Profile.png'),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "ID: ${userData!['id']}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 12, // Smaller font
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // Right side - Information
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // Take minimum space
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "KARTU ANGGOTA PERPUSTAKAAN",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Flexible(
                                          child: ListView(
                                            // Make info rows scrollable if needed
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            children: [
                                              _buildInfoRow(
                                                  "Nama Lengkap",
                                                  userData!['name'],
                                                  Color(0xFF3E78B2)),
                                              _buildInfoRow(
                                                "Tanggal Bergabung",
                                                _formatDate(
                                                    userData!['created_at']),
                                                Color(0xFF3E78B2),
                                              ),
                                              _buildInfoRow(
                                                "Status",
                                                userData!['status'] ?? '-',
                                                Color(0xFF3AA86D),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                    ),
                  ));
  }

  String _formatDate(String? dateStr) {
    try {
      final parsedDate = DateTime.parse(dateStr!);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return '-';
    }
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Take minimum space
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
          SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
