import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  String productId;
  String title;
  String shortInfo;
  int publishedDate;
  String thumbnailUrl;
  String longDescription;
  String status;
  int price;
  String condition;
  int oldPrice;
  String category;
  String publisher;
  String publisherID;
  String phone;
  String city;
  String country;

  Product(
      {this.title,
        this.productId,
        this.shortInfo,
        this.publishedDate,
        this.thumbnailUrl,
        this.longDescription,
        this.status,
        this.condition,
        this.price,
        this.publisherID,
        this.oldPrice,
        this.category,
        this.publisher,
        this.phone,
        this.country,
        this.city
      });

  factory Product.fromDocument(DocumentSnapshot doc) {
    return Product(
      productId: doc.documentID,
      title : doc['title'],
      shortInfo : doc['shortInfo'],
      publishedDate : doc['publishedDate'],
      thumbnailUrl : doc['thumbnailUrl'],
      longDescription : doc['longDescription'],
      status : doc['status'],
      condition : doc['condition'],
      price : doc['price'],
      oldPrice : doc['oldPrice'],
      category : doc['category'],
      publisher : doc['publisher'],
      publisherID : doc['publisherID'],
      phone : doc['phone'],
      country : doc['country'],
      city : doc['city'],
    );
  }

  Product.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    title = json['title'];
    shortInfo = json['shortInfo'];
    publishedDate = json['publishedDate'];
    thumbnailUrl = json['thumbnailUrl'];
    longDescription = json['longDescription'];
    status = json['status'];
    condition = json['condition'];
    price = json['price'];
    oldPrice = json['oldPrice'];
    category = json['category'];
    publisher = json['publisher'];
    publisherID = json['publisherID'];
    phone = json['phone'];
    country = json['country'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = this.title;
    data['shortInfo'] = this.shortInfo;
    data['price'] = this.price;
    if (this.publishedDate != null) {
      data['publishedDate'] = this.publishedDate;
    }
    data['thumbnailUrl'] = this.thumbnailUrl;
    data['longDescription'] = this.longDescription;
    data['status'] = this.status;
    data['oldPrice'] = this.oldPrice;
    data['productId'] = this.productId;
    data['condition'] = this.condition;
    data['category'] = this.category;
    data['publisher'] = this.publisher;
    data['publisherID'] = this.publisherID;
    data['phone'] = this.phone;
    data['country'] = this.country;
    data['city'] = this.city;
    return data;
  }
}