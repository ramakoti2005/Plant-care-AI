onPressed: () {

Navigator.pushNamedAndRemoveUntil(
context,
'/login',
(route) => false,
);

},