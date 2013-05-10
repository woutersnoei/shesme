~shesme.parentEvent = EM();

~shesme.parentEvent.mapSet = { |evt, what, value| 
	evt.perform( what.asSymbol.asSetter, evt.specs[ what.asSymbol.asGetter ].asSpec.map(value) );
};

~shesme.parentEvent.mapGet = { |evt, what, value| 
	evt.specs[ what.asSymbol.asGetter ].asSpec.unmap( evt.perform( what.asSymbol.asGetter ) );
};

~shesme.makeWindow = { |ev, which = 'tttt', parent|
	var specs, evt, ctrl;
	evt = ev[ which ];
	specs = evt !? _.specs;
	if( specs.notNil ) {
		evt.parent = ev.parentEvent;
		evt.composite = EZCompositeView( parent, 308@((specs.size + 1)* 20) );
		evt.composite.addFlowLayout;
		ctrl = SimpleController( evt );
		evt.composite.onClose = { ctrl.remove };
		evt.views = ();
		evt.views[ \label ] = StaticText( evt.composite, 300 @ 16 )
			.string_( " " ++ which )
			.font_( Font( "Helvetica-Bold", 9 ) )
			.background_( Color.gray(0.9) );
		evt.specs.keysValuesDo({ |key, spec|
			var view;
			view = EZSmoothSlider( evt.composite, 300 @ 16, key.asString, spec, { |sl|
				evt.perform( key.asSetter, sl.value );
			},  evt.perform( key.asGetter ) )
				.font_( Font( "Arial", 9 ) );
			evt.views[ key ] = view;
			ctrl.put( key, { view.value = evt.perform( key.asGetter ) });
		});
	} {
		"can't make GUI; no specs found".postln;
	};
};

