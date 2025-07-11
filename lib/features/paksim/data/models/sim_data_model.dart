// Model class for SIM data
class SimDataModel {
  final String mobileNumber; // Matches '📱 Mobile' from parsed data
  final String name;         // Matches '👤 Name'
  final String cnic;         // Matches '🆔 Cnic'
  final String address;      // Matches '📍' (address/location)

  SimDataModel({
    required this.mobileNumber,
    required this.name,
    required this.cnic,
    required this.address,
  });

  // Factory constructor to create a SimDataModel from a map
  // This is useful for consistent construction from parsed data.
  factory SimDataModel.fromMap(Map<String, String> data) {
    return SimDataModel(
      mobileNumber: data['mobileNumber'] ?? 'N/A',
      name: data['name'] ?? 'N/A',
      cnic: data['cnic'] ?? 'N/A',
      address: data['address'] ?? 'N/A',
    );
  }
}