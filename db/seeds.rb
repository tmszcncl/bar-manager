Product.destroy_all

products = [
  ['Hamburger', 6],
  ['Cheeseburger', 7],
  ['Kebab', 10],
  ['Coffee Black', 3],
  ['Coffee White', 4],
  ['French Fries', 4],
  ['Tortilla', 11],
]

products.each{ |name, price| Product.create(name: name, price: price)}