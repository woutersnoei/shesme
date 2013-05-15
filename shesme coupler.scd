(
~shesme = ~shesme ? EM();

~shesme.coupler = ~shesme.coupler ? EM();

~shesme.coupler.current = EM();

~shesme.coupler.settings = EM();

~shesme.coupler.performCurrent = { |evt, sensor = 'x1', val = 0|
	evt.current[ sensor ].do({ |array|
		var which, key, func;
		#which, key, func = array;
		case { func.isNil } {
			 ~shesme[ which ].mapSet( key, val );
		} { func.isKindOf( Spec ) } {
			~shesme[ which ].mapSet( key, func.unmap( val ) );
		} { func.isKindOf( Collection ) } {
			~shesme[ which ].mapSet( key, 
				val.linlin( func[0] ? 0, func[1] ? 1, func[2] ? 0, func[3] ? 1, \minmax ) 
			);
		} {
			func.value( ~shesme[ which ], key, val );
		};
	});
};

~shesme.coupler[ \updateFunc ] = ~shesme.coupler[ \updateFunc ]  ?? { { |obj, key, val|
	~shesme.coupler.performCurrent( key, val );
} };

~shesme.coupler.start = { |evt|
	~shesme.dataNetwork.vals.addDependant( evt[ \updateFunc ] );
};

~shesme.coupler.end = { |evt|
	~shesme.dataNetwork.vals.removeDependant( evt[ \updateFunc ] );
};

/*
~shesme.dataNetwork.vals.removeDependant( ~shesme.coupler[ \updateFunc ] );
~shesme.coupler[ \updateFunc ] = nil;
*/

~shesme.coupler.couple = { |evt, sensor = 'x1', which = 'tttt', key = 'speed', func, uncouple = true|
	if( uncouple ) { evt.uncouple( sensor, which, key ); };
	evt.current[ sensor ] = evt.current[ sensor ].add( [ which, key, func ] );
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
};
);

/*
~shesme.coupler.couple( 'x1', 'tttt', 'speed', [0.5, 0.75] );
~shesme.coupler.couple( 'y1', 'tttt', 'transpose', [0.3, 0.8] );
~shesme.coupler.couple( 'd1', 'chords', 'amp', [0.5, 0.6, 0.25, 1] );
~shesme.coupler.couple( 'y1', 'wapentuig', 'pos', [0.1, 0.8, 1, 0] );

~shesme.coupler.uncouple( 'tttt' );
~shesme.coupler.uncouple( 'wapentuig' );
~shesme.coupler.uncouple( 'chords' );

~shesme.coupler.current.cs;

~shesme.coupler.settings[ \a ] = ~shesme.coupler.current.deepCopy;
*/
