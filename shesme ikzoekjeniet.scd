(
~shesme = ~shesme ? EM();

~shesme.ikzoekjeniet = ~shesme.ikzoekjeniet ? EM();

~shesme.ikzoekjeniet.loadBuffers = { |evt, action|
	evt.vrolijkbuf = Buffer.read(s, 
		thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/ik_zoek_je_niet/vrolijk.aiff", 
		action: action );
};

/*
~shesme.ikzoekjeniet.loadBuffers;
*/


[ \amp, 0.1 ].pairsDo({ |key,value|
	~shesme.ikzoekjeniet[ key ] = value;
	~shesme.ikzoekjeniet[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
});

(
SynthDef( "shesme_ikzoekjeniet", { |bufnum = 0, amp = 0.1, gate = 1|
	var sig, verb;
	sig = PlayBuf.ar( 8, bufnum, doneAction: 2) * 3 * amp;
	verb = sig[[6,7]];
	sig = sig[..5];
	sig = sig.collect({ |item|
		RoundPan.ar( 4, item, LFDNoise3.kr(0.5) );
	}).sum;
	Out.ar( 0, Env.cutoff( 0.2 ).kr(2,gate) * sig )
}).load(s);
);

~shesme.ikzoekjeniet.start = { |evt|
	evt.end;
	evt.synths = evt.synths.add(
		Synth( "shesme_ikzoekjeniet", [ \bufnum, evt.vrolijkbuf, \amp, evt.amp ] )
			.freeAction_({ |synth| evt.synths.remove( synth ); });
	);
};


~shesme.ikzoekjeniet.end = { |evt|
	evt.synths.do(_.release);
};

)

/*
~shesme.ikzoekjeniet.start;
~shesme.ikzoekjeniet.synths;
*/