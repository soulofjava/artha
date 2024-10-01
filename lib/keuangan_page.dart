import 'package:flutter/material.dart';
import 'DB/keuangan_helper.dart';

class KeuanganPage extends StatefulWidget {
  @override
  _KeuanganPageState createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  final keuanganHelper = KeuanganHelper.instance;
  List<Map<String, dynamic>> _keuanganList = [];
  double _totalUangMasuk = 0.0;
  double _totalUangKeluar = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchKeuanganData();
  }

  // Ambil data keuangan dari SQLite
  void _fetchKeuanganData() async {
    final allRows = await keuanganHelper.queryAllRows();
    setState(() {
      _keuanganList = allRows;
      _calculateTotals();
    });
  }

  // Hitung total uang masuk dan uang keluar
  void _calculateTotals() {
    _totalUangMasuk = 0.0;
    _totalUangKeluar = 0.0;

    for (var item in _keuanganList) {
      _totalUangMasuk += item[KeuanganHelper.columnUangMasuk];
      _totalUangKeluar += item[KeuanganHelper.columnUangKeluar];
    }
  }

  // Fungsi untuk menampilkan dialog tambah data baru
  void _showAddDialog() {
    final TextEditingController _catatanController = TextEditingController();
    final TextEditingController _uangMasukController =
        TextEditingController(text: '0'); // Nilai default 0
    final TextEditingController _uangKeluarController =
        TextEditingController(text: '0'); // Nilai default 0

    // Tanggal baru dengan default hari ini
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Tambah Data Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _catatanController,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_add),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Tanggal menggunakan Date Picker
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: "${selectedDate.toLocal()}".split(' ')[0]),
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  // Kolom input untuk Uang Masuk
                  TextField(
                    controller: _uangMasukController,
                    decoration: InputDecoration(
                      labelText: 'Uang Masuk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  // Kolom input untuk Uang Keluar
                  TextField(
                    controller: _uangKeluarController,
                    decoration: InputDecoration(
                      labelText: 'Uang Keluar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.remove_circle_outline),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Validasi kolom tidak boleh kosong
                if (_catatanController.text.isEmpty ||
                    (_uangMasukController.text.isEmpty &&
                        _uangKeluarController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kolom tidak boleh kosong!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Hentikan proses jika ada kolom kosong
                }

                // Tambah data baru ke database
                Map<String, dynamic> newRecord = {
                  KeuanganHelper.columnTanggal:
                      "${selectedDate.toLocal()}".split(' ')[0],
                  KeuanganHelper.columnCatatan: _catatanController.text,
                  KeuanganHelper.columnUangMasuk:
                      double.tryParse(_uangMasukController.text) ?? 0.0,
                  KeuanganHelper.columnUangKeluar:
                      double.tryParse(_uangKeluarController.text) ?? 0.0,
                  KeuanganHelper.columnSaldo:
                      (double.tryParse(_uangMasukController.text) ?? 0.0) -
                          (double.tryParse(_uangKeluarController.text) ??
                              0.0), // Menghitung saldo
                };

                await keuanganHelper.insert(newRecord);
                _fetchKeuanganData(); // Refresh data
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog edit
  void _showEditDialog(Map<String, dynamic> keuangan) {
    final TextEditingController _catatanController =
        TextEditingController(text: keuangan[KeuanganHelper.columnCatatan]);
    final TextEditingController _uangMasukController = TextEditingController(
        text: keuangan[KeuanganHelper.columnUangMasuk].toString());
    final TextEditingController _uangKeluarController = TextEditingController(
        text: keuangan[KeuanganHelper.columnUangKeluar].toString());

    // Tanggal dalam bentuk DateTime
    DateTime selectedDate =
        DateTime.parse(keuangan[KeuanganHelper.columnTanggal]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Data Keuangan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _catatanController,
                    decoration: InputDecoration(
                      labelText: 'Catatan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Tanggal menggunakan Date Picker
                  TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: "${selectedDate.toLocal()}".split(' ')[0]),
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _uangMasukController,
                    decoration: InputDecoration(
                      labelText: 'Uang Masuk',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _uangKeluarController,
                    decoration: InputDecoration(
                      labelText: 'Uang Keluar',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.remove_circle_outline),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            // Tombol Hapus
            TextButton(
              onPressed: () async {
                // Konfirmasi sebelum menghapus
                bool confirmDelete = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Konfirmasi Hapus'),
                      content:
                          Text('Apakah Anda yakin ingin menghapus data ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text('Tidak'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text('Ya'),
                        ),
                      ],
                    );
                  },
                );

                // Jika konfirmasi ya, hapus data
                if (confirmDelete) {
                  await keuanganHelper
                      .delete(keuangan[KeuanganHelper.columnId]);
                  _fetchKeuanganData(); // Refresh data
                  Navigator.of(context).pop(); // Tutup dialog edit
                }
              },
              child: Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                // Validasi kolom tidak boleh kosong
                if (_catatanController.text.isEmpty ||
                    (_uangMasukController.text.isEmpty &&
                        _uangKeluarController.text.isEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Kolom tidak boleh kosong!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Hentikan proses jika ada kolom kosong
                }

                // Update data di database
                Map<String, dynamic> updatedRecord = {
                  KeuanganHelper.columnId: keuangan[KeuanganHelper.columnId],
                  KeuanganHelper.columnTanggal: "${selectedDate.toLocal()}"
                      .split(' ')[0], // simpan tanggal yang baru
                  KeuanganHelper.columnCatatan: _catatanController.text,
                  KeuanganHelper.columnUangMasuk:
                      double.tryParse(_uangMasukController.text) ?? 0.0,
                  KeuanganHelper.columnUangKeluar:
                      double.tryParse(_uangKeluarController.text) ?? 0.0,
                };

                await keuanganHelper.update(updatedRecord);
                _fetchKeuanganData(); // Refresh data
                Navigator.of(context).pop();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keuangan'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddDialog, // Panggil form tambah data saat ditekan
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _keuanganList.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data keuangan',
                      style: TextStyle(fontSize: 24),
                    ),
                  )
                : ListView.builder(
                    itemCount: _keuanganList.length,
                    itemBuilder: (context, index) {
                      final keuangan = _keuanganList[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        color: (keuangan[KeuanganHelper.columnUangMasuk] > 0)
                            ? Colors.green[
                                100] // Hijau terang jika uang masuk lebih dari 0
                            : (keuangan[KeuanganHelper.columnUangKeluar] > 0)
                                ? Colors.red[
                                    100] // Merah terang jika uang keluar lebih dari 0
                                : Colors.grey[
                                    100], // Warna abu-abu jika tidak ada uang masuk atau keluar
                        child: InkWell(
                          onTap: () {
                            _showEditDialog(
                                keuangan); // Tampilkan dialog saat item dipilih
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  keuangan[KeuanganHelper.columnCatatan],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tanggal: ${keuangan[KeuanganHelper.columnTanggal]}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 12),
                                if (keuangan[KeuanganHelper.columnUangMasuk] >
                                    0) // Tampilkan hanya jika ada uang masuk
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.add_circle,
                                          color: Colors.green,
                                          size: 20), // Ikon untuk uang masuk
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Masuk:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${keuangan[KeuanganHelper.columnUangMasuk]}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                if (keuangan[KeuanganHelper.columnUangKeluar] >
                                    0) // Tampilkan hanya jika ada uang keluar
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(Icons.remove_circle,
                                          color: Colors.red,
                                          size: 20), // Ikon untuk uang keluar
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Keluar:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Rp ${keuangan[KeuanganHelper.columnUangKeluar]}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FixedColumnWidth(200), // Lebar kolom pertama
                  1: FixedColumnWidth(150), // Lebar kolom kedua
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                        color: Colors
                            .grey[300]), // Warna latar belakang untuk header
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Deskripsi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Jumlah',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Total Uang Masuk'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Rp ${_totalUangMasuk.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Total Uang Keluar'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text('Rp ${_totalUangKeluar.toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Saldo'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            'Rp ${(_totalUangMasuk - _totalUangKeluar).toStringAsFixed(2)}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
