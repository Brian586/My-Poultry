class Category {
  final String imageUrl;
  final String title;
  final int id;

  Category({this.imageUrl, this.title, this.id});
}


List<Category> categoryList = [
  Category(
    imageUrl: "assets/eggs.jpg",
    title: "All",
    id: 1
  ),
  Category(
      imageUrl: "assets/chicken.jpg",
      title: "Chicken",
    id: 2
  ),
  Category(
      imageUrl: "assets/duck.jpg",
      title: "Ducks",
    id: 3
  ),
  Category(
      imageUrl: "assets/geese.jpg",
      title: "Geese",
    id: 4
  ),
  Category(
      imageUrl: "assets/guineafowls.png",
      title: "Guinea Fowls",
    id: 5
  ),
  Category(
      imageUrl: "assets/quail.jpg",
      title: "Quails",
    id: 6
  ),
  Category(
      imageUrl: "assets/turkey.jpg",
      title: "Turkey",
    id: 7
  ),
];