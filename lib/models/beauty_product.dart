class BeautyProduct {
  final String barcode;
  final String? name;
  final String? brands;
  final String? ingredientsText;
  final String? imageUrl;

  const BeautyProduct({
    required this.barcode,
    this.name,
    this.brands,
    this.ingredientsText,
    this.imageUrl,
  });
}
