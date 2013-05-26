(
~shesme = ~shesme ? EM();

~shesme.coupler = ~shesme.coupler ? EM();

~shesme.coupler.current = EM();

~shesme.coupler.settings = EM();

~shesme.coupler.specs = OEM( \current, CodeSpec(nil) );

~shesme.coupler.performCurrent = { |evt, sensor = 'x1', val = 0|
	evt.current[ sensor ].do({ |array|
		var which, key, func, spec;
		var action, getValue;
		#which, key, func, spec = array;
		
		if( func.isKindOf( Spec ) or: { func.isKindOf( Collection ) } ) {
			spec = func; func = nil;
		};
		
		if( func.isFunction.not ) {
			case { spec.isNil } {
				getValue = { |val| val };
			} { spec.isKindOf( Collection ) } {
				getValue = { |val| 
					val.linlin( spec[0] ? 0, spec[1] ? 1, spec[2] ? 0, spec[3] ? 1, \minmax ) 
				};
			} { spec.isKindOf( Spec ) } {
				getValue = { |val| spec.unmap( val ); };
			} { spec.isFunction } {
				getValue = { |val| spec.value( val ); };
			};
			if( func.isKindOf( ActionFunc ) ) {
				func.action = { |val| if( val.notNil ) { 
					~shesme[ which ].mapSet( key, val ); 
					} 
				};
				func.value( getValue.( val ) );
			} {
				 ~shesme[ which ].mapSet( key, getValue.( val ) );
			};
		} {
			func.value( ~shesme[ which ], key, val );
		};
	});
};

~shesme.coupler[ \updateFunc ] = ~shesme.coupler[ \updateFunc ]  ?? { { |obj, key, val|
	{ ~shesme.coupler.performCurrent( key, val ); }.try;
} };

~shesme.coupler.start = { |evt|
	~shesme.dataNetwork.vals.addDependant( evt[ \updateFunc ] );
	evt.active = true;
};

~shesme.coupler.end = { |evt|
	~shesme.dataNetwork.vals.removeDependant( evt[ \updateFunc ] );
	evt.active = false;
};

/*
~shesme.dataNetwork.vals.removeDependant( ~shesme.coupler[ \updateFunc ] );
~shesme.coupler[ \updateFunc ] = nil;
*/

~shesme.coupler.couple = { |evt, sensor = 'x1', which = 'tttt', key = 'speed', func, spec, uncouple = true|
	if( uncouple ) { evt.uncouple( which, key, sensor ); };
	evt.current[ sensor ] = evt.current[ sensor ].add( [ which, key, func, spec ] );
	evt.changed( \current, evt.current );
};

~shesme.coupler.uncouple = { |evt, which, key, sensor|
	sensor = (sensor ?? { evt.current.keys; }).asArray;
	which = (which ? ~shesme.names).asArray;
	which.do({ |which|
		(key ?? { (~shesme[ which ].specs ?? {()}).keys }).asArray.do({ |key|
			sensor.do({ |sensor|
				var removeThese;
				removeThese = evt.current[ sensor ] !? _.select({ |item| 
					(item[0] == which) && (item[1] == key)
				});
				removeThese.do({ |item| evt.current[ sensor ].remove( item ) });
				if( evt.current[ sensor ].size == 0 ) { evt.current[ sensor ] = nil };
			});
		});
	});
	evt.changed( \current, evt.current );
};
);

/*
~shesme.coupler.couple( 'press1', 'mumbling', 'filter', [0.1, 1] );
~shesme.coupler.couple( 'press1', 'tttt', 'speed', [0.65, 0.75] );
~shesme.coupler.couple( 'y1', 'tttt', 'speed', [0.4, 0.8] );
~shesme.coupler.couple( 'd2', 'chords', 'amp', [0, 0.5, 0.25, 0] );

~shesme.coupler.couple( 'd1', 'mumbling', 'speed', [0.025, 0.1, 0, 0.03] );

~shesme.coupler.couple( 'd1', 'chords', 'amp', { |which, key, val| 
	//which.mapSet( key, (val - 0.5).abs.linlin(0,0.05,0.25,0) );
	[which, key, val].postln;
});

~shesme.coupler.couple( 'y1', 'wapentuig', 'pos', [0.1, 0.8, 1, 0] );


~shesme.coupler.uncouple();
~shesme.coupler.uncouple( 'wapentuig' );
~shesme.coupler.uncouple( 'chords' );

~shesme.coupler.current = EM();
~shesme.coupler.current.cs;

~shesme.coupler.settings[ \a ] = ~shesme.coupler.current.deepCopy;
*/
