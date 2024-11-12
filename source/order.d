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
    Fok,
    Gtc,
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
