~shesme = ~shesme ? EM();

~shesme.pattern = ~shesme.pattern ? EM();

~shesme.pattern.loadBuffers = { |evt, action|
	evt.buffers = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/screams", nil, "wav", action: action ); 
};

/*
~shesme.pattern.loadBuffers;
*/

~shesme.pattern.specs = OEM();

[ 
	\amp, 0.1, \amp.asSpec, 
	\speed, 8, [1,16,\exp,1,8].asSpec, 
	\scream, 0, [0,1,\lin,1,0].asSpec,
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.pattern[ key ] = value;
	~shesme.pattern.specs[ key.asGetter ] = spec;
});

~shesme.pattern[ \scream_ ] = { |evt, value = 0|
	if( value > 0.5 ) {
		evt[ \scream ] = value;
		evt.pbind !? _.pause;
		Synth( "shesme_pattern_scream", [ 
				\bufnumx, evt.buffers.choose, 
				\amp, evt.amp * 0.5,
				\pan, 1.0.rand2
			 ] );
	} {
		evt[ \scream ] = value;
		evt.pbind !? _.resume;
	};
};

(
SynthDef( "shesme_pattern_short", { |bufnum = 0, startPos = 0, sustain = 1, amp = 0.1, pan = 0,
		attack = 0.005, ratio = 1, gain = 1, bend = 0|
	var sig, env;
	sig = PlayBuf.ar( 1, bufnum, ratio * Line.kr( bend * -0.5, bend * 0.5, sustain ).midiratio, 1, 
		( BufFrames.kr(bufnum) - ((sustain / ratio)* SampleRate.ir) ) * startPos 
	) * amp * gain * Line.ar(0,1,attack);
	env = Env([1,1,0],[sustain - attack, attack]).ar(2);
	sig = RoundPan.ar( 2, sig , pan );
	Out.ar( 0, sig * env);
	
}).store;
);

(
SynthDef( "shesme_pattern_scream", { |bufnumx = 0, startPos = 0, amp = 0.1, pan = 0,
		attack = 0.005, ratio = 1, gain = 1, bend = 0|
	var sig, env;
	var sustain;
	sustain = BufDur.kr( bufnumx );
	sig = PlayBuf.ar( 1, bufnumx, ratio * Line.kr( bend * -0.5, bend * 0.5, sustain ).midiratio, 1, 
		( BufFrames.kr(bufnumx) - ((sustain / ratio)* SampleRate.ir) ) * startPos 
	) * amp * Line.ar(0,1,attack);
	env = Env([1,1,0],[sustain - attack, attack]).ar(2);
	sig = RoundPan.ar( 2, sig , pan );
	Out.ar( 0, sig * env);
}).store;
);

~shesme.pattern.start = { |evt|
	evt.end;
	evt.pbind = Pbind( 
		\which, Pwrand( [ 0, 1, 2 ], [0.97,0.02,0.01], inf),
		\instrument, Pindex( 
			[ "shesme_pattern_short", "shesme_pattern_scream", "shesme_pattern_short" ],
			Pkey( \which ) 
		),
		\dur, Pindex( [ 1, 1 * Pwhite(8,18,1), 
			Pseq( {|i|i.linlin(0,20,pi,2pi).sin.linlin(-1,0,0.15,1)}!20, 1 ) 
		], Pkey( \which ), inf ) / PenvirGet( \speed, 8, evt ),
		\legato, Pbrown( 0.3, 0.6, 0.02,inf),
		\index, (Pstutter( Pwhite(15,20), Pwhite(0,92) ) + 
			Pbrown( 0, 92, 1.0 )).round(1).wrap(10,92),
		\attack, Pwhite( 0.0, 1.0, inf ).linexp(0,1,0.005,0.05),
		\bufnum, Pindex( ~shesme.notes.buffers, Pkey( \index ), 1 ), 
		\bufnumx,	 Pseq( evt.buffers, inf ),
		\gain, 1 / Pindex( ~shesme.notes.peaks/ ~shesme.notes.peaks.mean, Pkey( \index ), inf ),
		\amp, Pwhite( 0.15,1,inf) * PenvirGet( \amp, 0.1, evt ),
		\startPos, Pbrown( 0.2, 0.8, 0.05, inf ),
		\bend, Prand( [-2, 1,0,0,1], inf ),
		\pan, Pbrown( -1.0, 1.0, 0.5, inf ),
	).play;
	evt.active = true;
};

~shesme.pattern.end = { |evt|
	evt.pbind.stop;
	evt.pbind = nil;
	evt.active = false;
};
