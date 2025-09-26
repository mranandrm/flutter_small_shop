class HomeSlider {
  final int id;
  final String image_path;

  HomeSlider({
    required this.id,
    required this.image_path,
  });

  factory HomeSlider.fromJson(Map<String, dynamic> json) {
    return HomeSlider(
      id: json['id'],
      image_path: json['image_path'],
    );
  }
}