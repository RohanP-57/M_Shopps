import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _loadSavedAddress();
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

  Future<void> _loadSavedAddress() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser != null) {
        final userDoc = await AuthService().getUserData();
        final userData = userDoc?.data() as Map<String, dynamic>?;
        
        if (userData != null) {
          _nameController.text = userData['displayName'] ?? '';
          
          final addresses = userData['addresses'] as List<dynamic>?;
          if (addresses != null && addresses.isNotEmpty) {
            final lastAddress = addresses.last as Map<String, dynamic>;
            
            setState(() {
              _mobileController.text = lastAddress['mobileNumber'] ?? lastAddress['mobile'] ?? '';
              _houseController.text = lastAddress['street'] ?? '';
              _landmarkController.text = lastAddress['landmark'] ?? '';
              _cityController.text = lastAddress['city'] ?? '';
              _pincodeController.text = lastAddress['zipCode'] ?? '';
              _selectedState = lastAddress['state'];
              _selectedCountry = lastAddress['country'] ?? 'India';
            });
            
            if (_selectedCountry != null) {
              _onCountryChanged(_selectedCountry);
            }
          }
        }
      }
    } catch (e) {
      // Handle error silently
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

  void _proceedToSummary() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCountry == null || _selectedState == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select country and state')),
        );
        return;
      }
      
      await _saveAddressToProfile();
      
      String fullAddress = "${_houseController.text}, ${_landmarkController.text}, ${_cityController.text}, $_selectedState, $_selectedCountry - ${_pincodeController.text}";
      
      if (mounted) {
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
  }

  Future<void> _saveAddressToProfile() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser != null) {
        await FirestoreService().saveUserAddressAndMobile(
          userId: currentUser.uid,
          name: _nameController.text.trim(),
          mobile: _mobileController.text.trim(),
          street: _houseController.text.trim(),
          city: _cityController.text.trim(),
          state: _selectedState ?? '',
          zipCode: _pincodeController.text.trim(),
          paymentMethod: 'checkout_form',
          landmark: _landmarkController.text.trim(),
          country: _selectedCountry ?? 'India',
        );
      }
    } catch (e) {
      //
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
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: const TextStyle(fontSize: 12, color: Colors.grey),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 12),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
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
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
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
                                    Container(
                                      constraints: BoxConstraints(
                                        minWidth: MediaQuery.of(context).size.width * 0.3,
                                        maxWidth: MediaQuery.of(context).size.width * 0.5,
                                      ),
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
                                    const SizedBox(width: 12),
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
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter your name";
                              }
                              if (value.trim().length < 2) {
                                return "Name must be at least 2 characters";
                              }
                              return null;
                            },
                            helperText: "Letters and spaces only",
                          ),
                          _buildTextField(
                            controller: _mobileController,
                            label: "Mobile Number",
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter mobile number";
                              }
                              if (value.length != 10) {
                                return "Enter a valid 10-digit number";
                              }
                              if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
                                return "Enter a valid Indian mobile number";
                              }
                              return null;
                            },
                            helperText: "10-digit mobile number",
                          ),
                          _buildTextField(
                            controller: _houseController,
                            label: "House/Flat Number",
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-/]')),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter house/flat number";
                              }
                              if (value.trim().length < 1) {
                                return "Enter a valid house/flat number";
                              }
                              return null;
                            },
                            helperText: "Letters, numbers, spaces, hyphens only",
                          ),
                          _buildTextField(
                            controller: _landmarkController,
                            label: "Landmark / Area",
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-,.]')),
                              LengthLimitingTextInputFormatter(100),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter area or landmark";
                              }
                              if (value.trim().length < 2) {
                                return "Enter a valid landmark or area";
                              }
                              return null;
                            },
                            helperText: "Letters, numbers, spaces, commas, periods only",
                          ),
                          _buildTextField(
                            controller: _cityController,
                            label: "City/District/Town",
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              LengthLimitingTextInputFormatter(50),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter city";
                              }
                              if (value.trim().length < 2) {
                                return "Enter a valid city name";
                              }
                              return null;
                            },
                            helperText: "Letters and spaces only",
                          ),
                          _buildDropdown(
                            label: "Country",
                            value: _selectedCountry,
                            items: _countries,
                            onChanged: _onCountryChanged,
                          ),
                          _buildDropdown(
                            label: "   State",
                            value: _selectedState,
                            items: _availableStates,
                            onChanged: (value) => setState(() => _selectedState = value),
                          ),
                          _buildTextField(
                            controller: _pincodeController,
                            label: "Pincode",
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter pincode";
                              }
                              if (value.length < 6 || value.length > 8) {
                                return "Pincode must be 6-8 digits";
                              }
                              if (!RegExp(r'^[0-9]{6,8}$').hasMatch(value)) {
                                return "Enter a valid pincode";
                              }
                              return null;
                            },
                            helperText: "6-8 digits only",
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