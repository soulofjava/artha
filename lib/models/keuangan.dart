class Keuangan {
  final int? id; // ID can be null when creating a new record
  final String tanggal;
  final String catatan;
  final double uangMasuk;
  final double uangKeluar;
  final double saldo;

  // Constructor
  Keuangan({
    this.id,
    required this.tanggal,
    required this.catatan,
    required this.uangMasuk,
    required this.uangKeluar,
    required this.saldo,
  });

  // Convert a Map into a Keuangan object
  factory Keuangan.fromMap(Map<String, dynamic> json) => Keuangan(
        id: json['id'],
        tanggal: json['tanggal'],
        catatan: json['catatan'],
        uangMasuk: json['uangmasuk'],
        uangKeluar: json['uangkeluar'],
        saldo: json['saldo'],
      );

  // Convert a Keuangan object into a Map
  Map<String, dynamic> toMap() => {
        'id': id,
        'tanggal': tanggal,
        'catatan': catatan,
        'uangmasuk': uangMasuk,
        'uangkeluar': uangKeluar,
        'saldo': saldo,
      };
}
