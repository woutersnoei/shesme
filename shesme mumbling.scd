(
~shesme = ~shesme ? EM();

~shesme.mumbling = ~shesme.mumbling ? EM();

~shesme.mumbling.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition(false);
		evt.buffers = (thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/gesprek/gesprek*.wav")
			.pathMatch.collect({ |item|
				var buf;
				buf = Buffer.read(s, item, action: { cond.test = true; cond.signal } );
				cond.wait;
				cond.test = false;
				"\t% : %\n".postf( buf.bufnum, buf.path.basename );
				buf;
			});
		cond.test = false;
		evt.winenv = Env([0,1,1,0,0], [0.01,0.5,0.01,0.48], [4,-4]);
		evt.winbuf = Buffer.sendCollection(s, evt.winenv.discretize, 1, 
			action: { cond.test = true; cond.signal; } );
		cond.wait;
		action.value;
	}.fork
};

~shesme.mumbling.specs = OEM();

[ 
	\amp, 0.1, \amp.asSpec, 
	\duck, 0, [0,1].asSpec,
	\pan, [-1,1], [-1,1].asSpec.asRangeSpec,
	\speed, 3, [0,200,4].asSpec, 
	\spvar, true, BoolSpec(true), 
	\filter, 0, [-1,1, \lin,0,0].asSpec, 
	\useWinbuf, false, BoolSpec(false),
	\verb, 0, [0,1].asSpec 
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.mumbling[ key ] = value;
	~shesme.mumbling[ key.asSetter ] = { |evt, val|
		var lastVal;
		lastVal = evt[ key ];
		evt[ key ] = val;
		if( lastVal != val ) { evt.sn.set( key, val); };
	};
	~shesme.mumbling.specs[ key.asGetter ] = spec;
});
		
/*
~shesme.mumbling.loadBuffers;
~shesme.mumbling.buffers.size
*/

(
SynthDef( "shesme_mumbling", { |buffers = #[0,0,0,0,0], speed = 3, spvar = 1, amp = 0.1, filter = 0, verb = 0, gate = 1, pan = #[-1,1], duck = 0, winbuf = 0, useWinbuf = 0|
		var sig, verbSig;
		/*
		speed = (LFTri.kr(LFDNoise3.kr(0.1).exprange(0.01,0.1), -0.5 ).range(0,1) ** 3)
			.linlin(0,1,3,200);
		*/
		//speed = speed.varlag(1);
		
		duck = Select.kr( Line.kr(0,1,0.1).round(1), [ duck, Latch.kr( duck, Impulse.kr(10) ) ] );
		filter = Select.kr( Line.kr(0,1,0.1).round(1), [ filter, Latch.kr( filter, Impulse.kr(5) ) ] );
		
		amp = amp * duck.linlin(0,1,1,-0.1,\none).lag(0.1,4).max(0);
			
		sig = buffers.collect({ |buf|
			GrainBuf.ar(6, 
				if( spvar, Dust.ar( speed ), Impulse.ar( speed ) ),
				0.2, buf, 
				WhiteNoise.ar.exprange(0.95,1/0.95) * speed.linlin(5,100,-1,3,\minmax).midiratio, 
				WhiteNoise.ar.range(0,1), 
				pan: WhiteNoise.ar.range(*pan),
				envbufnum: if( useWinbuf, winbuf, -1 )
			);
		}).sum;
		sig = BLowCut.ar( sig, filter.clip(0,1).varlag(2).linexp(0,1,20,5000,\minmax), 3 );
		sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(2).linexp(-1,0,300,20000,\minmax), 3 );
		verbSig = FreeVerb.ar( sig, 1, Rand(0.6,0.8), 0.5 );
		verbSig = PitchShift.ar( verbSig, 0.1, 1, 0.01, 0.1 );
		sig = (sig * (1-verb)) + (verbSig * verb);
		Out.ar(0, sig * amp.lag(0.1) * Env.cutoff(0.1).kr(2,gate) );
}).load(s);
);

~shesme.mumbling.start = { |evt|
	evt.end;
	evt.sn = Synth( "shesme_mumbling", [ \buffers, evt.buffers, \amp, evt.amp ? 0.1, \duck, evt.duck ? 0, \pan, evt.pan, \speed, evt.speed ? 3, \spvar, evt.spvar ? true, \filter, evt.filter ? 0, \verb, evt.verb ? 0, \winbuf, evt.winbuf, \useWinbuf, evt.useWinbuf ? 0 ] ); 
	evt.active = true;
};

~shesme.mumbling.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
)

/*
~shesme.mumbling.start;
~shesme.mumbling.end;
*/