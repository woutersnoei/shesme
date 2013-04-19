(
~shesme = ~shesme ? EM();

~shesme.chords = ~shesme.chords ? EM();

~shesme.chords.loadBuffers = { |evt, action|
	evt.buffers = evt.buffers ? EM();
	evt.buffers_soft = evt.buffers_soft ? EM();
	{	
		var cond;
		cond = Condition(false);
		"/Users/woutersnoei/Dropbox/Work/shesme/samples/chords/*".pathMatch.do({ |item|
			evt.buffers[ item.basename.asSymbol ] = 
				Buffer.readDir(item, nil, "wav", action: { cond.test = true; cond.signal });
			cond.wait;
			cond.test = false;
		});
		"/Users/woutersnoei/Dropbox/Work/shesme/samples/chords_soft/*".pathMatch.do({ |item|
			evt.buffers_soft[ item.basename.asSymbol ] = 
				Buffer.readDir(item, nil, "wav", action: { cond.test = true; cond.signal });
			cond.wait;
			cond.test = false;
		});
		action.value;
	}.fork;
};

/*
~shesme.chords.loadBuffers({ "done".postln });
*/
 
(
SynthDef( "shesme_playnote", { |bufnum = 0, amp = 0.75, fadeIn = 0.25, gate = 1|
	var sig;
	sig = PlayBufAlt.ar( 1, bufnum, 1, //LFDNoise3.kr(1, 0.1).midiratio, 
		TDuty.ar( Dwhite( 1, 4 ) )
	);
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.125).exprange(20,2000), 3 );
	sig = BHiCut.ar( sig, LFDNoise1.kr(0.125).exprange(100,20000), 3 );
	sig = sig * LFDNoise3.kr(0.125).exprange(-13.dbamp, 0.dbamp) * amp;
	//sig = sig + PitchShift.ar( sig * 0.25, 0.1 rrand: 0.3, 0.5, 0.01, 0.2 );
	Out.ar( 0, RoundPan.ar( 4, sig, LFDNoise3.kr(0.125) ) * 
		Env.asr(fadeIn,1,fadeIn).kr(2,gate) 
	);
}).load(s);
);

~shesme.chords.start = { |evt|
	evt.end;
	evt.task = {	
		var fade = 1;
		inf.do({	
			var synths, bufs, ii;
			ii = 2.rand.postln;
			bufs = [ evt.buffers_soft, evt.buffers ][ii].choose;
			synths = 6.collect({|i|
				Synth( "shesme_playnote", [ 
					\bufnum, bufs[i], 
					\fadeIn, fade, 
					\amp, [1.5,0.75][ii] 
				]).freeAction_({ |synth|
					evt.synths.remove(synth);
				});
			});
			evt.synths = evt.synths.addAll( synths );
			(3 rrand: 25).wait;
			fade = 0.05 rrand: 3;
			//fade.postln;
			synths.do(_.release(fade));
		});
	}.fork
};

~shesme.chords.end = { |evt|
	evt.task.stop;
	evt.task = nil;
	evt.synths.do(_.release(1.5));
};
)

/*
~shesme.chords.start;
~shesme.chords.end;
*/

/*
x = {
	var fade = 1;
	inf.do({	
		var synths, bufs, ii;
		ii = 2.rand.postln;
		bufs = [ ~shesme.chords.buffers_soft.choose, ~shesme.chords.buffers.choose ][ii];
		synths = 6.collect({|i|
			Synth( "shesme_playnote", [ \bufnum, bufs[i], \fadeIn, fade, \amp, [1.5,0.75][ii] ]);
		});
		(3 rrand: 25).postln.wait;
		fade = 0.05 rrand: 3;
		fade.postln;
		synths.do(_.release(fade));
	});
}.fork;
);

x.stop;
~srw.stop;
*/
