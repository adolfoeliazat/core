import 'cashflow/ShareSale.sol';

library CreatorShareSale {
    function create(address _cashflow, uint256 _price_wei) returns (ShareSale)
    { return new ShareSale(_cashflow, _price_wei); }

    function version() constant returns (string)
    { return "v0.4.0 (755df2d5)"; }

    function interface() constant returns (string)
    { return '[{"constant":false,"inputs":[],"name":"kill","outputs":[],"type":"function"},{"constant":false,"inputs":[],"name":"available","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_owner","type":"address"}],"name":"delegate","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"type":"function"},{"constant":false,"inputs":[{"name":"_price_wei","type":"uint256"}],"name":"setPrice","outputs":[],"type":"function"},{"constant":true,"inputs":[],"name":"priceWei","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"cashflow","outputs":[{"name":"","type":"address"}],"type":"function"},{"inputs":[{"name":"_cashflow","type":"address"},{"name":"_price_wei","type":"uint256"}],"type":"constructor"}]'; }
}
