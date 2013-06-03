
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

(
~shesme.verb.points = WFSPointGroup([ 

	// paintings
	Point(-35,-19), 
	Point(-35, 17), 
	Point( -3, 50), 
	Point( 22, 33), 
	Point( 28,-5 ), 
	Point( 20,-32), 
	
	// speakers
	Point(-40,-27),
	Point(-27, 41), 
	Point( 28, 41), 
	Point( 28, -40) 
	
] / 10);
);

/*
(
WFSSpeakerConf.default = WFSSpeakerConf(); // hide speakerconf
~shesme.verb.pointsGUI = ~shesme.verb.points.gui;
~shesme.verb.pointsGUI.xyView.colors = (Color.blue ! 6) ++ (Color.web.brown ! 4);
)

"(\n~shesme.verb.points = " ++ ~shesme.verb.pointsGUI.object.cs ++ ";\n)";
*/

~shesme.verb.getVals = { |evt|
	var quad, stereo;
	evt.delays =  evt.points.positions[..5].collect({ |pos|
		evt.points.positions[6..].collect({ |sp|
			pos.dist(sp);
		});
	}) * (1/344);
	
	#quad, stereo = [ (6..9), [7,8] ].collect({ |sps|
		evt.points.positions[..5].collect({ |pos|
			var res = [], which, amt, angle = pos.angle;
			evt.points.positions[sps].collect(_.angle).wrapExtend(sps.size+1)
				.doAdjacentPairs({ |a,b,i|
					a = a.wrap(angle, angle + 2pi);
					b = b.wrap( a - 2pi, a );
					amt = angle.linlin( a, b, 0,1,\none);
					res = res.add( amt );
					if( (amt >= 0) and: (amt < 1) ) {
						which = i;
					};
				});
			res.do({ |amt, i|
				if( (amt >= 0) and: (amt < 1) ) {
					which = i;
				};
			});
			(res[ which ].linlin(0,1,-0.25,1.25).clip(0,1) + which);
		});
	});
	
	evt.panValuesQuad = quad;
	evt.panValuesStereo = stereo;
};

~shesme.verb.getVals;

/*
~shesme.verb.delays;
~shesme.verb.panValuesStereo;
~shesme.verb.panValuesQuad;
*/

q = q ? EM();
q.verb = q.verb ? EM();

q.verb.font = Font( Font.defaultSansFace, 10 );

q.verb.active = 0;
q.verb.n = 4; // number of channels
q.verb.fftsize= 2048; 
q.verb.amp = 0.1;
q.verb.preDelay = 0;
q.verb.dur = 0.8;
q.verb.leak = 0.33;
q.verb.private = false;
q.verb.out = 6;
q.verb.dry = 0.4;
q.verb.pan = 1;
q.verb.quad = 1;

q.verb.offset = 22; // eucon slider

(
SynthDef( "ws_shesme_verb%".format( q.verb.n ), { |in = 0, amp = 0.33, preDelay = 0, out = 0, 
		fftsize = 2048, private = 0, gate = 1, dry = 0, dryhicut = 400, pan = 1, quad = 1,
		hishelf = -6, hishelfFreq = 3000, lowshelf = 0, lowshelfFreq = 600, leak = 0.05|
	var bufs = \bufs.ir( 0!q.verb.n );
	var input, sig, env, ni = 6;
	env = Env([0,1,1,0,0], [0.1,0,0.1, BufDur.ir( bufs[0] ) + preDelay ], \lin, 2 ).kr(2, gate );
	input = In.ar( 0 + (FirstPrivateBus.ir * private), ni );
	//CheckBadValues.ar( input );
	//input = input + WhiteNoise.ar(1.0e-9);
	input = RemoveBadValues.ar(input);
	input = if( quad,
		input.collect({ |sig, i|
			var xx;
			xx = PanAz.ar( q.verb.n, sig, ~shesme.verb.panValuesQuad[i] / 4 * 2, orientation: 0 );
			~shesme.verb.delays[i].collect({ |delay, ix|
				DelayN.ar( xx[ix], delay, delay );
			});
		}).sum,
		[ DC.ar(0) ] ++ input.collect({ |input, i|
			var xx;
			xx = Pan2.ar( input, ~shesme.verb.panValuesStereo[i]);
			~shesme.verb.delays[i][[0,3]].collect({ |delay, ix|
				DelayN.ar( xx[ix], delay, delay );
			});
		}).sum ++ [ DC.ar(0) ]
	);
	dry = dry * input * 4;
	//dry = BHiCut.ar( dry, dryhicut, 1 );
	dry = BHiShelf.ar( dry, dryhicut, 1, -16 );
	dry = DelayN.ar(dry, 0.25, preDelay );
	input = input + (input.sum * leak ) * env * amp ;
	input = BHiShelf.ar( input, hishelfFreq, 1, hishelf );
	input = BLowShelf.ar( input, lowshelfFreq, 1, lowshelf );
	input = DelayN.ar(input, 0.25, preDelay );
	sig = bufs.collect({ |sp, i| 
		PartConv.ar(input[i], fftsize, sp, 0.5); 
	});
	Out.ar( out, ((sig * 1) + (dry * env)) * 0.5 );
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
	evt.sn = Synth( "ws_shesme_verb%".format( evt.n ), [
		 		\amp, evt.amp, 
 		 		\preDelay, evt.preDelay,
 		 		\bufs, evt.irspectrum,
 		 		\fftsize, evt.fftsize,
 		 		\leak, evt.leak,
 		 		\private, evt.private.binaryValue,
 		 		\quad, evt.quad ? 1,
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
q.verb.w = Window( "verb", Rect(146, 365, 113, 124)).front;
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
	.put( \quad, {
		if( q.verb.w.notNil && { q.verb.w.isClosed.not } ) {
			q.verb.views[ \quad ].value = q.verb.	quad;
			q.verb.sn.set( \quad, q.verb.quad );
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
	
q.verb.views[ \quad ] = SmoothSlider(  q.verb.w, 94@16,  ).value_( q.verb.quad ? 1 )
	.string_( " quad " )
	.action_({ |sl| 
		q.verb.quad = sl.value;
		q.verb.sn.set( \quad, q.verb.quad ); 
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