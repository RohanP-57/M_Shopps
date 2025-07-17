import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/services.dart';
import 'summary_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _selectedCountry;
  String? _selectedState;
  List<String> _availableStates = [];
  List<String> _countries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    try {
      _countries = await LocationService.instance.getCountries();
      _selectedCountry = 'India';
      _availableStates = await LocationService.instance.getStatesForCountry('India');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _countries = LocationService.instance.getCountriesSync();
      _selectedCountry = 'India';
      _availableStates = LocationService.instance.getStatesForCountrySync('India');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onCountryChanged(String? country) async {
    setState(() {
      _selectedCountry = country;
      _selectedState = null;
      _availableStates = [];
    });
    
    if (country != null) {
      try {
        final states = await LocationService.instance.getStatesForCountry(country);
        setState(() {
          _availableStates = states;
        });
      } catch (e) {
        setState(() {
          _availableStates = LocationService.instance.getStatesForCountrySync(country);
        });
      }
    }
  }

  void _proceedToSummary() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountry == null || _selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select country and state')),
        );
        return;
      }
      String fullAddress =
          "${_houseController.text}, ${_landmarkController.text}, ${_cityController.text}, $_selectedState, $_selectedCountry - ${_pincodeController.text}";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            name: _nameController.text,
            mobile: _mobileController.text,
            address: fullAddress,
          ),
        ),
      );
    }
  }

  void _increment(Product product) {
    setState(() {
      Cart.add(product);
    });
  }

  void _decrement(Product product) {
    setState(() {
      Cart.removeOne(product);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.items.entries.toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Checkout"),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9900)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading location data...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_cart, color: Color(0xFFFF9900), size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Order Summary",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = cartItems[index].key;
                      final quantity = cartItems[index].value;

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image_not_supported),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _decrement(product),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.remove, size: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  InkWell(
                                    onTap: () => _increment(product),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.add, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFFF9900), size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Delivery Address",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _nameController,
                      label: "Full Name",
                      validator: (value) => value == null || value.isEmpty ? "Enter your name" : null,
                    ),

                    _buildTextField(
                      controller: _mobileController,
                      label: "Mobile Number",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter mobile number";
                        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                          return "Enter a valid 10-digit number";
                        }
                        return null;
                      },
                    ),

                    _buildTextField(
                      controller: _houseController,
                      label: "House/Flat Number",
                      validator: (value) => value == null || value.isEmpty ? "Enter house/flat number" : null,
                    ),

                    _buildTextField(
                      controller: _landmarkController,
                      label: "Landmark / Area",
                      validator: (value) => value == null || value.isEmpty ? "Enter area or landmark" : null,
                    ),

                    _buildTextField(
                      controller: _cityController,
                      label: "City/District/Town",
                      validator: (value) => value == null || value.isEmpty ? "Enter city" : null,
                    ),

                    _buildDropdown(
                      label: "Country",
                      value: _selectedCountry,
                      items: _countries,
                      onChanged: _onCountryChanged,
                    ),

                    _buildDropdown(
                      label: "State",
                      value: _selectedState,
                      items: _availableStates,
                      onChanged: (value) => setState(() => _selectedState = value),
                    ),

                    _buildTextField(
                      controller: _pincodeController,
                      label: "Pincode",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Enter pincode";
                        if (value.length < 5) return "Enter valid pincode";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${Cart.totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _proceedToSummary,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Proceed to Checkout",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}