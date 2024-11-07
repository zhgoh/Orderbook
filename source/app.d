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
	auto orderBook = new Orderbook();
	State state = new StartState(orderBook, null);

	while (state)
	{
		state = state.run();
	}
}

alias FnMap = State delegate()[char];

class State
{
	State prevState_;
	Orderbook orderBook_;

	this(Orderbook orderbook, State prevState)
	{
		orderBook_ = orderbook;
		prevState_ = prevState;
	}

	State run()
	{
		return null;
	}

	string getInput(string prompt)
	{
		writeln();
		writeln(prompt);
		return readln();
	}

	State choices(string prompt, FnMap functions)
	{
		immutable resp = getInput(prompt);
		auto matched = false;
		foreach (ch, fn; functions)
		{
			if (resp[0].toLower() == ch)
			{
				matched = true;
				return fn();
			}
		}
		if (!matched)
		{
			writeln("Not a valid choice: ", resp);
		}
		return this;
	}

	State quit()
	{
		return prevState_;
	}
}

class StartState : State
{
	this(Orderbook orderbook, State prevState)
	{
		super(orderbook, prevState);
		writeln(" 
######            #######  #######  ######   #######  #######  #######  #######  #######  ##   ## 
     ##                ##       ##       ##                ##       ##       ##       ##  ##  ##  
##   ##           ##   ##  #######  ##   ##  ####     #######  ######   ##   ##  ##   ##  #####   
##   ##           ##   ##  ##  ##   ##   ##  ##       ##  ##   ##   ##  ##   ##  ##   ##  ##  ##  
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ##");
	}

	override State run()
	{
		FnMap charToFunctionMap;
		charToFunctionMap['p'] = toDelegate(&printOrderbook);
		charToFunctionMap['s'] = toDelegate(&submitOrder);
		charToFunctionMap['q'] = toDelegate(&quit);

		return choices("Main menu:\n(P)rint Orderbook\n(S)ubmit Order\n(Q)uit", charToFunctionMap);
	}

	State printOrderbook()
	{
		writeln("Print Orderbook");
		writeln();
		orderBook_.show();
		return this;
	}

	State submitOrder()
	{
		return new OrderState(orderBook_, this);
	}

}

class OrderState : State
{
	OrderType orderType_;
	this(Orderbook orderbook, State prevState)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		FnMap charToFunctionMap;
		charToFunctionMap['m'] = toDelegate(&marketOrder);
		charToFunctionMap['l'] = toDelegate(&limitOrder);
		charToFunctionMap['q'] = toDelegate(&quit);

		return choices("Order Type:\n(M)arket\n(L)imit\n(Q)uit to previous menu", charToFunctionMap);
	}

	State marketOrder()
	{
		orderType_ = OrderType.MARKET;
		return new ActionState(orderBook_, this);
	}

	State limitOrder()
	{
		orderType_ = OrderType.LIMIT;
		return new ActionState(orderBook_, this);
	}
}

class ActionState : State
{
	Action action_;
	this(Orderbook orderbook, State prevState)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		FnMap charToFunctionMap;
		charToFunctionMap['b'] = toDelegate(&buyOrder);
		charToFunctionMap['s'] = toDelegate(&sellOrder);
		charToFunctionMap['q'] = toDelegate(&quit);

		return choices("Order Direction:\n(B)uy\n(S)ell\n(Q)uit to previous menu", charToFunctionMap);
	}

	State buyOrder()
	{
		action_ = Action.BUY;
		return new QuantityState(orderBook_, this);
	}

	State sellOrder()
	{
		action_ = Action.SELL;
		return new QuantityState(orderBook_, this);
	}
}

class QuantityState : State
{
	float qty_;
	this(Orderbook orderbook, State prevState)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		writeln("\nInput quantity: ");
		immutable resp = readln();
		return this;
	}

}
