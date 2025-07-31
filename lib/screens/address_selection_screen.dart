import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/services.dart';
import 'add_address_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  final String? selectedAddressId;
  final Function(Map<String, dynamic>) onAddressSelected;

  const AddressSelectionScreen({
    super.key,
    this.selectedAddressId,
    required this.onAddressSelected,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<Map<String, dynamic>> addresses = [];
  String? selectedAddressId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedAddressId = widget.selectedAddressId;
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser != null) {
        final userDoc = await FirestoreService().getUserData(currentUser.uid);
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final userAddresses = List<Map<String, dynamic>>.from(
            userData['addresses'] ?? []
          );
          
          setState(() {
            addresses = userAddresses.asMap().entries.map((entry) {
              final address = Map<String, dynamic>.from(entry.value);
              address['id'] = entry.key.toString();
              return address;
            }).toList();
            
            if (selectedAddressId == null && addresses.isNotEmpty) {
              final defaultAddress = addresses.firstWhere(
                (addr) => addr['isDefault'] == true,
                orElse: () => addresses.first,
              );
              selectedAddressId = defaultAddress['id'];
            }
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select a delivery address'),
        backgroundColor: const Color(0xFF232F3E),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All addresses (${addresses.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...addresses.map((address) => _buildAddressCard(address)),
                        const SizedBox(height: 16),
                        _buildAddAddressCard(),
                      ],
                    ),
                  ),
                ),
                if (selectedAddressId != null) _buildBottomButton(),
              ],
            ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final isSelected = selectedAddressId == address['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFFFF9900) : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            value: address['id'],
            groupValue: selectedAddressId,
            onChanged: (value) {
              setState(() {
                selectedAddressId = value;
              });
            },
            activeColor: const Color(0xFFFF9900),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${address['street']}, ${address['city']}, ${address['state']}, ${address['zipCode']}, ${address['country'] ?? 'India'}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone number: ${address['mobileNumber'] ?? address['mobile'] ?? 'Not provided'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final selectedAddress = addresses.firstWhere(
                          (addr) => addr['id'] == selectedAddressId,
                        );
                        widget.onAddressSelected(selectedAddress);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Deliver to this address',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _editAddress(address),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Edit address',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _addDeliveryInstructions(address),
                    child: const Text(
                      'Add delivery instructions',
                      style: TextStyle(color: Color(0xFF007185)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddAddressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add delivery address',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _addNewAddress(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add new address',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            final selectedAddress = addresses.firstWhere(
              (addr) => addr['id'] == selectedAddressId,
            );
            widget.onAddressSelected(selectedAddress);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9900),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            'Use this address',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _editAddress(Map<String, dynamic> address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          editingAddress: address,
          onAddressSaved: () {
            _loadAddresses();
          },
        ),
      ),
    );
  }

  void _addNewAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          onAddressSaved: () {
            _loadAddresses();
          },
        ),
      ),
    );
  }

  void _addDeliveryInstructions(Map<String, dynamic> address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add delivery instructions'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'e.g., Ring the doorbell, Leave at door',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            address['deliveryInstructions'] = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Delivery instructions added'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}