(
~shesme = ~shesme ? EM();

~shesme.ikzoekjeniet = ~shesme.ikzoekjeniet ? EM();

~shesme.ikzoekjeniet.which = \langzaam;

~shesme.ikzoekjeniet.loadBuffers = { |evt, action|
	evt.buffers = ();
	{
		var cond;
		cond = Condition(false);
		(
			thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/ik_zoek_je_niet/*.aiff"
		).pathMatch.do({ |path|
			var key;
			key = path.basename.removeExtension.asSymbol;
			evt.buffers[ key ] = Buffer.read(s, path, action: { cond.test = true; cond.signal });
			cond.wait;
			cond.test = false;
			"\tloaded % : %\n".postf( evt.buffers[ key ].bufnum, path.basename );
		});
		action.value;
	}.fork;
};

/*
~shesme.ikzoekjeniet.loadBuffers;
*/


[ \amp, 0.1, \tvar, 0 ].pairsDo({ |key,value|
	~shesme.ikzoekjeniet[ key ] = value;
	~shesme.ikzoekjeniet[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
});

(
SynthDef( "shesme_ikzoekjeniet_8", { |bufnum = 0, amp = 0.1, tvar = 0, gate = 1|
	var sig, verb;
	sig = PlayBuf.ar( 8, bufnum, doneAction: 2) * 3 * amp;
	verb = sig[[6,7]];
	sig = sig[..5];
	sig = PitchShift.ar( sig, 0.5, 1, 0, tvar * 0.5 );
	sig = sig.collect({ |item|
		RoundPan.ar( 4, item, LFDNoise3.kr(0.2) );
	}).sum;
	Out.ar( 0, Env.cutoff( 0.2 ).kr(2,gate) * sig )
}).load(s);
);

(
SynthDef( "shesme_ikzoekjeniet_5", { |bufnum = 0, amp = 0.1, gate = 1|
	var sig, verb;
	sig = PlayBuf.ar( 5, bufnum, doneAction: 2) * 3 * amp;
	verb = sig[[3,4]];
	sig = sig[..2];
	sig = sig.collect({ |item|
		RoundPan.ar( 4, item, LFDNoise3.kr(0.2) );
	}).sum;
	Out.ar( 0, Env.cutoff( 0.2 ).kr(2,gate) * sig )
}).load(s);
);

~shesme.ikzoekjeniet.start = { |evt|
	var bufs;
	evt.end;
	bufs = evt.which.asCollection.collect({ |wh| evt.buffers[ wh ] }).select(_.notNil);
	bufs.do({ |buf|
		evt.synths = evt.synths.add(
			Synth( "shesme_ikzoekjeniet_" ++ buf.numChannels, [ 
				\bufnum, buf, \amp, evt.amp, \tvar, evt.tvar 
			] )
				.freeAction_({ |synth| evt.synths.remove( synth ); });
		);
	});
};


~shesme.ikzoekjeniet.end = { |evt|
	evt.synths.do(_.release);
};

)

/*
~shesme.ikzoekjeniet.start;
~shesme.ikzoekjeniet.tvar = 1;

~shesme.ikzoekjeniet.synths;
*/