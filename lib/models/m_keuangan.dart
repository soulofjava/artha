class Keuangan {
  int? id;
  String? tanggal;
  String? catatan;
  double? uangMasuk;
  double? uangKeluar;

  Keuangan({
    this.id,
    this.tanggal,
    this.catatan,
    this.uangMasuk,
    this.uangKeluar,
  });

  // Factory method to create a Keuangan object from a Map (e.g., database row)
  factory Keuangan.fromMap(Map<String, dynamic> json) {
    return Keuangan(
      id: json['id'],
      tanggal: json['tanggal'],
      catatan: json['catatan'],
      uangMasuk: json['uangMasuk'],
      uangKeluar: json['uangKeluar'],
    );
  }

  // Method to convert a Keuangan object into a Map (e.g., for inserting into a database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'catatan': catatan,
      'uangMasuk': uangMasuk,
      'uangKeluar': uangKeluar,
    };
  }
}
