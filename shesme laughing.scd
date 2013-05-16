(
~shesme = ~shesme ? EM();

~shesme.laughing = ~shesme.laughing ? EM();

~shesme.laughing.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir(thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/laughing", 
		action: action );
};

/*
~shesme.laughing.loadBuffers({"done".postln});
*/

~shesme.laughing.specs = OEM();

(
[  
	\amp, 0.1, \amp.asSpec, 
	\pos, 0.5, [0,1,\lin,0,0.5].asSpec,
	\filter, 0, [-1,1,\lin,0,0].asSpec, 
	\verb, 0, [0,1].asSpec,
	\pbrate, 1, [0.25,4,\exp,0,1].asSpec 
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.laughing[ key ] = value;
	~shesme.laughing[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.laughing.specs[ key.asGetter ] = spec;
});
);

(
SynthDef( "shesme_laughing", { |bufnum = 0, pos = 0.5, pbrate = 1, verb = 0, amp = 0.1, gate = 1,
		filter = 0|
	var sig, verbSig;
	pos = pos * BufFrames.kr(bufnum);
	sig = PlayBufCF.ar( 1, bufnum, pbrate, 
		Dwhite(0.2,0.8), (Dwhite(-3,3) * SampleRate.ir) + pos 
	 ) * amp * LFDNoise3.kr(0.1).exprange(0.1,1);
	 
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(Rand(3, 5)).linexp(0,1,20,10000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(Rand(3, 5)).linexp(-1,0,100,20000,\minmax),3 );
	verbSig = FreeVerb.ar( sig, 1, Rand(0.9,4), 0.3 );
	verbSig = PitchShift.ar( verbSig, 0.2, 1, 0.01, 0.2 );
	sig = (sig * (1-verb)) + (verbSig * verb);
	sig = RoundPan.ar( 4, sig, LFDNoise3.kr( verb.linlin(0,1,0.5,0.1) ) );
	Out.ar(0, sig * Env.cutoff(2).kr(2,gate) );	
}).load(s);
);


~shesme.laughing.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		2.collect({ 
			Synth( "shesme_laughing", [ \bufnum, buf ] ++ 
				evt.getPairs([\amp, \pos, \pbrate, \verb, \filter]) );		});
	}).flatten(1);
	evt.active = true;
};

~shesme.laughing.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};
)

/*
~shesme.laughing.start;
~shesme.laughing.end;

~shesme.laughing.pos = 0.1;
~shesme.laughing.pos = 0.5;
*/