module order;

enum Action
{
    Buy,
    Sell,
}

enum OrderType
{
    Market,
    Limit,
}

enum TimeInForce
{
    Day,
    Gtc,
    Fok
}

struct Order
{
    int orderID;
    Action action;
    OrderType orderType;
    TimeInForce timeInForce;
    int quantity;
    double price;
}
