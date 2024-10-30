import std.stdio;
import std.uni;
import orderbook;

// Inspired by https://www.youtube.com/watch?v=E2y5wiBO1oE
// Inspired by https://www.youtube.com/watch?v=XeLWe0Cx_Lg

void main()
{
	writeln(" 
######            #######  #######  ######   #######  #######  #######  #######  #######  ##   ## 
     ##                ##       ##       ##                ##       ##       ##       ##  ##  ##  
##   ##           ##   ##  #######  ##   ##  ####     #######  ######   ##   ##  ##   ##  #####   
##   ##           ##   ##  ##  ##   ##   ##  ##       ##  ##   ##   ##  ##   ##  ##   ##  ##  ##  
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ##");
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
				writeln();
				writeln(
					"Enter Order Type:\n(M)arket\n(L)imit\n(F)ill-or-kill\n(G)ood-till-cancel\n(Q)uit to previous menu");

				immutable order = readln();
				switch (order[0].toLower())
				{
				case 'm':
					break;

				case 'l':
					break;

				case 'f':
					break;

				case 'g':
					break;

				case 'q':
					orderLoop = false;
					break;

				default:
					writeln("Not a valid choice: ", order);
					break;
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
