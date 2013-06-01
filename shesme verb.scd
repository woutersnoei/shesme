
(
/// 4ch reverb
// luistert naar bus PrivateBus 0,1,2,3

//Server.default = Server.local;
//s = Server.default;

~shesme = ~shesme ? EM();
~shesme.verb = ~shesme.verb ? EM();

~shesme.verb.start = { |evt| q.verb.start; evt.active = true; };
~shesme.verb.end = { |evt| q.verb.end; evt.active = false; };
~shesme.verb.active = { q.verb.active.booleanValue };

q = q ? EM();
q.verb = q.verb ? EM();

q.verb.font = Font( Font.defaultSansFace, 10 );

q.verb.active = 0;
q.verb.n = 6; // number of channels
q.verb.fftsize= 2048; 
q.verb.amp = 0.1;
q.verb.preDelay = 0;
q.verb.dur = 0.8;
q.verb.leak = 0.33;
q.verb.private = false;
q.verb.out = 6;
q.verb.dry = 0.4;
q.verb.pan = 1;

q.verb.offset = 22; // eucon slider

(
SynthDef( "ws_verb%".format( q.verb.n ), { |in = 0, amp = 0.33, preDelay = 0, out = 0, 
		fftsize = 2048, private = 0, gate = 1, dry = 0, dryhicut = 400, pan = 1,
		hishelf = -6, hishelfFreq = 3000, lowshelf = 0, lowshelfFreq = 600, leak = 0.05|
	var bufs = \bufs.ir( 0!q.verb.n );
	var input, sig, env;
	env = Env([0,1,1,0,0], [0.1,0,0.1, BufDur.ir( bufs[0] ) + preDelay ], \lin, 2 ).kr(2, gate );
	input = In.ar( 0 + (FirstPrivateBus.ir * private), bufs.size );
	//CheckBadValues.ar( input );
	//input = input + WhiteNoise.ar(1.0e-9);
	input = RemoveBadValues.ar(input);
	dry = dry * input;
	dry = BHiCut.ar( dry, dryhicut, 1 );
	dry = DelayN.ar(dry, 0.25, preDelay );
	input = input + (input.sum * leak ) * env * amp ;
	input = BHiShelf.ar( input, hishelfFreq, 1, hishelf );
	input = BLowShelf.ar( input, lowshelfFreq, 1, lowshelf );
	input = DelayN.ar(input, 0.25, preDelay );
	sig = bufs.collect({ |sp, i| 
		PartConv.ar(input[i], fftsize, sp, 0.5); 
	});
	if( q.verb.n == 6 ) {
		// 6 to 4 channels
		sig[2] = sig[2] * 2.sqrt;
		sig[4] = sig[4] * 2.sqrt;
		sig = [ sig[0], sig[1] + sig[2], sig[2] + sig[3] + sig[4], sig[5] + sig[4] ];
		
		dry[2] = dry[2] * 2.sqrt;
		dry[4] = dry[4] * 2.sqrt;
		dry = [ dry[0], dry[1] + dry[2], dry[2] + dry[3] + dry[4], dry[5] + dry[4] ];
		DelayN.ar(  dry, 0.015, 0.015 );
	};
	
	Out.ar( out, ((sig * 2) + (dry * env)) * 0.5 );
}).load(s);
);

(
SynthDef( "ws_verb%_sum".format( q.verb.n ), { |in = 0, amp = 0.33, preDelay = 0, out = 0, 
		fftsize = 2048, private = 0, gate = 1, hishelf = 0, hishelfFreq = 1200|
	var bufs = \bufs.ir( 0!q.verb.n );
	var input, sig, env;
	env = Env([0,1,1,0,0], [0.1,0,0.1, BufDur.ir( bufs[0] ) + preDelay ], \lin, 3 ).kr(2, gate );
	input = In.ar( 0 + (FirstPrivateBus.ir * private), bufs.size ).sum;
	input = input * env;
	input = BHiShelf.ar( input, hishelfFreq, 1, hishelf );
	input = DelayC.ar(input, 0.25, preDelay );
	sig = bufs.collect({ |sp, i| 
		PartConv.ar(input, fftsize, sp, 0.5); 
	});
	
	Out.ar( out, sig * amp * 2 );
}).load(s);
);


q.verb.danStowel = {|evt| 
	var ir, f;
	//synthesise the honourable 'Dan Stowell' impulse response
	ir = ((0..evt.dur*44100).linlin(0,evt.dur*44100,1,0.125).collect{|f| f =
	f.squared.squared; f = if(f.coin){0}{f.squared}; f =
	if(0.5.coin){0-f}{f}  }) * (-27.dbamp);
};

q.verb.prepare = { |evt, action|
	
		evt.irspectrum.do( _.free );
		evt.irspectrum = nil;
		
		{
		q.verb.n.do({ |i|
			var ir, irbuffer, bufsize; 
		
			ir = q.verb.danStowel;
			irbuffer = Buffer.loadCollection(s,ir);
				
			s.sync;
			
			bufsize= PartConv.calcBufSize(evt.fftsize,irbuffer);
			//q.verb.numpartitions= PartConv.calcNumPartitions(q.verb.fftsize,irbuffer);
			
			evt.irspectrum = evt.irspectrum.add( Buffer.alloc(s,bufsize,1) );
			0.1.wait; // make sure it's allocated
			evt.irspectrum.last.preparePartConv(irbuffer, evt.fftsize);
			
			s.sync; 
			
			irbuffer.free; //don't need time domain data anymore, just needed spectral version
			});
		"prepare done".postln;
		action.value;
		}.fork;

};
		
q.verb.start = { |evt, endFirst = true|  // doesn't check if already started !!
	if( endFirst ) { evt.end; };
	evt.active = 1;
	evt.sn = Synth( "ws_verb%".format( evt.n ), [
		 		\amp, evt.amp, 
 		 		\preDelay, evt.preDelay,
 		 		\bufs, evt.irspectrum,
 		 		\fftsize, evt.fftsize,
 		 		\leak, evt.leak,
 		 		\private, evt.private.binaryValue,
 		 		\out, evt.out ? 0,
 		 		\dry, evt.dry ? 0
 			 ], addAction: \addAfter );
	};

q.verb.end = { |evt|
	evt.active = 0;
	evt.sn.release; evt.sn = nil;
};


q.verb.cmdPeriod = { |evt| if( evt.active == 1 ) { { evt.start( false ) }.defer(0.1); } };
	
CmdPeriod.add( q.verb );

// window and views
q.verb.w = Window( "verb", Rect(146, 365, 113, 104)).front;
q.verb.w.addFlowLayout;
q.verb.views = ();

q.verb.ctrl.remove;
q.verb.ctrl = SimpleController( q.verb )
	.put( \active, {
		if( q.verb.w.notNil && { q.verb.w.isClosed.not } ) {
			q.verb.views[ \power ].value = q.verb.active;
		};
	})
	.put( \amp, {
		if( q.verb.w.notNil && { q.verb.w.isClosed.not } ) {
			q.verb.views[ \amp ].value = q.verb.amp;
			q.verb.sn.set( \amp, q.verb.amp ); 
		};
	})
	.put( \dry, {
		if( q.verb.w.notNil && { q.verb.w.isClosed.not } ) {
			q.verb.views[ \dry ].value = q.verb.dry;
			q.verb.sn.set( \dry, q.verb.dry ); 
		};
	})
	.put( \preDelay, {
		if( q.verb.w.notNil && { q.verb.w.isClosed.not } ) {
			q.verb.views[ \preDelay ].value = q.verb.preDelay;
			q.verb.sn.set( \preDelay, q.verb.preDelay ); 
		};
	})
	.put( \dur, {
		if( q.verb.w.notNil && { q.verb.w.isClosed.not } ) {
			q.verb.views[ \dur ].value = q.verb.dur;
		};
	});

q.verb.w.onClose = { 
	q.verb.sn.free; 
	q.verb.sn = nil; 
	q.verb.ctrl.remove; 
	CmdPeriod.remove( q.verb ); 
};

q.verb.views[ \prepare ] = RoundButton( q.verb.w, 70@16 )
	.states_([[ "prepare" ]])
	.font_( q.verb.font )
	.action_({ q.verb.prepare });

q.verb.views[ \power ] = RoundButton( q.verb.w, 16@16 )
	.states_([[ 'power' ], [ 'power', Color.black, Color.green(0.75).alpha_(0.75) ]])
	.action_({ |bt|
		switch( bt.value,
			1, { q.verb.start; },
	 		0, { q.verb.end; })
			});
			
q.verb.views[ \amp ] = SmoothSlider(  q.verb.w, 94@16,  ).value_( q.verb.amp ? 0.33 )
	.string_( " amp " )
	.action_({ |sl| 
		q.verb.amp = sl.value;
		q.verb.sn.set( \amp, q.verb.amp ); 
	});
	
q.verb.views[ \dry ] = SmoothSlider(  q.verb.w, 94@16,  ).value_( q.verb.dry ? 0 )
	.string_( " dry " )
	.action_({ |sl| 
		q.verb.dry = sl.value;
		q.verb.sn.set( \dry, q.verb.dry ); 
	});
			
StaticText( q.verb.w, 50@16 ).string_( "predelay" ).align_( \right ).font_( q.verb.font );
q.verb.views[ \preDelay ] = SmoothNumberBox( q.verb.w, 40@16 ).value_( q.verb.preDelay ? 0)
	.clipLo_( 0 ).clipHi_(0.25).step_(0.01).font_( q.verb.font )
	.action_({ |sl| 
		q.verb.preDelay = sl.value;
		q.verb.sn.set( \preDelay, q.verb.preDelay ); 
	});
				
StaticText( q.verb.w, 50@16 ).string_( "dur" ).align_( \right ).font_( q.verb.font );
q.verb.views[ \dur ] = SmoothNumberBox( q.verb.w, 40@16 ).value_( q.verb.dur ? 1.3 )
	.clipLo_( 0.1 ).clipHi_(5).scroll_step_(0.1).step_(0.1).font_( q.verb.font )
	.action_({ |nb| q.verb.dur = nb.value; });
	
q.verb.prepare({ q.verb.views.power.valueAction = 1; });
	
/*
if( e.notNil )
	{
		e.coupleSlider( 7, { |sl| q.verb.views.amp.valueAction = sl.value }, "verb" );
		e.actions.button.rec[7] = { |bt|  q.verb.views.power.valueAction = bt.value.asInt };		e.sliders[7].valueAction = q.verb.amp;
		e.buttons.rec[ 7].valueAction = 0;		
	};
*/

// now on NanoKONTROL fader 9

)