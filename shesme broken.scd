(
~shesme = ~shesme ? EM();

~shesme.broken = ~shesme.broken ? EM();

~shesme.broken.specs = OEM();

[ 	
	\amp, 0.1, \amp.asSpec, 
	\pbrate, [0.5,1.6], [0.25,4,\exp].asSpec.asRangeSpec, 
	\shiftvar, 0, [0,24].asSpec,
	\filter, 0, [-1,1].asSpec,
	\pvar, 0, [0,0.25].asSpec
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.broken[ key ] = value;
	~shesme.broken[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.broken.specs[ key.asGetter ] = spec;
});

~shesme.broken.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/broken", 
		action: action );
};

(
SynthDef( "shesme_broken", { |bufnum = 0, amp = 0.1, pbrate = #[0.8,1.2], shiftvar = 0, pvar = 0, gate = 1, filter = 0|
	var sig;
	sig = PlayBufCF.ar( 1, bufnum, Dwhite(0, 1, inf).linexp(0,1,*pbrate) * Drand([-1,1], inf), 
		Dwhite(2, 5, inf), Dwhite(0, BufFrames.kr(bufnum)), 1, 1 );
	//sig = sig ring1: SinOsc.ar( LFDNoise3.kr(0.1).exprange(200,800), 0, 0.33 );
	sig = BLowCut.ar( sig, LFDNoise3.kr(0.2).exprange( 20, 20000 ), 4 );
	//sig = BHiCut.ar( sig, LFDNoise3.kr(0.1).exprange( 200, 20000 ), 4 );
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(2).linexp(0,1,20,5000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(2).linexp(-1,0,300,20000,\minmax),3 );
	sig = PitchShift.ar(sig, 0.005, 
		LFDNoise3.kr(0.3).range(shiftvar.neg, shiftvar).midiratio, 
		pvar, pvar * 0.02);
	sig = RoundPan.ar( 6, sig, LFDNoise3.kr(0.1) * 2 ) * amp * 0.25;
	Out.ar( 0, sig * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.broken.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		Synth( "shesme_broken", [\bufnum, buf, \amp, evt.amp, \pbrate, evt.pbrate ? [0.8,1.2], \shiftvar, evt.shiftvar ? 0, \pvar, evt.pvar ? 0, \filter, evt.filter ? 0 ]);
	});
	evt.active = true;
};

~shesme.broken.end = { |evt|
	evt.synths.do(_.release(0.05));
	evt.synths = nil;
	evt.active = false;
};
)