(
~shesme = ~shesme ? EM();

~shesme.quotes = ~shesme.quotes ? EM();

~shesme.quotes.currentQouteDur = 0;
~shesme.quotes.currentquotestartedAt = 0;

~shesme.quotes.whichwhere = [ 1, 3, 0, 2, 5, 4 ];

~shesme.quotes.specs = OEM();

[ \amp, 0.1, \amp.asSpec, \filter, 0, [-1,1,\lin,0,0].asSpec, \pan, [-1,1], [-1,1].asSpec.asRangeSpec, 
	\selection, 0, ListSpec((..6), 0, [ 
		"all",
		"100_procent_man_vrouw", 
		"als_ik_dans", 
		"denk_je_echt_kort",
		 "in_mijn_land", 
		 "meiden_zijn_krengen_kort", 
		 "onvoorwaardelijke_liefde" 
		] )
].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.quotes[ key ] = value;
	~shesme.quotes[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.quotes.specs[ key.asGetter ] = spec;
});

~shesme.quotes.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition( false );
		evt.buffers = (thisProcess.nowExecutingPath.dirname.dirname +/+ 
				"samples/quotes/*.wav").pathMatch.collect({ |item|
			var buf;
			buf = Buffer.read(s, item, action: { cond.test = true; cond.signal });
			cond.wait;
			cond.test = false;
			"\t%: %\n".postf( buf.bufnum, buf.path.dirname.basename +/+ buf.path.basename );
			buf;
		});
		action.value;
	}.fork;	
};

/*
~shesme.quotes.loadBuffers;
*/

(
SynthDef( "shesme_quote", { |bufnum = 0, rate = 1, filter = 0, gain = 1, amp = 0.1, pan = 0, gate = 1|
	var sig;
	var fadeIn, fadeOut;
	fadeIn = Rand(0,1);
	fadeOut = 1-fadeIn;
	sig = PlayBuf.ar( 1, bufnum, rate, doneAction: 2 );
	sig = BHiShelf.ar( sig, 6000, 1, 4 );
	sig = BPeakEQ.ar( sig, 2500, 1, 9 );
	sig = BPeakEQ.ar( sig, 200, 1, -7 );
	sig = BLowCut.ar( sig, filter.clip(0,1).varlag(Rand(3, 5)).linexp(0,1,20,5000,\minmax), 3 );
	sig = BHiCut.ar( sig, filter.clip(-1,0).varlag(Rand(3, 5)).linexp(-1,0,300,20000,\minmax),3 );
	sig = sig * amp * gain;
	Out.ar( 0, RoundPan.ar( 6, sig, pan - 1.1666) * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.quotes.start = { |evt|
	evt.end;
	evt.task = {
		var index = 0;
		loop {
			if( evt.selection != 0 ) {
				index = evt.selection - 1;
			} {
				index = (index + 1).wrap( 0, evt.buffers.size-1 );
			};
			evt.synths = evt.synths.add( 
				Synth( "shesme_quote", [ 
					\bufnum, evt.buffers[index], 
					\pan, evt.whichwhere[index].linlin( 0, 6, evt.pan[0], evt.pan[1] ),
					\amp, evt.amp,
					\filter, evt.filter ? 0,
				] ).freeAction_({ |synth|
					 evt.synths.remove( synth );
				});
			);
			evt.currentQuoteDur = evt.buffers[index].duration;
			evt.currentquotestartedAt = Process.elapsedTime;
			(evt.currentQuoteDur + (2.0 rrand: 6.0)).wait;
		};
	}.fork;
	evt.active = true;
};

~shesme.quotes.end = { |evt|
	evt.task.stop;
	//evt.synths.do(_.release);
	evt.active = false;
};

)

/*
~shesme.quotes.start;
~shesme.quotes.fade = 1;
~shesme.quotes.fade = 0;
~shesme.quotes.end;
*/