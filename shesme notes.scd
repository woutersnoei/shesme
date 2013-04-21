(
~shesme = ~shesme ? EM();

~shesme.notes = ~shesme.notes ? EM();

[ \amp, 0.1, \fade, 0 ].pairsDo({ |key,value|
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
		evt.buffers = [ 
			"samples/low notes/*.wav",
			"samples/midhigh notes/*.wav",
			"samples/high notes/*.wav"
		].collect({ |item|
			(thisProcess.nowExecutingPath.dirname.dirname +/+ item).pathMatch
		}).flatten(1).collect({ |item|
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
SynthDef( "shesme_note", { |bufnum = 0, rate = 1, amp = 0.1, pan = 0, gate = 1, fade = 0|
	var sig;
	sig = PlayBuf.ar( 1, bufnum, rate, doneAction: 2 );
	sig = sig * amp;
	sig = sig * Env([0,1,1,0], (BufDur.kr(bufnum) / rate) * [fade,2-(fade*2),fade]/2).kr;
	Out.ar( 0, RoundPan.ar( 4, sig, pan ) * Env.cutoff.kr(2,gate) );
}).load(s);
);

~shesme.notes.start = { |evt|
	evt.end;
	evt.task = {
		var index = 0;
		loop {
			index = (evt.buffers.size - 1).asInt.xrand(index);
			evt.synths = evt.synths.add( 
				Synth( "shesme_note", [ 
					\bufnum, evt.buffers[index], 
					\rate, (evt.freqs[ index ].cpsmidi.round(1).midicps ) / evt.freqs[ index ],
					\pan, 0.25.rand2,
					\fade, evt.fade ? 0,
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

(
~shesme.notes.freqs = [ 219.02687072754, 225.7346496582, 184.53628540039, 245.15466308594, 203.73629760742, 222.35473632812, 198.00444030762, 172.77813720703, 160.67652893066, 222.81889343262, 195.16038513184, 209.80244445801, 229.69987487793, 170.63356018066, 271.91952514648, 325.84085083008, 202.09211730957, 224.34912109375, 211.83322143555, 193.57633972168, 163.21849060059, 170.83335876465, 174.96678161621, 179.65646362305, 196.07621765137, 181.14038085938, 171.89540100098, 194.19169616699, 208.31672668457, 208.41586303711, 287.46130371094, 265.53295898438, 187.78530883789, 198.935546875, 383.42984008789, 347.80480957031, 429.70532226562, 484.67413330078, 388.14572143555, 284.50787353516, 339.65005493164, 541.28460693359, 509.91690063477, 458.50823974609, 509.59429931641, 534.41174316406, 618.14837646484, 662.72869873047, 341.46063232422, 312.1796875, 372.99353027344, 388.85595703125, 432.82949829102, 462.55816650391, 346.03695678711, 510.68893432617, 419.75967407227, 375.28631591797, 490.05661010742, 466.94836425781, 545.75769042969, 490.16848754883, 547.43096923828, 554.03338623047, 582.10321044922, 428.16955566406, 438.01809692383, 437.55563354492, 452.32308959961, 468.33169555664, 438.78457641602, 512.02825927734, 491.82797241211, 583.33099365234, 391.50802612305, 406.31936645508, 774.80706787109, 702.78369140625, 735.34545898438, 686.35223388672, 729.0849609375, 768.14770507812, 816.37847900391, 846.31585693359, 1134.1580810547, 895.51812744141, 1006.28125, 800.63323974609, 852.50164794922, 725.1201171875, 660.37048339844, 936.95269775391, 806.54132080078 ];
);

)

/*
~shesme.notes.start;
~shesme.notes.end;
*/