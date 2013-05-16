(
~shesme = ~shesme ? EM();

~shesme.sfr = ~shesme.sfr ? EM();

~shesme.sfr.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition(false);
		evt.s_bufs = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/ssss",
			action: { cond.test = true; cond.signal; }
		);
		cond.wait;
		cond.test = false;
		evt.f_bufs = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/ffff",
			action: { cond.test = true; cond.signal; }
		);
		cond.wait;
		cond.test = false;
		evt.r_bufs = Buffer.readDir( thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/voiceless_r",
			action: { cond.test = true; cond.signal; }
		);
		cond.wait;
		action.value;
	}.fork;
};

/*
~shesme.sfr.loadBuffers;
*/

~shesme.sfr.specs = OEM();

[ 	\amp, 0.1, \amp.asSpec,
	\transpose, 0, [-24,24,\lin,0,0].asSpec,
	\rvar, 0, [0,12,\lin].asSpec,
	\overlap, 8, [0.125,8,\exp,0.125,8].asSpec,
	\tvar, 1.5, [0,2].asSpec,
	\speed, 10, [1,100,\exp, 0, 10].asSpec,
	\range, [0.1,0.9], [0,1].asSpec.asRangeSpec,
	\mode, \s, ListSpec([\s,\f,\r])
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.sfr[ key ] = value;
	~shesme.sfr[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.sfr.specs[ key.asGetter ] = spec;
});

~shesme.sfr[ \mode_ ] = { |evt, newMode|
	if( [ \f, \s, \r ].includes( newMode ) ) {
		evt[ \mode ] = newMode;
		if( evt.synths.notNil ) {
			evt.start(2);
		};
	};
};

/*
~shesme.sfr.amp = 0.1;
~shesme.sfr.transpose = -12;
~shesme.sfr.rvar = 0;
~shesme.sfr.overlap = 8;
~shesme.sfr.tvar = 1.5;
~shesme.sfr.speed = 10;
~shesme.sfr.range = #[0.1,0.9];
*/

(
SynthDef( "shesme_sfr", { |bufnum = 0, amp = 0.1, transpose = 0, rvar = 0, 
	overlap = 8, tvar = 1.5, speed = 10, range = #[0.1,0.9], gate = 1, fadeIn = 0.1|
	var sig;
	sig = GrainBuf.ar( 4, 
		TDuty.ar( 1/speed * (1 + Dwhite( tvar.neg/2, tvar/2, inf ) ) ),
		overlap/speed,
		bufnum,
		((WhiteNoise.ar * rvar) + transpose).midiratio,
		LFDNoise1.kr(0.25).range(*range),
		4,
		(WhiteNoise.ar * 0.05) + LFDNoise3.kr(0.125),
	) / (overlap.sqrt).max(1).lag(1) * amp.lag(1);
	Out.ar( 0, sig * Env.asr( fadeIn, 1, fadeIn ).kr(2,gate) );
}).load(s);
);

~shesme.sfr.start = { |evt, fade = 0.1|
	evt.end( fade );
	evt.synths = evt[ (evt.mode ++ "_bufs").asSymbol ].collect({ |buf|
		Synth( "shesme_sfr", [ \bufnum, buf, \fadeIn, fade ] ++ 
			evt.getPairs([ 'amp', 'transpose', 'rvar', 'overlap', 'tvar', 'speed', 'range' ])
		);
	});
	evt.active = true;
};

~shesme.sfr.end = { |evt, fade = 0.1|
	evt.synths.do(_.release(fade));
	evt.synths = nil;
	evt.active = false;
};

)

/*
~shesme.sfr.start;
~shesme.sfr.mode = \f;
~shesme.sfr.mode = \r;
~shesme.sfr.mode = \s;
~shesme.sfr.end(2);
*/
