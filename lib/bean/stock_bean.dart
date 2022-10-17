class StockBean {
  ///股票诊断
  StockAnalyze? analyze;

  ///股票分红
  String dividend = "";

  ///股票代码
  String code = "";

  ///当前价格详情
  StockPrice? priceDetail;

  ///股票名字
  String name = "";

  StockBean();

  StockBean.init(this.code);
}

class StockPrice {
  String code = "";
  String name = "";

  ///当前价格
  double currentPrice = 0;

  ///当前涨幅
  String pricePlus = "";

  ///当前涨幅
  double ttm = 0;

  @override
  String toString() {
    return 'StockPrice{currentPrice: $currentPrice, pricePlus: $pricePlus}';
  }
}

class StockAnalyze {}
