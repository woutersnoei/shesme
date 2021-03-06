(
~shesme = ~shesme ? EM();

~shesme.spiegel = ~shesme.spiegel ? EM();

~shesme.spiegel.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/spiegel", 
		action: action, nlevels: 0 );
};

/*
~shesme.spiegel.loadBuffers;
*/

~shesme.spiegel.specs = OEM();

[ \amp, 0.1, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.spiegel[ key ] = value;
	~shesme.spiegel[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.spiegel.specs[ key.asGetter ] = spec;
});

(
SynthDef( "shesme_spiegel", { |bufnum = 0, amp = 0.1, gate = 1|
	var sig;
	sig = PlayBufCF.ar( 1, bufnum, 1, Dwhite(10, 30), Dwhite( 0, BufFrames.kr(bufnum) ), 1, 4 );
	sig = sig * 4 * amp.lag(0.1);
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.1).linexp(-1,1,20,5000) );
	sig = RoundPan.ar(6, sig, LFDNoise3.kr(0.05,2) );
	
	Out.ar( 0, sig * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.spiegel.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		Synth( "shesme_spiegel", [ \bufnum, buf, \amp, evt.amp ? 0.1 ] );
	});
	evt.active = true;
};

~shesme.spiegel.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};
)

/*
~shesme.spiegel.start
~shesme.spiegel.end;
*/