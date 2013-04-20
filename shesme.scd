(
~shesme = ~shesme ? EM();

~shesme.path = thisProcess.nowExecutingPath.dirname;

~shesme.names = [
	\baarmoeder,
	\broken,
	\chords,
	\gedicht,
	\humming,
	\ikzoekjeniet,
	\laughing,
	\mumbling,
	\rrrr,
	\tttt,
	\tzu,
	\wapentuig,
];

~shesme.names.do({ |item|
	( ~shesme.path +/+ "shesme" + item ++ ".scd" ).load;
});

(~shesme.path +/+ "shesme verb.scd").load;

~shesme.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition( false );
		evt.names.do({ |name|
			"loading buffers for ~shesme.%\n".postf( name );
			evt[ name ].loadBuffers( { cond.test = true; cond.signal } );
			cond.wait;
			cond.test = false;
		});
		action.value;
	}.fork;
};

~shesme.loadBuffers( { "\n~shesme loading buffers done".postln; } );

)