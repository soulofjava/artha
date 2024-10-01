import 'package:flutter/material.dart';
import 'DB/database_helper.dart';
import 'models/user.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<List<User>> users;

  @override
  void initState() {
    super.initState();
    users = fetchUsers(); // Ambil daftar pengguna saat halaman diinisialisasi
  }

  Future<List<User>> fetchUsers() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getAllUsers(); // Ambil semua pengguna dari database
  }

  Future<void> _deleteUser(int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteUser(id); // Hapus pengguna dari database
    setState(() {
      users = fetchUsers(); // Refresh daftar pengguna setelah penghapusan
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green, // Set background color to green
        content: Center(
          child: Text(
            'User deleted successfully!',
            style: TextStyle(color: Colors.white), // Set text color to white
            textAlign: TextAlign.center, // Align text to center
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User'),
      ),
      body: FutureBuilder<List<User>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(), // Tampilkan loader saat memuat
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  'Error: ${snapshot.error}'), // Tampilkan pesan error jika ada
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                  'Tidak ada pengguna ditemukan'), // Jika tidak ada pengguna
            );
          }

          // Tampilkan daftar pengguna
          final userList = snapshot.data!;
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, index) {
              final user = userList[index];
              return ListTile(
                title: Text(user.username), // Tampilkan username
                subtitle: Text('ID: ${user.id}'), // Tampilkan ID pengguna
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red), // Ikon delete
                  onPressed: () {
                    // Tampilkan dialog konfirmasi sebelum menghapus
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Konfirmasi Hapus'),
                          content: Text(
                              'Apakah Anda yakin ingin menghapus user ${user.username}?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                              },
                              child: Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Tutup dialog
                                if (user.id != null) {
                                  // Pastikan ID tidak null
                                  _deleteUser(user
                                      .id!); // Hapus pengguna jika konfirmasi
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors
                                          .red, // Set background color to green
                                      content: Center(
                                        child: Text(
                                          'ID pengguna tidak valid.',
                                          style: TextStyle(
                                              color: Colors
                                                  .white), // Set text color to white
                                          textAlign: TextAlign
                                              .center, // Align text to center
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text('Hapus'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
