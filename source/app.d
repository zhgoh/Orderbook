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
	auto state = new State();
	state.mainMenu();
}

final class State
{
	Random rnd;
	Orderbook orderbook;
	alias FnMap = void delegate()[char];

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

	void loop(string prompt, FnMap functions)
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
		FnMap charToFunctionMap;
		charToFunctionMap['p'] = toDelegate(&menuPrintOrderbook);
		charToFunctionMap['s'] = toDelegate(&menuSubmitOrder);
		charToFunctionMap['q'] = null;
		loop("Choice:\n(P)rint Orderbook\n(S)ubmit Order\n(Q)uit", charToFunctionMap);
	}

	void menuPrintOrderbook()
	{
		writeln("Print Orderbook");
		writeln();
		orderbook.show();
	}

	void menuSubmitOrder()
	{
		FnMap charToFunctionMap;
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
