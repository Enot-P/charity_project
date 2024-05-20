
class LastDonationListData {
  LastDonationListData({
    this.imageUrl = '',
    this.fundName = '',
    this.amount = '',
  });

  String imageUrl;
  String fundName;
  String amount;

  static List<LastDonationListData> DonateList = <LastDonationListData>[
    LastDonationListData(
      imageUrl: 'assets/images/fond.png',
      fundName: 'Милосердие',
      amount: '525',
    ),
    LastDonationListData(
      imageUrl: 'assets/images/fond.png',
      fundName: 'Милосердие',
      amount: '525',
    ),
    LastDonationListData(
      imageUrl: 'assets/images/fond.png',
      fundName: 'Милосердие',
      amount: '525',
    ),
    LastDonationListData(
      imageUrl: 'assets/images/fond.png',
      fundName: 'Милосердие',
      amount: '525',
    ),
  ];
}
