~shesme = ~shesme ? EM();

~shesme.speakerCorrect = ~shesme.speakerCorrect ? EM();

~shesme.speakerCorrect.specs = OEM();

[ \toMain, 0, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.speakerCorrect[ key ] = value;
	~shesme.speakerCorrect[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.sn.set( key, val);
	};
	~shesme.speakerCorrect.specs[ key.asGetter ] = spec;
});

SynthDef( "shesme_speakerCorrect", {
	var in;
	in = In.ar(0,10);
	ReplaceOut.ar(0, Limiter.ar( BLowCut.ar( in[..5], 200 ), -24.dbamp, 0.25 ) ++
		DelayN.ar( in[6..], 0.25,0.25 ) );
}).load(s);

~shesme.speakerCorrect.start = { |evt|
	evt.end;
	evt.sn = Synth( "shesme_speakerCorrect", target: RootNode(s), addAction: \addToTail );
	evt.active = true;
};

~shesme.speakerCorrect.end = { |evt|
	evt.sn.free;
	evt.active = false; 
};

