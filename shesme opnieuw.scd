(
~shesme = ~shesme ? EM();

~shesme.opnieuw = ~shesme.opnieuw ? EM();

~shesme.opnieuw.loadBuffers = { |evt, action|
	evt.buffers = evt.buffers ? EM();
	{	
		var cond;
		cond = Condition(false);
		(thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/opnieuw/*").pathMatch
			.do({ |item|
				evt.buffers[ item.basename.asSymbol ] = 
					Buffer.readDir(item, nil, "wav", action: { cond.test = true; cond.signal });
				cond.wait;
				cond.test = false;
			});
		action.value;
	}.fork;
};

~shesme.opnieuw.specs = OEM();

[ \amp, 0.1, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.opnieuw[ key ] = value;
	~shesme.opnieuw[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.opnieuw.specs[ key.asGetter ] = spec;
});

/*
~shesme.opnieuw.loadBuffers({ "done".postln });
*/
 
(
SynthDef( "shesme_opnieuw", { |amp = 0.1, gate = 1|
	var sig, verb;
	var buffers;
	buffers = \buffers.kr(0!6);
	sig = buffers.collect({ |bufnum|
		PlayBuf.ar( 1, bufnum, doneAction: 2) * 3 * amp;
	});
	sig = sig.collect({ |item|
		RoundPan.ar( 6, item, LFDNoise3.kr(0.125/2) * 2 );
	}).sum;
	Out.ar( 0, Env.cutoff( 0.2 ).kr(2,gate) * sig )
}).load(s);
);

~shesme.opnieuw.start = { |evt|
	evt.end;
	evt.synths = evt.synths.add(
		Synth( "shesme_opnieuw", [ \buffers, evt.buffers.choose.collect(_.bufnum), \amp, evt.amp ] )
			.freeAction_({ |synth| 
				evt.synths.remove( synth ); 
				if( evt.synths.size == 0 ) { evt.active = false; };
			});
	);
	evt.active = true;
};

~shesme.opnieuw.end = { |evt|
	evt.synths.do(_.release);
};
)

/*
~shesme.opnieuw.start;
~shesme.opnieuw.buffers.choose[0]
~shesme.opnieuw.synths;
*/