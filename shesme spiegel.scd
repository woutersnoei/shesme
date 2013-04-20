(
~shesme = ~shesme ? EM();

~shesme.spiegel = ~shesme.spiegel ? EM();

~shesme.spiegel.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir( "/Users/woutersnoei/Dropbox/Work/shesme/samples/spiegel", 
		action: action );
};

/*
~shesme.spiegel.loadBuffers;
*/

[ \amp, 0.1 ].pairsDo({ |key,value|
	~shesme.spiegel[ key ] = value;
	~shesme.spiegel[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
});

(
SynthDef( "shesme_spiegel", { |bufnum = 0, amp = 0.1, gate = 1|
	var sig;
	sig = PlayBufCF.ar( 1, bufnum, 1, Dwhite(10, 30), Dwhite( 0, BufFrames.kr(bufnum) ), 1, 4 );
	sig = sig * 4 * amp.lag(0.1);
	sig = RoundPan.ar(4, sig, LFDNoise3.kr(0.05,2) );
	Out.ar( 0, sig * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.spiegel.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		Synth( "shesme_spiegel", [ \bufnum, buf, \amp, evt.amp ? 0.1 ] );
	});
};

~shesme.spiegel.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
};
)

/*
~shesme.spiegel.start
~shesme.spiegel.end;
*/