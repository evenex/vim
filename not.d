template not ()
{
	bool not (T)(T value)
	{
		return !value;
	}
}
template not (alias predicate)
{
	static if (__traits(isTemplate, predicate))
	{
		bool not (Args...)(Args args)
		{
			return !(predicate (args));
		}
		bool not (Args...)()
		{
			return !(predicate!Args);
		}
	}
	else {
		import std.traits: isSomeFunction, ParameterTypeTuple;

		static if (isSomeFunction!predicate)
			bool not (ParameterTypeTuple!predicate args)
			{
				return !predicate (args);
			}
		else bool not ()
		{
			return !predicate;
		}
	}
}
template not (string predicate)
{
	bool not (Args...)(Args args)
	{
		static if (Args.length == 0)
		mixin(q{
			return !} ~predicate~ q{;
		});
		else static if (Args.length == 1)
		mixin(q{
			auto a = args[0];

			return !} ~predicate~ q{;
		});
		else static if (Args.length == 2)
		mixin(q{
			auto a = args[0];
			auto b = args[1];

			return !} ~predicate~ q{;
		});
		else static assert (0, `string mixin template functions with greater than 2 arguments not supported`);
	}
}
///
version (unittest) 
{
	template is_true (Args...)
	if (Args.length == 1)
	{
		enum is_true = Args[0];
	}

	alias is_false_t = not!is_true;

	auto is_false_f (T)(T thing)
	{
		return !thing;
	}

	unittest 
	{
		import std.functional;
		alias not = std.functional.not;
		enum x = true;

		assert (x);
		assert (not (x) == false);
		assert (not!x == false);


		assert (is_false_f (x) == false);
		assert (not!is_false_f (x));
		assert (is_false_t!x == false);
	}
}
