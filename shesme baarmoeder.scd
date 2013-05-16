(
~shesme = ~shesme ? EM();

~shesme.baarmoeder = ~shesme.baarmoeder ? EM();

~shesme.baarmoeder.specs = OEM();

[ \amp, 0.1, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.baarmoeder[ key ] = value;
	~shesme.baarmoeder[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.synths.do(_.set( key, val) );
	};
	~shesme.baarmoeder.specs[ key.asGetter ] = spec;
});

~shesme.baarmoeder.path = thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/baarmoeder";

~shesme.baarmoeder.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition( false );
		evt.buffers = [];
		(evt.path +/+ "*").pathMatch.sort.do({ |folder|
			evt.buffers = evt.buffers.add(
				(folder +/+ "*.wav").pathMatch.select({ |item|
					item.basename[0].isDecDigit;
				}).collect({ |item|
					var buf;
					buf = Buffer.read(s,item, action: { cond.test = true; cond.signal });
					cond.wait;
					cond.test = false;
					"loaded %: %\n".postf( buf.bufnum, buf.path.dirname );
					buf
				})
			);
		});
		action.value;
	}.fork;
};

/*
~shesme.baarmoeder.loadBuffers({ "done".postln });
*/

(
(2..6).do({ |item|
	SynthDef( "shesme_baarmoeder_%".format(item), { |amp = 0.1, gate = 1|
		var bufs, n;
		var sig, amps = 1;
		n = item;
		bufs = \bufs.kr( 0!n );
		sig = bufs.collect({ |item|
			PlayBuf.ar( 1, item, doneAction:2) * 1.4;
		});
		amps = LFDNoise3.kr( 0.5.dup(bufs.size) ).exprange( -24.dbamp, 1 );
		amps = amps / amps.sum * 8;
		sig = RoundPan.ar( 4, (sig * amps).sum * amp, LFDNoise3.kr( 0.1 ) );
		Out.ar( 0, sig * Env.cutoff(2).kr(2,gate) );
	}).load(s);
});
);

~shesme.baarmoeder.start = { |evt|
	evt.end;
	evt.task = {
		var index = 0;
		loop {
			var bufs;
			index = evt.buffers.size.asInt.xrand( index );
			bufs = evt.buffers[index];
			evt.synths = evt.synths.add(
				Synth( "shesme_baarmoeder_%".format(bufs.size), [ \bufs, bufs, \amp, evt.amp ])
				.freeAction_({ |synth|
					evt.synths.remove( synth );
					if( evt.synths.size == 0 ) { evt.active = false; };
				})
			);
			(6 rrand: 15).wait;
		};
	}.fork;
	evt.active = true;
};

~shesme.baarmoeder.end = { |evt|
	evt.task.stop;
	evt.task = nil;
	evt.synths.do(_.release);
};
)

/*
~shesme.baarmoeder.start;
~shesme.baarmoeder.end;

*/