~shesme = ~shesme ? EM();

~shesme.speakerCorrect = ~shesme.speakerCorrect ? EM();

~shesme.speakerCorrect.specs = OEM();

SynthDef( "shesme_speakerCorrect", {
	var in;
	in = In.ar(0,10);
	ReplaceOut.ar(0, (Limiter.ar( BLowCut.ar( in[..5], 200 ), -24.dbamp, 0.1 ) * 12.dbamp) ++
		DelayN.ar( in[6..], 0.2,0.2 ) 
	);
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

