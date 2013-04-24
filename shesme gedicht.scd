(
~shesme = ~shesme ? EM();

~shesme.gedicht = ~shesme.gedicht ? EM();

// ULib.startup;

~shesme.gedicht.loadBuffers = { |evt, action| action.value };

~shesme.gedicht.paths = (
	nl: thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/gedicht/en",
	en: thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/gedicht/nl"
);

~shesme.gedicht.makeScore = { |evt|
	var voices, z=0, waitPoints;
	voices = [ "bauwien", "elsbeth", "jennifer", "marine", "michaela" ];
	waitPoints = [ 6, 10, 14, 18, 21, 25, 30, 32, 36, 39, 43, 49 ] - 2;
	evt.score = UScore(
		*53.collect({ |i|
			var chains;
			chains = [  UChain( i * 2,
					[ \bufSoundFile, 
						[ \soundFile, evt.paths.en +/+ voices.choose +/+ 
							(i+1).asStringToBase(10,2) ++ ".wav" ] ],
					[ \output, [ \bus, 3.rand ] ]
				).gain_(-12).useSndFileDur,
				UChain( i * 2, 1, 
					[ \bufSoundFile, 
						[ \soundFile, evt.paths.nl +/+ voices.choose +/+ 
							(i+1).asStringToBase(10,2) ++ ".wav" ] ],
					[ \output, [ \bus, 3.rand ] ]
				).gain_(-12).useSndFileDur,
			];
			chains.do( _.startTime_( z ) );
			z = z + 2.max( chains.collect(_.dur).maxItem + 0.5 );
			
			if( waitPoints.includes( i ) ) {
				z = z + ((30 * 60) / waitPoints.size);
				chains = chains.add( 
					UMarker(z - 0.1, 2, "pause", { |marker, score| 
						// pause the score
						score.pause; 
					})
				);
			};
			
			chains;
		}).flatten(1);
	).name_( "shesme gedicht" );
	evt.score.gui;
};

~shesme.gedicht.start = { |evt|
	if( evt.score.isNil ) {
		evt.makeScore;
	};
	if( evt.score.playState == \stopped ) {
		evt.score.prepareAndStart;
	};
	if( evt.score.playState == \paused ) {
		evt.score.resume;
	};
};

~shesme.gedicht.end = { |evt|
	if( evt.score.notNil ) {
		evt.score.stop;
		evt.score.dispose;
	};
};


)

/*
~shesme.gedicht.makeScore;
~shesme.gedicht.start;
~shesme.gedicht.end;
*/