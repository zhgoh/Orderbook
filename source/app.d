import std.stdio : writeln, readln, write;

// import std.uni;
// import std.random;
import std.functional : toDelegate;
import std.conv : to, ConvException;
import std.string : strip, toLower;
import orderbook;
import order;

void main()
{
	writeln(" 
######            #######  #######  ######   #######  #######  #######  #######  #######  ##   ## 
     ##                ##       ##       ##                ##       ##       ##       ##  ##  ##  
##   ##           ##   ##  #######  ##   ##  ####     #######  ######   ##   ##  ##   ##  #####   
##   ##           ##   ##  ##  ##   ##   ##  ##       ##  ##   ##   ##  ##   ##  ##   ##  ##  ##  
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ##");

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
		write(prompt);
		return readln().strip();
	}

	State choices(string prompt, FnMap functions)
	{
		immutable resp = getInput(prompt);
		if (resp.length == 0)
		{
			return this;
		}

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
	}

	override State run()
	{
		FnMap charToFunctionMap;
		charToFunctionMap['p'] = toDelegate(&printOrderbook);
		charToFunctionMap['s'] = toDelegate(&submitOrder);
		charToFunctionMap['q'] = toDelegate(&quit);

		return choices("Main menu:\n(P)rint Orderbook\n(S)ubmit Order\n(Q)uit\n", charToFunctionMap);
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

		return choices("Order Direction:\n(B)uy\n(S)ell\n(Q)uit to previous menu\n", charToFunctionMap);
	}

	State buyOrder()
	{
		action_ = Action.BUY;
		return new OrderState(orderBook_, this);
	}

	State sellOrder()
	{
		action_ = Action.SELL;
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

		return choices("Order Type:\n(M)arket\n(L)imit\n(Q)uit to previous menu\n", charToFunctionMap);
	}

	State marketOrder()
	{
		orderType_ = OrderType.MARKET;
		return new QuantityState(orderBook_, this);
	}

	State limitOrder()
	{
		orderType_ = OrderType.LIMIT;
		return new LimitPriceState(orderBook_, this);
	}
}

class LimitPriceState : State
{
	float price_;
	this(Orderbook orderbook, State prevState)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		try
		{
			price_ = to!float(getInput("Input price: "));
		}
		catch (ConvException e)
		{
			writeln("Invalid price.");
			return this;

		}

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
		try
		{
			qty_ = to!int(getInput("Input quantity: "));
		}
		catch (ConvException e)
		{
			writeln("Invalid quantity.");
			return this;

		}
		// TODO: Get order type, action by traversing the prevStates

		return new StartState(orderBook_, null);
	}

}
