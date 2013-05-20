~shesme = ~shesme ? EM();

~shesme.speakerTest = ~shesme.speakerTest ? EM();

(
SynthDef( "shesme_speakerTest", { |out = 0, amp = 0.1, sustain = 1|
	OffsetOut.ar( out, PinkNoise.ar(amp) * Env([0,1,1,0], [0.01, sustain-0.02,0.01]).kr(2) );
}).store;
);

~shesme.speakerTest.start = { |evt|
	evt.end;
	evt.active = true;
	evt.pat = Pbind( 
		\instrument, "shesme_speakerTest",
		\dur, 0.25,
		\legato, 0.5,
		\amp, 0.1,
		\out, Pseq( (..9), inf )
	).play;
};

~shesme.speakerTest.end = { |evt|
	evt.active = false;
	evt.pat.stop;
};

/*
~shesme.speakerTest.start;
~shesme.speakerTest.end;
*/