import std.stdio;
import std.uni;
import std.random;
import std.functional;
import orderbook;
import order;

// Inspired by https://www.youtube.com/watch?v=E2y5wiBO1oE
// Inspired by https://www.youtube.com/watch?v=XeLWe0Cx_Lg

void main()
{
	auto engine = new Engine();
	engine.mainMenu();
}

final class State
final class Engine
{
	Random rnd;
	Orderbook orderbook;
	alias FnMap = void delegate()[char];

	bool buy, sell;

	this()
	{
		orderbook = new Orderbook();
		rnd = Random(unpredictableSeed);

		writeln(" 
######            #######  #######  ######   #######  #######  #######  #######  #######  ##   ## 
     ##                ##       ##       ##                ##       ##       ##       ##  ##  ##  
##   ##           ##   ##  #######  ##   ##  ####     #######  ######   ##   ##  ##   ##  #####   
##   ##           ##   ##  ##  ##   ##   ##  ##       ##  ##   ##   ##  ##   ##  ##   ##  ##  ##  
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ##");

	}

	string displayPrompt(string prompt)
	{
		writeln();
		writeln(prompt);
		return readln();
	}

	void choices(string prompt, FnMap functions)
	{
		bool running = true;
		while (running)
		{
			immutable resp = displayPrompt(prompt);
			bool matched = false;
			foreach (ch, fn; functions)
			{
				if (resp[0].toLower() == ch)
				{
					matched = true;
					if (fn != null)
						fn();
					else
						return;

				}
			}
			if (!matched)
			{
				writeln("Not a valid choice: ", resp);
			}
		}
	}

	void mainMenu()
	{
		FnMap charToFunctionMap;
		charToFunctionMap['p'] = toDelegate(&menuPrintOrderbook);
		charToFunctionMap['s'] = toDelegate(&menuSubmitOrderQty);
		charToFunctionMap['q'] = null;
		choices("Choice:\n(P)rint Orderbook\n(S)ubmit Order\n(Q)uit", charToFunctionMap);
	}

	void menuPrintOrderbook()
	{
		writeln("Print Orderbook");
		writeln();
		orderbook.show();
	}

	void menuSubmitOrderQty()
	{
		// TODO: does not work
		FnMap charToFunctionMap;
		charToFunctionMap['b'] = toDelegate(&menuSubmitOrderBuy);
		charToFunctionMap['s'] = toDelegate(&menuSubmitOrderSell);
		charToFunctionMap['q'] = null;
		choices("Choice:\n(B)uy\n(S)ell\n(Q)uit", charToFunctionMap);

		buy = sell = false;
		auto qty = displayPrompt("Quantity: ");

	}

	void menuSubmitOrderBuy()
	{
		buy = true;
		sell = false;
	}

	void menuSubmitOrderSell()
	{
		sell = true;
		buy = false;
	}

	void menuSubmitOrder()
	{
		auto direction = displayPrompt("Buy/Sell: ");

		FnMap charToFunctionMap;
		charToFunctionMap['m'] = toDelegate(&menuMarketOrder);
		charToFunctionMap['l'] = toDelegate(&menuLimitOrder);
		charToFunctionMap['q'] = null;
		choices("Enter Order Type:\n(M)arket\n(L)imit\n(Q)uit to previous menu", charToFunctionMap);
	}

	void menuMarketOrder()
	{
	}

	void menuLimitOrder()
	{
	}
}
