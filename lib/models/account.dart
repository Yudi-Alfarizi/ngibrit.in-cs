class Account {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String kycStatus; 
  final String? rejectReason; 
  final String? ktpUrl;
  final String? selfieUrl;
  final String? profileUrl; 

  Account({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.kycStatus = 'UNVERIFIED',
    this.rejectReason,
    this.ktpUrl,
    this.selfieUrl,
    this.profileUrl,
  });

  bool get isVerified => kycStatus == 'VERIFIED';

  factory Account.fromJson(Map<String, dynamic> json) {
    String status = 'UNVERIFIED';
    if (json['kycStatus'] != null) {
      status = json['kycStatus'];
    } else if (json['isVerified'] == true) {
      status = 'VERIFIED';
    }

    return Account(
      uid: json['uid'] ?? '',
      // [FIX NULL SAFETY] Mencegah crash jika data name/email kosong
      name: json['name'] ?? 'Tanpa Nama',
      email: json['email'] ?? 'Tanpa Email',
      phoneNumber: json['phoneNumber'] ?? '',
      kycStatus: status,
      rejectReason: json['rejectReason'],
      ktpUrl: json['ktpUrl'],
      selfieUrl: json['selfieUrl'],
      profileUrl: json['profileUrl'],
    );
  }
}