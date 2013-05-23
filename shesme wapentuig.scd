(
~shesme = ~shesme ? EM();

~shesme.wapentuig = ~shesme.wapentuig ? EM();

~shesme.wapentuig.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir(thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/wapentuig", nil, 
		"aiff", action: action );
};

/*
~shesme.wapentuig.loadBuffers;
*/

~shesme.wapentuig.specs = OEM();

[ \amp, 0.1, \amp.asSpec, \pos, 0, [0,1].asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.wapentuig[ key ] = value;
	~shesme.wapentuig[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.wapentuig.specs[ key.asGetter ] = spec;
});

(
SynthDef( "shesme_wapentuig", { |bufnum = 0, pos = 0, amp = 0.1, gate = 1|
	var sig, verb;
	pos = pos * BufFrames.kr(bufnum);
	sig = PlayBufCF.ar( 8, bufnum, 1, 
		Dwhite(0.1,0.3), (Dwhite(-1.5,1.5) * SampleRate.ir) + pos 
	 ) * 3;
	verb = sig[[6,7]];
	sig = sig[..5];
	//RandSeed.kr( Impulse.kr(0), 56789 );
	//RandSeed.kr(MouseX.kr > 0.5, 12345);
	//sig = sig.collect({ |item|
	//RoundPan.ar( 6, sig.sum, LFDNoise3.kr(0.25,2) );
	
	sig = sig.sum;
	
	sig = RoundPan.ar( 6, sig, LFSaw.kr(0.025) );
	
	//}).sum;
	/*
	sig = sig.collect({ |item|
		RoundPan.ar( 6, item, LFDNoise3.kr(0.25,2) );
	}).sum;
	*/
	Out.ar( 0, sig * amp.lag(0.1) * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.wapentuig.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		1.collect({
			Synth( "shesme_wapentuig", [ \bufnum, buf, \amp, evt.amp ? 0.1, \pos, evt.pos ] );
		})
	}).flatten(1);
	evt.active = true;
};

~shesme.wapentuig.end = { |evt|
	evt.synths.do(_.release);
	evt.synths = nil;
	evt.active = false;
};
)

/*
~shesme.wapentuig.start;
~shesme.wapentuig.end;

~shesme.wapentuig.amp = 0.3;

~shesme.wapentuig.pos = 0.1;
~shesme.wapentuig.pos = 0.3;
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
