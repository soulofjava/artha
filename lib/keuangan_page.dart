import 'package:flutter/material.dart';
import 'DB/keuangan_helper.dart';

class KeuanganPage extends StatefulWidget {
  @override
  _KeuanganPageState createState() => _KeuanganPageState();
}

class _KeuanganPageState extends State<KeuanganPage> {
  final keuanganHelper = KeuanganHelper.instance;
  List<Map<String, dynamic>> _keuanganList = [];

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
    });
  }

  // Fungsi untuk menampilkan dialog tambah data baru
  void _showAddDialog() {
    final TextEditingController _catatanController = TextEditingController();
    final TextEditingController _uangMasukController = TextEditingController();
    final TextEditingController _uangKeluarController = TextEditingController();
    final TextEditingController _saldoController = TextEditingController();

    // Tanggal baru dengan default hari ini
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Data Keuangan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _catatanController,
                  decoration: InputDecoration(labelText: 'Catatan'),
                ),
                SizedBox(height: 10),
                // Tanggal menggunakan Date Picker
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: "${selectedDate.toLocal()}".split(' ')[0]),
                  decoration: InputDecoration(labelText: 'Tanggal'),
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
                  decoration: InputDecoration(labelText: 'Uang Masuk'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _uangKeluarController,
                  decoration: InputDecoration(labelText: 'Uang Keluar'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _saldoController,
                  decoration: InputDecoration(labelText: 'Saldo'),
                  keyboardType: TextInputType.number,
                ),
              ],
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
                      double.tryParse(_saldoController.text) ?? 0.0,
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
    final TextEditingController _saldoController = TextEditingController(
        text: keuangan[KeuanganHelper.columnSaldo].toString());

    // Tanggal dalam bentuk DateTime
    DateTime selectedDate =
        DateTime.parse(keuangan[KeuanganHelper.columnTanggal]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Data Keuangan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _catatanController,
                  decoration: InputDecoration(labelText: 'Catatan'),
                ),
                SizedBox(height: 10),
                // Tanggal menggunakan Date Picker
                TextField(
                  readOnly: true,
                  controller: TextEditingController(
                      text: "${selectedDate.toLocal()}".split(' ')[0]),
                  decoration: InputDecoration(labelText: 'Tanggal'),
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
                  decoration: InputDecoration(labelText: 'Uang Masuk'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _uangKeluarController,
                  decoration: InputDecoration(labelText: 'Uang Keluar'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _saldoController,
                  decoration: InputDecoration(labelText: 'Saldo'),
                  keyboardType: TextInputType.number,
                ),
              ],
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
                  KeuanganHelper.columnSaldo:
                      double.tryParse(_saldoController.text) ?? 0.0,
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
      body: _keuanganList.isEmpty
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
                  elevation: 4.0,
                  child: ListTile(
                    title: Text(keuangan[KeuanganHelper.columnCatatan]),
                    subtitle: Text(
                        'Tanggal: ${keuangan[KeuanganHelper.columnTanggal]}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            'Masuk: Rp ${keuangan[KeuanganHelper.columnUangMasuk]}'),
                        Text(
                            'Keluar: Rp ${keuangan[KeuanganHelper.columnUangKeluar]}'),
                        Text(
                            'Saldo: Rp ${keuangan[KeuanganHelper.columnSaldo]}'),
                      ],
                    ),
                    onTap: () {
                      _showEditDialog(
                          keuangan); // Tampilkan dialog saat item dipilih
                    },
                  ),
                );
              },
            ),
    );
  }
}
