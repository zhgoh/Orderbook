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
######            #######  ##   ##  ######   #######  ##   ##  #######  #######  #######  ##   ## 
");
	Orderbook orderbook = new Orderbook();

	while (true)
	{
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
			writeln("\nEnter Order Type:\n(M)arket order\n(Limit) order");

			while (true)
			{
				immutable order = readln();
				switch (order[0].toLower())
				{
				case 'm':
					break;

				case 'l':
					break;

				default:
					writeln("Not a valid choice: ", order);
					break;
				}
			}

			break;

		case 'q':
			writeln("Quitting the app.");
			return;

		default:
			writeln("Not a valid choice: ", choice);
			break;

		}
	}
}
