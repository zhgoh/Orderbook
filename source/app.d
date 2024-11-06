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
	auto rnd = Random(unpredictableSeed);
	writeln(" 
######            #######  #######  ######   #######  #######  #######  #######  #######  ##   ## 
     ##                ##       ##       ##                ##       ##       ##       ##  ##  ##  
##   ##           ##   ##  #######  ##   ##  ####     #######  ######   ##   ##  ##   ##  #####   
##   ##           ##   ##  ##  ##   ##   ##  ##       ##  ##   ##   ##  ##   ##  ##   ##  ##  ##  
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ##");
	auto state = new State();
	state.mainMenu();
	return;

	Orderbook orderbook = new Orderbook();

	bool appLoop = true;
	while (appLoop)
	{
		writeln();
		writeln("Choice:\n(P)rint Orderbook\n(S)ubmit Order\n(Q)uit");
		immutable choice = readln();
		switch (choice[0].toLower())
		{
		case 'p':
			writeln("Print Orderbook");
			writeln();
			orderbook.show();
			break;

		case 's':
			bool orderLoop = true;
			while (orderLoop)
			{
				Order order;
				immutable id = uniform(1, 1_000_000, rnd);
				order.orderID = id;

				bool timeInForceLoop = true;
				writeln();
				writeln(
					"Enter Order Type:\n(M)arket\n(L)imit\n(Q)uit to previous menu");

				immutable orderResp = readln();
				switch (orderResp[0].toLower())
				{
				case 'm':
					order.orderType = OrderType.MARKET;
					break;

				case 'l':
					order.orderType = OrderType.LIMIT;
					break;

				case 'q':
					orderLoop = false;
					timeInForceLoop = false;
					break;

				default:
					writeln("Not a valid choice: ", orderResp);
					break;
				}

				while (timeInForceLoop)
				{
					writeln();
					writeln(
						"Enter Time in force:\n(D)ay\n(G)ood-till-cancelled\n(F)ill-or-kill\n(Q)uit to previous menu");

					immutable resp = readln();
					switch (resp[0].toLower())
					{
					case 'd':
						timeInForceLoop = false;
						orderLoop = false;
						order.timeInForce = TimeInForce.DAY;
						break;
					case 'g':
						timeInForceLoop = false;
						orderLoop = false;
						order.timeInForce = TimeInForce.GTC;
						break;

					case 'f':
						timeInForceLoop = false;
						orderLoop = false;
						order.timeInForce = TimeInForce.FOK;
						break;

					case 'q':
						timeInForceLoop = false;
						break;

					default:
						writeln("Not a valid choice: ", resp);
						break;
					}
				}

				if (orderbook.submitOrder(order))
				{
					writeln("Successfully submitted order ", order);
				}
				else
				{
					writeln("Failed to submit order ", order);
				}
			}
			break;

		case 'q':
			writeln("Quitting the app.");
			appLoop = false;
			break;

		default:
			writeln("Not a valid choice: ", choice);
			break;

		}
	}
}

final class State
{
	Orderbook orderbook;
	this()
	{
		orderbook = new Orderbook();
	}

	void loop(string prompt, void delegate()[char] functions)
	{
		bool running = true;
		while (running)
		{
			writeln();
			writeln(prompt);
			immutable resp = readln();
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
		void delegate()[char] charToFunctionMap;
		charToFunctionMap['p'] = toDelegate(&mainMenuPrintOrderbook);
		charToFunctionMap['s'] = toDelegate(&mainMenuSubmitOrder);
		charToFunctionMap['q'] = null;
		loop("Choice:\n(P)rint Orderbook\n(S)ubmit Order\n(Q)uit", charToFunctionMap);
	}

	void mainMenuPrintOrderbook()
	{
		writeln("Print Orderbook");
		writeln();
		orderbook.show();
	}

	void mainMenuSubmitOrder()
	{
		void delegate()[char] charToFunctionMap;
		charToFunctionMap['m'] = toDelegate(&menuMarketOrder);
		charToFunctionMap['l'] = toDelegate(&menuLimitOrder);
		charToFunctionMap['q'] = null;
		loop("Enter Order Type:\n(M)arket\n(L)imit\n(Q)uit to previous menu", charToFunctionMap);
	}

	void menuMarketOrder()
	{
	}

	void menuLimitOrder()
	{
	}
}
