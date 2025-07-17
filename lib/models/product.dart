class Product {
  final int id;
  final String name;
  final int price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  static List<Product> getDummyProducts() {
    return [
      Product(
        id: 1,
        name: 'Bluetooth Headphones',
        price: 1999,
        imageUrl:
        'https://th.bing.com/th/id/R.4598d1bda3bd21f0c0c290f6d08edee7?rik=CLcM1sylVTpOlg&riu=http%3a%2f%2fwww.bhphotovideo.com%2fimages%2fimages2500x2500%2fbeats_by_dr_dre_900_00108_01_studio_wireless_headphones_white_1016366.jpg&ehk=%2fBwHdKJ0eGmmpzE7oTrCNsim037FuKZAmyeWVDddWhg%3d&risl=&pid=ImgRaw&r=0',
      ),
      Product(
        id: 2,
        name: 'Smart Watch',
        price: 3999,
        imageUrl:
        'https://th.bing.com/th/id/OIP.0Lojdc0N5O2RxyQGEYrCcQHaJC?w=208&h=180&c=7&r=0&o=7&pid=1.7&rm=3',
      ),
      Product(
        id: 3,
        name: 'Wireless Mouse',
        price: 4999,
        imageUrl: 'https://m.media-amazon.com/images/I/51b7iu8AovL._SX569_.jpg',
      ),
      Product(
        id: 4,
        name: 'Laptop Stand',
        price: 1499,
        imageUrl:
        'https://th.bing.com/th/id/OIP.hUw_PVoIUXySyMcpU3j09AHaHa?w=190&h=188&c=7&r=0&o=5&pid=1.7',
      ),
      Product(
        id: 5,
        name: 'Portable SSD',
        price: 6499,
        imageUrl:
        'https://th.bing.com/th/id/OIP.a5e170S55LS_fMUzzckTbwHaEi?w=298&h=182&c=7&r=0&o=7&pid=1.7&rm=3',
      ),
    ];
  }
}
