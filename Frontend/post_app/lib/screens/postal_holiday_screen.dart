import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostalHolidayScreen extends StatefulWidget {
  const PostalHolidayScreen({super.key});

  @override
  State<PostalHolidayScreen> createState() => _PostalHolidayScreenState();
}

class _PostalHolidayScreenState extends State<PostalHolidayScreen> {
  final List<Map<String, dynamic>> _cities = [
    {
      'name': 'Anuradhapura (current)',
      'image': 'assets/Anuradhapura.png',
      'maxHeads': 12,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2266550',
      'rates': [
        {'type': 'Outsiders', 'booking': '5000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '2000.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Trincomalee "A"',
      'image': 'assets/Trinco 01.png',
      'maxHeads': 12,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2221234',
      'rates': [
        {'type': 'Outsiders', 'booking': '8000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '3000.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Trincomalee "B"',
      'image': 'assets/trinco2.png',
      'maxHeads': 25,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2225678',
      'rates': [
        {'type': 'Outsiders', 'booking': '5000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '4000.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Nuwara Eliya',
      'image': 'assets/nuwara_eliya.png',
      'maxHeads': 10,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2223456',
      'rates': [
        {'type': 'Outsiders', 'booking': '8000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '3000.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Mannar',
      'image': 'assets/mannar.png',
      'maxHeads': 10,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2227890',
      'rates': [
        {'type': 'Outsiders', 'booking': '6000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '2500.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Karainagar',
      'image': 'assets/karainagar.png',
      'maxHeads': 10,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2221122',
      'rates': [
        {'type': 'Outsiders', 'booking': '6000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '2500.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Chullipuram',
      'image': 'assets/chullipuram.png',
      'maxHeads': 10,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2223344',
      'rates': [
        {'type': 'Outsiders', 'booking': '4000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '2000.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Sigiriya "A"',
      'image': 'assets/sigiriya01.png',
      'maxHeads': 4,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2225566',
      'rates': [
        {'type': 'Outsiders', 'booking': '5000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '1850.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Sigiriya "B"',
      'image': 'assets/sigiriya02.png',
      'maxHeads': 4,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2227788',
      'rates': [
        {'type': 'Outsiders', 'booking': '5000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '1850.00', 'service': '200.00'},
      ],
    },
    {
      'name': 'Mihintalaya',
      'image': 'assets/mihinthalaya.png',
      'maxHeads': 4,
      'description': 'Relaxing environment\nTwo furnished AC comfortable rooms\nAmple space for vehicle parking\nNo Indoor catering service\n\nTelephone:011-2229900',
      'rates': [
        {'type': 'Outsiders', 'booking': '5000.00', 'service': '300.00'},
        {'type': 'Staff Rates', 'booking': '2000.00', 'service': '200.00'},
      ],
    },
  ];

  int _selectedCityIndex = 0;
  int _carouselIndex = 0;
  final PageController _carouselController = PageController();

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final city = _cities[_selectedCityIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postal Holiday'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedCityIndex,
                decoration: const InputDecoration(
                  labelText: 'Select City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
                items: List.generate(_cities.length, (i) => DropdownMenuItem(
                  value: i,
                  child: Text(_cities[i]['name']),
                )),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCityIndex = val;
                      _carouselIndex = val;
                      _carouselController.jumpToPage(val);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _carouselController,
                  itemCount: _cities.length,
                  onPageChanged: (i) {
                    setState(() {
                      _carouselIndex = i;
                      _selectedCityIndex = i;
                    });
                  },
                  itemBuilder: (context, i) {
                    final c = _cities[i];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            c['image'],
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 220,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 18,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                c['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_cities.length, (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _carouselIndex == i ? Colors.orange : Colors.grey[300],
                  ),
                )),
              ),
              const SizedBox(height: 10),
              const Text('Booking Rates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FixedColumnWidth(40),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(90),
                  3: FixedColumnWidth(90),
                  4: FixedColumnWidth(80),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.orange[50]),
                    children: const [
                      Padding(padding: EdgeInsets.all(6), child: Text('No.', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(6), child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(6), child: Text('Booking', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(6), child: Text('Service', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.all(6), child: Text('Max Heads', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...List.generate(city['rates'].length, (i) => TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(6), child: Text('${i + 1}')),
                      Padding(padding: const EdgeInsets.all(6), child: Text(city['rates'][i]['type'])),
                      Padding(padding: const EdgeInsets.all(6), child: Text(city['rates'][i]['booking'])),
                      Padding(padding: const EdgeInsets.all(6), child: Text(city['rates'][i]['service'])),
                      Padding(padding: const EdgeInsets.all(6), child: Text(city['maxHeads'].toString())),
                    ],
                  )),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  city['description'],
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.book_online),
                  label: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen, // Light green color
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    String? fullName;
                    String? mobileNumber;
                    String paymentOption = 'Credit Card';
                    String customerType = 'Outsiders';
                    final paymentOptions = [
                      'Credit Card',
                      'Debit Card',
                      'Bank Transfer',
                      'Cash',
                    ];
                    final customerTypes = ['Outsiders', 'Staff Rates'];
                    int selectedRateIndex = 0;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            // Find the selected rate row
                            selectedRateIndex = customerTypes.indexOf(customerType);
                            final selectedRate = city['rates'][selectedRateIndex];
                            return AlertDialog(
                              title: Text('Booking Details for ${city['name']}'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (val) => fullName = val,
                                    ),
                                    const SizedBox(height: 14),
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Mobile Number',
                                        border: OutlineInputBorder(),
                                      ),
                                      maxLength: 10,
                                      onChanged: (val) {
                                        // Only allow digits 0-9
                                        final filtered = val.replaceAll(RegExp(r'[^0-9]'), '');
                                        if (val != filtered) {
                                          // If user entered non-digit, update the field
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            setState(() {});
                                          });
                                        }
                                        mobileNumber = filtered;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    const Text('Customer Type:'),
                                    DropdownButtonFormField<String>(
                                      value: customerType,
                                      items: customerTypes.map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      )).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => customerType = val);
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text('Booking Amount: LKR ${selectedRate['booking']}'),
                                    Text('Service Charge: LKR ${selectedRate['service']}'),
                                    const SizedBox(height: 14),
                                    const Text('Payment Option:'),
                                    DropdownButtonFormField<String>(
                                      value: paymentOption,
                                      items: paymentOptions.map((opt) => DropdownMenuItem(
                                        value: opt,
                                        child: Text(opt),
                                      )).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => paymentOption = val);
                                      },
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (fullName == null || fullName!.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter your full name.')),
                                      );
                                      return;
                                    }
                                    if (mobileNumber == null || mobileNumber!.trim().length != 10) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please enter a valid 10-digit mobile number.')),
                                      );
                                      return;
                                    }
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Success'),
                                        content: const Text('Thank you. Please check your email for the booking details'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Text('Confirm Booking'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
