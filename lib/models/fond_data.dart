
class FondData {
  FondData({
    this.id = -1,
    this.imageUrl = '',
    this.fundName = '',
    this.amount = '',
    this.tag = '',
  });

  int id;
  String imageUrl;
  String fundName;
  String amount;
  String tag;

  static List<FondData> FondList = <FondData>[
    FondData(
      id: 0,
      imageUrl: 'assets/images/fond.png',
      fundName: 'Милосердие',
      amount: '525',
      tag: 'Социальная помощь'
    ),
    FondData(
      id: 1,
      imageUrl: 'assets/images/fond_zdrav.jpeg',
      fundName: 'ФондЗдрав',
      amount: '525',
      tag: 'Здравоохранение',
    ),
    FondData(
      id: 2,
      imageUrl: 'assets/images/fond_wwf.png',
      fundName: 'WWF',
      amount: '525',
      tag: 'Окружающая среда'
    ),
    FondData(
      id: 3,
      imageUrl: 'assets/images/fond_animals.png',
      fundName: 'Рука помощи',
      amount: '525',
      tag: 'Животные'
    ),
  ];
}
