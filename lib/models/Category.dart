class Category {
  final int id;
  final String name;
  final String status;


  Category({
    required this.id,
     required this.name,
    required this.status
});

  factory Category.fromJson(Map<String,dynamic>json){

    return Category(
        id: json['id'],
        name: json['name'],
        status: json['status']
    );
  }
}