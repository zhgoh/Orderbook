module orderbook;
import std.stdio : writeln;
import std.range;
import std.format : format;
import std.random : uniform;
import std.algorithm;
import order;

final class Orderbook
{
    public this()
    {
        generateRandomOrderbook();
    }

    void generateRandomOrderbook()
    {
        const auto price = 100.0;
        const auto spread = uniform(0.0, 300.0) / 100.0;
        auto bidPrice = price - (spread * 0.5);
        auto askPrice = price + (spread * 0.5);

        foreach (i; 0 .. 5)
        {
            bidLevels[bidPrice] = uniform(1, 30);
            askLevels[askPrice] = uniform(1, 30);
            bidPrice -= uniform(0.01, 1.0);
            askPrice += uniform(0.01, 1.0);
        }

    }

    public void show()
    {
        writeln("=== Orderbook ===");
        writeln("");

        writeln("Price, Quantity");
        immutable green = 10;
        immutable red = 210;

        printLevels(askLevels, red);
        printLevels(bidLevels, green);
    }

    void printLevels(int[double] levels, int color) const
    {
        auto sortedKeys = levels.keys.array.sort.reverse;
        foreach (key; sortedKeys)
        {
            const value = levels[key];
            const auto s = format("$%6.2f %2d %s", key, value, writeColorBar(value, color));
            writeln(s);
        }

    }

    string writeColorBar(int length, int color) const
    {
        immutable char[] bars = repeat(' ', length).array;
        return format("\033[48;5;%dm%s\033[0m", color, bars);
    }

    bool submitOrder(Order order)
    {
        writeln(order);
        return true;

    }

    int[double] bidLevels;
    int[double] askLevels;
}
