(
~shesme = ~shesme ? EM();

~shesme.mumbling = ~shesme.mumbling ? EM();

~shesme.mumbling.loadBuffers = { |evt, action|
	{
		var cond;
		cond = Condition(false);
		evt.buffers = (thisProcess.nowExecutingPath.dirname.dirname +/+ "samples/gesprek/gesprek*.wav")
			.pathMatch.collect({ |item|
				var buf;
				buf = Buffer.read(s, item, action: { cond.test = true; cond.signal } );
				cond.wait;
				cond.test = false;
				"\t% : %\n".postf( buf.bufnum, buf.path.basename );
				buf;
			});
		action.value;
	}.fork
};

~shesme.mumbling.specs = OEM();

[ \amp, 0.1, \amp.asSpec ].clump(3).do({ |array|
	var key, value, spec;
	#key, value, spec = array;
	~shesme.mumbling[ key ] = value;
	~shesme.mumbling[ key.asSetter ] = { |evt, val|
		evt[ key ] = val;
		evt.sn.set( key, val);
	};
	~shesme.mumbling.specs[ key.asGetter ] = spec;
});
		
/*
~shesme.mumbling.loadBuffers;
~shesme.mumbling.buffers.size
*/

(
SynthDef( "shesme_mumbling", { |buffers = #[0,0,0,0,0], amp = 0.1, gate = 1|
		var sig, speed;
		speed = (LFTri.kr(LFDNoise3.kr(0.1).exprange(0.01,0.1), -0.5 ).range(0,1) ** 3)
			.linlin(0,1,3,200);
		sig = buffers.collect({ |buf|
			GrainBuf.ar(4, Dust.ar( speed ), 0.2, buf, 
				WhiteNoise.ar.exprange(0.95,1/0.95) * speed.linlin(5,100,-2,3).midiratio, 
				WhiteNoise.ar.range(0,1), 
				pan: WhiteNoise.ar 
			);
		}).sum;
		Out.ar(0, sig * amp.lag(0.1) * Env.cutoff(2).kr(2,gate) );
}).load(s);
);

~shesme.mumbling.start = { |evt|
	evt.end;
	evt.sn = Synth( "shesme_mumbling", [ \buffers, evt.buffers, \amp, evt.amp ? 0.1 ] ); 
	evt.active = true;
};

~shesme.mumbling.end = { |evt|
	evt.sn.release;
	evt.sn = nil;
	evt.active = false;
};
)

/*
~shesme.mumbling.start;
~shesme.mumbling.end;
*/