(
~shesme = ~shesme ? EM();

~shesme.path = thisProcess.nowExecutingPath.dirname;

~shesme.names = [ // files that require buffer loading
	\baarmoeder,
	\broken,
	\chords,
	\gedicht,
	\humming,
	\ikzoekjeniet,
	\laughing,
	\mumbling,
	\notes,
	\opnieuw,
	\rrrr,
	\sfr,
	\spiegel,
	\tttt,
	\tzu,
	\wapentuig,
	\verb,
];

~shesme.filePaths = ~shesme.names.collect({ |item|
	~shesme.path +/+ "shesme" + item ++ ".scd"
});

~shesme.filePaths.do(_.load);

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

// make window for loading documents
~shesme.makeFilesWindow = { |evt|
	var views;
	if( evt.filesWindow.notNil && { evt.filesWindow.isClosed.not }) {
		evt.filesWindow.close;
	};
	evt.filesWindow = Window( "shesme files",
		Rect( 5, 256, 140, 4 + (~shesme.filePaths.size * 20) ) 
	);
	evt.filesWindow.front.addFlowLayout;
	views = ~shesme.filePaths.do({ |item|
		var name;
		name = item.basename.split( $  )[1].removeExtension;
		[
			SmoothButton( evt.filesWindow, 112 @ 16 )
				.border_(1)
				.background_( Gradient( Color.gray(1), Color.gray(0.8), \v ) )
				.radius_(2)
				.label_( name )
				.action_({ Document.open( item ) })
				.resize_(2),
			SmoothButton( evt.filesWindow, 16 @ 16 )
				.border_(1)
				.background_( Gradient( Color.gray(1), Color.gray(0.8), \v ) )
				.label_(['power','power'])
				.value_( (name == "verb").binaryValue )
				.hiliteColor_( Color.green )
				.action_({ |bt|
					switch( bt.value.asInt,
						1, { evt[ name.asSymbol ].start },
						0, { evt[ name.asSymbol ].end }
					);
				})
				.resize_(2)
		]	
	});
};

~shesme.makeFilesWindow;
)