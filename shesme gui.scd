~shesme = ~shesme ? EM();

~shesme.parentEvent = EM();

~shesme.parentEvent.mapSet = { |evt, what, value| 
	evt.perform( what.asSymbol.asSetter, evt.specs[ what.asSymbol.asGetter ].asSpec.map(value) );
};

~shesme.parentEvent.mapGet = { |evt, what, value| 
	evt.specs[ what.asSymbol.asGetter ].asSpec.unmap( evt.perform( what.asSymbol.asGetter ) );
};

~shesme.makeWindowFor = { |ev, which = 'tttt', parent, width = 250|
	var specs, evt, ctrl;
	var path;
	evt = ev[ which ];
	specs = evt !? _.specs;
	evt.parent = ev.parentEvent;
	evt.composite = EZCompositeView( parent, (width+8)@((specs.size + 1)* 19) );
	evt.composite.view.background = Gradient( Color.gray(0.8), Color.gray(0.9), \v ) ;
	ctrl = SimpleController( evt );
	evt.composite.onClose = { ctrl.remove };
	evt.views = ();
	evt.views[ \power ] = SmoothButton( evt.composite, 15 @ 15 )
			.border_(1)
			.radius_(2)
			.background_( Gradient( Color.gray(1), Color.gray(0.8), \v ) )
			.label_(['power','power'])
			.hiliteColor_( Color.green )
			.action_({ |bt|
				switch( bt.value.asInt,
					1, { evt.start },
					0, { evt.end }
				);
			})
			.resize_(2);
	evt.views[ \label ] = StaticText( evt.composite, (width - 150) @ 15 )
		.string_( which.asString )
		.font_( Font( "Helvetica-Bold", 10 ) );
	if( evt.keys.asArray.includes( \getPreset ) ) {
		evt.views[ \fillPresets ] = {
			evt.views[ \presets ].items = [ "presets", "" ] ++ evt.presetNames ++ 
				[ "", "save", "revert", "add..", "remove.." ];
		};
		evt.views[ \presets ] = PopUpMenu( evt.composite, 116 @ 15 )
			.action_({ |pu|
				case { pu.item.isKindOf( Symbol ) } {
					evt.applyPreset( pu.item );
				} { pu.item == "save" } {
					~shesme.presetSystem.save;
				} { pu.item == "revert" } {
					~shesme.presetSystem.read;
					~shesme.names.do({ |key|
						key = ~shesme[ key ];
						if( key.views !? { |x| x.keys.includes( \fillPresets ) } ? false) {
							key.views.fillPresets;
						};
					});
				} { pu.item == "add.." } {
					SCRequestString( "default", "Please enter preset name:", { |string|
						evt.getPreset( string.asSymbol );
						evt.views.fillPresets;	
					});
				} { pu.item == "remove.." } {
					SCRequestString( evt.presetNames.cs, "Please edit preset names:", { 
						|string|
						evt.presetNames_( string.interpret );
						evt.views.fillPresets;
					});
				};
				pu.value = 0;
			}).font_( Font( "Helvetica", 10 ) );
		evt.views.fillPresets;
	} {
		evt.composite.decorator.shift(120,0);
	};
	evt.views[ \file ] = SmoothButton( evt.composite, 15 @ 15 )
		.border_(1)
		.background_( Gradient( Color.gray(1), Color.gray(0.8), \v ) )
		.radius_(2)
		.label_( 'document' )
		.action_({ Document.open( ev.path +/+ "shesme" + which ++ ".scd" ) })
		.resize_(2);
	ctrl.put( \active, {
		evt.views[ \power ].value = (evt.active == true).binaryValue;
	});
	evt.changed( \active );
	if( specs.notNil ) {
		RoundView.pushSkin( ( font:  Font( "Arial", 9 ) ) );
		evt.specs.keysValuesDo({ |key, spec|
			var view;
			view = spec.makeView(  evt.composite, width @ 15, key.asString, { |sl, val|
				evt.perform( key.asSetter, val );
			});
			ctrl.put( key, { spec.setView( view, evt.perform( key.asGetter ) ) });
			evt.changed( key );
			evt.views[ key ] = view;
		});
		RoundView.popSkin;
	};
	evt.composite;
};

~shesme.makeWindow = { |evt, which, width = 230, columns = 2|
	which = which ? evt.names;
	evt.window = Window( "shesme controls", Rect(550, 250,(width+14) * columns, 750) ).front;
	evt.window.addFlowLayout;
	evt.composite = EZCompositeView( evt.window, (width+8) @ evt.window.bounds.height );
	evt.composite.addFlowLayout;
	which.do({ |item|
		var comp;
		comp = evt.makeWindowFor( item, evt.composite, width );
		evt.composite.decorator.nextLine;
		if( evt.composite.decorator.top >= (evt.composite.bounds.height - 5) ) {
			comp.view.remove;
			evt.composite = EZCompositeView( evt.window, width+8 @ evt.window.bounds.height );
			evt.composite.addFlowLayout;
			comp = evt.makeWindowFor( item, evt.composite, width );
		};
	});
};

/*
~shesme.makeWindow(  );
*/