(
~shesme = ~shesme ? EM();

~shesme.wapentuig = ~shesme.wapentuig ? EM();

~shesme.wapentuig.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir("/Users/woutersnoei/Dropbox/Work/shesme/samples/wapentuig", nil, 
		"aiff", action: action );
};

/*
~shesme.wapentuig.loadBuffers;
*/

[ \amp, 0.1, \pos, 0 ].pairsDo({ |key,value|
	~shesme.wapentuig[ key ] = value;
	~shesme.wapentuig[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
});

(
SynthDef( "shesme_wapentuig", { |bufnum = 0, pos = 0, amp = 0.1, gate = 1|
	var sig, verb;
	pos = pos * BufFrames.kr(bufnum);
	sig = PlayBufCF.ar( 8, bufnum, 1, 
		Dwhite(0.1,0.3), (Dwhite(-1.5,1.5) * SampleRate.ir) + pos 
	 );
	verb = sig[[6,7]];
	sig = sig[..5];
	sig = sig.collect({ |item|
		RoundPan.ar( 4, item, LFDNoise3.kr(0.5) );
	}).sum;
	Out.ar( 0, sig * amp.lag(0.1) * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.wapentuig.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		3.collect({
			Synth( "shesme_wapentuig", [ \bufnum, buf, \amp, evt.amp ? 0.1, \pos, evt.pos ] );
		})
	}).flatten(1);
};

~shesme.wapentuig.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
};
)

/*
~shesme.wapentuig.start;
~shesme.wapentuig.end;

~shesme.wapentuig.amp = 0.3;

~shesme.wapentuig.pos = 0.1;
~shesme.wapentuig.pos = 0.5;
~shesme.wapentuig.pos = 0.9;

(
{
	var time = 20, res = 0.1;
	var n;
	n = (time/res).floor;
	n.do({ |i|
		~shesme.wapentuig.pos = i.linlin(0,n-1,0,0.9);
		res.wait;
	});
}.fork;
);
*/
