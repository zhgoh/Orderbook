import std.stdio : writeln, readln, write;

// import std.uni;
// import std.random;
import std.functional : toDelegate;
import std.conv : to, ConvException;
import std.string : strip, toLower;
import std.format : format;
import std.random : Random, unpredictableSeed, uniform;
import orderbook;
import order;

int generateRandomId()
{
	// Create a random number generator
	auto rng = Random(unpredictableSeed);
	return uniform(0, 1_000_000, rng);
}

void main()
{
	writeln(" 
######            #######  #######  ######   #######  #######  #######  #######  #######  ##   ## 
     ##                ##       ##       ##                ##       ##       ##       ##  ##  ##  
##   ##           ##   ##  #######  ##   ##  ####     #######  ######   ##   ##  ##   ##  #####   
##   ##           ##   ##  ##  ##   ##   ##  ##       ##  ##   ##   ##  ##   ##  ##   ##  ##  ##  
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ##");

	auto orderBook = new Orderbook();
	State state = new StartState(orderBook);

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

	float limitPrice_;
	int bidAskQty_;
	OrderType orderType_;
	Action action_;
	TimeInForce timeInForce_;

	this(Orderbook orderbook, State prevState = null)
	{
		orderBook_ = orderbook;
		prevState_ = prevState;
		if (prevState)
		{
			limitPrice_ = prevState.limitPrice_;
			bidAskQty_ = prevState.bidAskQty_;
			orderType_ = prevState.orderType_;
			action_ = prevState.action_;
			timeInForce_ = prevState.timeInForce_;
		}
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
	this(Orderbook orderbook, State prevState = null)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		printOrderbook();
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
	this(Orderbook orderbook, State prevState = null)
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
		action_ = Action.Buy;
		return new OrderState(orderBook_, this);
	}

	State sellOrder()
	{
		action_ = Action.Sell;
		return new OrderState(orderBook_, this);
	}
}

class OrderState : State
{
	this(Orderbook orderbook, State prevState = null)
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
		orderType_ = OrderType.Market;
		return new QuantityState(orderBook_, this);
	}

	State limitOrder()
	{
		orderType_ = OrderType.Limit;
		return new LimitPriceState(orderBook_, this);
	}
}

class LimitPriceState : State
{
	this(Orderbook orderbook, State prevState = null)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		try
		{
			limitPrice_ = to!float(getInput("Input price: "));
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
	this(Orderbook orderbook, State prevState = null)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		try
		{
			bidAskQty_ = to!int(getInput(format("%s %s quantity: ", to!string(action_), to!string(
					orderType_).toLower())));

			return new TimeInForceState(orderBook_, this);
		}
		catch (ConvException e)
		{
			writeln("Invalid quantity.");
			return this;
		}
	}
}

class TimeInForceState : State
{

	this(Orderbook orderbook, State prevState = null)
	{
		super(orderbook, prevState);
	}

	override State run()
	{
		FnMap charToFunctionMap;
		charToFunctionMap['f'] = toDelegate(&filledOrKilled);
		charToFunctionMap['g'] = toDelegate(&goodTillCancelled);
		charToFunctionMap['q'] = toDelegate(&quit);

		return choices("Time in force:\n(F)illed-or-killed\n(G)ood-till-cancelled\n(Q)uit to previous menu\n",
			charToFunctionMap);
	}

	State filledOrKilled()
	{
		timeInForce_ = TimeInForce.Fok;
		return submitOrder();
	}

	State goodTillCancelled()
	{
		timeInForce_ = TimeInForce.Gtc;
		return submitOrder();
	}

	State submitOrder()
	{
		auto order = Order(generateRandomId(), action_, orderType_, timeInForce_, bidAskQty_, limitPrice_);
		orderBook_.submitOrder(order);
		return new StartState(orderBook_, null);
	}

}
