module order;

enum Action
{
    BUY,
    SELL
}

enum OrderType
{
    MARKET,
    LIMIT
}

enum TimeInForce
{
    DAY,
    GTC,
    FOK
}

struct Order
{
    int orderID;
    Action action;
    OrderType orderType;
    TimeInForce timeInForce;
    double price;
}
