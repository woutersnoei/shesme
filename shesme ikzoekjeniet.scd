(
~shesme = ~shesme ? EM();

~shesme.ikzoekjeniet = ~shesme.ikzoekjeniet ? EM();

~shesme.ikzoekjeniet.which = \langzaam;

~shesme.ikzoekjeniet.verbOut = 0;

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

~shesme.ikzoekjeniet.specs = OEM();

[ 
	\amp, 0.1, \amp.asSpec, 
	\tvar, 0, [0,1].asSpec,
	\filter, 0, [-1,1, \lin,0,0].asSpec,
	\hold, false, BoolSpec(false),
	\verb, 0, [0,1].asSpec,
	\which, \langzaam, ListSpec([ 'hoog', 'laag', 'langzaam', 'snel', 'vrolijk', 'footsteps' ])
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.ikzoekjeniet[ key ] = value;
	~shesme.ikzoekjeniet[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.ikzoekjeniet.specs[ key.asGetter ] = spec;
});

~shesme.ikzoekjeniet[ \which_ ] = nil;

(
SynthDef( "shesme_ikzoekjeniet_8", { |bufnum = 0, amp = 0.1, tvar = 0, hold = 0, filter = 0, gate = 1, verb = 0, verbOut = 0|
	var sig, verbSig, env;
	sig = PlayBuf.ar( 8, bufnum, rate: Slew.kr(1-hold, inf,5) > 0, doneAction: 2) * 3;
	hold = Slew.kr(hold, 5,5);
	sig = sig.collect({ |item|
		var inA, chainA, inB, chainB, chain;
		inA = BLowCut.ar( WhiteNoise.ar(1), 100 );
		inB = item;
		chainA = FFT(LocalBuf(2048), inA);
		chainB = FFT(LocalBuf(2048), inB);
		chainB = PV_MagFreeze(chainB, hold );
		chain = PV_MagMul(chainA, chainB);
		((0.05 * IFFT(chain)) * hold) + (inB * (1-hold));
	});
	sig = sig * amp;
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(2).linexp(0,1,20,5000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(2).linexp(-1,0,300,20000,\minmax), 3 );
	sig = PitchShift.ar( sig * (1+(tvar > 0)).varlag(0.5), 0.5, 1, 0, tvar * 0.5 );
	verbSig = sig[[6,7,6,7]];
	sig = sig[..5];
	sig = sig.collect({ |item|
		RoundPan.ar( 6, item, LFDNoise3.kr(0.1) * 2 );
	}).sum;
	env = Env.cutoff( 0.2 ).kr(2,gate);
	Out.ar( 0, env * sig * (1-verb.sqrt) );
	Out.ar( verbOut, env * verbSig * verb.sqrt );
}).load(s);
);

(
SynthDef( "shesme_ikzoekjeniet_5", { |bufnum = 0, amp = 0.1, tvar = 0, filter = 0, hold = 0, gate = 1, verb = 0, verbOut = 0|
	var sig, verbSig, env;
	sig = PlayBuf.ar( 5, bufnum, rate: Slew.kr(1-hold, inf,5) > 0, doneAction: 2) * 3 * amp;
	sig = sig.collect({ |item|
		var inA, chainA, inB, chainB, chain;
		inA = BLowCut.ar( WhiteNoise.ar(1), 100 );
		inB = item;
		chainA = FFT(LocalBuf(2048), inA);
		chainB = FFT(LocalBuf(2048), inB);
		chainB = PV_MagFreeze(chainB, hold );
		chain = PV_MagMul(chainA, chainB);
		((0.05 * IFFT(chain)) * hold) + (inB * (1-hold));
	});	
	sig = PitchShift.ar( sig * (1+(tvar > 0)).varlag(0.5), 0.5, 1, 0, tvar * 0.5 );
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(2).linexp(0,1,20,5000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(2).linexp(-1,0,300,20000,\minmax), 3 );
	verbSig = sig[[3,4,3,4]];
	sig = sig[..2];
	sig = sig.collect({ |item|
		RoundPan.ar( 6, item, LFDNoise3.kr(0.1) * 2 );
	}).sum;
	env = Env.cutoff( 0.2 ).kr(2,gate);
	Out.ar( 0, env * sig * (1-verb.sqrt) );
	Out.ar( verbOut, env * verbSig * verb.sqrt );
}).load(s);
);

~shesme.ikzoekjeniet.start = { |evt|
	var bufs;
	evt.end;
	bufs = evt.which.asCollection.collect({ |wh| evt.buffers[ wh ] }).select(_.notNil);
	evt.hold = false;
	bufs.do({ |buf|
		evt.synths = evt.synths.add(
			Synth( "shesme_ikzoekjeniet_" ++ buf.numChannels, [ 
				\bufnum, buf, \amp, evt.amp, \filter, evt.filter, \tvar, evt.tvar, 
				\verb, evt.verb, \verbOut, evt.verbOut ? 0
			] )
				.freeAction_({ |synth| 
					evt.synths.remove( synth ); 
					if( evt.synths.size == 0 ) { evt.active = false; }; 
				});
		);
	});
	evt.active = true;
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