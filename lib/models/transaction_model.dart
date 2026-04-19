class TransactionModel {
  int? id;
  String cashierId;
  String namaPembeli;
  int totalHarga;
  int levelPedas;
  DateTime? createdAt;

  TransactionModel({
    this.id,
    required this.cashierId,
    required this.namaPembeli,
    required this.totalHarga,
    required this.levelPedas,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'cashier_id': cashierId,
      'nama_pembeli': namaPembeli,
      'total_harga': totalHarga,
      'level_pedas': levelPedas,
    };
  }
}