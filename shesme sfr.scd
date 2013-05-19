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
		cond.test = false;
		evt.winenv = Env([0,1, 0], [0.05,0.95], [4,-4]);
		evt.winbuf = Buffer.sendCollection(s, evt.winenv.discretize, 1, 
			action: { cond.test = true; cond.signal; } );
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
	\filter, 0, [-1,1,\lin,0,0].asSpec,
	\convolve, 0, [0,1].asSpec,
	\useWinbuf, false, BoolSpec(false),
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
SynthDef( "shesme_sfr", { |bufnum = 0, amp = 0.1, transpose = 0, filter = 0, convolve = 0, rvar = 0, 
	overlap = 8, tvar = 1.5, speed = 10, range = #[0.1,0.9], gate = 1, fadeIn = 0.1, 
	winbuf = 0, useWinbuf = 0|
	var sig, fft1, fft2;
	var sig2, trigger;
	
	sig = GrainBuf.ar( 6, 
		TDuty.ar( 1/speed * (1 + Dwhite( tvar.neg/2, tvar/2, inf ) ) ),
		overlap/speed,
		bufnum,
		((WhiteNoise.ar * rvar) + transpose).midiratio,
		LFDNoise1.kr(0.25).range(*range),
		4,
		(WhiteNoise.ar * 0.05) + LFDNoise3.kr(0.125),
		if( useWinbuf, winbuf, -1 )
	) / (overlap.sqrt).max(1).lag(1) * amp.lag(1);
	
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(Rand(3, 5)).linexp(0,1,20,5000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(Rand(3, 5)).linexp(-1,0,300,20000,\minmax),3 );
	
	trigger = ToggleFF.kr( TDuty.kr(10,30) );
	trigger = [ trigger, 1-trigger ];
	
	sig2 = trigger.collect({ |tr|
		DynKlank.ar( 
			`[ 
				SortedRand.kr(tr, 4, 48, 120, 0.5 ).round(1).midicps + 
					LFDNoise1.kr(0.2).range(-10,10), 
				1/4,
				1/LFDNoise3.kr(0.1.dup(4)).range(1,20) 
			], sig
		) * 0.2 * (Slew.kr( tr, 1/5, 1/5 ) * 0.5pi).sin
	}).sum;
	
	/*
	trigger = ToggleFF.kr( TDuty.kr(10,30) );
	trigger = [ trigger, 1-trigger ];
	
	sig2 = trigger.collect({ |tr|
		Siren.ar( 
			SortedRand.kr(tr, 4, 48, 100, 0.5 ).round(1).midicps + LFDNoise1.kr(0.2).range(-10,10), 
			sharpness: LFDNoise3.kr(0.1.dup(4)).range(1,10) 
		).mean * (Slew.kr( tr, 1/5, 1/5 ) * 0.5pi).sin
	}).sum;
	
	fft2 = FFT( LocalBuf(1024).clear, sig2 );
	
	sig2 = sig.collect({ |sig|
		var fft; 
		fft = FFT( LocalBuf(1024).clear, sig );
		fft = PV_MagMul( fft, fft2 );
		IFFT( fft ) * 0.2;
	});
	
	sig = (DelayN.ar( sig, ((1024 * 0.75) + 128)/44100, ((1024 * 0.75) + 128)/44100) * (1-convolve)) + (sig2 * convolve);
	*/
	
	sig = (sig * (1-convolve)) + (sig2 * convolve);
	Out.ar( 0, sig * Env.asr( fadeIn, 1, fadeIn ).kr(2,gate) );
}).load(s);
);

~shesme.sfr.start = { |evt, fade = 0.1|
	evt.end( fade );
	evt.synths = evt[ (evt.mode ++ "_bufs").asSymbol ].collect({ |buf|
		Synth( "shesme_sfr", [ \bufnum, buf, \fadeIn, fade, \winbuf, evt.winbuf ] ++ 
			evt.getPairs([ 'amp', 'transpose', 'rvar', 'filter', 'convolve', 'overlap', 'tvar', 'speed', 'range', 'useWinbuf' ])
		);
	});
	evt.active = true;
};

~shesme.sfr.end = { |evt, fade = 2|
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
