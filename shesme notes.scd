(
~shesme = ~shesme ? EM();

~shesme.notes = ~shesme.notes ? EM();

[ \amp, 0.1 ].pairsDo({ |key,value|
	~shesme.notes[ key ] = value;
	~shesme.notes[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
});

~shesme.notes.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition( false );
		evt.buffers = (
			"/Users/woutersnoei/Dropbox/Work/shesme/samples/low notes/*.wav".pathMatch ++
			"/Users/woutersnoei/Dropbox/Work/shesme/samples/midhigh notes/*.wav".pathMatch ++
			"/Users/woutersnoei/Dropbox/Work/shesme/samples/high notes/*.wav".pathMatch
		).collect({ |item|
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
~shesme.notes.loadBuffers;
*/

(
SynthDef( "shesme_note", { |bufnum = 0, amp = 0.1, pan = 0, gate = 1|
	var sig;
	sig = PlayBuf.ar( 1, bufnum, doneAction: 2 );
	sig = sig * amp;
	Out.ar( 0, RoundPan.ar( 4, sig, pan ) * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.notes.start = { |evt|
	evt.end;
	evt.task = {
		loop {
			evt.synths = evt.synths.add( 
				Synth( "shesme_note", [ 
					\bufnum, evt.buffers.choose, 
					\pan, 0.25.rand2,
					\amp, evt.amp
				] ).freeAction_({ |synth|
					 evt.synths.remove( synth );
				});
			);
			(1.0 rrand: 8.0).wait;
		};
	}.fork;
};

~shesme.notes.end = { |evt|
	evt.task.stop;
	evt.synths.do(_.release);
};
)

/*
~shesme.notes.start;
~shesme.notes.end;
*/