(
~shesme = ~shesme ? EM();

~shesme.rrrr = ~shesme.rrrr ? EM();

~shesme.rrrr.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/rrrr",
		action: action );
};

/*
~shesme.rrrr.loadBuffers;
*/

~shesme.rrrr.specs = OEM();

[ \amp, 0.1, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.rrrr[ key ] = value;
	~shesme.rrrr[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.rrrr.specs[ key.asGetter ] = spec;
});

(
SynthDef( "shesme_rrrr", { |bufnum = 0, amp = 0.1, rate = #[0.25,1.25], gate = 1|
	var sig;
	sig = PlayBufCF.ar( 1, bufnum, Dwhite(0, 1, inf).linexp(0,1,*rate) * Drand([-1,1], inf), 
		Dwhite(1, 4, inf), Dwhite(0, BufFrames.kr(bufnum)), 1, 1 ) * 4;
	sig = sig ring1: SinOsc.ar( LFDNoise3.kr(0.1).exprange(200,800), 0, 0.33 );
	sig = BLowCut.ar( sig, LFDNoise3.kr(0.1).exprange( 20, 10000 ), 4 );
	sig = BHiCut.ar( sig, LFDNoise3.kr(0.1).exprange( 200, 20000 ), 4 );
	//sig = PitchShift.ar(sig, 0.2, 1, 0.01, 0.2);
	sig = RoundPan.ar( 4, sig * amp, LFDNoise3.kr(0.1) * 2 );
	Out.ar( 0, sig * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.rrrr.start = { |evt|
	evt.end;
	evt.synths = evt.buffers[1..].collect({ |buf|
		Synth( "shesme_rrrr", [\bufnum, buf, \amp, evt.amp ]);
	});
	evt.active = true;
};

~shesme.rrrr.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};
)

/*
~shesme.rrrr.start;
~shesme.rrrr.end;

~shesme.rrrr.synths.do(_.set(\rate, [0.25,4]) );
*/