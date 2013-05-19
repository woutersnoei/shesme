~shesme = ~shesme ? EM();

~shesme.words = ~shesme.words ? EM();

~shesme.words.loadBuffers = { |evt, action|
	var names;
	names = (thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/words/*").pathMatch;
	evt.paths = OEM();
	\output.asUdef;
	\bufSoundFile.asUdef;
	names.do({ |item|
		var em, splitnames;
		em = EM();
		em[ \paths ] = (item ++ "*.wav").pathMatch;
		splitnames = em[ \paths ].collect({ |item|
			item.basename.split( $_ );
		}); 
		em[ \languages ] = splitnames.collect({ |item|
			item[ 0 ].asSymbol;
		});
		em[ \indices ] = splitnames.collect({ |item|
			item[ 1 ].interpret;
		});
		em[ \texts ] = splitnames.collect({ |item|
			item[ 2 ];
		});
		em[ \levels ] = (item ++ "levels.scd").load;
		em[ \uchains ] = em[ \paths ].collect({ |item|
			UChain( [ \bufSoundFile, [ \soundFile, item ] ], \output ).useSndFileDur;
		});
		evt.paths[ item.basename.asSymbol ] = em;
	});
	
	evt.texts = Order();
	evt.paths.atIndex(0).languages.do({ |item, i|
		if( item == \en ) {
			evt.texts[ evt.paths.atIndex(0).indices[i] ] = evt.paths.atIndex(0).texts[i];
		};
	});
	
	evt.texts = evt.texts.asArray;
	evt.all = Order();
	evt.soft = Order();
	evt.loud = Order();
	evt.paths.keysValuesDo({ |key, value|
		var meanLevel;
		meanLevel = [ value.levels.minItem, value.levels.maxItem ].dbamp.mean;
		value.indices.do({ |index, i|
			evt.all[ index ] = evt.all[ index ].add( value.uchains[ i ] );
			if( value.levels[i].dbamp < meanLevel ) {
				evt.soft[ index ] = evt.soft[ index ].add( value.uchains[ i ] );
			} {
				evt.loud[ index ] = evt.loud[ index ].add( value.uchains[ i ] );
			};
		});
	});
	"loaded paths for ~shesme.words".postln;
	action.value;
};

/*
~shesme.words.loadBuffers;
*/

~shesme.words.specs = OEM();

~shesme.words.amp = 0.1;
~shesme.words.which = \all;
~shesme.words.index = 0;
~shesme.words.trigger = 1;

~shesme.words.trigger_ = { |evt, value = 1|
	evt.playSingle;
	evt[ \trigger ] = value;
};

~shesme.words.specs.amp = \amp.asSpec;
~shesme.words.specs.which = ListSpec( [\all, \soft, \loud ] );
~shesme.words.specs.index = ListSpec( (..15), 0, ~shesme.words.texts );
~shesme.words.specs.trigger = TriggerSpec( "start" );

~shesme.words.playSingle = { |evt, index, which|
	var chain;
	index = index ? evt.index;
	which = which ? evt.which;
	if( index < 16 ) {
		chain = evt[ which ][index].choose.deepCopy;
		chain.set( \bus, [0,5].choose );
		chain.gain = evt.amp.ampdb;
		chain.prepareAndStart;
	};
};

~shesme.words.start = {|evt|
	evt.active = true;
};

~shesme.words.end = {|evt|
	evt.active = false;
};

/*
~shesme.words.paths.bouwien.uchains.choose.deepCopy.set( \bus, [0,1].choose ).prepareAndStart;

~shesme.words.texts.size.asArray

~shesme.words.paths.keysValuesDo({ |a,b| [a,b].postln });

~shesme.words.all.asArray.do({ |item, i|
	[ i, item.size ].postln;
}); "";

~shesme.words.loud.asArray.do({ |item, i|
	[ i, item.size ].postln;
}); "";

~shesme.words.soft.asArray.do({ |item, i|
	[ i, item.size ].postln;
}); "";

~shesme.words.soft[2].choose.prepareAndStart;

~shesme.words.playSingle
*/