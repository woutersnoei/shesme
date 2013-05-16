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
SynthDef( "shesme_laughing", { |bufnum = 0, pos = 0.5, pbrate = 1, amp = 0.1, gate = 1|
	var sig;
	pos = pos * BufFrames.kr(bufnum);
	sig = PlayBufCF.ar( 1, bufnum, pbrate, 
		Dwhite(0.2,0.8), (Dwhite(-3,3) * SampleRate.ir) + pos 
	 ) * amp * LFDNoise3.kr(0.1).exprange(0.1,1);
	sig = RoundPan.ar( 4, sig, LFDNoise3.kr(0.5) );
	Out.ar(0, sig * Env.cutoff.kr(2,gate) );	
}).load(s);
);


~shesme.laughing.start = { |evt|
	evt.end;
	evt.synths = evt.buffers.collect({ |buf|
		2.collect({ 
			Synth( "shesme_laughing", [ \bufnum, buf ] ++ evt.getPairs([\amp, \pos, \pbrate]) );		});
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