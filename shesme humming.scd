(
~shesme = ~shesme ? EM();

~shesme.humming = ~shesme.humming ? EM();

~shesme.humming.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir(thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/humming", 
		action: action );
};

~shesme.humming.specs = OEM();

[ \amp, 0.1, \amp.asSpec, \duck, 0, [0,1].asSpec, \ring, 0, [0,1].asSpec,
	\speed, 1, [1,32,\exp].asSpec ].clump(3).do({ |array|
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
SynthDef( "shesme_humming", { |buffers = #[0,0,0,0,0,0,0,0], ring = 0, amp = 0.1, duck = 0, 
		speed = 1, gate = 1|
	var levels, sig;
	levels = buffers.collect({ LFDNoise1.kr(0.1 * speed).exprange(-70.dbamp,1); });
	levels = levels / levels.sum;
	levels = levels * buffers.collect({ 
		SinOsc.kr( Rand(2,12) ).range(speed.linlin(1,32,1,0),1);
	});
	ring = ring.varlag(2);
	sig = buffers.collect({ |buf, i|
			var sig, verb, basefr;
			var pos, rate = 1;
			sig = PlayBufCF.ar( 1, buf, rate * speed.linlin(1,32,1,1.25), 
				Dwhite(3,8) / speed, Dwhite(0, BufFrames.kr(buf)),
				lag: 2 / speed
			 ) * 8 * levels[i];
			 sig = BPeakEQ.ar( sig, 220, 2, -9 );
			/*
			basefr = LFDNoise3.kr(0.1).exprange(100,2000);
			sig = (sig * (1-ring) ) + 
				(sig * SinOsc.ar( basefr * LFDNoise3.kr(0.1.dup(2)).exprange(0.9,1/0.9)
				).mean * ring );
			*/
			sig = FreqShift.ar( sig, LFDNoise3.kr(0.1, ring).range(-600,600).abs );
			//sig = BLowCut.ar( sig, LFDNoise3.kr( 0.1 ).exprange(20, 1000 ), 3 );
			RoundPan.ar( 6, sig, LFDNoise3.kr(0.025) * 2 );
	}).sum;
	sig = sig * duck.linlin(0,1,1,-0.1,\none).lag(20,3).max(0);
	Out.ar( 0, sig * amp.lag(0.1) * Env.cutoff(2).kr(2,gate) );

}).load(s);
);

/*
~shesme.humming.loadBuffers;
*/

~shesme.humming.start = { |evt|
	evt.end;
	evt.sn = Synth( "shesme_humming", [ 
		\buffers, evt.buffers[[0,2,3,4,5,6,7,8]], 
		\amp, evt.amp ? 0.1,
		\duck, evt.duck ? 0,
		\speed, evt.speed ? 1,
		\ring, evt.ring ? 0
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