(
~shesme = ~shesme ? EM();

~shesme.broken = ~shesme.broken ? EM();

~shesme.broken.pbrate = [0.8, 1.2];

~shesme.broken.pbrate = { |evt, new|
	evt[ \pbrate ] = new;
	evt.synths.do(_.set( \pbrate, evt[ \pbrate ] ));
};

~shesme.broken.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/broken", 
		action: action );
};

(
SynthDef( "shesme_broken", { |bufnum = 0, amp = 0.1, pbrate = #[0.8,1.2], gate = 1|
	var sig;
	sig = PlayBufCF.ar( 1, bufnum, Dwhite(0, 1, inf).linexp(0,1,*pbrate) * Drand([-1,1], inf), 
		Dwhite(2, 5, inf), Dwhite(0, BufFrames.kr(bufnum)), 1, 1 );
	//sig = sig ring1: SinOsc.ar( LFDNoise3.kr(0.1).exprange(200,800), 0, 0.33 );
	//sig = BLowCut.ar( sig, LFDNoise3.kr(0.1).exprange( 20, 10000 ), 4 );
	//sig = BHiCut.ar( sig, LFDNoise3.kr(0.1).exprange( 200, 20000 ), 4 );
	sig = PitchShift.ar(sig * amp, 0.2.dup, 1, 0.01, 0.2);
	//sig = RoundPan.ar( 4, sig, LFDNoise3.kr(0.1) * 2 );
	Out.ar( 0, sig * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.broken.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		Synth( "shesme_broken", [\bufnum, buf, \pbrate, evt.pbrate ? [0.8,1.2]]);
	});
};

~shesme.broken.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
};
)