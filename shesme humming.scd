(
~shesme = ~shesme ? EM();

~shesme.humming = ~shesme.humming ? EM();

~shesme.humming.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir(thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/humming", 
		action: action );
};

~shesme.humming.specs = OEM();

[ \amp, 0.1, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.humming[ key ] = value;
	~shesme.humming[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.sn.set( key, val);
	};
	~shesme.humming.specs[ key.asGetter ] = spec;
});

(
SynthDef( "shesme_humming", { |buffers = #[0,0,0,0,0,0,0,0], amp = 0.1, gate = 1|
	var levels, sig;
	levels = buffers.collect({ LFDNoise3.kr(0.06).exprange(-60.dbamp,1); });
	levels = levels / levels.sum;
	sig = buffers.collect({ |buf, i|
			var sig, verb;
			var pos, rate = 1;
			sig = PlayBufCF.ar( 1, buf, rate, 
				Dwhite(3,8), Dwhite(0, BufFrames.kr(buf)),
				lag: 2 
			 ) * 8 * levels[i];
			sig = BLowCut.ar( sig, LFDNoise3.kr( 0.1 ).exprange(20, 6000 ), 3 );
			RoundPan.ar( 4, sig, LFDNoise3.kr(0.05) );
	}).sum;
	Out.ar( 0, sig * amp.lag(0.1) * Env.cutoff.kr(2,gate) );

}).load(s);
);

/*
~shesme.humming.loadBuffers;
*/

~shesme.humming.start = { |evt|
	evt.end;
	evt.sn = Synth( "shesme_humming", [ 
		\buffers, evt.buffers[[0,2,3,4,5,6,7,8]], 
		\amp, evt.amp ? 0.1 
	] );
	evt.active = true;
};

~shesme.humming.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};

)

/*
~shesme.humming.start;
~shesme.humming.end;
*/

/*
(
x = {
	var levels;
	levels = ~shesme.humming.buffers.collect({ LFDNoise3.kr(0.05).exprange(0.0001,1); });
	levels = levels / levels.sum;
	~shesme.humming.buffers[[0,2,3,4,5,6,7,8]].collect({ |buf|
			var sig, verb;
			var pos, rate = 1;
			sig = PlayBufCF.ar( 1, buf, rate, 
				Dwhite(3,8), Dwhite(0, BufFrames.kr(buf)),
				lag: 2 
			 ) * 1 * LFDNoise3.kr(0.1).exprange(0.005,1);
			 sig = BLowCut.ar( sig, LFDNoise3.kr( 0.1 ).exprange(20, 6000 ), 3 );
			 RoundPan.ar( 4, sig, LFDNoise3.kr(0.05) );
	}).sum;
}.play;
);
*/