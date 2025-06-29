class MarkPrice {
  String? eventType;
  num? eventTime;
  String? symbol;
  String? markPrice;
  String? estSettlePrice;
  String? indexPrice;
  String? fundingRate;
  num? nextFundingTime;

  MarkPrice({
    this.eventTime,
    this.eventType,
    this.symbol,
    this.markPrice,
    this.estSettlePrice,
    this.indexPrice,
    this.fundingRate,
    this.nextFundingTime,
  });

  MarkPrice.fromJson(Map<String, dynamic> json) {
    eventType = json['e'];
    eventTime = json['E'];
    symbol = json['s'];
    markPrice = json['p'];
    estSettlePrice = json['P'];
    indexPrice = json['i'];
    fundingRate = json['r'];
    nextFundingTime = json['T'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['e'] = eventType;
    data['E'] = eventTime;
    data['s'] = symbol;
    data['p'] = markPrice;
    data['P'] = estSettlePrice;
    data['i'] = indexPrice;
    data['r'] = fundingRate;
    data['T'] = nextFundingTime;
    return data;
  }
}
